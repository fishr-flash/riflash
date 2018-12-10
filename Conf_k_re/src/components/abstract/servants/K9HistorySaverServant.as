package components.abstract.servants
{
	import components.abstract.DEVICESB;
	import components.abstract.functions.loc;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.IAbstractAdapter;
	import components.interfaces.IKontaktHistorySaverServant;
	import components.interfaces.ILoadAni;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;

	public class K9HistorySaverServant implements IKontaktHistorySaverServant
	{
		public var book:Array;
		
		private var _READING:Boolean = false;
		
		private var history:Array;
		private var buttons:Vector.<TextButton>;
		private var linkTarget:ILoadAni;
		private var cell:int;
		private var fBitField:Function;
		private var fCIDcrc:Function;
		
		private var totalRequested:int;
		private var totalGot:int;
		private const portion:int = 10;
		
		private var start_line:int;
		private var totalHardMaxStructures:int;
		private var readStartPoint:int;		// реальная структура с которой начинается сохранение истории
		private var maxWrittenStructures:int;
		
		public var historyAdapter:IAbstractAdapter;
		public var working_cmd:int = CMD.HISTORY_REC;
		
		public function K9HistorySaverServant(a:Array,cellnum:int,fbitfield:Function, fcidcrc:Function)
		{
			buttons = new Vector.<TextButton>;
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				buttons.push( a[i] );
			}
			cell = cellnum;
			fBitField = fbitfield;
			fCIDcrc = fcidcrc;
		}
		public function start(value:int, page:int, _maxWrittenStructures:int, hardMaxStructures:int, lastStructure:int):void
		{
			if (value > 0) {
				READING = true;
				
				totalHardMaxStructures = hardMaxStructures;
				maxWrittenStructures = _maxWrittenStructures;
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
					{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:"", getLink:link} )
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
				
				start_line = (page-1)*CLIENT.HISTORY_LINES_PER_PAGE;
				readStartPoint = lastStructure - start_line;
				
				if (value > maxWrittenStructures - start_line)
					value = maxWrittenStructures - start_line;// + start_line;
				
				var s:int;
				totalRequested = 0;
				totalGot = 0;
				CLIENT.NO_CLONE_HUNT = true;
				for( var i:int=0; i<value; ++i) {
			//		if ( lastStructure - i < 1 )
					if( lastStructure - (i + start_line) < 1 )
						s = lastStructure + hardMaxStructures - (i + start_line);
					else
						s = lastStructure - (i + start_line);
					
					RequestAssembler.getInstance().fireEvent( new Request( working_cmd, assembler, s ));
					totalRequested++;
				}
				history = new Array(totalRequested);
			}
		}
		private function assembler(p:Package):void
		{
			history[totalGot] = p.data[0];
		//	(history[totalGot] as Array)[cell] = p.structure;
			totalGot++;
			linkTarget.goto( int((totalGot/totalRequested)*100) );
			if ( totalGot == totalRequested ) {
				var len:int = history.length;
				for (var i:int=0; i<len; ++i) {
					if (i+1 > totalRequested) {
						history.splice(i,len);
						break;
					}
					
					(history[i] as Array)[cell] = (maxWrittenStructures-start_line) - i;//totalHardMaxStructures - (start_line+i);//readStartPoint--;//totalHardMaxStructures - (start_line+i);
					if (historyAdapter)	// если есть адаптер, используем его
						history[i] = historyAdapter.adapt(history[i]);
					else
						history[i] = adapt(history[i]);
				}
				READING = false;
				
				len = buttons.length;
				for (i=0; i<len; ++i) {
					buttons[i].disabled = false;
				}
			}
		}
		public function getFieldData():Array
		{
			return history;
		}
		public function halt():void
		{
			READING = false;
			if (linkTarget) {
				linkTarget.halt();
				removeCurtain();
			}
		}
		public function set READING(value:Boolean):void
		{
			_READING = value;
			if (value)
				TabOperator.getInst().block = true;
		}
		public function get READING():Boolean
		{
			return _READING;
		}
		private function link(i:ILoadAni):void
		{
			if (!linkTarget) {
				linkTarget = i;
				linkTarget.goto(0);
			} else {
				removeCurtain();
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
				//pageReturn(startPage);
			}
		}
		private function removeCurtain():void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
			linkTarget = null;
			TabOperator.getInst().block = false;
			CLIENT.NO_CLONE_HUNT = false;
			RequestAssembler.getInstance().activeHandler();
		}
		private function adapt(a:Array):Array
		{
			var adapted:Array = [];
			adapted.push( a[cell] );
			adapted.push( UTIL.formateZerosInFront(a[1].toString(16),2)+"."+ UTIL.formateZerosInFront(a[2].toString(16),2)+ ".20" +UTIL.formateZerosInFront(a[3].toString(16),2)
				+ " " + UTIL.formateZerosInFront(a[4].toString(16),2) + ":"+UTIL.formateZerosInFront(a[5].toString(16),2) + ":"+UTIL.formateZerosInFront(a[6].toString(16),2));
			adapted.push( UTIL.formateZerosInFront(a[7].toString(16),4));
			
			var num:int = int( a[9] );
			var result:int = (num & 0x0FFF) << 4 | (num & 0xF000) >> 12;
			
			var label:String="";
			var param:String="";
			var cidEvent:Array = CIDServant.getEvent();
			for( param in cidEvent) {
				if( int( "0x"+cidEvent[param].data ) == result )
					label = cidEvent[param].label;
			}
			/**	Параметр 9 - 0x18h;*/
			/**	Параметр 10 - старшая тетрада -тревога/восстановление, остальное -Код тревоги (BCD);*/
			
			// Номер CID 1301
			adapted.push( label.slice(0,6) );
			
			// Т\В
			var s:String = "";
			var n:int = int((a[9].toString(16) as String).slice(0,1));
			if (n == 1)
				s = loc("his_alarm")
			else if (n == 3)
				s = loc("his_revert");
			adapted.push(s);
			
			//getField(operatingCMD,5).setCellInfo( UTIL.formateLength(label.slice(6),23));
			adapted.push( label.slice(6) );
			
			/**	Параметр 11 - Номер раздела 1-99 (BCD);*/
			// Раздел
			adapted.push( a[10] );
			
			// ГБР
			var zonecrc:String = (a[11]).toString(16);
			var devicecrc:String = zonecrc.slice(zonecrc.length-1);
			var zone:String = zonecrc.slice(0, zonecrc.length-1 );
			if (zone.length == 0)
				zone = "0";
			adapted.push( zone );
			
			// Посылка
			s = UTIL.fz((a[7]).toString(16),4) +
				(a[8]).toString(16)+ 
				(a[9]).toString(16) + 
				UTIL.fz((a[10]).toString(16),2) + 
				UTIL.fz(zone,3) + 
				devicecrc;
			adapted.push( s.toUpperCase() );
			
			// КС
			adapted.push( fCIDcrc(a) );

			// Передано
			adapted.push( a[12] == 0x33 ? loc("g_yes"):loc("g_no") );
				
			// Направления
			adapted.push( fBitField(a) );

			return adapted;
		}
		private function passBottomRelease(num:int):Boolean
		{	// проверка нижней платы
			if (SERVER.DUAL_DEVICE) {
				return DEVICESB.release >= num;
			}
			return DS.release >= num;
		}
	}
}