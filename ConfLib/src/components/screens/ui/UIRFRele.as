package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import components.abstract.functions.loc;
	import components.basement.UIRadioDeviceRoot;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptRFRele;
	import components.screens.opt.OptRele_awset;
	import components.screens.opt.OptRele_pattern;
	import components.static.CMD;
	import components.static.PAGE;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;

	public class UIRFRele extends UIRadioDeviceRoot
	{
		private var timer_rele:Timer;
		//private var sub:int=-1;
		private var opt_awset:OptRele_awset;
		private var opt_pattern:OptRele_pattern;
		private var relay:int;
		public static const SWITCH_NONE:int = 0x00;
		public static const SWITCH_RFRELAY_INDPART:int = 0x01;
		public static const SWITCH_RFRELAY_ALARM:int = 0x02;
		public static const SWITCH_RFRELAY_INDMES:int = 0x03;
		
		private const localY:int = 10;
		
		private var CommandsInitialized:int = 0; // 0 - not initialized, 1 - in progress, 2 - initialized
		
		public function UIRFRele()
		{
			label = loc("ui_rfrelay");
			labelParentPadejM = loc("ui_rfrelay_padejm")
			labelParentPadejS = loc("ui_rfrelay_padejs")
			labelParentPadejR = loc("ui_rfrelay_padejr");
			LOCALE_NOT_FOUND = loc("ui_rfrelay_found");
			label_construct = loc("ui_rfrelay")+" ";
			cmd = CMD.RFRELAY_INIT;
			deviceType = RF_FUNCT.TYPE_RADIORELE;
			DEVICE_MAX = 16;
			treeContent = [loc("rfd_wire"),loc("rfd_output")+"1",loc("rfd_output")+"2",
				loc("rfd_output")+"3",loc("rfd_output")+"4",loc("rfd_output")+"5",loc("rfd_output")+"6"];
			
			fwidth = 619;;
			fheight = 249;
			
			super();
			
			ISRELE = true;
			navi.setXOffset(PAGE.CONTENT_LEFT_SUBMENU_SHIFT);
			
			opt = new OptRFRele;
			addChild( opt );
			opt.visible = false;
			
			opt.y = localY;
			
			timer_rele = new Timer( CLIENT.TIMER_EVENT_SPAM);
			
			starterCMD = CMD.RFRELAY_INIT;
		}
		override public function open():void
		{
			super.open();
			if(opt_awset)
				opt_awset.visible = false;
			if(opt_pattern)
				opt_pattern.visible = false;
			timer_rele.addEventListener( TimerEvent.TIMER, time_funct );
			timer_rele.reset();
			timer_rele.start();
		}
		override public function close():void
		{
			super.close();
			timer_rele.removeEventListener( TimerEvent.TIMER, time_funct );
			timer_rele.stop();
		}
		override protected function openDevice( value:Object ):void
		{
			forgotten.visible = false;
			SavePerformer.save();
			navi.disable(true);
			var selection:Object;
			if(value is int) {
				selection = {num:value,sub:0};
			} else
				selection = value;
				
			currentActionDeviceId = int(selection.num);
			switch(selection.sub) {
				case 0:
					RequestAssembler.getInstance().fireEvent( new Request( cmd, openDeviceSuccess, int(selection.num)+1));
					break;
				case 1:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_AWSET, openDeviceSuccess, int(selection.num)+1) );
					break;
				default:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_INDPART, openDeviceSuccess ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_INDMES, openDeviceSuccess ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_ALARM1, openDeviceSuccess ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_ALARM2, openDeviceSuccess ));
					relay = selection.sub-1;
					break;
			}
		//	trace("num "+value.num +" sub " +value.sub);
		}
		override protected function openDeviceSuccess(p:Package):void
		{
			if(opt_awset)
				opt_awset.visible = false;
			if(opt_pattern)
				opt_pattern.visible = false;
			opt.visible = false;
			navi.disable(false);
			BLOCK_BUTTONS = false;
			switch( p.cmd ) {
				case CMD.RFRELAY_INIT:
					super.openDeviceSuccess(p);
					label_second_current = loc("ui_rfrelay_wire_state")+" "+(currentActionDeviceId+1)+", "+loc("g_setting").toLowerCase();
					break;
				case CMD.RFRELAY_AWSET:
					if(!opt_awset) {
						opt_awset = new OptRele_awset;
						addChild( opt_awset );
						opt_awset.y = localY;
					}
					opt_awset.putData( Package.create( [p.getStructure()], currentActionDeviceId+1 ));
					opt_awset.visible = true;
					label_second_current = loc("ui_rfrelay_config_wire")+" "+(currentActionDeviceId+1);
					break;
				case CMD.RFRELAY_INDPART:
					if(!opt_pattern) {
						opt_pattern = new OptRele_pattern;
						opt_pattern.visible = false;
						addChild( opt_pattern );
						opt_pattern.y = localY;
					}
				case CMD.RFRELAY_INDMES:
				case CMD.RFRELAY_ALARM1:
				case CMD.RFRELAY_ALARM2:
					//Controller.getInstance().dataModel.installModel( re[0], re.slice(1));
					if ( p.cmd == CMD.RFRELAY_ALARM2 ) {
						
						var pattern:Array = OPERATOR.dataModel.getData( CMD.RFRELAY_INDPART );
						var i:int;
						var pack:Array = [currentActionDeviceId,relay,0];
						var ends:Array = new Array;
						
						trace("Выбран "+(currentActionDeviceId+1) + " выход "+relay);
						
						for( i=0; i<16; ++i) {
							if( pattern[i][0] == 0 && pattern[i][1] == 0 ) {
								if( ends[SWITCH_RFRELAY_INDPART] == undefined )
									ends[SWITCH_RFRELAY_INDPART] = i+1;
						//		trace( "EVENT_RFRELAY_INDPART шаблон "+(i+1)+" пустой");
							} else {
								if( pattern[i][0] == (currentActionDeviceId+1) && pattern[i][1] == relay ) {
									trace( "EVENT_RFRELAY_INDPART Bingo" );
									pack[2] = SWITCH_RFRELAY_INDPART;
									ends[SWITCH_RFRELAY_INDPART] = i+1;
								}
								trace( "EVENT_RFRELAY_INDPART шаблон "+(i+1)+" занят РЕЛЕ "+pattern[i][0]+" ВЫХОД "+pattern[i][1] );
							}
						}
						
						pattern = OPERATOR.dataModel.getData( CMD.RFRELAY_INDMES );
						for( i=0; i<16; ++i) {
							if( pattern[i][0] == 0 && pattern[i][1] == 0 ) {
								if( ends[SWITCH_RFRELAY_INDMES] == undefined )
									ends[SWITCH_RFRELAY_INDMES] = i+1;
						//		trace( "EVENT_RFRELAY_INDMES шаблон "+(i+1)+" пустой");
							} else {
								if( pattern[i][0] == (currentActionDeviceId+1) && pattern[i][1] == relay ) {
									trace( "EVENT_RFRELAY_INDMES Bingo" );
									pack[2] = SWITCH_RFRELAY_INDMES;
									ends[SWITCH_RFRELAY_INDMES] = i+1;
								}
								trace( "EVENT_RFRELAY_INDMES шаблон "+(i+1)+" занят РЕЛЕ "+pattern[i][0]+" ВЫХОД "+pattern[i][1] );
							}
						}
						
						pattern = OPERATOR.dataModel.getData( CMD.RFRELAY_ALARM1 );
						for( i=0; i<16; ++i) {
							if( pattern[i][0] == 0 && pattern[i][1] == 0 ) {
								if( ends[SWITCH_RFRELAY_ALARM] == undefined )
									ends[SWITCH_RFRELAY_ALARM] = i+1;
						//		trace( "EVENT_RFRELAY_ALARM1 шаблон "+(i+1)+" пустой");
							} else
								if( pattern[i][0] == (currentActionDeviceId+1) && pattern[i][1] == relay ) {
									trace( "EVENT_RFRELAY_INDMES Bingo" );
									pack[2] = SWITCH_RFRELAY_ALARM;
									ends[SWITCH_RFRELAY_ALARM] = i+1;
								}
								trace( "EVENT_RFRELAY_ALARM1 шаблон "+(i+1)+" занят РЕЛЕ "+pattern[i][0]+" ВЫХОД "+pattern[i][1] );
						}
						
						for(i=0; i<4; ++i ) {
							if(ends[i] == undefined )
								ends[i] = 17;
						}
						
						pack.push( ends );
						trace( ends.toString() );
						opt_pattern.putRawData( pack );
						opt_pattern.visible = true;
						
						label_second_current = loc("ui_rfrelay_config_output")+" "+(relay)+" "+loc("rfd_rfrelay").toLowerCase()+" "+(currentActionDeviceId+1);
					}
					break;
			}
			buttonsEnabler();
			changeSecondLabel( label_second_current + label_jumper);
		}
		override protected function getSecondLabel():String
		{
			return loc("ui_rfrelay_wire_state")+" "+deletedDevice.structure+", "+loc("g_setting").toLowerCase();
		}
		private function time_funct(ev:TimerEvent):void
		{
			/**	Команда RFRELAY_FUNCT - команда выходу включить/выключить и запросить состояние;
			 Параметр 1 - Номер радиореле (1-16);
			 Параметр 2 - Запросить состояние всех радиореле ( 0- нет, 1-запросить)
			 Параметр 3 - Включить выходы радиореле бит0 - резерв, бит 1 - выход 1, бит 2 - выход 2,..., бит 6 - выход 6;
			 Параметр 4 - Выключить выходы радиореле бит0 - резерв,  бит 1 - выход 1, бит 2 - выход 2,..., бит 6 - выход 6;
			 Параметр 5 - Изменить состояние выхода радиореле бит0 - резерв,  бит 1 - выход 1, бит 2 - выход 2,..., бит 6 - выход 6;	*/
			
			if(opt.visible) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_FUNCT, null, 1,[opt.getStructure(),1,0,0,0] ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_STATE, catchState, opt.getStructure() ));
			}
		}
		
		private function catchState(p:Package):void
		{
			if(opt.visible)
				(opt as OptRFRele).putState(p.getStructure());
		}
	}
}