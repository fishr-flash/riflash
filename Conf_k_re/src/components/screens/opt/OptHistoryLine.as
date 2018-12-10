package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIHistoryExt;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class OptHistoryLine extends OptionListBlock
	{
		private static var colormap:Vector.<String>;
		private var isCIDError:Boolean;
		private var CIDlineLength:int;
		public function OptHistoryLine(_struct:int)
		{
			super();
			structureID = _struct;
			width = 1155+80+45;
			operatingCMD = CMD.K5_HISTORY_REC;
			FLAG_VERTICAL_PLACEMENT = false;
			
			globalX = -7;
			
			/** 
			"Команда K5_HISTORY_REC - архив событий, история.

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
			Параметр 14 - отправлено по LAN (0 - нет, 1 - да);
			Параметр 15 - отправлено по GPRS SIM1 (0 - нет, 1 - да);Для РТ1(РТ3)(0 - нет, 1 - да, по SIM1, 2 - да, по SIM2)
			Параметр 16 - отправлено по GPRS SIM2 (0 - нет, 1 - да);Для РТ1(РТ3)(0 - нет, 1 - да, по SIM1, 2 - да, по SIM2)
			Параметр  17 - Погашение - 8 альтернативных каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;
			Параметр  18 - Флаг контрольной суммы (CRC) записи истории (0 - CRC не корректная, 1 - CRC корректная)"			 
			 * 
			 * №	Время	№ объекта	Код	Т\В	Событие	Раздел	Шлейф/ ТМ (ГБР)	Посылка	КС	Передано	Направления
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
		public function getParsedData(re:Array):Array
		{
			
			/*
			0  {label:loc("his_k5_num"),align:"center",xpos:22},
			1  {label:loc("his_k5_time"), xpos:45+38},
			2  {label:loc("his_k5_objnum"), align:"center", xpos:160+30},
			3  {label:loc("his_k5_code"), align:"center", xpos:230+40}, 
			4  {label:loc("his_k5_alarm_restore"), align:"center", xpos:230+45+45},
			5  {label:loc("his_k5_event"), xpos:360+45+20},
			6  {label:loc("his_k5_part"), xpos:590+45+20},
			7  {label:loc("his_k5_wire_tmkey"), align:"center", xpos:660+45+20},
			8  {label:loc("his_k5_package"), xpos:745+45+20},
			9  {label:loc("his_k5_crc"), xpos:867+45+20}, 
			10 {label:loc("his_k5_sent"), xpos:900-8+45+20}, 
			11 {label:loc("his_k5_dir"), xpos:995+40+20} ], {size:11} );
			*/
			
			var a:Array = [];
			a[0] = re[0];
			
			// Номер время
			a[1] = UTIL.formateZerosInFront(re[1].toString(16),2)+"."+ UTIL.formateZerosInFront(re[2].toString(16),2)+ ".20" +UTIL.formateZerosInFront(re[3].toString(16),2)
				+ " " + UTIL.formateZerosInFront(re[4].toString(16),2) + ":"+UTIL.formateZerosInFront(re[5].toString(16),2) + ":"+UTIL.formateZerosInFront(re[6].toString(16),2);
			// 16.09.2011 17:27:22
			
			// Номер объъекта
			a[2] = UTIL.formateZerosInFront(re[7].toString(16),4);
			
			// Т\В
			var s:String = "";
			var n:int = int((re[9].toString(16) as String).slice(0,1));
			if (n == 1)
				s = loc("his_alarm")
			else if (n == 3)
				s = loc("his_revert");
			a[4] = s;
			
			// Код
			s = (re[9].toString(16) as String).slice(1);
			a[3] = s;
			
			// Номер расшифровка CID
			n = int( re[9] );
			var result:int = (n & 0x0FFF) << 4 | (n & 0xF000) >> 12;
			
			s="";
			var param:String="";
			var cid:Array = CIDServant.getEvent();
			for( param in cid) {
				if( int( "0x"+cid[param].data ) == result ) {
					s = cid[param].label;
					break;
				}
			}
			a[5] = s.slice(6);
			
			// Раздел
			a[6] = int(re[10]).toString(16)
			
			// Шлейф/ ТМ
			var zonecrc:String = (re[11]).toString(16);
			var devicecrc:String = zonecrc.slice(zonecrc.length-1);
			var zone:String = zonecrc.slice(0, zonecrc.length-1 );
			if (zone.length == 0)
				zone = "0";
			a[7] = zone;
			
			// Посылка
			s = UTIL.fz((re[7]).toString(16),4) +
				(re[8]).toString(16)+ 
				(re[9]).toString(16) + 
				UTIL.fz((re[10]).toString(16),2) + 
				UTIL.fz(zone,3) + 
				devicecrc;
			CIDlineLength = s.length;
			a[8] = s.toUpperCase();
			
			// КС
			a[9] = re[17] == 1 ? loc("g_yes"):loc("g_no");
			
			// Передано
			a[10] = re[12] == 0x33 ? loc("g_yes"):loc("g_no");
			
			// Направление
			/**	Параметр 14 - отправлено по LAN (0 - нет, 1 - да);
			 Параметр 15 - отправлено по GPRS SIM1 (0 - нет, 1 - да);
			 Параметр 16 - отправлено по GPRS SIM2 (0 - нет, 1 - да);
			 Параметр  17 - Погашение - 8 альтернативных каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;*/
			
			s = "";
			
			/**	Команда K5_HISTORY_REC - архив событий, история.
			Для К5:
			Параметр 15 - отправлено по GPRS IP1(основной) (0 - нет, 1 - да);
			Параметр 16 - отправлено по GPRS IP2(резервный) (0 - нет, 1 - да);
			
			Для РТ1(РТ3):
			Параметр 15 - отправлено по GPRS IP1(основной) (0 - нет, 1 - да, по SIM1, 2 - да, по SIM2);
			Параметр 16 - отправлено по GPRS IP2(резервный) (0 - нет, 1 - да, по SIM1, 2 - да, по SIM2);					*/
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					if (re[13] == 1)
						s = "LAN";
					if (re[14] == 1) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS IP1";
					}
					if (re[15] == 1) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS IP2";
					}
					break;
				case DS.K5RT1:
				case DS.K5RT13G:
				case DS.K5RT1L:
				case DS.K5RT3:
				case DS.K5RT3L:
				case DS.K5RT33G:
					if (re[13] == 1)
						s = "LAN";
					if (re[14] != 0) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS SIM" + ( re[14] ) + " IP1";
					}
					if (re[15] != 0) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS SIM" + ( re[15] ) + " IP2";
					}
					break;
			}				
			
			var bitfield:int = re[16];
			
			var done:String = "";
			var failed:String = "";
			
			if (bitfield != 0xff) {
				if (s.length > 0)
					s += ", ";
				for (var i:int=0; i<8; i++) {
					
					(bitfield & (1 << i)) == 0 ? done += (i+1).toString() : failed += (i+1).toString();
				}
			}
			
			if (done.length > 0)
				s += loc("his_transfered").toLowerCase() + " " + done;
			if (failed.length > 0) {
				if (done.length > 0)
					s += ", ";
				s += loc("his_not_transfered").toLowerCase() + " "+ failed;
			}
			
			//	s = "LAN, GPRS SIM1, GPRS SIM1, 12345678";
			a[11] = s;
			
			return a;
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
			getField(operatingCMD,9).setCellInfo( re[17] == 1 ? loc("g_yes"):loc("g_no") );
			
			// Передано
			getField(operatingCMD,10).setCellInfo( re[12] == 0x33 ? loc("g_yes"):loc("g_no") );
			
			// Направление
			/**	Параметр 14 - отправлено по LAN (0 - нет, 1 - да);
				Параметр 15 - отправлено по GPRS SIM1 (0 - нет, 1 - да);
				Параметр 16 - отправлено по GPRS SIM2 (0 - нет, 1 - да);
				Параметр  17 - Погашение - 8 альтернативных каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;*/
			
			s = "";
		/*	if (re[13] == 1)
				s = "LAN";
			if (re[14] == 1) {
				if (s.length > 0)
					s += ", ";
				s += "GPRS IP1";
			}
			if (re[15] == 1) {
				if (s.length > 0)
					s += ", ";
				s += "GPRS IP2";
			}*/
			
			/**	Команда K5_HISTORY_REC - архив событий, история.
			 Для К5:
			 Параметр 15 - отправлено по GPRS IP1(основной) (0 - нет, 1 - да);
			 Параметр 16 - отправлено по GPRS IP2(резервный) (0 - нет, 1 - да);
			 
			 Для РТ1(РТ3):
			 Параметр 15 - отправлено по GPRS IP1(основной) (0 - нет, 1 - да, по SIM1, 2 - да, по SIM2);
			 Параметр 16 - отправлено по GPRS IP2(резервный) (0 - нет, 1 - да, по SIM1, 2 - да, по SIM2);					*/
			
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					if (re[13] == 1)
						s = "LAN";
					if (re[14] == 1) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS IP1";
					}
					if (re[15] == 1) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS IP2";
					}
					break;
				case DS.K5RT1:
				case DS.K5RT13G:
				case DS.K5RT1L:
				case DS.K5RT3:
				case DS.K5RT3L:
				case DS.K5RT33G:
					if (re[13] == 1)
						s = "LAN";
					if (re[14] != 0) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS SIM" + ( re[14]  ) + " IP1";
					}
					if (re[15] != 0) {
						if (s.length > 0)
							s += ", ";
						s += "GPRS SIM" + ( re[15] ) + " IP2";
					}
					break;
			}	
			
			
			var bitfield:int = re[16];
			
			
			var color:uint;
			//if (bitfield != 0xff) {
			if (s.length == 0) {
				if (s.length > 0)
					s += ", ";
				for (var i:int=0; i<8; i++) {
					
					color = ( bitfield & (1 << i)) == 0 ?COLOR.GREEN:COLOR.RED_BLOOD;
					if( ( DS.alias == DS.K5 || DS.alias == DS.K5GL || DS.isDevice(DS.K53G) ) && UIHistoryExt.K5_ACTIVE_CHANELS[ i ] == 0 ) color = COLOR.GREY_GLOBAL_OUTLINE;
					else if ( DS.isfam( DS.K5RT3 ) && UIHistoryExt.K5_ACTIVE_CHANELS[ i ][ 5 ] == 0 ) color = COLOR.GREY_GLOBAL_OUTLINE;
					//if( DEVICES.isFamily( DEVICES.K5 ) && UIHistoryExt.K5_ACTIVE_CHANELS[ i ] == 0 ) color = COLOR.GREY_GLOBAL_OUTLINE;
					
					
					s += UTIL.wrapHtml( (i+1).toString(), color, 12, true );
				}
			}
		//	s = "LAN, GPRS SIM1, GPRS SIM1, 12345678";
			getField(operatingCMD,11).setCellInfo( s );
			
			
		}
		public static function getEmulatedvisualizeBitfield(bit:int,msgflag:int):Array
		{
			
			var chanstring:String = visualizeBitfield(bit,msgflag);
			return [chanstring.replace(/<[^>]*>/g, "" ), colormap.slice()];
		}
		
		private static function visualizeBitfield(bit:int,msgflag:int):String
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
			if (msgflag == 0xff) {
				line += "<font color='#ED1C24'><b>!</b></font>";
				colormap.push( "ED1C24" );
			}
			
			return line + "</font>";
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