package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.static.DS;
	
	public class UIWifiMenu extends UI_BaseComponent
	{
		public static const S_WIFI_INFO:int=1;
		public static const S_WIFI_MONITOR:int=2;
		public static const S_WIFI_CONNECT:int=3;
		public static const S_WIFI_AP:int=4;

		private var uiWifiInfo:UIWifiInfo;
		private var uiWiFiAp:UIWifiAp;
		private var uiWiFiConnect:UIWiFiConnect;
		private var uiWiFiMonitor:UIWifiMonitor;
		
		private var uis:Vector.<UI_BaseComponent>;
		private var ui:UI_BaseComponent;
		
		public function UIWifiMenu()
		{
			super();
			
			uis = new Vector.<UI_BaseComponent>;
			
			initNavi();
			navi.setUp( onChoose, 10 );
			
			if (DS.isVgr) {
				if (DS.release > 28 ) { 
					navi.addButton( loc("ui_wifi_info"), S_WIFI_INFO, TabOperator.GROUP_BUTTONS + S_WIFI_INFO*1000 );
					navi.addButton( loc("ui_wifi_net_monitor"), S_WIFI_MONITOR, TabOperator.GROUP_BUTTONS + S_WIFI_MONITOR*1000 );
					navi.addButton( loc("ui_wifi_connect_net"), S_WIFI_CONNECT, TabOperator.GROUP_BUTTONS + S_WIFI_CONNECT*1000 );
				}
				navi.addButton( loc("ui_wifi_ap"), S_WIFI_AP, TabOperator.GROUP_BUTTONS + S_WIFI_AP*1000 );
			} else {
				navi.addButton( loc("ui_wifi_info"), S_WIFI_INFO, TabOperator.GROUP_BUTTONS + S_WIFI_INFO*1000 );
				navi.addButton( loc("ui_wifi_net_monitor"), S_WIFI_MONITOR, TabOperator.GROUP_BUTTONS + S_WIFI_MONITOR*1000 );
				navi.addButton( loc("ui_wifi_connect_net"), S_WIFI_CONNECT, TabOperator.GROUP_BUTTONS + S_WIFI_CONNECT*1000 );
				navi.addButton( loc("ui_wifi_ap"), S_WIFI_AP, TabOperator.GROUP_BUTTONS + S_WIFI_AP*1000 );
			}
		}
		override public function open():void
		{
			super.open();
			loadComplete();
			if ( navi.selection > -1 )
				onChoose( navi.selection );
		}
		override public function close():void
		{
			super.close();
			
			if (ui)
				ui.close();
			ui = null;
		}
		private function onChoose(n:Number):void
		{
			if( ui )
				ui.close();
			
			switch(n) {
				case S_WIFI_INFO:
					if (!uiWifiInfo) {
						uiWifiInfo = new UIWifiInfo;
						addChild( uiWifiInfo );
						height = 520;
						width = 450;
						uis.push( uiWifiInfo );
					}
					ui = uiWifiInfo;
					break;
				case S_WIFI_AP:
					if (!uiWiFiAp) {
						uiWiFiAp = new UIWifiAp;
						addChild( uiWiFiAp );
						height = 520;
						width = 450;
						uis.push( uiWiFiAp );
					}
					ui = uiWiFiAp;
					break;
				case S_WIFI_MONITOR:
					if (!uiWiFiMonitor) {
						uiWiFiMonitor = new UIWifiMonitor(gotoConnect);
						//дописать передачу функции управляющей меню и передающей информацию
						addChild( uiWiFiMonitor );
						height = 200;
						width = 675;
						uis.push( uiWiFiMonitor );
					}
					ui = uiWiFiMonitor;
					break;
				case S_WIFI_CONNECT:
					if (!uiWiFiConnect) {
						uiWiFiConnect = new UIWiFiConnect;
						addChild( uiWiFiConnect );
						height = 520;
						width = 450;
						uis.push( uiWiFiConnect );
					}
					ui = uiWiFiConnect;
					break;
			}
			if (ui)
				ui.open();
			visualize( ui );
			
		}
		private function gotoConnect(ssid:String):void
		{
			navi.selection = S_WIFI_CONNECT;
			onChoose(S_WIFI_CONNECT);
			(ui as UIWiFiConnect).fillFirstWifi(ssid);
		}
		private function visualize(ui:UI_BaseComponent):void
		{
			var len:int = uis.length;
			for (var i:int=0; i<len; i++) {
				uis[i].visible = uis[i] == ui;
			}
		}
	}
}