package components.abstract.servants
{
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.primitive.ProgressSpy;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.ILoadAni;
	import components.protocol.statics.CRC16;
	import components.system.UTIL;

	public class HistorySaverVyagerServant
	{
		public var isReading:Boolean=false;
		public var book:Array;
		public var bookraw:Array;
		public var total_history_lines:int;
		
		private var HIS_COLLAPSED_PARAMS:Vector.<int>;
		private var HIS_PERBLOCK_PARAMS:Vector.<Vector.<int>>;
		private var currentParam:Object;
		private var formated_crc_arr:Array;
		private var fDisable:Function;
		private var spy:ProgressSpy;
		private var linkTarget:ILoadAni;
		private var linkTargetP:ILoadAni;
		private var cycler:PerformanceIndependantCycle;
		
		private var _DISABLED:Boolean = false;

		public function HistorySaverVyagerServant(f:Function)
		{
			fDisable = f;
			DISABLED = true;
		}
		public function isExportButtonDisabled():Boolean
		{
			return DISABLED;
		}
		public function register(collapsed:Vector.<int>, perBlock:Vector.<Vector.<int>>):void
		{
			HIS_COLLAPSED_PARAMS = collapsed;
			HIS_PERBLOCK_PARAMS = perBlock;
			DISABLED = true;
		}
		public function start():void
		{
			isReading = true;
			DISABLED = true;
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:"", getLink:link} );
			TabOperator.getInst().block = true;
				
		}
		public function put(a:Array):void
		{
			book = [];
			bookraw = [];
			cycler = new PerformanceIndependantCycle(perform,a,reportp);
			DISABLED = false;
		}
		public function halt():void
		{
			TabOperator.getInst().block = false;
			isReading = false;
		}
		public function getSpy():ProgressSpy
		{
			if (!spy)
				spy = new ProgressSpy(report);
			return spy;
		}
		private function set DISABLED(value:Boolean):void
		{
			fDisable(value);
			_DISABLED = value;
		}
		private function get DISABLED():Boolean
		{
			return _DISABLED
		}
		
		private function perform(a:Array, i:int):void
		{
			if (a[i] != null) {
				book.push( calc(a[i]) );
				bookraw.push( calcraw(a[i]) );
			}
		}
		private function report(param:Object):void
		{
			if (linkTarget)
				linkTarget.goto( int((param.current/param.total)*100) );
		}
		private function reportp(param:Object):void
		{
			if (linkTargetP)
				linkTargetP.goto( int((param.current/param.total)*100) );
		}
		private function link(i:ILoadAni):void
		{
			if (!linkTarget) {
				linkTarget = i;
				linkTarget.goto(0);
			} else {
				linkTarget.halt();
				linkTarget = null;
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
					{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:"", getLink:linkp} );
			}
		}
		private function linkp(i:ILoadAni):void
		{
			if (!linkTargetP) {
				linkTargetP = i;
				linkTargetP.goto( int((cycler.interator/cycler.total)*100) );
			} else {
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
				linkTargetP.halt();
				linkTargetP = null;
				cycler = null;
				halt();
			}
		}
		private function calc(data:Array):Array
		{
			var assemblege:Array = new Array;
			var i:int;
			if (data && data[0] == "header") {
				for( i=0; i<256; ++i ) {
					if (HIS_COLLAPSED_PARAMS[i] > 0)
						assemblege.push( loc(VoyagerHistoryServant.PARAMS[i].title) );
					else
						continue;
				}
				var len:int = assemblege.length;
			} else if(!data || data.length==0)
				return null;
			else {
				formated_crc_arr = data.slice(0, data.length-2);
				var blockNum:int = data[0]-1;
				if (blockNum>3 || blockNum<0) {
					dtrace( "ERROR History Export: Индекс SELECT_PAR="+blockNum+", возможно произошла ошибка парсинга");
					blockNum = 0;
				}
				
				var value:uint;
				var ob:Object = HIS_PERBLOCK_PARAMS[blockNum];
				var global_byte_shift:int=0;
				var bitgroup:Vector.<int>;
				var naxtParam:Object;
				
				currentParam = null;
				
				VoyagerHistoryServant.crcCalculation = calcCrc;  
				
				for( i=0; i<256; ++i ) {
					if (HIS_PERBLOCK_PARAMS[blockNum][i] > 0) {
						
						value = 0;
						var lastWasBitgroup:Boolean=false;
						//if (currentParam && PARAMS[i].bit == null ) {
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
			}
			len = assemblege.length;
			for(i=0; i<len; ++i ) {
				if( assemblege[i] == null )
					assemblege[i] = "";
			}
			//var ob:Object = assemblege.splice(3,1)[0];
			assemblege[0] = assemblege.splice(3,1)[0];
			return assemblege;
		}
		
		private function calcraw(data:Array):Array
		{
			var assemblege:Array = new Array;
			var i:int;
			if (data && data[0] == "header") {
				for( i=0; i<256; ++i ) {
					if (HIS_COLLAPSED_PARAMS[i] > 0)
						assemblege.push( loc(VoyagerHistoryServant.PARAMS[i].title) );
					else
						continue;
				}
				var len:int = assemblege.length;
			} else if(!data || data.length==0)
				return null;
			else {
				formated_crc_arr = data.slice(0, data.length-2);
				var blockNum:int = data[0]-1;
				if (blockNum>3 || blockNum<0) {
					dtrace( "ERROR History Export: Индекс SELECT_PAR="+blockNum+", возможно произошла ошибка парсинга");
					blockNum = 0;
				}
				
				var value:uint;
				var ob:Object = HIS_PERBLOCK_PARAMS[blockNum];
				var global_byte_shift:int=0;
				var bitgroup:Vector.<int>;
				var naxtParam:Object;
				
				currentParam = null;
				
				VoyagerHistoryServant.crcCalculation = calcCrc;  
				
				for( i=0; i<256; ++i ) {
					if (HIS_PERBLOCK_PARAMS[blockNum][i] > 0) {
						
						value = 0;
						var lastWasBitgroup:Boolean=false;
						//if (currentParam && PARAMS[i].bit == null ) {
						if (currentParam ) {
							lastWasBitgroup = true;
							global_byte_shift += getByteSize(i);
						}
						
						var bitnum:int = VoyagerHistoryServant.PARAMS[i].bit is int ? i - VoyagerHistoryServant.PARAMS[i].bit : 0xFF;
						/*assemblege[ getHeaderPlaceByBitNum(i) ] = VoyagerHistoryServant.format( data.slice(global_byte_shift,global_byte_shift+VoyagerHistoryServant.PARAMS[i].byte), 
							VoyagerHistoryServant.PARAMS[i].print, bitnum );*/
						var pdata:Array = data.slice(global_byte_shift,global_byte_shift+VoyagerHistoryServant.PARAMS[i].byte);
						if ( VoyagerHistoryServant.PARAMS[i].bit is int )
							assemblege[ getHeaderPlaceByBitNum(i) ] = (UTIL.toLitleEndian(pdata) & (1 << bitnum)) > 0 ? 1:0;
						else
							assemblege[ getHeaderPlaceByBitNum(i) ] = UTIL.toLitleEndian(pdata);
								
						if (!lastWasBitgroup || (lastWasBitgroup && !VoyagerHistoryServant.PARAMS[i].bit)  )
							global_byte_shift += getByteSize(i);
						if(i==2)
							formated_crc_arr[2] = 0xff;
					} else
						continue;
				}
			}
			len = assemblege.length;
			for(i=0; i<len; ++i ) {
				if( assemblege[i] == null )
					assemblege[i] = "";
			}
			//assemblege[0] = assemblege.splice(3,1)[0];
			return assemblege;
		}
		
		private function calcCrc(crcFromDevice:int):String
		{
			var crc16:int = CRC16.calculate(formated_crc_arr, formated_crc_arr.length);
			if( crc16 == crcFromDevice )
				return loc("g_no");
			return loc("g_yes");
		}
		private function getHeaderPlaceByBitNum(bit:int):int
		{
			var num:int = 0;
			for( var i:int=0; i<256; ++i ) {
				if (HIS_COLLAPSED_PARAMS[i] > 0) {
					if ( i == bit )
						return num;
					num++;
				}
			}
			trace("OptHistoryLine: wrong bit " + bit);
			return 0;
		}
		private function getByteSize(num:int):int
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
}
import flash.display.Sprite;
import flash.events.Event;

class PerformanceIndependantCycle extends Sprite
{
	public var interator:int;
	public var total:int;
	
	private var perform:Function;
	private var update:Function;
	private var target:Array;
	
	public function PerformanceIndependantCycle(f:Function, a:Array, fupdate:Function)
	{
		perform = f;
		update = fupdate;
		target = a;
		total = a.length;
		update({current:interator,total:total});
		this.addEventListener( Event.ENTER_FRAME, interate );
	}
	private function interate(e:Event):void
	{
		if (interator < total) {
			var len:int = 1000;
			for (var i:int=0; i<len; ++i) {
				perform(target, interator++);
			}
		} else
			this.removeEventListener( Event.ENTER_FRAME, interate );
		update({current:interator,total:total});
	}
}