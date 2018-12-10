package components.screens
{
	import mx.containers.Canvas;
	
	import components.abstract.BalloonBot;
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIBolidOnline;
	import components.screens.ui.UIC2000Events;
	import components.screens.ui.UICert;
	import components.screens.ui.UIDevicePower;
	import components.screens.ui.UIEnginK;
	import components.screens.ui.UIEnginRT1;
	import components.screens.ui.UIGeneralOptionsK5;
	import components.screens.ui.UIGeneralOptionsK9;
	import components.screens.ui.UIGeneralOptionsRT1;
	import components.screens.ui.UIGuard;
	import components.screens.ui.UIHistoryExt;
	import components.screens.ui.UIKeyboardK5;
	import components.screens.ui.UIKeyboardK9;
	import components.screens.ui.UIKeysTMK5;
	import components.screens.ui.UIKeysTMK9;
	import components.screens.ui.UILinkChannelsK5;
	import components.screens.ui.UILinkChannelsK9;
	import components.screens.ui.UILinkChannelsRT1;
	import components.screens.ui.UILockFromWriters;
	import components.screens.ui.UIMap;
	import components.screens.ui.UINetwork;
	import components.screens.ui.UINetworkStatus;
	import components.screens.ui.UIOutputK5;
	import components.screens.ui.UIOutputK9;
	import components.screens.ui.UIPartitionK5;
	import components.screens.ui.UIPartitionK9;
	import components.screens.ui.UIPhoneLine;
	import components.screens.ui.UIRSim;
	import components.screens.ui.UIRSimK9Sim1;
	import components.screens.ui.UIRSms;
	import components.screens.ui.UIRUserCode;
	import components.screens.ui.UIRWire;
	import components.screens.ui.UIReader;
	import components.screens.ui.UIScreenKeyboard;
	import components.screens.ui.UISensorTemperatureK9;
	import components.screens.ui.UISensorTemperatureV2;
	import components.screens.ui.UIServer;
	import components.screens.ui.UIServerAETH;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UIServiceSimple;
	import components.screens.ui.UISimK9;
	import components.screens.ui.UISimRT1;
	import components.screens.ui.UISysEventsK1;
	import components.screens.ui.UISysEventsRT1;
	import components.screens.ui.UISysEventsUni;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIUpdateK5;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIVerInfoLan;
	import components.screens.ui.UIWireConfigK5;
	import components.screens.ui.UIWireConfigK9;
	import components.screens.ui.UIWireK1;
	import components.screens.ui.UIWireRT1;
	import components.static.DS;
	import components.static.NAVI;
	
	public class OptionBuilder
	{
		
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;
		
		private var uiVerInfo:UIVerInfo;
		private var uiServiceSimple:UIServiceSimple;
		private var uiUpdate:UIUpdate;
		private var uiService:UIServiceLocal;
		private var uirSim:UIRSim;
		private var uirEngin:UIEnginK;
		private var uirSysEvents:UISysEventsUni;
		private var uiGeneralOptions:UIGeneralOptionsK5;
		private var uiPartitionK5:UIPartitionK5;
		private var uirUserCode:UIRUserCode;
		private var uiKeyboardK5:UIKeyboardK5;
		private var uiSms:UIRSms;
		private var uiHistory:UIHistoryExt;
		private var uiRWire:UIRWire;
		private var uiRLinkChannels:UILinkChannelsK5;
		private var uiWireConfigK5:UIWireConfigK5;
		private var uiOutputK5:UIOutputK5;
		private var uiKeysTMK5:UIKeysTMK5;
		private var uiMap:UIMap;
		private var uiCertificate:UICert;
		private var uiReader:UIReader;
		// K-9
		private var uiGeneralOptionsk9:UIGeneralOptionsK9;
		private var uiLinkChannelsk9:UILinkChannelsK9;
		private var uiPartitionK9:UIPartitionK9;
		private var uiScreenKeyboard:UIScreenKeyboard;
		private var uiKeyboardK9:UIKeyboardK9;
		private var uiKeysTMK9:UIKeysTMK9;
		private var uiOutputK9:UIOutputK9;
		private var uiWireConfigK9:UIWireConfigK9;
		private var uirSim1:UIRSimK9Sim1;
		private var uiSimK9:UISimK9;
		// K LAN
		private var uiVerInfoLan:UIVerInfoLan
		private var uiGuard:UIGuard;
		private var uiNetwork:UINetwork;
		private var uiServer:UIServer;
		private var uiNetworkStatus:UINetworkStatus;
		// K5 RT1
		private var uiGeneralOptionsRT1:UIGeneralOptionsRT1;
		private var uirSysEventsRT1:UISysEventsRT1;
		private var uiSimRT1:UISimRT1;
		private var uiLinkChannelsRT1:UILinkChannelsRT1;
		private var uiWireRT1:UIWireRT1;
		private var uiEnginRT1:UIEnginRT1;
		private var uiBolidOnline:UIBolidOnline;
		private var uiC2000Events:UIC2000Events;
		// K1
		private var uiSysEventsK1:UISysEventsK1;
		private var uiWireK1:UIWireK1;
		private var uiLockFromWriters:UILockFromWriters
		

		private var uiSensorTemperature_v:UISensorTemperatureV2;
		private var uiSensorTemperature:UISensorTemperatureK9;
		private var uiPhoneLine:UIPhoneLine;

		private var uiServerAETH:UIServerAETH;
		private var uiDevicePower:UIDevicePower;
		
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
					if( DS.isfam( DS.KLAN ) )
					{
						if ( !uiVerInfoLan )
							uiVerInfoLan = new UIVerInfoLan;
						ui = uiVerInfoLan;
					}
					else
					{
						if ( !uiVerInfo )
							uiVerInfo = new UIVerInfo;
						ui = uiVerInfo;
					}
					break;
				case NAVI.MAP:
					if ( !uiMap )
						uiMap = new UIMap;
					ui = uiMap;
					break;
				case NAVI.TM_READER:
					
					if ( !uiReader)
						uiReader = new UIReader;
					ui = uiReader;
					break;
				case NAVI.CERTIFICATE:
					if ( !uiCertificate )
						uiCertificate = new UICert;
					ui = uiCertificate;
					break;
				case NAVI.TM_KEYS:
					switch(DS.alias) {
						case DS.isfam( DS.K5 ):
							if ( !uiKeysTMK5)
								uiKeysTMK5 = new UIKeysTMK5;
							ui = uiKeysTMK5;
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
								if ( !uiKeysTMK9)
								uiKeysTMK9 = new UIKeysTMK9;
							ui = uiKeysTMK9;
							break;
					}
					break;
				case NAVI.OUT:
					switch(DS.alias) {
						case DS.isfam( DS.K5 ):
							if ( !uiOutputK5)
								uiOutputK5 = new UIOutputK5;
							ui = uiOutputK5;
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9K:
						case DS.K9M:
							if ( !uiOutputK9)
								uiOutputK9 = new UIOutputK9;
							ui = uiOutputK9;
							break;
					}
					break;
				case NAVI.ALARM_WIRE:
					switch(DS.alias) {
						case DS.isfam( DS.K5 ):
							if ( !uiWireConfigK5 )
								uiWireConfigK5 = new UIWireConfigK5;
							ui = uiWireConfigK5;
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
						if ( !uiWireConfigK9 )
								uiWireConfigK9 = new UIWireConfigK9;
							ui = uiWireConfigK9;
							break;
					}
					break
				case NAVI.TEMPERATURE:
					switch(DS.alias) {
						case DS.isfam( DS.K9 ):
							
							if( !uiSensorTemperature )
								uiSensorTemperature = new UISensorTemperatureK9;
							ui = uiSensorTemperature;
							break;
						
						default:
							if( !uiSensorTemperature_v )
								uiSensorTemperature_v = new UISensorTemperatureV2;
							ui = uiSensorTemperature_v;
							
					}
					
					break
				case NAVI.LINK_CHANNELS:
					switch(DS.alias) {
						case DS.isfam( DS.K5 ):
							if ( !uiRLinkChannels )
								uiRLinkChannels = new UILinkChannelsK5;
							ui = uiRLinkChannels;
							break;
						case DS.K1:
						case DS.K1M:
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
						if ( !uiLinkChannelsk9 )
								uiLinkChannelsk9 = new UILinkChannelsK9;
							ui = uiLinkChannelsk9;
							break;
						case DS.K5RT1:
						case DS.K5RT13G:
						case DS.K5RT1L:
						case DS.K5RT3:
						case DS.K5RT3L:
						case DS.K5RT33G:
							if ( !uiLinkChannelsRT1 )
								uiLinkChannelsRT1 = new UILinkChannelsRT1;
							ui = uiLinkChannelsRT1;
							break;
					}
					break
				case NAVI.PHONE_LINE:
					if ( !uiPhoneLine )
						uiPhoneLine = new UIPhoneLine;
					ui = uiPhoneLine;
					break;
				case NAVI.WIRE_OPTIONS:
					switch(DS.alias) {
						case DS.K5RT1:
						case DS.K5RT13G:
						case DS.K5RT1L:
						case DS.K5RT3:
						case DS.K5RT3L:
						case DS.K5RT33G:
							if ( !uiWireRT1 )
								uiWireRT1 = new UIWireRT1;
							ui = uiWireRT1;
							break;
						case DS.K1:
						case DS.K1M:
							if ( !uiWireK1 )
								uiWireK1 = new UIWireK1;
							ui = uiWireK1;
							break;
						default:
							if ( !uiRWire )
								uiRWire = new UIRWire;
							ui = uiRWire;
					}
					break
				case NAVI.HISTORY:
					if ( !uiHistory )
						uiHistory = new UIHistoryExt;
					ui = uiHistory;
					break
				case NAVI.SMS:
					//					switch(DEVICES.alias) {
					//						case DEVICES.K5:
					if ( !uiSms )
						uiSms = new UIRSms;
					ui = uiSms;
					//							break;
					//						case DEVICES.isK9:
					//							if ( !uiSmsK9 )
					//								uiSmsK9 = new UISmsK9;
					//							ui = uiSmsK9;
					//							break;
					//					}
					break
				case NAVI.KEYBOARD:
					switch(DS.alias) {
						case DS.isfam( DS.K5 ):
							if ( !uiKeyboardK5 )
								uiKeyboardK5 = new UIKeyboardK5;
							ui = uiKeyboardK5;
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
							if ( !uiKeyboardK9 )
								uiKeyboardK9 = new UIKeyboardK9;
							ui = uiKeyboardK9;
							break;
					}
					break
				case NAVI.USER_PASS:
					if ( !uirUserCode )
						uirUserCode = new UIRUserCode;
					ui = uirUserCode;
					break
				case NAVI.PARTITION:
					switch(DS.alias) {
						case DS.isfam( DS.K5 ):
							if ( !uiPartitionK5 )
								uiPartitionK5 = new UIPartitionK5;
							ui = uiPartitionK5;
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
							if ( !uiPartitionK9 )
								uiPartitionK9 = new UIPartitionK9;
							ui = uiPartitionK9;
							break;
					}
					break;
				case NAVI.SCREEN_KEYBOARD:
					if ( !uiScreenKeyboard )
						uiScreenKeyboard = new UIScreenKeyboard;
					ui = uiScreenKeyboard;
					break;
				case NAVI.GENERAL_OPTIONS:
					
					
					switch(DS.alias) {
						case DS.isfam( DS.K5 ):
							if ( !uiGeneralOptions )
								uiGeneralOptions = new UIGeneralOptionsK5;
							ui = uiGeneralOptions;
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
						case DS.K1:
						case DS.K1M:
							
							if ( !uiGeneralOptionsk9 )
								uiGeneralOptionsk9 = new UIGeneralOptionsK9;
							ui = uiGeneralOptionsk9;
							break;
						case DS.K5RT1:
						case DS.K5RT13G:
						case DS.K5RT1L:
						case DS.K5RT3:
						case DS.K5RT3L:
						case DS.K5RT33G:
							if ( !uiGeneralOptionsRT1 )
								uiGeneralOptionsRT1 = new UIGeneralOptionsRT1;
							ui = uiGeneralOptionsRT1;
							break;
						
							
					}
					break
				case NAVI.SYS_EVENTS:
					switch(DS.alias) {
						case DS.K5RT1:
						case DS.K5RT13G:
						case DS.K5RT1L:
						case DS.K5RT3:
						case DS.K5RT3L:
						case DS.K5RT33G:
							if ( !uirSysEventsRT1 )
								uirSysEventsRT1 = new UISysEventsRT1;
							ui = uirSysEventsRT1;
							break;
						case DS.K1:
						case DS.K1M:
							if ( !uiSysEventsK1 )
								uiSysEventsK1 = new UISysEventsK1;
							ui = uiSysEventsK1;
							break;
						default:
							if ( !uirSysEvents )
								uirSysEvents = new UISysEventsUni;
							ui = uirSysEvents;
							break;
					}
					break;
				case NAVI.ENGIN_NUMB:
					switch(DS.alias) {
						case DS.K5RT1:
						case DS.K5RT13G:
						case DS.K5RT1L:
						case DS.K5RT3:
						case DS.K5RT3L:
						case DS.K5RT33G:
							if ( !uiEnginRT1 )
								uiEnginRT1 = new UIEnginRT1;
							ui = uiEnginRT1;
							break;
						default:
							if ( !uirEngin )
								uirEngin = new UIEnginK;
							ui = uirEngin;
					}
					break;
				
				case NAVI.GPRS_SIM:
					switch(DS.alias) {
						case DS.K5RT1:
						case DS.K5RT13G:
						case DS.K5RT1L:
						case DS.K5RT3:
						case DS.K5RT3L:
						case DS.K5RT33G:
							if ( !uiSimRT1 )
								uiSimRT1 = new UISimRT1;
							ui = uiSimRT1;
							break;
						case DS.K1:
						case DS.K1M:
							if ( !uirSim1 )
								uirSim1 = new UIRSimK9Sim1;
							ui = uirSim1;
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
							if (int(DS.app)==3) {
								// прибор с 1 симкой
								if ( !uirSim1 )
									uirSim1 = new UIRSimK9Sim1;
								ui = uirSim1;
							} else {
								if ( !uiSimK9 )
									uiSimK9 = new UISimK9;
								ui = uiSimK9;
							}
							break;
						default:
								if ( !uirSim )
									uirSim = new UIRSim;
								ui = uirSim;						
							break;
					}
					
					break;
				case NAVI.DEVICE_POWER:
					
						if ( !uiDevicePower )
							uiDevicePower = new UIDevicePower;
						ui = uiDevicePower;
					
					break;
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIServiceLocal;
					ui = uiService;
					break;
				case NAVI.UPDATE:
					if ( DS.isfam( DS.K5 ) ) {
						if ( !uiUpdate )
							uiUpdate = new UIUpdateK5;
						ui = uiUpdate;
					} else {
						if ( !uiUpdate )
							uiUpdate = new UIUpdate;
						ui = uiUpdate;
					}
					break;
				/***********************************************************************/
				
				case NAVI.GUARD:
					if ( !uiGuard )
						uiGuard = new UIGuard;
					ui = uiGuard;
					break;
				/***********************************************************************/				
				case NAVI.SERVICE_SIMPLE:
					if ( !uiServiceSimple )
						uiServiceSimple = new UIServiceSimple;
					ui = uiServiceSimple;
					break;
				case NAVI.NETWORK:
					if ( !uiNetwork )
						uiNetwork = new UINetwork;
					ui = uiNetwork;
					break;
				case NAVI.SERVER:
					if( DS.isDevice( DS.KLAN ) )
					{
						if ( !uiServer )
							uiServer = new UIServer;
						ui = uiServer;
					}
					else 
					{
						if ( !uiServerAETH )
						uiServerAETH = new UIServerAETH;
						ui = uiServerAETH;
					}
					
					break;
				case NAVI.NETWORK_MODE:
				
					if ( !uiNetworkStatus )
						uiNetworkStatus = new UINetworkStatus;
					ui = uiNetworkStatus;
					break;
				
				case NAVI.BOLID_ONLINE:
					
					if( !uiBolidOnline )
						uiBolidOnline = new UIBolidOnline();
					ui = uiBolidOnline;
					break;
				
				case NAVI.C2000_EVENTS:
					
					if( !uiC2000Events )
						uiC2000Events = new UIC2000Events();
					ui = uiC2000Events;
					
					break;
				case NAVI.LOCK_FROM_WRITERS:
					if ( !uiLockFromWriters )
						uiLockFromWriters = new UILockFromWriters;
					ui = uiLockFromWriters;
					break;
			}
			
			if(ui) {
				container.addChild( ui );
				ui.open();
				if (DS.isDevice(DS.K5)|| 
					DS.isDevice(DS.K53G) || 
					DS.isDevice(DS.K5GL) || 
					DS.isDevice(DS.K5A))
					BalloonBot.access().open();
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