package components.screens.opt
{
	/** STANDART VOYAGER HISTORY LINE 1.1 	*/
	
	import components.abstract.HistoryDataProvider;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.VoyagerHistoryServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.statics.CRC16;
	import components.static.CMD;
	import components.static.MISC;
	
	public class OptHistoryLine extends OptionListBlock
	{
		private var formated_crc_arr:Array;
		private var total_params:Array;
		
		public function OptHistoryLine(s:int)
		{
			super();
			
			structureID = s;
			operatingCMD = CMD.HISTORY_BLOCK;
			FLAG_VERTICAL_PLACEMENT = false;
			FLAG_SAVABLE = false;
			
			globalX = VoyagerHistoryServant.PARAMS[4].w+5;
			var counter:int=1;
			var columnwidth:int;
			for(var i:int=0;i<256; ++i) {
				if (HistoryDataProvider.HIS_COLLAPSED_PARAMS[i] > 0) {
					
					createUIElement( new FormString, operatingCMD, "", null, counter ).x = globalX;
					counter++;
					(getLastElement() as FormString).leading = 0;
					
					columnwidth = VoyagerHistoryServant.PARAMS[i].w;
					if (MISC.DEBUG_HISTORY_DIGITAL_VIEW == 1 && !VoyagerHistoryServant.PARAMS[i].fw )
						columnwidth /= 2;
					
					attuneElement( columnwidth, NaN, FormString.F_MULTYLINE );
					if (i != 4)
						globalX += columnwidth + 5;
					else
						getLastElement().x = 0;
				}
			}
			width = globalX < 780 ? 780 : globalX;
		}
		override public function putRawData(data:Array):void
		{
			var assemblege:Array = new Array;
			var i:int;
			if (data && data[0] == "header") {
				for( i=0; i<256; ++i ) {
					if (HistoryDataProvider.HIS_COLLAPSED_PARAMS[i] > 0) {
						if (MISC.DEBUG_HISTORY_DIGITAL_VIEW == 1)
							assemblege.push( (VoyagerHistoryServant.PARAMS[i].title as String).replace(/\s/,"\n") );
						else
							assemblege.push( VoyagerHistoryServant.PARAMS[i].title );
					} else
						continue;
				}
				var len:int = assemblege.length;
				var f:FormString;
				for(i=0; i<len; ++i ) {
					f = getField(operatingCMD,i+1) as FormString;
					f.attune( FormString.F_TEXT_BOLD | FormString.F_TEXT_MINI );
					f.y = 5;
				}
				
			} else if(!data || data.length==0)
				return;
			else {
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
						
						if (MISC.DEBUG_HISTORY_DIGITAL_VIEW == 1 && bitnum != 0xff )
							assemblege[ getHeaderPlaceByBitNum(i) ] = VoyagerHistoryServant.dformat( data.slice(global_byte_shift,global_byte_shift+VoyagerHistoryServant.PARAMS[i].byte),
							VoyagerHistoryServant.PARAMS[i].print, bitnum );
						else
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
			distribute( assemblege, operatingCMD );
			
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
				color_dark = 0xeeaaa4;
				color_light = 0xffdad7;
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
		override public function getFieldsData():Array
		{
			
			var len:int = aCells.length;
			var arr:Array =  new Array;
			for(var i:int=0; i<len; ++i ) {
				if (i==0)
					continue;
				if (i==3) {
					arr.splice(0,0, (getField(operatingCMD,i+1) as FormString).getCellInfo() );
				} else
					arr.push( (getField(operatingCMD,i+1) as FormString).getCellInfo() );
			}
			return arr;
		}
	}
}