package components.screens.opt
{
	/** Специальная версия для K2	*/ 
	
	import components.abstract.SmsServant;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.CRC16;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIHistory;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	import components.system.CONST;
	import components.system.UTIL;
	
	public class OptHistoryLine extends OptionListBlock
	{
		private var colormapSMS:Vector.<String>;
		private var colormapVoice:Vector.<String>;
		private var isCIDError:Boolean;
		private var CIDlineLength:int;
		private var ALARM:Boolean=false;
		
		public function OptHistoryLine(_struct:int)
		{
			super();
			structureID = _struct;
			operatingCMD = CMD.EVENT_LOG_REC;
			FLAG_VERTICAL_PLACEMENT = false;
			FLAG_SAVABLE = false;
			// Номер п/п
			createUIElement( new FormString,operatingCMD,"",null,1).x = -7;
			attuneElement(80,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI);
			globalX += 80;
			// Номер время
			createUIElement( new FormString,operatingCMD,"",null,2).x = globalX;
			attuneElement(130,NaN,FormString.F_TEXT_MINI);
			globalX += 135;
			// Идентификатор события
			createUIElement( new FormString,operatingCMD,"",null,3).x = globalX;
			attuneElement(490,NaN,FormString.F_TEXT_MINI);
			globalX += 500;
			// Передача по СМС, куда отправили СМС
			createUIElement( new FormString,operatingCMD,"",null,4).x = globalX;
			attuneElement(70,NaN,FormString.F_HTML_TEXT | FormString.F_TEXT_MINI | FormString.F_TEXT_BOLD );
			globalX += 100;
			// Передача по голосовому вызову, куда дозвонились
			createUIElement( new FormString,operatingCMD,"",null,5).x = globalX;
			attuneElement(250,NaN,FormString.F_HTML_TEXT | FormString.F_TEXT_MINI | FormString.F_TEXT_BOLD);
			globalX += 100;
			if (CONST.DEBUG) {
				// CRC16
				createUIElement( new FormString,operatingCMD,"",null,6).x = globalX;
				attuneElement(80,NaN,FormString.F_ALIGN_CENTER | FormString.F_TEXT_MINI );
				width = 1010;
			} else
				width = 930;
		}
		public function getHeaderDimensions():Object
		{
			var obj:Object = new Object;
			for(var i:int=0; i<6; ++i ) {
				obj[i] = 10 + (getField(operatingCMD,i+1) as FormString).x
			}
			return obj;
		}
		override public function putRawData(re:Array):void
		{
			if (re && re[0] == "header") {
				getField(operatingCMD,1).setCellInfo(loc("his_exp_index"));
				getField(operatingCMD,2).setCellInfo(loc("his_event_time"));
				getField(operatingCMD,3).setCellInfo(loc("his_event"));
				getField(operatingCMD,4).setCellInfo(loc("his_sms"));
				getField(operatingCMD,5).setCellInfo(loc("k2_history_voice"));
				var headerlen:int = 5;
				if (CONST.DEBUG) {
					getField(operatingCMD,6).setCellInfo(loc("his_exp_crc_error"));
					headerlen++;
				}
				
				//(getField(operatingCMD,i+1) as FormString).attune( FormString.F_MULTYLINE | FormString.F_TEXT_BOLD | FormString.F_TEXT_MINI );
				for(var i:int=0; i<headerlen; ++i ) {
					(getField(operatingCMD,i+1) as FormString).attune( FormString.F_TEXT_BOLD | FormString.F_TEXT_MINI );
				}
				return;
			}
			
			/**	Команда EVENT_LOG_REC - Журнал событий, записи в журнале событий записываются по кругу от младшего индекса к старшему.
				Параметр 1 - Уникальный номер записи, по возрастанию, каждый номер новой записи увеличивается на 1. (1 - 4 294 967 295). */
			
			// Номер п/п
			//getField(operatingCMD,1).setCellInfo(re[0]);
			//var numpp:Array = re.splice(21,1);
			getField(operatingCMD,1).setCellInfo(re[re.length-1]);
			
			/**	Параметр 2 - Дата - 1-31 ( возможно нулевое значение, если дата/время отсутствуют) (BCD);
				Параметр 3 - Месяц - 1-12 ( возможно нулевое значение, если дата/время отсутствуют) (BCD);
				Параметр 4 - Год - 00-99 ( 00 - 2000г., 01 - 2001г. ) (BCD);
				Параметр 5 - Часы - 0-23 (BCD);
				Параметр 6 - Минуты - 0-59 (BCD);
				Параметр 7 - Секунды - 0-59 (BCD);	*/
			
			// Номер время
			getField(operatingCMD,2).setCellInfo( UTIL.formateZerosInFront(re[1].toString(16),2)+"."+ UTIL.formateZerosInFront(re[2].toString(16),2)+ ".20" +UTIL.formateZerosInFront(re[3].toString(16),2)
				+ " " + UTIL.formateZerosInFront(re[4].toString(16),2) + ":"+UTIL.formateZerosInFront(re[5].toString(16),2) + ":"+UTIL.formateZerosInFront(re[6].toString(16),2));
			// 16.09.2011 17:27:22
			
			/**	Параметр 8 - Идентификатор события - Номер СМС из страницы настройка СМС, начинается с 0;*/
			
			// Идентификатор события
			var a:Array = OPERATOR.dataModel.getData( CMD.SMS_TEXT_K2 );
			var s:String = OPERATOR.dataModel.getData( CMD.SMS_TEXT_K2 )[re[7]];
				
			getField(operatingCMD,3).setCellInfo( SmsServant.adaptForHistory( OPERATOR.dataModel.getData( CMD.SMS_TEXT_K2 )[re[7]] ) );
			
			switch( re[7] ) {
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
				case 10:
					ALARM = true;
					color_dark = COLOR.HISTORY_RED_DARK;
					color_light = COLOR.HISTORY_RED_LIGHT;
					break;
				/*case 1:
					color_dark = COLOR.HISTORY_BLUE_DARK;
					color_light = COLOR.HISTORY_BLUE_LIGHT;
					break;
				case 8:
					color_dark = COLOR.HISTORY_YELLOW_DARK;
					color_light = COLOR.HISTORY_YELLOW_LIGHT;
					break;*/
				default:
					color_light = COLOR.HISTORY_GREY_DARK;
					color_dark = COLOR.HISTORY_GREY_LIGHT;
			}

			/**	Параметр 9 - Резерв
				Параметр 10 - Передача по СМС, куда отправили СМС ( 8бит - 8 номеров ) в расчете КС не участвует */
			getField(operatingCMD,4).setCellInfo( visualizeBitfield( re[9],true ));
			
			/**	Параметр 11 - Передача по голосовому вызову, куда дозвонились ( 8бит - 8 номеров ) в расчете КС не участвует	*/
			getField(operatingCMD,5).setCellInfo( visualizeBitfield( re[10],false ));
			
			/**	Параметр 12 - Контрольная сумма всей записи CRC16, полином: x^16 + x^15 + x^2 + 1 (0xa001) в расчете КС участвуют параметры с 1 по 9 включительно.	 */
			if (CONST.DEBUG)
				getField(operatingCMD,6).setCellInfo( calcCRC16(re) );
		}
		private function calcCRC16(re:Array):String
		{
			var param:String="";
			var cmd:CommandSchemaModel = OPERATOR.getSchema( CMD.EVENT_LOG_REC );
			var ps:ParameterSchemaModel
			var bytes:Array = new Array;
			for( param in cmd.Parameters ) {
				ps = cmd.Parameters[param] as ParameterSchemaModel;
				if(ps.Order < 10) {
					var mask:uint = 0xFF;
					for(var i:int=0; i<ps.Length; ++i ) {
						mask = 0xFF << i*8;
						bytes.push( (re[param] & mask) >> i*8 );
					}
				}
			}
			var crc16:int = CRC16.calculate( bytes, bytes.length );
			if( crc16 == re[11] )
				return loc("g_no");
			else
				return loc("g_yes");
		}
		private function visualizeBitfield(bit:int, sms:Boolean):String
		{
			var colormap:Vector.<String> = new Vector.<String>;
			var line:String="";
			var bitfield:int;
			if( ALARM ) {
				if (sms)
					bitfield = UIHistory.NOTIFY_LIST_SMS_ALARM;
				else
					bitfield = UIHistory.NOTIFY_LIST_VOICE_ALARM;
			} else {
				if (sms)
					bitfield = UIHistory.NOTIFY_LIST_SMS_EVENT;
				else
					bitfield = 0;
			}
			var color:String;
			for(var i:int=0; i<8; ++i ) {
				
				if ( (bitfield & (1<<i)) > 0 ) {
					if ( (bit & (1 << i)) == 0 ) {
						color = UTIL.formateZerosInFront(COLOR.GREEN_SIGNAL.toString(16),6);
						line += "<font face='"+PAGE.MAIN_FONT+"' size='11' color='#"+color+"'>"+(i+1)+"</font>";
					} else {
						color = COLOR.RED.toString(16);
						line += "<font face='"+PAGE.MAIN_FONT+"' size='11' color='#"+color+"'>"+(i+1)+"</font>";
					}
				} else {
					color = COLOR.LIGHT_GREY.toString(16);
					line += "<font face='"+PAGE.MAIN_FONT+"' size='11' color='#"+color+"'>"+(i+1)+"</font>";
				}
				colormap.push( color );
			}
			if (sms)
				colormapSMS = colormap;
			else
				colormapVoice = colormap;
			return line;
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
			
			var a:Array = [ 
				getField(operatingCMD,1).getCellInfo(),
				getField(operatingCMD,2).getCellInfo(),
				getField(operatingCMD,3).getCellInfo(),
				[getField(operatingCMD,4).getCellInfo(),colormapSMS],
				[getField(operatingCMD,5).getCellInfo(),colormapVoice],
			];
			
			if (CONST.DEBUG)
				a.push( getField(operatingCMD,6).getCellInfo() );
			
			return a;
		}
	}
}