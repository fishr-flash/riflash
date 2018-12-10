package components.screens.opt
{
	import components.abstract.DEVICESB;
	import components.abstract.RegExpCollection;
	import components.abstract.Utility;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.CRC16;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class OptHistoryLine extends OptionListBlock
	{
		private static var colormap:Vector.<String>;
		private var isCIDError:Boolean;
		private var CIDlineLength:int;
		private static var reRemoveHTMLTags:RegExp;
		private static var currentColor:uint;
		
		public function OptHistoryLine(_struct:int)
		{
			super();
			structureID = _struct;
			width = 833+199;
			operatingCMD = CMD.HISTORY_REC;
			FLAG_VERTICAL_PLACEMENT = false;
			// Номер п/п
			createUIElement( new FormString,operatingCMD,"",null,1).x = -7;
			attuneElement(80,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			//globalX += 80;
			// Номер время
			createUIElement( new FormString,operatingCMD,"",null,2).x = 80;
			attuneElement(130,NaN,FormString.F_TEXT_MINI);
			// Номер объъекта
			createUIElement( new FormString,operatingCMD,"",null,3).x = 180+35;
			attuneElement(60,NaN,FormString.F_TEXT_MINI);
			// Номер CID 1301
			createUIElement( new FormString,operatingCMD,"",null,4).x = 240+40;
			attuneElement(60,NaN,FormString.F_TEXT_RETURNS_HEXDATA | FormString.F_TEXT_MINI);
			// Номер расшифровка CID
			createUIElement( new FormString,operatingCMD,"",null,5).x = 345;
			attuneElement(250,NaN,FormString.F_TEXT_MINI);
			// Раздел
			createUIElement( new FormString,operatingCMD,"",null,6).x = 600;
			attuneElement(60,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI );
			// Зона пользователя
			createUIElement( new FormString,operatingCMD,"",null,7).x = 665;
			attuneElement(50,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			// Битовое поле каналов связи
			createUIElement( new FormString,operatingCMD,"",null,8).x = 730;
			attuneElement(100,NaN,FormString.F_HTML_TEXT | FormString.F_TEXT_MINI );
			//attuneElement(100-35,NaN,FormString.F_HTML_TEXT | FormString.F_TEXT_MINI | FormString.F_ALIGN_RIGHT);
			// CID
			createUIElement( new FormString,operatingCMD,"",null,9).x = 825;
			attuneElement(NaN,NaN,FormString.F_TEXT_MINI);
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString,1,loc("cid_error"),null,1).x = 825;
			(getLastElement() as FormString).y = 8;
			attuneElement(NaN,NaN,FormString.F_TEXT_MINI);
			FLAG_SAVABLE = true;
			
			globalX = 825 + 155;
			
			if ( passBottomRelease(7) ) {
				// R7+ Voltage
				createUIElement( new FormString,operatingCMD,"",null,11).x = globalX;
				attuneElement(NaN,NaN,FormString.F_TEXT_MINI);
				globalX += 100;
			}
			
			// CRC16
			createUIElement( new FormString,operatingCMD,"",null,10).x = globalX;
			attuneElement(30,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			if (SERVER.DUAL_DEVICE)
				getLastElement().visible = false;
		}
		override public function putRawData(re:Array):void
		{
			/**	Команда HISTORY_REC - архив событий, история.
			/**	Параметр 1 - Уникальный номер записи 1 - 4 294 967 295. Индексов 0 и 0xFFFFFFFF быть не может. */
			
			// Номер п/п
			//getField(operatingCMD,1).setCellInfo(re[0]);
			var numpp:Array = re.splice(21,1);
			getField(operatingCMD,1).setCellInfo(numpp[0]);
			
			/**	Параметр 2 - Дата - 1-31 ( возможно нулевое значение, если дата/время отсутствуют) (BCD);*/
			/**	Параметр 3 - Месяц - 1-12 ( возможно нулевое значение, если дата/время отсутствуют) (BCD);*/
			/**	Параметр 4 - Год - 00-99 ( 00 - 2000г., 01 - 2001г. ) (BCD);*/
			/**	Параметр 5 - Часы - 0-23 (BCD);*/
			/**	Параметр 6 - Минуты - 0-59 (BCD);*/
			/**	Параметр 7 - Секунды - 0-59 (BCD);*/
			
			// Номер время
			getField(operatingCMD,2).setCellInfo( UTIL.formateZerosInFront(re[1].toString(16),2)+"."+ UTIL.formateZerosInFront(re[2].toString(16),2)+ ".20" +UTIL.formateZerosInFront(re[3].toString(16),2)
				+ " " + UTIL.formateZerosInFront(re[4].toString(16),2) + ":"+UTIL.formateZerosInFront(re[5].toString(16),2) + ":"+UTIL.formateZerosInFront(re[6].toString(16),2));
			// 16.09.2011 17:27:22
			
			/**	Параметр 8 - Номер объекта (BCD);*/
			
			// Номер объъекта
			getField(operatingCMD,3).setCellInfo( UTIL.formateZerosInFront(re[7].toString(16),4));
			
			var num:int = int( re[9] );
			var result:int = (num & 0x0FFF) << 4 | (num & 0xF000) >> 12;
			
			var label:String="";
			var param:String="";
			var a:Array = CIDServant.getEvent();
			for( param in a) {
				if( int( "0x"+a[param].data ) == result ) {
					label = a[param].label;
					switch( a[param].group ) {
						case 1:
						case 3:
							color_dark = 0xfbd3d0;
							color_light = 0xfad4e5;
							break;
						case 2:
						case 4:
							color_dark = 0xc7e8fa;
							color_light = 0xdbf0f6;
							break;
						case 8:
							color_dark = 0xfbf9c5;
							color_light = 0xfcfbd6;
							break;
						default:
							color_light = 0xf5f5f5;
							color_dark = 0xededed;
					}
					break;
				}
			}
			currentColor = color_dark;
			
			/**	Параметр 9 - 0x18h;*/
			/**	Параметр 10 - старшая тетрада -тревога/восстановление, остальное -Код тревоги (BCD);*/

			// Номер CID 1301
			getField(operatingCMD,4).setCellInfo( label.slice(0,6) );
			// Номер расшифровка CID
			getField(operatingCMD,5).setCellInfo( label.slice(6) );
			
			/**	Параметр 11 - Номер раздела 1-99 (BCD);*/
			// Раздел
			getField(operatingCMD,6).setCellInfo( (re[10]).toString(16) );
			
			var zonecrc:String = (re[Utility.hash_1To0(12)]).toString(16);
			var devicecrc:String = zonecrc.slice(zonecrc.length-1);
			var zone:String = zonecrc.slice(0, zonecrc.length-1 );
			if (zone == "")
				zone = "0";
			
			/**	Параметр 12 - Номер зоны 1-0x999 (BCD), младшая тетрада Контрольная сумма CID;*/
			// Зона пользователя
			getField(operatingCMD,7).setCellInfo( zone );

			/**	Параметр 13 - Погашение - 8 каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;*/
			/**	Параметр 14 - Глобальный флаг 0x33 - сообщение передано, 0xFF - сообщение не передано;*/
			// Битовое поле каналов связи
			if (SERVER.DUAL_DEVICE)
				getField(operatingCMD,8).setCellInfo( visualizeBitfield(re[12],re[13] ) );
			else
				getField(operatingCMD,8).setCellInfo( re[13] == 0x33 ? "Да" : "Нет" );
	
			/**	Параметр 15 - Номер прибора в сети; //служебная информация*/
			/**	Параметр 16 - Тип датчика / шлейфа / выхода; //служебная информация*/
			/**	Параметр 17 - Номер шлейфа / номер радиодатчика / номер выхода; //служебная информация*/
			
			/***		R 7+	
				Параметр 18 - Значение напряжения питания в момент записи события. 0.00В-25.5В = 0-255	*/
			if ( passBottomRelease(7) )
				getField(operatingCMD,11).setCellInfo( re[17] == 0 ? "" : (int(re[17])/10).toFixed(2) );
			
			/**	Параметры 19,20 - резерв */
			
			
			var crc:String = calcCIDCRC( [ UTIL.formateZerosInFront((re[Utility.hash_1To0(8)]).toString(16),4), 
				(re[Utility.hash_1To0(9)]).toString(16),
				(re[Utility.hash_1To0(10)]).toString(16),
				UTIL.formateZerosInFront((re[Utility.hash_1To0(11)]).toString(16),2), 
				UTIL.formateZerosInFront(zone,3)] );
			
			if( devicecrc.toLowerCase() != crc.toLowerCase() ) {
				// Ошибка кода CID
				(getField(operatingCMD,9) as FormString).setTextColor( 0xED1C24 );
				(getField(1,1) as FormString).visible = true;
				(getField(1,1) as FormString).setCellInfo( "Ошибка кода CID ("+crc+")" );
				isCIDError = true;
			} else {
				(getField(operatingCMD,9) as FormString).setTextColor( 0x000000 );
				(getField(1,1) as FormString).visible = false;
				isCIDError = false;
			}
			// CID
			var cid_line:String = UTIL.formateZerosInFront((re[Utility.hash_1To0(8)]).toString(16),4) +
				(re[Utility.hash_1To0(9)]).toString(16)+ 
				(re[Utility.hash_1To0(10)]).toString(16) + 
				UTIL.formateZerosInFront((re[Utility.hash_1To0(11)]).toString(16),2) + 
				UTIL.formateZerosInFront(zone,3) + 
				devicecrc;
			CIDlineLength = cid_line.length;
			getField(operatingCMD,9).setCellInfo( cid_line );
			/**	Параметр 21 - Контрольная сумма всей записи CRC16, полином: x^16 + x^15 + x^2 + 1 (0xa001) */
			// CRC16
			var cmd:CommandSchemaModel = OPERATOR.getSchema( CMD.HISTORY_REC );
			var ps:ParameterSchemaModel
			var bytes:Array = new Array;
			for( param in cmd.Parameters ) {
				 ps = cmd.Parameters[param] as ParameterSchemaModel;
				 if(ps.Order < 21) {
					 var mask:uint = 0xFF;
					 for(var i:int=0; i<ps.Length; ++i ) {
						 mask = 0xFF << i*8;
						 bytes.push( (re[param] & mask) >> i*8 );
					 }
				 }
			}
			var crc16:int = CRC16.calculate( bytes, bytes.length );
			if( crc16 == re[20] )
				getField(operatingCMD,10).setCellInfo( loc("g_no") );
			else
				getField(operatingCMD,10).setCellInfo( loc("g_yes") );
		}
		public static function getEmulatedvisualizeBitfield(bit:int,msgflag:int):Array
		{
			var chanstring:String = visualizeBitfield(bit,msgflag,true);
			return [chanstring.replace(/<[^>]*>/g, "" ), colormap.slice()];
		}
		public static function calcCIDCRC(arr:Array):String
		{
			var hash:Object = {0:10, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, "B":11, "C":12, "D":13, "E":14, "F":15};
			//var hash16:Object = {0:"F",1:"1", 2:"2", 3:"3", 4:"4", 5:"5", 6:"6", 7:"7", 8:"8", 9:"9",10:"A",11:"B",12:"C",13:"D",14:"E"};
			var hash16:Object = {0:"F",1:"1", 2:"2", 3:"3", 4:"4", 5:"5", 6:"6", 7:"7", 8:"8", 9:"9",10:"A",11:"B",12:"C",13:"D",14:"E"};
			var summ:int;
			for(var key:String in arr) {
				var target:String = String(arr[key]).toLocaleUpperCase();
				for(var i:int=0; i<target.length; ++i) {
					summ += hash[target.charAt(i)];
				}
			}
			var crc:int = Math.ceil(summ/15)*15 - summ;
			return hash16[crc];
		}
		private static function visualizeBitfield(bit:int,msgflag:int,export:Boolean=false):String
		{
			colormap = new Vector.<String>;
			
			var links:Array = OPERATOR.dataModel.getData( CMD.CH_COM_LINK );
			var groups:Array = new Array;
			for(var g:String in links ) {
				groups.push( links[g][0] );
			}
			var line:String="<font face='"+PAGE.MAIN_FONT+"' size='9'>";
			var result:int;
			for(var i:int; i<8; ++i ) {
				result = bit & (1 << i);
				
				var groupopen:String="";
				var groupclose:String="";
				if ( groups[i-1] is int && groups[i] == groups[i-1] ) {
					if ( !(groups[i+1] is int) || groups[i] != groups[i+1] )
						groupclose = ")";
				} else {
					if ( groups[i+1] is int && groups[i] == groups[i+1] )
						groupopen = "(";
				}
				
				line += groupopen;
				
				if (groupopen.length>0 )
					colormap.push( "000000" );	
				
				if(links[i][4] == 0) {
					line += "<font color='#cccccc'>";
					colormap.push( "cccccc" );
				} else if (result==0) {
					line += "<font color='#009444'>";
					colormap.push( "009444" );
				} else {
					line += "<font color='#ED1C24'>";
					colormap.push( "ED1C24" );
				}
				line += int(i+1)+"</font>"+groupclose;
				
				if (groupclose.length>0 )
					colormap.push( "000000" );
			}
			
			switch(msgflag) {
				case 0x11:
					return "";
				case 0x77:
					colormap = new Vector.<String>;
					colormap.push( "ED1C24" );
					if (export) {
						return "<font color='#ED1C24'><b>!</b></font>";
					} else {
						if (!reRemoveHTMLTags)
							reRemoveHTMLTags = new RegExp(RegExpCollection.REF_REMOVE_HTML_TAGS, "gi"); 
						var lineclear:String = line.replace(reRemoveHTMLTags, "");
						return "<font color='#"+currentColor.toString(16)+"'>"+lineclear+"</font><font color='#ED1C24'><b>!</b></font>";
					}
				case 0xff:
					line += "<font color='#ED1C24'><b>!</b></font>";
					colormap.push( "ED1C24" );
					break;
			}
			return line + "</font>";
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