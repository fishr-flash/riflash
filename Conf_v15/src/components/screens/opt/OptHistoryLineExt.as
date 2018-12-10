package components.screens.opt
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.gui.visual.HistoryVideoLoader;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.UTIL;
	
	import sandy.materials.attributes.AAttributes;
	
	public class OptHistoryLineExt extends OptionListBlock
	{
		private static var colormap:Vector.<String>;
		private var isCIDError:Boolean;
		private var CIDlineLength:int;
		private var date:Date;
		
		public function OptHistoryLineExt(_struct:int)
		{
			super();
			structureID = _struct;
			width = 833+199;
			operatingCMD = CMD.HISTORY_REC;
			FLAG_VERTICAL_PLACEMENT = false;
			// Номер п/п
			createUIElement( new FormString,operatingCMD,"",null,1).x = -7;
			attuneElement(80,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			globalX += 80;
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
			createUIElement( new FormString,operatingCMD,"",null,8).x = 770;
			attuneElement(100,NaN,FormString.F_HTML_TEXT | FormString.F_TEXT_MINI);
			// CID
			createUIElement( new FormString,operatingCMD,"",null,9).x = 835;
			attuneElement(NaN,NaN,FormString.F_TEXT_MINI);
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString,1,"Ошибка кода CID",null,1).x = 825;
			(getLastElement() as FormString).y = 8;
			attuneElement(NaN,NaN,FormString.F_TEXT_MINI);
			FLAG_SAVABLE = true;
			// CRC16
			//createUIElement( new FormString,operatingCMD,"",null,10).x = 790+190;
			//attuneElement(30,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			
			if (!SERVER.isGeoritm() ) {
				this.addEventListener( MouseEvent.CLICK, onClick );
			}
		}
		private function onClick(e:Event):void
		{
			HistoryVideoLoader.access().open(date,localToGlobal(new Point));
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
			

			var year1:int = re[3];
			var year2:int = int(int(re[3]).toString(16));
			var year3:int = int(int(re[3]).toString(10));
			
			date = new Date;
			date.setUTCFullYear( int(int(re[3]).toString(16)),int(int(re[2] - 1).toString(16)),int(int(re[1]).toString(16)) );
			date.setUTCHours( int(int(re[4]).toString(16)), int(int(re[5]).toString(16)), int(int(re[6]).toString(16)) );
				
			getField(operatingCMD,2).setCellInfo( UTIL.formateZerosInFront( String(date.getDate() ),2 )
				+"."+UTIL.formateZerosInFront( String(date.getMonth()+1),2)
				+"."+UTIL.formateZerosInFront( String(date.getFullYear()),2 )+ "      "
				+UTIL.formateZerosInFront( String( date.getHours() ),2)+":"
				+UTIL.formateZerosInFront( String( date.getMinutes() ),2)+":"
				+UTIL.formateZerosInFront( String( date.getSeconds() ),2) );
			
			// Номер время
			/*
			getField(operatingCMD,2).setCellInfo( UTIL.formateZerosInFront(re[1].toString(16),2)+"."+ UTIL.formateZerosInFront(re[2].toString(16),2)+ ".20" +UTIL.formateZerosInFront(re[3].toString(16),2)
				+ " " + UTIL.formateZerosInFront(re[4].toString(16),2) + ":"+UTIL.formateZerosInFront(re[5].toString(16),2) + ":"+UTIL.formateZerosInFront(re[6].toString(16),2));
			*/
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
			/**	Параметр 9 - 0x18h;*/
			/**	Параметр 10 - старшая тетрада -тревога/восстановление, остальное -Код тревоги (BCD);*/

			// Номер CID 1301
			getField(operatingCMD,4).setCellInfo( label.slice(0,6) );
			// Номер расшифровка CID
			getField(operatingCMD,5).setCellInfo( label.slice(6) );
			
			/**	Параметр 11 - Номер раздела 1-99 (BCD);*/
			// Раздел
			getField(operatingCMD,6).setCellInfo( (re[10]).toString(16) );
			
			var zonecrc:String = (re[UTIL.hash_1To0(12)]).toString(16);
			var devicecrc:String = zonecrc.slice(zonecrc.length-1);
			var zone:String = zonecrc.slice(0, zonecrc.length-1 );
			if (zone.length == 0)
				zone = "0";
			
			/**	Параметр 12 - Номер зоны 1-0x999 (BCD), младшая тетрада Контрольная сумма CID;*/
			// Зона пользователя
			getField(operatingCMD,7).setCellInfo( zone );

			/**	Параметр 13 - Погашение - 8 каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;*/
			/**	Параметр 14 - Глобальный флаг 0x33 - сообщение передано, 0xFF - сообщение не передано;*/
			// Битовое поле каналов связи
			getField(operatingCMD,8).setCellInfo( re[13] == 0x33 ? loc("g_yes"):loc("g_no") );
	
			/**	Параметр 15 - Номер прибора в сети; //служебная информация*/
			/**	Параметр 16 - Тип датчика / шлейфа / выхода; //служебная информация*/
			/**	Параметр 17 - Номер шлейфа / номер радиодатчика / номер выхода; //служебная информация*/
			/**	Параметры 18,19,20 - резерв */
			
			var crc:String = calcCIDCRC( [ UTIL.formateZerosInFront((re[UTIL.hash_1To0(8)]).toString(16),4), 
				(re[UTIL.hash_1To0(9)]).toString(16),
				(re[UTIL.hash_1To0(10)]).toString(16),
				UTIL.formateZerosInFront((re[UTIL.hash_1To0(11)]).toString(16),2), 
				UTIL.formateZerosInFront(zone,3)] );
			
			if( devicecrc.toLowerCase() != crc.toLowerCase() ) {
				// Ошибка кода CID
				(getField(operatingCMD,9) as FormString).setTextColor( 0xED1C24 );
				(getField(1,1) as FormString).visible = true;
				(getField(1,1) as FormString).setCellInfo( loc("cid_error")+" ("+crc+")" );
				isCIDError = true;
			} else {
				(getField(operatingCMD,9) as FormString).setTextColor( 0x000000 );
				(getField(1,1) as FormString).visible = false;
				isCIDError = false;
			}
			// CID
			var cid_line:String = UTIL.formateZerosInFront((re[UTIL.hash_1To0(8)]).toString(16),4) +
				(re[UTIL.hash_1To0(9)]).toString(16)+ 
				(re[UTIL.hash_1To0(10)]).toString(16) + 
				UTIL.formateZerosInFront((re[UTIL.hash_1To0(11)]).toString(16),2) + 
				UTIL.formateZerosInFront(zone,3) + 
				devicecrc;
			CIDlineLength = cid_line.length;
			getField(operatingCMD,9).setCellInfo( cid_line );
			/**	Параметр 21 - Контрольная сумма всей записи CRC16, полином: x^16 + x^15 + x^2 + 1 (0xa001) */
		}
		public static function getEmulatedvisualizeBitfield(bit:int,msgflag:int):Array
		{
			return [msgflag == 0x33 ? loc("g_yes"):loc("g_no")];
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
		override public function getFieldsData():Array
		{
			var color:String;
			if ( isCIDError )
				color = "ED1C24";
			else
				color = "000000";
			
			var v:Vector.<String> = new Vector.<String>(CIDlineLength);
			for(var i:int=0;i<CIDlineLength;++i) {
				v[i] = color;
			}
			var cid:Array = [getField(operatingCMD,9).getCellInfo(),v];
			
			return [ int(getField(operatingCMD,1).getCellInfo()),
				getField(operatingCMD,2).getCellInfo(),
				getField(operatingCMD,3).getCellInfo(),
				(getField(operatingCMD,4).getCellInfo() as String).slice(2),
				getField(operatingCMD,5).getCellInfo(),
				int(getField(operatingCMD,6).getCellInfo()),
				int(getField(operatingCMD,7).getCellInfo()),
				[getField(operatingCMD,8).getCellInfo(),colormap],
				cid, 
				//getField(operatingCMD,10).getCellInfo()
			];
		}
	}
}