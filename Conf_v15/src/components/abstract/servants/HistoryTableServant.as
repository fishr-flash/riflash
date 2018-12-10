package components.abstract.servants
{
	import components.abstract.HistoryDataProvider;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.interfaces.IMTableAdapter;
	import components.protocol.statics.CRC16;
	import components.static.MISC;

	public class HistoryTableServant
	{
		private var formated_crc_arr:Array;
		private var adapter:TableAdapter;
		private var headers:Array;
		private var content:Array;
		
		public function HistoryTableServant()
		{
		}
		public function generateHeader():Array
		{
			headers = [];
			
			var p:Object = {
				p:VoyagerHistoryServant.PARAMS
			}
			for(var i:int=2;i<256; ++i) {
				if (HistoryDataProvider.HIS_COLLAPSED_PARAMS[i] > 0 && HistoryDataProvider.isVisible(i) ) {
					headers.push( 
						[loc(VoyagerHistoryServant.PARAMS[i].title), calcWidth(VoyagerHistoryServant.PARAMS[i].title)] );
				}
			}
			return headers;
		}
		public function getHeaderLabels():Array
		{
			var h:Array = [];
			var len:int = headers.length;
			for (var i:int=0; i<len; i++) {
				h.push( headers[i][0] );
			}
			return h;
		}
		public function getHeader():Array
		{
			return headers;
		}
		public function getAdapter():IMTableAdapter
		{
			if (!adapter)
				adapter = new TableAdapter(getExistingContent);
			return adapter;
		}
		private function updateWidth(a:Array):void
		{
			var w:int = 0;
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				w = calcWidth(a[i]);
				if (w > headers[i][1])
					headers[i][1] = w;
			}
		}
		private function calcWidth(s:String):int
		{
			var total:int = 0;
			var len:int = s.length;
			for (var i:int=0; i<len; i++) {
				if (s.charAt(i) == " ")
					total+=3;
				else if( s.charAt(i) == s.charAt(i).toLowerCase() )
					total+=7;
				else
					total+=9;
			}
			return total + 15+20;
		}
		public function getWidth():int
		{
			var w:int = 0;
			var len:int = headers.length;
			for (var i:int=0; i<len; i++) {
				w += headers[i][1];
			}
			return w;
		}
		public function getContent(a:Array):Array
		{
			content = [];
			var len:int = a.length;
			for( var key:String in a ) {
				if (a[key] is Array && a[key].length > 0)
					content.push( put(a[key]) );
			}
				
			return content;
		}
		public function getExistingContent():Array
		{
			return content;
		}
		private function put(data:Array):Array
		{
			var assemblege:Array = new Array;
			
			formated_crc_arr = data.slice(0, data.length-2);
			var blockNum:int = data[0]-1;
			if (blockNum>3 || blockNum<0) {
				dtrace( "ERROR: Индекс SELECT_PAR="+blockNum+", возможно произошла ошибка парсинга");
				blockNum = 0;
			}
			
			var value:uint;
			var ob:Object = HistoryDataProvider.HIS_PERBLOCK_PARAMS[blockNum];
			var global_byte_shift:int=0;
			var bitgroup:Vector.<int>;
			var currentParam:Object;
			var naxtParam:Object;
			
			VoyagerHistoryServant.crcCalculation = calcCrc;  
			
			for( var i:int=0; i<256; ++i ) {
				if (HistoryDataProvider.HIS_PERBLOCK_PARAMS[blockNum][i] > 0) {
					
					value = 0;
					var lastWasBitgroup:Boolean=false;
					//if (currentParam && HistoryDataProvider.PARAMS[i].bit == null ) {
					if (currentParam ) {
						lastWasBitgroup = true;
						global_byte_shift += getByteSize(i);
					}
					
					if (i > 1 && HistoryDataProvider.isVisible(i)) {
					
						var bitnum:int = VoyagerHistoryServant.PARAMS[i].bit is int ? i - VoyagerHistoryServant.PARAMS[i].bit : 0xFF;
						
						if (MISC.DEBUG_HISTORY_DIGITAL_VIEW == 1 && bitnum != 0xff )
							assemblege[ getHeaderPlaceByBitNum(i) ] = VoyagerHistoryServant.dformat( data.slice(global_byte_shift,global_byte_shift+VoyagerHistoryServant.PARAMS[i].byte),
								VoyagerHistoryServant.PARAMS[i].print, bitnum );
						else
							assemblege[ getHeaderPlaceByBitNum(i) ] = VoyagerHistoryServant.format( data.slice(global_byte_shift,global_byte_shift+VoyagerHistoryServant.PARAMS[i].byte), 
								VoyagerHistoryServant.PARAMS[i].print, bitnum );
						// проверить нет ли функции привязанной к параметру, если есть - послать в нее весь уже собранный массив
						if (VoyagerHistoryServant.PARAMS[i].func is Function)
							VoyagerHistoryServant.PARAMS[i].func(assemblege);
					}
					
					if (!lastWasBitgroup || (lastWasBitgroup && !VoyagerHistoryServant.PARAMS[i].bit)  )
						global_byte_shift += getByteSize(i);
					if(i==2)
						formated_crc_arr[2] = 0xff;
				} else
					continue;//assemblege.push("пусто");
			}
			
			var len:int = assemblege.length;
			for (i=0; i<len; i++) {
				if (!assemblege[i] ) {
					assemblege.splice(i,1);
					i--;
					len--;
				}
			}
			
			updateWidth(assemblege);
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
		
		private function calcCrc(crcFromDevice:int):String
		{
			var crc16:int = CRC16.calculate(formated_crc_arr, formated_crc_arr.length);
			
			if( crc16 == crcFromDevice )
				return loc("g_no");
			else {
				return loc("g_yes");
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
	}
}
import mx.controls.dataGridClasses.DataGridColumn;

import components.abstract.functions.loc;
import components.interfaces.IMTableAdapter;
import components.system.UTIL;

class TableAdapter implements IMTableAdapter
{
	private var fGetContent:Function;
	
	public function TableAdapter(f:Function)
	{
		fGetContent = f;
	}
	public function adapt(a:Array, n:int):Array
	{
		return null;
	}
	
	public function getRowColor(rowIndex:int, sourceColor:uint):uint
	{
		var a:Array = fGetContent();
		var c:uint = sourceColor;
		if (a && a[rowIndex]) {
			var row:Array = a[rowIndex];
			if (row.length > 0) {	// если радок т.е. информации в табилце нет вообще
				if( (row[row.length-1] as String).toLowerCase() == loc("g_yes").toLowerCase() ) {
					if (UTIL.isEven(rowIndex) )
						c = 0xeeaaa4;
					else
						c = 0xffdad7;
				}
			}
		}
		return c;
	}
	public function get isAdapt():Boolean
	{
		return false;
	}
	public function get isRowColor():Boolean
	{
		return true;
	}
	public function assignCellRenderer(c:DataGridColumn):void
	{
	}
	public function get isCellRenderer():Boolean
	{
		return false;
	}
}