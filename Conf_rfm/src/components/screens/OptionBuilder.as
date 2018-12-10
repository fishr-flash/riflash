package components.screens
{
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIAddress;
	import components.screens.ui.UIAlarmKeys;
	import components.screens.ui.UIAlarmKeysII;
	import components.screens.ui.UIControlDevice;
	import components.screens.ui.UIEncryption;
	import components.screens.ui.UILog;
	import components.screens.ui.UILogLR;
	import components.screens.ui.UIMap;
	import components.screens.ui.UIOutMenu;
	import components.screens.ui.UIOutMenuLoRa;
	import components.screens.ui.UIOutMenuRdk;
	import components.screens.ui.UIRFSysLoRa;
	import components.screens.ui.UIRFSystem;
	import components.screens.ui.UIRFSystemMRR1;
	import components.screens.ui.UIRelayMenu;
	import components.screens.ui.UIRfMap;
	import components.screens.ui.UIRfSensor;
	import components.screens.ui.UIRfTrinket;
	import components.screens.ui.UISensors;
	import components.screens.ui.UIServer;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIVerInfoLoRa;
	import components.screens.ui.UIVerInfoR10;
	import components.screens.ui.UIVerInfoRdk;
	import components.screens.ui.UIWifiMenu;
	import components.static.DS;
	import components.static.NAVI;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiVerinfo:UIVerInfo;
		private var uiWIfiMenu:UIWifiMenu;
		private var uiService:UIServiceLocal;
		private var uiEncryption:UIEncryption;
		private var uiControlDevice:UIControlDevice;
		private var uiOutMenu:UIOutMenu;
		private var uiOutMenuLoRa:UIOutMenuLoRa;
		private var uiUpdate:UIUpdate;
		private var uiServer:UIServer;
		private var uiSensors:UISensors;
		private var uiMap:UIMap;
		// RDK
		private var uiVerinfoRdk:UIVerInfoRdk;
		private var uiRfSystem:UIRFSystem;
		private var uiRfSystemMRR1:UIRFSystemMRR1;
		private var uiRfSensor:UIRfSensor;
		private var uiRfMap:UIRfMap;
		private var uiRfTrinket:UIRfTrinket;
		private var uiLog:UILog;
		private var uiOutMenuRdk:UIOutMenuRdk;
		// R10 RELAY
		private var uiVerinfoR10:UIVerInfoR10;
		private var uiAddress:UIAddress;
		private var uiRelay:UIRelayMenu;

		private var uiVerinfoLoRa:UIVerInfoLoRa;
		private var uiRfSysLoRa:UIRFSysLoRa;
		private var uiLogLR:UILogLR;
		private var uiAlarmKeys:UIAlarmKeys;
		
		public function OptionBuilder(c:Canvas, sm:Canvas)
		{
			container = c; 
			subMenuContainer = sm;
		}
		public function initProcess( cmd:int ):void 
		{
			ui = null;
		
			
			switch( cmd ) {
				
				case NAVI.VER_INFO:
				
					switch(DS.alias) {
						
						case DS.RDK_LR:
							
							if( !uiVerinfoLoRa )
									uiVerinfoLoRa = new UIVerInfoLoRa;
							ui = uiVerinfoLoRa;
							
							break;
						case DS.M_RR1:
							
							
						case DS.RDK:
							if ( !uiVerinfoRdk )
								uiVerinfoRdk = new UIVerInfoRdk;
							ui = uiVerinfoRdk;
							break;
						case DS.R10:
						case DS.A_REL:
							if ( !uiVerinfoR10 )
								uiVerinfoR10 = new UIVerInfoR10;
							ui = uiVerinfoR10;
							break;
						default:
							if ( !uiVerinfo )
								uiVerinfo = new UIVerInfo;
							ui = uiVerinfo;
							break;
					}
					break;
				case NAVI.OUT:
					if (DS.isDevice(DS.RDK) ) { 
						if ( !uiOutMenuRdk )
							uiOutMenuRdk = new UIOutMenuRdk;
						ui = uiOutMenuRdk;
					}else if ( DS.isDevice( DS.RDK_LR ) ){
						if ( !uiOutMenuLoRa )
							uiOutMenuLoRa = new UIOutMenuLoRa;
						ui = uiOutMenuLoRa;
					
					} else {
						if ( !uiOutMenu )
							uiOutMenu = new UIOutMenu;
						ui = uiOutMenu;						
					}
					break;
				case NAVI.CONNECT_SERVER:
					if ( !uiServer )
						uiServer = new UIServer;
					ui = uiServer;
					break;
				case NAVI.CONTROL_DEVICE:
					if ( !uiControlDevice )
						uiControlDevice = new UIControlDevice;
					ui = uiControlDevice;
					break;
				case NAVI.PARAMS_WIFI:
					if ( !uiWIfiMenu )
						uiWIfiMenu = new UIWifiMenu;
					ui = uiWIfiMenu;
					break;
				case NAVI.UPDATE:
					if ( !uiUpdate )
						uiUpdate = new UIUpdate;
					ui = uiUpdate;
					break;
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIServiceLocal;
					ui = uiService;
					break;
				case NAVI.ENCRYPTION:
					if ( !uiEncryption )
						uiEncryption = new UIEncryption;
					ui = uiEncryption;
					break;
				case NAVI.SENSOR:
					if ( !uiSensors )
						uiSensors = new UISensors;
					ui = uiSensors;
					break;
				case NAVI.MAP:
					if ( !uiMap )
						uiMap = new UIMap;
					ui = uiMap;
					break;
				/* RDK	*******************************/
				case NAVI.RF_SYSTEM:
					
					
					if( DS.isDevice( DS.RDK_LR ) )
					{
						if ( !uiRfSysLoRa )
							uiRfSysLoRa = new UIRFSysLoRa;
						ui = uiRfSysLoRa;
					}
					else if( DS.isDevice( DS.M_RR1 ) )
					{
						
						if( !uiRfSystemMRR1 )
							uiRfSystemMRR1 = new UIRFSystemMRR1;
						ui = uiRfSystemMRR1
					}
					else 
					{
						if ( !uiRfSystem )
							uiRfSystem = new UIRFSystem;
						ui = uiRfSystem;
					}
						
					break;
				case NAVI.RF_SENSOR:
					if ( !uiRfSensor )
						uiRfSensor = new UIRfSensor;
					ui = uiRfSensor;
					break;
				case NAVI.RF_MAP:
					if ( !uiRfMap )
						uiRfMap = new UIRfMap;
					ui = uiRfMap;
					break;
				case NAVI.RF_RCTRL:
					if ( !uiRfTrinket )
						uiRfTrinket = new UIRfTrinket;
					ui = uiRfTrinket;
					break;
				case NAVI.HISTORY:
					if( DS.isDevice( DS.RDK ) )
					{
						if ( !uiLog )
							uiLog = new UILog;
						ui = uiLog;
					}
					else if( DS.isDevice( DS.RDK_LR ) )
					{
						if ( !uiLogLR )
							uiLogLR = new UILogLR;
						ui = uiLogLR;
					}
					
					break;
				/* R10 Relay **************************/
				case NAVI.ADDRESS:
					if ( !uiAddress )
						uiAddress = new UIAddress;
					ui = uiAddress;
					break;
				case NAVI.DATA_RELE:
					if ( !uiRelay )
						uiRelay = new UIRelayMenu;
					ui = uiRelay;
					break;
				case NAVI.ALARM_KEY:
					if ( !uiAlarmKeys )
						uiAlarmKeys = new UIAlarmKeys;
					ui = uiAlarmKeys;
					break;
			}
			
			if(ui) {
				container.addChild( ui );
				ui.open();
			}
		}
		public function hideAllUI():void 
		{
			var comp:UI_BaseComponent;
			while( container.numChildren > 0) {
				comp = container.getChildAt(0) as UI_BaseComponent;
				comp.close();
				container.removeChild(comp);
			}
		}
		public static function get subMenuContainer():Canvas
		{
			return subMenuContainer;
		}
	}
}