package components.screens.opt
{
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.UTIL;
	
	public class OptHistoryLineK9 extends OptionListBlock
	{
		private static var colormap:Vector.<String>;
		private var isCIDError:Boolean;
		private var CIDlineLength:int;
		public function OptHistoryLineK9(_struct:int)
		{
			super();
			structureID = _struct;
			width = 1155+80+45;
			operatingCMD = CMD.K5_HISTORY_REC;
			FLAG_VERTICAL_PLACEMENT = false;
			
			globalX = -7;
			
			/** 
			"Команда K9_HISTORY_REC - архив событий, история.

				Параметр 1 - Уникальный идентификатор события 1-4 294 967 294
				Параметр 2 - Дата - 1-31 ( возможно нулевое значение, если дата/время отсутствуют) (BCD);
				Параметр 3 - Месяц - 1-12 ( возможно нулевое значение, если дата/время отсутствуют) (BCD);
				Параметр 4 - Год - 00-99 ( 00 - 2000г., 01 - 2001г. ) (BCD);
				Параметр 5 - Часы - 0-23 (BCD);
				Параметр 6 - Минуты - 0-59 (BCD);
				Параметр 7 - Секунды - 0-59 (BCD);
				Параметр 8 - Номер объекта (HEX)
				Параметр 9 - 0x18;
				Параметр 10 - старшая тетрада -тревога/восстановление, остальное -Код тревоги (BCD);
				Параметр 11 - Номер раздела 1-99 (BCD);
				Параметр 12 - Номер зоны 1-999 (BCD) либо номер пользователя если взятие/снятие, младшая тетрада Контрольная сумма CID (c 8 по 12 параметр);
				Параметр 13 - Глобальный флаг 0x33 - сообщение передано, 0xFF - сообщение не передано;
				Параметр 14 - отправлено по GPRS SIM1 IP1(основной) (0 - нет, 1 - да);
				Параметр 15 - отправлено по GPRS SIM1 IP2(резервный) (0 - нет, 1 - да);
				Параметр 16 - отправлено по GPRS SIM2 IP1(основной) (0 - нет, 1 - да);
				Параметр 17 - отправлено по GPRS SIM2 IP2(резервный) (0 - нет, 1 - да);
				Параметр  18 - Погашение - 8 альтернативных каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;
				Параметр  19 - Флаг контрольной суммы (CRC) записи истории (0 - CRC не корректная, 1 - CRC корректная)"													
 			 *  №	Время	№ объекта	Код	Т\В	Событие	Раздел	Шлейф/ ТМ (ГБР)	Посылка	КС	Передано	Направления
			 * */
			
			
			// Номер п/п
			createUIElement( new FormString,operatingCMD,"",null,1);
			attuneElement(80,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			globalX += 87;
			// время
			createUIElement( new FormString,operatingCMD,"",null,2);
			attuneElement(130,NaN,FormString.F_TEXT_MINI);
			globalX += 128;
			// Номер объъекта
			createUIElement( new FormString,operatingCMD,"",null,3);
			attuneElement(60,NaN,FormString.F_TEXT_MINI);
			globalX += 65;
			// Код
			createUIElement( new FormString,operatingCMD,"",null,12);
			attuneElement(80,NaN,FormString.F_TEXT_RETURNS_HEXDATA | FormString.F_TEXT_MINI);
			globalX += 45;
			// Т\В
			createUIElement( new FormString,operatingCMD,"",null,4);
			attuneElement(80,NaN,FormString.F_TEXT_RETURNS_HEXDATA | FormString.F_TEXT_MINI);
			globalX += 105;
			// Событие
			createUIElement( new FormString,operatingCMD,"",null,5);
			attuneElement(250,NaN,FormString.F_TEXT_RETURNS_HEXDATA | FormString.F_TEXT_MINI);
			globalX += 255;
			
			// Раздел
			createUIElement( new FormString,operatingCMD,"",null,6);
			attuneElement(60,NaN,FormString.F_TEXT_MINI);
			globalX += 65;
			// Шлейф/ ТМ
			createUIElement( new FormString,operatingCMD,"",null,7);
			attuneElement(50,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI );
			globalX += 55;
			// Посылка
			createUIElement( new FormString,operatingCMD,"",null,8);
			attuneElement(130,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			globalX += 135;
			// КС
			createUIElement( new FormString,operatingCMD,"",null,9);
			attuneElement(40,NaN,FormString.F_HTML_TEXT | FormString.F_TEXT_MINI);
			globalX += 45;
			// Передано
			createUIElement( new FormString,operatingCMD,"",null,10);
			attuneElement(40,NaN,FormString.F_TEXT_MINI);
			globalX += 75;
			// Направление
			createUIElement( new FormString,operatingCMD,"",null,11);
			attuneElement(200,NaN,FormString.F_TEXT_MINI | FormString.F_HTML_TEXT);
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
			
			// Т\В
			var s:String = "";
			var n:int = int((re[9].toString(16) as String).slice(0,1));
			if (n == 1)
				s = loc("his_alarm")
			else if (n == 3)
				s = loc("his_revert");
			getField(operatingCMD,4).setCellInfo( s );
			
			// Код
			s = (re[9].toString(16) as String).slice(1);
			getField(operatingCMD,12).setCellInfo( s );
			
			// Номер расшифровка CID
			n = int( re[9] );
			var result:int = (n & 0x0FFF) << 4 | (n & 0xF000) >> 12;
			//var result:int = n;
			
			dtrace("#"+numpp[0]+ ": " +n +  " hex " + n.toString(16));
			s="";
			var param:String="";
			var a:Array = CIDServant.getEvent();
			for( param in a) {
				if( int( "0x"+a[param].data ) == result ) {
					s = a[param].label;
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
		/*	if (s=="") {
				result = n;
				param="";
				for( param in a) {
					if( int( "0x"+a[param].data ) == result ) {
						s = a[param].label;
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
			}
			*/
			
			/// Событие
			getField(operatingCMD,5).setCellInfo( s.slice(6) );
			
			// Раздел
			getField(operatingCMD,6).setCellInfo( (re[10]).toString(16) );
			
			// Шлейф/ ТМ
			var zonecrc:String = (re[11]).toString(16);
			var devicecrc:String = zonecrc.slice(zonecrc.length-1);
			var zone:String = zonecrc.slice(0, zonecrc.length-1 );
			if (zone.length == 0)
				zone = "0";
			getField(operatingCMD,7).setCellInfo( zone );
			
			// Посылка
			s = UTIL.fz((re[7]).toString(16),4) +
				(re[8]).toString(16)+ 
				(re[9]).toString(16) + 
				UTIL.fz((re[10]).toString(16),2) + 
				UTIL.fz(zone,3) + 
				devicecrc;
			CIDlineLength = s.length;
			getField(operatingCMD,8).setCellInfo( s.toUpperCase() );
			
			// КС
			getField(operatingCMD,9).setCellInfo( re[18] == 1 ? loc("g_yes"):loc("g_no") );
			
			// Передано
			getField(operatingCMD,10).setCellInfo( re[12] == 0x33 ? loc("g_yes"):loc("g_no") );
			
			// Направление
			/**	Параметр 14 - отправлено по LAN (0 - нет, 1 - да);
				Параметр 15 - отправлено по GPRS SIM1 (0 - нет, 1 - да);
				Параметр 16 - отправлено по GPRS SIM2 (0 - нет, 1 - да);
				Параметр  17 - Погашение - 8 альтернативных каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;*/
			
			
			/*
			Параметр 14 - отправлено по GPRS SIM1 IP1(основной) (0 - нет, 1 - да);
			Параметр 15 - отправлено по GPRS SIM1 IP2(резервный) (0 - нет, 1 - да);
			Параметр 16 - отправлено по GPRS SIM2 IP1(основной) (0 - нет, 1 - да);
			Параметр 17 - отправлено по GPRS SIM2 IP2(резервный) (0 - нет, 1 - да);
			*/
			
			s = "";
			//if ( re[12] == 0x33 ) {
				if (re[13] == 1)
					s = "SIM1 IP1";
				if (re[14] == 1) {
					if (s.length > 0)
						s += ", ";
					s += "SIM1 IP2";
				}
				if (re[15] == 1) {
					if (s.length > 0)
						s += ", ";
					s += "SIM2 IP1";
				}
				if (re[16] == 1) {
					if (s.length > 0)
						s += ", ";
					s += "SIM2 IP2";
				}
				
				var bitfield:int = re[17];
				
				if (s.length == 0) {
					var directions:Array = OPERATOR.dataModel.getData(CMD.K9_DIRECTIONS);
					for (var i:int=0; i<8; i++) {
						s += (bitfield & (1 << i)) == 0 ? UTIL.wrapHtml( (i+1).toString(), COLOR.GREEN, 12, true ): UTIL.wrapHtml( (i+1).toString(), COLOR.RED, 12, true );
					}
				}
			/*} else
				s = UTIL.wrapHtml( "-", COLOR.RED, 12, true );*/
			
		//	s = "LAN, GPRS SIM1, GPRS SIM1, 12345678";
			getField(operatingCMD,11).setCellInfo( s );
		}
		public static function getEmulatedvisualizeBitfield(re:Array):String
		{
			var s:String = "";
			if (re[13] == 1)
				s = "SIM1 IP1";
			if (re[14] == 1) {
				if (s.length > 0)
					s += ", ";
				s += "SIM1 IP2";
			}
			if (re[15] == 1) {
				if (s.length > 0)
					s += ", ";
				s += "SIM2 IP1";
			}
			if (re[16] == 1) {
				if (s.length > 0)
					s += ", ";
				s += "SIM2 IP2";
			}
			
			var bitfield:int = re[17];
			
			if (s.length == 0) {
				var directions:Array = OPERATOR.dataModel.getData(CMD.K9_DIRECTIONS);
				for (var i:int=0; i<8; i++) {
					s += (bitfield & (1 << i)) == 0 ? (i+1).toString():"";
				}
			}
			return s;
		}
		
		public static function calcCIDCRC(re:Array):String
		{
			return re[18] == 1 ? loc("g_yes"):loc("g_no");
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