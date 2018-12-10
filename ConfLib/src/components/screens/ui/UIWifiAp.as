package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIWifiAp extends UI_BaseComponent implements IWidget
	{
		private var fsPass:IFormString;
		private var fsPassCheck:IFormString;
		private var tClients:SimpleTextField;
		private var task:ITask;
		private var title:SimpleTextField;
		private var wasresponse:Boolean;
		private var msg:String;
		private var connectedClients:Array;
		
		public function UIWifiAp()
		{
			super();
			
			toplevel = false;

			/**"Команда ESP_POINT_SETTINGS - установка настроек точки доступа.

			Параметр 1 - для Вояджер 2N: 0-точка доступа выключена, 1-только при движении, 2-только при заведенном двигателе, 3-при движении или заведенном двигателе, 4-при движении и заведенном двигателе, 5 - включена всегда, 6 - до сигнала подтверждения от пользователя, 7- только для конфигурации
			Параметр 1 - для Контакт-14 : 0-точка доступа выключена,  5 - включена всегда, 7-только для конфигурации
			Параметр 2 - МАС адрес точки доступа
			Параметр 3 - IP адрес точки доступа
			Параметр 4 - SSID точки доступа
			Параметр 5 - Безопасность 0-OPEN, 3-WPA2
			Параметр 6 - пароль
			Параметр 7 - канал 1..12
			Параметр 8 - органичить время работы точки доступа в мин, 1..255, 0-нет ограничения"													
			 * */
			
			title = new SimpleTextField("",400);
			addChild( title );
			title.setSimpleFormat("left", 0, 16, true );
			title.height = 40;
			title.textColor = COLOR.MENU_ITEM_BLUE;
			title.x = globalX;
			title.y = globalY;
			globalY += 40;
			
			var list:Array;
			if (DS.isVoyager())
				list = UTIL.getComboBoxList([[0,loc("ui_wifi_ap_disabled")],[1,loc("ui_wifi_while_moving")],
					[2,loc("ui_wifi_when_engine_working")],[3,loc("ui_wifi_when_moving_or_engine_working")],[4,loc("ui_wifi_when_moving_and_engine_working")],
					[5,loc("ui_wifi_always_on")]//,[6,"до сигнала подтверждения от пользователя"],[7,"только для конфигурации"]
				]);
			else
				list = UTIL.getComboBoxList([[0,loc("ui_wifi_ap_disabled")],[5,loc("ui_wifi_always_on")]]);
			
			var security:Array = UTIL.getComboBoxList( [[0,"OPEN"],[3,"WPA2"]] );
			var worktime:Array = UTIL.getComboBoxList( [[0,loc("ui_wifi_no_limit")],[10,"10"],[60,"60"],[120,"120"]] );
			
			var globalw:int = 170;
			var shift:int = 230;
			
			if (DS.isK14s) {
				addui( new FSShadow, CMD.ESP_POINT_SETTINGS,"", null, 1, list );
			} else {
				addui( new FSComboBox, CMD.ESP_POINT_SETTINGS, loc("ui_wifi_turnon_ap"), null, 1, list );
				attuneElement( shift, globalw, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			}
			addui( new FSSimple, CMD.ESP_POINT_SETTINGS, loc("ui_wifi_mac"), null, 2, null, "A-Fa-f0-9:", 20 );
			attuneElement( shift, globalw, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX);
			addui( new FSSimple, CMD.ESP_POINT_SETTINGS, loc("ui_wifi_ip"), null, 3, null, "0-9.", 20 );
			attuneElement( shift, globalw, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX);
			
			addui( new FSSimple, CMD.ESP_POINT_SETTINGS, loc("ui_wifi_ssid"), null, 4, null, "", 20 );
			attuneElement( shift, globalw, FSSimple.F_CELL_ALIGN_LEFT );
			addui( new FSComboBox, CMD.ESP_POINT_SETTINGS, loc("ui_wifi_security"), onSecurity, 5, security );
			attuneElement( shift, globalw, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			fsPass = addui( new FSSimple, CMD.ESP_POINT_SETTINGS, loc("g_pass"), null, 6, null, "A-z0-9\"#$%&\'()*+,-./:;<=>?|{}`[]\\", 20 ); 
			attuneElement( shift, globalw, FSSimple.F_CELL_ALIGN_LEFT );
			FLAG_SAVABLE = false;
			fsPassCheck = addui( new FSCheckBox, 0, loc("g_show_pass"), onShowPass, 1 );
			attuneElement( globalw + 188 + 30 );
			FLAG_SAVABLE = true;
			addui( new FSComboBox, CMD.ESP_POINT_SETTINGS, loc("ui_wifi_ch"), null, 7, UTIL.comboBoxNumericDataGenerator(1,12) );
			attuneElement( shift, globalw, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			
			addui( new FSShadow, CMD.ESP_POINT_SETTINGS, "", null, 8 );
			/*addui( new FSComboBox, CMD.ESP_POINT_SETTINGS, "Ограничить время работы, мин", null, 8, worktime, "0-9", 3, new RegExp(RegExpCollection.REF_0to255)  );
			attuneElement( shift, globalw );*/
			
			drawSeparator(500-110+50);
			
			tClients = new SimpleTextField("",300);
			addChild(tClients);
			tClients.x = globalX;
			tClients.y = globalY;
			tClients.height = 200;
			
			starterCMD = CMD.ESP_POINT_SETTINGS;
		}
		override public function open():void
		{
			super.open();
			SavePerformer.trigger({after:after});
			WidgetMaster.access().registerWidget(CMD.ESP_POINT_CLIENT_LIST,this);
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.ESP_POINT_CLIENT_LIST:
					/*wasresponse = true;
					if (!msg)
						msg = loc("ui_wifi_connected_clients")+":\r\r"
					var len:int = p.length;
					for (var i:int=0; i<len; i++) {
						if( p.getStructure(i+1)[1] != "0.0.0.0,00:00:00:00:00:00" )
							msg += String(p.getStructure(i+1)[1]).replace(",",", ") + "\r";
					}
					tClients.text = msg;
					tClients.height = tClients.textHeight + 10;
					
					*/
					
					
					if (!wasresponse) {
						connectedClients = new Array;
						wasresponse = true;
					}
					
					var len:int = p.length;
					for (var i:int=0; i<len; i++) {
						if( p.getStructure(i+1)[1] != "0.0.0.0,00:00:00:00:00:00" )
							connectedClients[int(p.getStructure(i+1)[0])-1] = String(p.getStructure(i+1)[1]).replace(",",", ") + "\r";
					}
					
					if (connectedClients.length > 0) {
						msg = loc("ui_wifi_connected_clients")+":\r\r";
						len = connectedClients.length;
						for (i=0; i<len; i++) {
							msg += String(connectedClients[i]).replace(",",", ") + "\r";
						}
					} else
						msg = "";
					
					tClients.text = msg;
					tClients.height = tClients.textHeight + 10;
							
							
					break;
				case CMD.ESP_POINT_SETTINGS:
					fsPassCheck.setCellInfo( 0 );
					onShowPass();
					distribute( p.getStructure(), p.cmd );
					onSecurity(null);
					title.text = p.getStructure()[3];
					loadComplete();
					getClientCount();
					break;
			}
		}
		private function onSecurity(t:IFormString):void
		{
			var f:IFormString = getField(CMD.ESP_POINT_SETTINGS,5);
			if( int(f.getCellInfo()) == 0)
				(fsPass as FSSimple).rule = null;
			else
				(fsPass as FSSimple).rule = new RegExp(RegExpCollection.COMPLETE_ATLEST8SYMBOL);
			if (t)
				remember(t);
		}
		private function onShowPass():void
		{
			(fsPass as FSSimple).displayAsPassword( fsPassCheck.getCellInfo() == 0 );
		}
//		private function onRevert():void
//		{
//			RequestAssembler.getInstance().fireEvent( new Request(CMD.ESP_POINT_MANUFACTURE,onManufacture));
//		}
		private function onManufacture(p:Package):void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.ESP_POINT_SETTINGS, put, 1, p.data[0]));
		}
		
		private function getClientCount(p:Package=null):void
		{
			if (!task)
				task = TaskManager.callLater( getClientCount, TaskManager.DELAY_1SEC * 20 );
			else
				task.repeat();
			msg = null;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.ESP_GET_POINT_CLIENTS, null, 1, [1] ));
			if (!wasresponse) {
				tClients.text = "";
				tClients.height = tClients.textHeight + 10;
			}
			wasresponse = false;
		}
		private function after():void
		{
			title.text = String(getField(CMD.ESP_POINT_SETTINGS,4).getCellInfo());
		}
	}
}