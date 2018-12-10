package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboImageBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.static.GuiLib;
	import components.system.SavePerformer;
	
	public class OptSms_Param extends OptionsBlock
	{
		private var cbList:Vector.<FSComboBox>;
		
		public function OptSms_Param()
		{
			super();
			/**
			Команда SMS_PARAM
			Параметр 1 - Отправлять SMS сообщения транслитом (0x00 - сброшено, 0x01 - установлено);
			Параметр 2 - Обрезать текст SMS сообщения, если его длина превышает одно SMS (0x00 - сброшено, 0x01 - установлено);
			Параметр 3 - Расстановка полей,
				(0x00 - не отправлять, 0x01 - Текст события, 0x02 - Раздел, 0x03 - Зона/Брелок/Пользователь);
			Параметр 4 - Расстановка полей,
				(0x00 - не отправлять, 0x01 - Текст события, 0x02 - Раздел, 0x03 - Зона/Брелок/Пользователь);
			Параметр 5 - Расстановка полей,
				(0x00 - не отправлять, 0x01 - Текст события, 0x02 - Раздел, 0x03 - Зона/Брелок/Пользователь);
			Параметр 6 - Разделитель между полями (разделитель для удобства чтения документа взят в [],
				(0x00 - [ ], 0x01 - [перевод строки], 0x02 - [.], 0x03 - [,], 0x04 - [/], 0x05 - [-], 0x06 - [*], 0x07 - [:], 0x08 - [;] , 0x09 - [_] ).*/
			
			yshift = 5;
			operatingCMD = CMD.SMS_PARAM;
			createUIElement( new FSCheckBox, operatingCMD, loc("sms_send_translit"), null, 1 );
			attuneElement( 500 );
			createUIElement( new FSCheckBox, operatingCMD, loc("sms_cut_message_if_exceed_one_sms"), null, 2 );
			attuneElement( 500 );
			globalY += 10;
			yshift = 20;
			var sep:Separator = new Separator(617+20);
			addChild( sep );
			sep.y = globalY;
			globalY += 20;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("sms_can_rearange_message_blocks"),null,1);
			attuneElement( 640, NaN, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX);
			//globalY += 10;
			var anchor:int = globalY;
			createUIElement( new FormString, 0, loc("sms_send_message")+":",null,2);
			attuneElement( 90,NaN, FormString.F_MULTYLINE );
			globalX += 95+5+20;
			
			cbList = new Vector.<FSComboBox>;
			
			FLAG_SAVABLE = true;
			var list:Array = [{data:0x00, label:loc("sms_not_send")},{data:0x01,label:loc("sms_event_msg")},{data:0x02,label:loc("g_partition")},{data:0x03,label:loc("sms_zone_trinket_user")}];
			globalY = anchor;
			createUIElement( new FSComboBox, operatingCMD, "", callUnique,3, list );
			attuneElement( 172,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 152+13+9+3;
			globalY = anchor;
			cbList.push( getLastElement() );
			
			createUIElement( new FSComboBox, operatingCMD, "", callUnique,4, list );
			attuneElement( 172,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 152+13+9+3;
			globalY = anchor;
			cbList.push( getLastElement() );
			
			createUIElement( new FSComboBox, operatingCMD, "", callUnique,5, list );
			attuneElement( 163,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			var list_special:Array = [{label:"\u2423",data:0x00, img:GuiLib.symbol_2423},{label:"\u21b2",data:0x01, img:GuiLib.symbol_21b2},
				{label:".",data:0x02, img:GuiLib.symbol_dot},{label:",",data:0x03, img:GuiLib.symbol_comma},
				{label:"\/",data:0x04, img:GuiLib.symbol_slash},{label:"-",data:0x05, img:GuiLib.symbol_minus},
				{label:"*",data:0x06, img:GuiLib.symbol_star},{label:":",data:0x07, img:GuiLib.symbol_comma},
				{label:"_",data:0x09, img:GuiLib.symbol_underline}];
			cbList.push( getLastElement() );
			
			globalX = 0;
			createUIElement( new FSComboImageBox, operatingCMD, loc("sms_use_delim_between_fields"), null, 6, list_special );
			attuneElement( 528+20,89 );
		}
		override public function putRawData(re:Array):void
		{
			getField( operatingCMD, 1 ).setCellInfo( String(re[0]) );
			getField( operatingCMD, 2 ).setCellInfo( String(re[1]) );
			getField( operatingCMD, 3 ).setCellInfo( String(re[2]) );
			getField( operatingCMD, 4 ).setCellInfo( String(re[3]) );
			getField( operatingCMD, 5 ).setCellInfo( String(re[4]) );
			getField( operatingCMD, 6 ).setCellInfo( String(re[5]) );
			
			callUnique(null);
		}
		private function callUnique(t:IFormString):void
		{
			var a:Vector.<FSComboBox> = new Vector.<FSComboBox>;
			if ( t ) {
				a.push(t);
				for (var i:int=0; i<3; ++i) {
					if (cbList[i] != t)
						a.push( cbList[i] );
				}
			} else
				a = cbList;
			var vdata:Array = [0,1,2,3];
			var unique:Boolean;
			var save:Boolean = false;
			for (i=0; i<3; ++i) {
				var len:int = vdata.length;
				unique = false;
				for (var j:int=0; j<len; ++j) {
					var h1:* = a[i].getCellInfo();
					var h2:* = vdata[j];
					
					if ( int(a[i].getCellInfo()) == vdata[j] ) {
						vdata.splice(j,1);
						unique = true;
						break;
					}
											
				}
				if (!unique) {
					a[i].setCellInfo( vdata.splice(0,1)[0] );
					save = true;
				}
			}
			if ( (!t && save) || t )
				SavePerformer.remember(structureID,cbList[0]);
		}
	}
}