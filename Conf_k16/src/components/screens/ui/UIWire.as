package components.screens.ui
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import mx.events.ResizeEvent;
	
	import components.abstract.Utility;
	import components.abstract.functions.loc;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptWire;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIWire extends UI_BaseComponent
	{
		public static var MIN_LEVEL_ACP:int = 0;
		public static var MAX_LEVEL_ACP:int = 0;
		public static var MIN_LEVEL_OM:int = 0;
		public static var MAX_LEVEL_OM:int = 0;
		public static var MIN_PREFERRED_LEVEL_OM:int = 0;
		public static var LABEL_LEVEL_SIGN:String = "";	// <, ,> - постановка знака перед лейблом для WireUbitBig 
		
		public static var LAST_PARTITION:int = 0;
		
		public static const MAX_TIMELINE_OM:int = 14820;//10500;
		public static const MIN_TIMELINE_OM:int = 2100;
		public static const MIDDLE_DRY_TIMELINE_OM:int = 6200;
		private var NEED_FUNCT_UPDATE:Boolean = false;
		
		private var opt:OptWire;
		
		private var hash16toA:Object = { 1:0, 3:2, 5:4, 7:6, 9:8, 11:10, 13:12, 15:14 };
		private var hash8toA16:Object = { 1:0, 3:1, 5:2, 7:3, 9:4, 11:5, 13:6, 15:7 };
		private var hash16to8:Object = { 1:1, 3:2, 5:3, 7:4, 9:5, 11:6, 13:7, 15:8 };
		
		private var hash8toA:Object = { 1:0, 2:1, 3:2, 4:3, 5:4, 6:5, 7:6, 8:7 };
		private var hash16to8A:Object = { 1:0, 3:1, 5:2, 7:3, 9:4, 11:5, 13:6, 15:7 };
		
		private var page:int = 1;
		
		public function UIWire()
		{
			super();
			
			initNavi();
			navi.setUp( openWire, 40 );
			var counter:int=1;
			for(var i:int; i<16; ++i ) {
				navi.addButton( loc("rfd_wire")+" "+ counter, i+1, i*500 );
				
				counter++;
				i++;
				
				if ( counter > 8)
					break;
			}
			
			opt = new OptWire;
			addChild( opt );
			opt.x = globalX + 100;
			opt.y = globalY;
			opt.visible = false;
			SavePerformer.addCMDParam( CMD.ALARM_WIRE_LEVEL, SavePerformer.INVERT_SAVE, true );
			opt.addEventListener( ResizeEvent.RESIZE, optREsize );
			
			starterCMD = [CMD.ALARM_WIRE_SET,CMD.ALARM_WIRE_RES];
		}
		override public function close():void
		{
			if ( !this.visible ) return;
			super.close();
			
			navi.isReady = true;	// иначе при фастклике меню может залипнуть
			opt.visible = false;
			navi.selection = 0;
		}
		override public function put(p:Package):void
		{
			if (p.cmd == CMD.ALARM_WIRE_RES)
				navi.tree_selection = page;
		}
		private function processThreshold(p:Package):void
		{
			if( this.visible ) {	// защита от фастклика
				navi.isReady = true;
				
				if ( p.error )
					return;
				
				var currentACP:Array = OPERATOR.dataModel.getData(CMD.ALARM_WIRE_LEVEL)[ hash16to8A[opt.getId()] ];
				
				MAX_LEVEL_ACP = currentACP[0];
				MIN_LEVEL_ACP = currentACP[6];
				
				MAX_LEVEL_OM = Utility.mathACPtoOM(MIN_LEVEL_ACP);
				MIN_LEVEL_OM = Utility.mathACPtoOM(MAX_LEVEL_ACP);
				
				openThreshold(currentACP);
				initSpamTimer( CMD.ALARM_WIRE_STATE );
				loadComplete();
			}	
		}
		private function openWire( struct:int ):void
		{
			
			page = struct;
			navi.isReady = false;
			
			changeSecondLabel( loc("wire_config")+" "+ hash16to8[struct] );
			var sectionList:Array = PartitionServant.getPartitionList();
			var allSectionList:Array = UTIL.comboBoxNumericDataGenerator( 1,99 );
			opt.allSection = allSectionList;
			opt.section = sectionList;

			SavePerformer.closePage();
			SavePerformer.trigger( {"prepare":refine, "cmd":cmd} );
			opt.visible = true;
			opt.put( getDataByStructure( struct ), getDualStructure( struct), getRes(struct), struct );
			
			NEED_FUNCT_UPDATE = true;

			RequestAssembler.getInstance().fireEvent( new Request( CMD.ALARM_WIRE_LEVEL, processThreshold, hash16to8[struct] ));
		}
		private function optREsize(e:Event):void
		{
			this.width = opt.width;//670;
			this.height = opt.height;//820;
		}
		private function openThreshold(re:Array):void
		{
			opt.putThreshold(re.reverse());
		}
		private function getDataByStructure( struct:int ):Array
		{
			return OPERATOR.dataModel.getData( CMD.ALARM_WIRE_SET )[ hash16toA[struct] ];
		}
		private function getDualStructure( struct:int ):Array
		{
			return OPERATOR.dataModel.getData( CMD.ALARM_WIRE_SET )[ hash16toA[struct]+1 ];
		}
		private function getRes( struct:int ):Array
		{
			return OPERATOR.dataModel.getData( CMD.ALARM_WIRE_RES )[ hash8toA16[struct] ];
		}
		override protected function timerComplete(ev:TimerEvent):void
		{
			if ( opt.needUpdate ) {
				if (NEED_FUNCT_UPDATE) {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.ALARM_WIRE_FUNCT, null, 1, [ hash16to8[opt.getId()],1] ));
					NEED_FUNCT_UPDATE = false;
				}
				RequestAssembler.getInstance().fireEvent( new Request( CMD.ALARM_WIRE_STATE, processState ));
			}
			
			stateRequestTimer.reset();
			stateRequestTimer.start();
		}
		override protected function processState(p:Package):void
		{
			if ( !p.error && this.visible ) {
				
				/** Команда ALARM_WIRE_STATE
					Параметр 1 - Номер проводного шлейфа ( 1-8)
					Параметр 2 - Текущий порог шлейфа, значение АЦП
					Параметр 3 - Текущий порог шлейфа, 0-нет значения, 1 - к.з. , 2,3,4,5 - диапазоны по возрастанию сопротивления в шлейфе, 6 - обрыв */
				
				if ( hash16to8[opt.getId()] != p.getStructure()[0] ) {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.ALARM_WIRE_FUNCT, null, 1, [ hash16to8[opt.getId()],1] ));
					return;
				}
				
				var min:int = MIN_LEVEL_ACP;
				var max:int = MAX_LEVEL_ACP;
				
				LABEL_LEVEL_SIGN = "";
				var acpstate:int = p.getStructure()[1];
				if (acpstate < MIN_LEVEL_ACP ) {
					LABEL_LEVEL_SIGN = ">";
					acpstate = MIN_LEVEL_ACP;
				}
				if (acpstate > MAX_LEVEL_ACP) {
					LABEL_LEVEL_SIGN = "<";
					acpstate = MAX_LEVEL_ACP;
				}
				
				
				
				opt.putWireResistance( acpstate, p.getStructure()[2] );
				RequestAssembler.getInstance().fireEvent( new Request( CMD.ALARM_WIRE_FUNCT, null, 1, [hash16to8[opt.getId()],1] ));
			}
		}
		private function refine():void
		{
			var o:Object = SavePerformer.oNeedToSave;
			
			if( o[CMD.ALARM_WIRE_SET] ) {
				for(var key:String in o[CMD.ALARM_WIRE_SET] ) {
					//o[CMD.ALARM_WIRE_SET]
					if ( isEven(key) ) {
						if ( o[CMD.ALARM_WIRE_SET][int(key)-1][1] == TYPE_WIRE_FIRE_BATTERY || o[CMD.ALARM_WIRE_SET][int(key)-1][1] == TYPE_WIRE_FIRE_NOBATTERY ) {
							for(var redkey:String in o[CMD.ALARM_WIRE_SET][int(key)-1] ) {
								if (redkey != "8" )
									o[CMD.ALARM_WIRE_SET][key][redkey] = o[CMD.ALARM_WIRE_SET][int(key)-1][redkey];
							}
						}
					}
				}
			}
		}
		private function cmd(o:Object):int
		{
			if (o is int) {
				if (o == CMD.ALARM_WIRE_SET) {
					return SavePerformer.CMD_TRIGGER_TRUE;
				}
			} else {
				if (o["data"][CMD.ALARM_WIRE_SET]) {
					for (var key:String in o["data"][CMD.ALARM_WIRE_SET]) {
						if ( !UTIL.isEven(key) ) {
							LAST_PARTITION = o["data"][CMD.ALARM_WIRE_SET][key][6];
							break;
						}
					}
				}
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function isEven(n:Object):Boolean
		{
			return !Boolean( (int(n) & 0x01) > 0);
		}
/********************************************************************
 * 		STATIC VARS & METHODS
 * ******************************************************************/
	
		public static var TYPE_WIRE_NO:int = 0x00; // - Нет
		public static var TYPE_WIRE_FIRE_BATTERY:int = 0x01; //- Пожарный с питанием
		public static var TYPE_WIRE_GUARD_RESIST:int = 0x02; // - Охранный резистивный
		public static var TYPE_WIRE_FIRE_NOBATTERY:int = 0x03; //  - Пожарный без питания
		public static var TYPE_WIRE_GUARD_DRY:int = 0x04; // - Охранный сухой контакт

		public static var WIRE_NAMES:Array = [{label:loc("g_no"), data:0},
			{label:loc("wire_guard_dry"), data:4},
			{label:loc("wire_guard_res"), data:2},
			{label:loc("wire_fire_nopower"), data:3},
			{label:loc("wire_fire_power"), data:1}
		];
	}
}