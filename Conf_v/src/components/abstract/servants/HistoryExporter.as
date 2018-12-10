package components.abstract.servants
{
	import components.abstract.HistoryDataProvider;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.VoyagerHistoryServant;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.visual.ScreenBlock;
	import components.protocol.statics.CRC16;
	import components.system.UTIL;

	public class HistoryExporter
	{
		private var clone:Array = [1,3,255,141,154,3,0,0,0,0,0,0,0,0,0,112,1,1,23,0,0,0,0,0,0,0,0,0,0,0,0,0,0,21,0,16,2,220,60,38];
		
		public var READING:Boolean;
		public var history:Array;
		private var export:Function;		
		
		public function HistoryExporter(_export:Function)
		{
			export = _export;
		}
		public function start():void
		{
			UTIL.timerResultGet();
		/*	history = [];
			var len:int = 200000;
			for (var i:int=0; i<len; ++i) {
				history.push( decypher(clone) );
			}
			return;
			*/
			
			READING = true;
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:"", getLink:null} )
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
		}
		public function put(a:Array):void
		{
			history = [];
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if (a[i] != null)
					history.push( decypher(a[i]) );
			}
			READING = false;
			dtrace( UTIL.timerResultGet(true) );
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				null)
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
		}
		
		private var formated_crc_arr:Array;
		private function decypher(data:Array):Array
		{
			var assemblege:Array = new Array;
			var i:int;
			var len:int;
			
			formated_crc_arr = data.slice(0, data.length-2);
			var blockNum:int = data[0]-1;
			if (blockNum>3 || blockNum<0)
				blockNum = 0;
			
			var value:uint;
			var ob:Object = HistoryDataProvider.HIS_PERBLOCK_PARAMS[blockNum];
			var global_byte_shift:int=0;
			var bitgroup:Vector.<int>;
			var currentParam:Object;
			var naxtParam:Object;
			
			VoyagerHistoryServant.crcCalculation = calcCrc;  
			
			for( i=0; i<256; ++i ) {
				if (HistoryDataProvider.HIS_PERBLOCK_PARAMS[blockNum][i] > 0) {
					
					value = 0;
					var lastWasBitgroup:Boolean=false;
					//if (currentParam && HistoryDataProvider.PARAMS[i].bit == null ) {
					if (currentParam ) {
						lastWasBitgroup = true;
						global_byte_shift += getByteSize(i);
					}
					
					var bitnum:int = VoyagerHistoryServant.PARAMS[i].bit is int ? i - VoyagerHistoryServant.PARAMS[i].bit : 0xFF;
					assemblege[ getHeaderPlaceByBitNum(i) ] = VoyagerHistoryServant.format( data.slice(global_byte_shift,global_byte_shift+VoyagerHistoryServant.PARAMS[i].byte), 
						VoyagerHistoryServant.PARAMS[i].print, bitnum );
					// проверить нет ли функции привязанной к параметру, если есть - послать в нее весь уже собранный массив
					if (VoyagerHistoryServant.PARAMS[i].func is Function)
						VoyagerHistoryServant.PARAMS[i].func(assemblege);
					
					if (!lastWasBitgroup || (lastWasBitgroup && !VoyagerHistoryServant.PARAMS[i].bit)  )
						global_byte_shift += getByteSize(i);
					if(i==2)
						formated_crc_arr[2] = 0xff;
				} else
					continue;//assemblege.push("пусто");
			}
			
			len = assemblege.length;
			for(i=0; i<len; ++i ) {
				if( assemblege[i] == null )
					assemblege[i] = "";
			}
			
			return assemblege;
			
			function getByteSize(num:int):int
			{
				var p:Object = VoyagerHistoryServant.PARAMS[num];
				if (!p)
					return 0;
				
				var byte:int;
				if ( p.bit is int) {
					if (currentParam ) { 
						if( currentParam.bit == p.bit)
							return 0;	// если биты равны значит перебирается одна группа битов, не надо увеличивать байты
						else {
							byte = currentParam.byte;
							currentParam = p;
							return byte;	// если не равны, значит другая группа битов, надо увеличить байты
						}
					} else {
						currentParam = p;
						return 0;	// если currentParam=null значит началась новая битовая группа
					}
					
				} else if (currentParam) {	// если currentParam существует значит предыдущий параметр был битовый (сохраняются только битовые параметры)
					byte = currentParam.byte;
					currentParam = null;
					return byte;	// если p.bit не инт, значит перебирается уже другой параметр и надо увеличить количество байт
				}
				return p.byte;	// значит обычный (не битовый) параметр
			}
		}
		private function getHeaderPlaceByBitNum(bit:int):int
		{
			var num:int = 0;
			for( var i:int=0; i<256; ++i ) {
				if (HistoryDataProvider.HIS_COLLAPSED_PARAMS[i] > 0) {
					if ( i == bit )
						return num;
					num++;
				}
			}
			trace("OptHistoryLine: wrong bit " + bit);
			return 0;
		}
		private function calcCrc(crcFromDevice:int):String
		{
			var crc16:int = CRC16.calculate(formated_crc_arr, formated_crc_arr.length);
			if( crc16 == crcFromDevice )
				return loc("g_no");
			else
				return loc("g_yes");
		}
	}
}