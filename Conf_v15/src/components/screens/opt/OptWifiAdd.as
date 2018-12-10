package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IFormString;
	import components.screens.ui.UIWifi;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class OptWifiAdd extends OptionsBlock
	{
		private var cbPass:IFormString;
		
		public function OptWifiAdd()
		{
			super();
			
			operatingCMD = CMD.WIFI_NETS_CHANGE;
			
			globalX = 0;
			
			var shift:int = 300;
			
			/**
			 	"Команда WIFI_NETS_CHANGE - добавить/удалить сеть WIFI

				Параметр 1 - Добавление сети в прибор, 0 - удалить сеть из прибора , 1- добавить сеть в прибор ( изменить настройки сети, которая уже есть в приборе )
				Параметр 2 - Разрешено подключаться к сети, 0 - нет, 1 - да;
				Параметр 3 - SSID; ( Имя сети, которую хотим удалить или добавить. );
				Параметр 4 - Безопасность (0 - открытая сеть, 1 - WEP, 2 - WPA2-PSK AES )
				Параметр 5 - Пароль;"													
 			**/
			
			createUIElement( new FSShadow, operatingCMD, "1", null, 1 );
			
			createUIElement( new FSCheckBox, operatingCMD, loc("wifi_allow_conn"), null, 2 );
			attuneElement( shift + 89 );
			
			createUIElement( new FSSimple, operatingCMD, "SSID", null, 3, null, "_`{}|~A-z0-9 !\"#$%&'()*+,-./:;<=>?@[\\]^", 32 );
			attuneElement( shift, 300 );
			
			var secur:Array = UTIL.getComboBoxList( UIWifi.WIFI_SECURITY_CB );
			createUIElement( new FSComboBox, operatingCMD, loc("ui_wifi_security"), onSecur,4,secur);
			attuneElement( shift, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			FLAG_SAVABLE = false;
			FLAG_VERTICAL_PLACEMENT = false;
			cbPass = addui( new FSCheckBox, 0, loc("g_show_pass"), onPass, 1 );
			attuneElement( 140 );
			(cbPass as FormEmpty).x = 410;
			FLAG_SAVABLE = true;
			FLAG_VERTICAL_PLACEMENT = true;
			
			createUIElement( new FSSimple, operatingCMD, loc("g_pass"), null, 5, null, "_`{}|~A-z0-9 !\"#$%&'()*+,-./:;<=>?@[\\]^", 32 );
			attuneElement( shift );
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if (value) {
				
				refreshCells( operatingCMD );
				
				cbPass.setCellInfo(0);
				onPass();
				
				getField( operatingCMD, 2).setCellInfo( "" );
				getField( operatingCMD, 3).setCellInfo( "" );
				getField( operatingCMD, 4).setCellInfo( "0" );
				getField( operatingCMD, 5).setCellInfo( "" );
				
				onSecur();
			}
		}
		override public function putRawData(a:Array):void
		{
			refreshCells( operatingCMD );
			
			cbPass.setCellInfo(0);
			onPass();
			
			getField( operatingCMD, 2).setCellInfo( 1 );
			getField( operatingCMD, 3).setCellInfo( a[0] );
			getField( operatingCMD, 4).setCellInfo( a[1] );
			getField( operatingCMD, 5).setCellInfo( a[2] == null ? "":a[2] );
			
			onSecur();
			
			remember( getField( operatingCMD, 2) );
		}
		private function onSecur(t:IFormString=null):void
		{
			getField( operatingCMD, 5).disabled = int(getField( operatingCMD, 4).getCellInfo())==0;
			cbPass.visible = int(getField( operatingCMD, 4).getCellInfo())!=0;
			
			if (t)
				remember(t);
		}
		private function onPass():void
		{
			(getField( operatingCMD, 5) as FSSimple).displayAsPassword( cbPass.getCellInfo() == 0 );
		}
	}
}