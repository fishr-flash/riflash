package components.screens
{
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIAgps;
	import components.screens.ui.UIAuthorization;
	import components.screens.ui.UIButtons;
	import components.screens.ui.UICan;
	import components.screens.ui.UICanIrma;
	import components.screens.ui.UICanR42;
	import components.screens.ui.UICarInformer;
	import components.screens.ui.UICertificate;
	import components.screens.ui.UICounters;
	import components.screens.ui.UIDate;
	import components.screens.ui.UIEModeDebug;
	import components.screens.ui.UIEgtsParams;
	import components.screens.ui.UIEgtsStats;
	import components.screens.ui.UIEnergyModeV2;
	import components.screens.ui.UIEnergyModeV4;
	import components.screens.ui.UIEnergyModeV5;
	import components.screens.ui.UIEnergyModeV6;
	import components.screens.ui.UIEnginV;
	import components.screens.ui.UIHistoryStructure;
	import components.screens.ui.UIHistoryTable;
	import components.screens.ui.UIImbKeys;
	import components.screens.ui.UIIndication;
	import components.screens.ui.UIIndicationV3;
	import components.screens.ui.UIInput;
	import components.screens.ui.UILinkChannels;
	import components.screens.ui.UIMap;
	import components.screens.ui.UIMessageTerminal;
	import components.screens.ui.UINaviReceiver;
	import components.screens.ui.UINetworkMode;
	import components.screens.ui.UINotify;
	import components.screens.ui.UIOutput;
	import components.screens.ui.UISensorMenu;
	import components.screens.ui.UISerialPortMenu;
	import components.screens.ui.UIServerCoordUNI;
	import components.screens.ui.UIServerCoordUNIV5;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UIServiceSimple;
	import components.screens.ui.UISim;
	import components.screens.ui.UISimApn;
	import components.screens.ui.UITangenta;
	import components.screens.ui.UITemperatureSensor;
	import components.screens.ui.UITestSekop;
	import components.screens.ui.UITrack;
	import components.screens.ui.UITrackII;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIUpdateLight;
	import components.screens.ui.UIVSensorsShort;
	import components.screens.ui.UIVSms;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIVerInfoSimple;
	import components.screens.ui.UIVojagerEvents;
	import components.screens.ui.UIWifiMenu;
	import components.static.DS;
	import components.static.NAVI;
	import components.system.CONST;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiHistoryStructure:UIHistoryStructure;
		
		private var uiSim:UISimApn;
		private var uiSimOld:UISim;
		private var uiEngin:UIEnginV;
		private var uiServerCoord:UI_BaseComponent;
		private var uiVerinfo:UIVerInfo;
		private var uiTrack:UITrack;
		private var uiVSensorsShort:UIVSensorsShort;
		private var uiTangenta:UITangenta;
		private var uiCan:UICan;
		private var uiCanR42:UICanR42;
		private var uiDate:UIDate;
		private var uiService:UIServiceLocal;
		private var uiAgps:UIAgps;
		private var uiVerInfoSimple:UIVerInfoSimple;
		private var uiServiceSimple:UIServiceSimple;
		private var uiUpdate:UIUpdate;
		private var uiLinkChannels:UILinkChannels;
		
		// V6
		private var uiEnergyModeV6:UIEnergyModeV6;
		// V5
		private var uiEnergyModeV5:UIEnergyModeV5;
		// V4
		private var uiEnergyModeV4:UIEnergyModeV4;
		// V3
		private var uiNotify:UINotify;
		private var uiIndicationV3:UIIndicationV3;
		private var uiButtons:UIButtons;
		// V2
		private var uiMessageTerminal:UIMessageTerminal;
		private var uiNetworkMode:UINetworkMode;
		private var uiWIfiMenu:UIWifiMenu;
		private var uiMap:UIMap;
		private var uiEnergyModeV2:UIEnergyModeV2;
		private var uiIndication:UIIndication;
		private var uiNaviReceiver:UINaviReceiver;
		private var uiIn:UIInput;
		private var uiOutput:UIOutput;
		private var uiSensorMenu:UISensorMenu;
		private var uiCertificate:UICertificate;
		private var uiEgtsParams:UIEgtsParams;
		private var uiCarInformer:UICarInformer;
		private var uiCounters:UICounters;
		private var uiSerialPortMenu:UISerialPortMenu;
		private var uiEgtsStats:UIEgtsStats;
		// DEBUG
		private var uiEModeDebug:UIEModeDebug;
	//	private var uiHistoryExporter:UIHistoryExporter;
		private var uiHistoryTable:UIHistoryTable;
		private var uiUpdateLight:UIUpdateLight;
		// SEKOP
		private var uiTestSekop:UITestSekop;
		
		//example
		private var uiTrackII:UITrackII;
		private var uiVSms:UIVSms;
		private var uiVEvents:UIVojagerEvents;
		private var uiTSensor:UITemperatureSensor;

		private var uiCanIrma:UICanIrma;
		private var uiImbKeys:UIImbKeys;
		private var uiAuthorization:UIAuthorization;
		
		
		public function OptionBuilder(c:Canvas, sm:Canvas)
		{
			container = c; 
			subMenuContainer = sm;
		}
		public function initProcess( cmd:int ):void 
		{
			ui = null;
		
			switch( cmd ) {
				case NAVI.MESSAGE_TERMINAL:
					if ( !uiMessageTerminal)
						uiMessageTerminal = new UIMessageTerminal;
					ui = uiMessageTerminal;
					break;
				case NAVI.NETWORK_MODE:
					if ( !uiNetworkMode )
						uiNetworkMode = new UINetworkMode;
					ui = uiNetworkMode;
					break;
				case NAVI.DEBUG_UPDATE:
					if ( !uiUpdateLight )
						uiUpdateLight = new UIUpdateLight;
					ui = uiUpdateLight;
					break;
				case NAVI.SERIAL_PORT:
					if ( !uiSerialPortMenu )
						uiSerialPortMenu = new UISerialPortMenu;
					ui = uiSerialPortMenu;
					break;
				case NAVI.LINK_CHANNELS:
					if ( !uiLinkChannels )
						uiLinkChannels = new UILinkChannels;
					ui = uiLinkChannels;
					break;
				case NAVI.COUNTERS:
					if ( !uiCounters )
						uiCounters = new UICounters;
					ui = uiCounters;
					break;
				case NAVI.TEMPERATURE:
					if ( !uiTSensor )
						uiTSensor = new UITemperatureSensor;
					ui = uiTSensor;
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
				case NAVI.CARINFORMER:
					if ( !uiCarInformer )
						uiCarInformer = new UICarInformer;
					ui = uiCarInformer;
					break
				case NAVI.MAP:
					if ( !uiMap )
						uiMap = new UIMap;
					ui = uiMap;
					break;
				/*case NAVI.TEST:
					if ( !uiTestSekop )
						uiTestSekop = new UITestSekop;
					ui = uiTestSekop;
					break;
				
				case NAVI.TEST:
					if( !uiTrackII )
						uiTrackII = new UITrackII();
					ui = uiTrackII;
					break;*/
				case NAVI.PARAMS_EGTS:
					if ( !uiEgtsParams )
						uiEgtsParams = new UIEgtsParams;
					ui = uiEgtsParams;
					break;
				case NAVI.STATS_EGTS:
					if ( !uiEgtsStats )
						uiEgtsStats = new UIEgtsStats;
					ui = uiEgtsStats;
					break;
				case NAVI.CERTIFICATE:
					if ( !uiCertificate )
						uiCertificate = new UICertificate;
					ui = uiCertificate;
					break;
				case NAVI.DATE:
					if ( !uiDate )
						uiDate = new UIDate;
					ui = uiDate;
					break;
				case NAVI.VER_INFO_SIMPLE:
					if ( !uiVerInfoSimple )
						uiVerInfoSimple = new UIVerInfoSimple;
					ui = uiVerInfoSimple;
					break;
				case NAVI.SERVICE_SIMPLE:
					if ( !uiServiceSimple )
						uiServiceSimple = new UIServiceSimple;
					ui = uiServiceSimple;
					break;
				case NAVI.HISTORY:
					if ( !uiHistoryTable )
						uiHistoryTable = new UIHistoryTable;
					ui = uiHistoryTable;
					break;
				case NAVI.VSENSORS:
					if ( !uiSensorMenu )
						uiSensorMenu = new UISensorMenu;
					ui = uiSensorMenu;
					break;
				case NAVI.ENERGY_MODE:
					switch(CONST.PRESET_NUM) {
						case 1:
						case 2:
						case 7:
						case 8:
							if ( !uiEnergyModeV2 )
								uiEnergyModeV2 = new UIEnergyModeV2;
							ui = uiEnergyModeV2;
							break;
						case 4:
							if ( !uiEnergyModeV4 )
								uiEnergyModeV4 = new UIEnergyModeV4;
							ui = uiEnergyModeV4;
							break;
						case 5:
							if ( !uiEnergyModeV5 )
								uiEnergyModeV5 = new UIEnergyModeV5;
							ui = uiEnergyModeV5;
							break;
						case 3:
						case 6:
							if ( !uiEnergyModeV6 )
								uiEnergyModeV6 = new UIEnergyModeV6;
							ui = uiEnergyModeV6;
					}
					break;
				case NAVI.SMS:
					  if( !uiVSms ) uiVSms = new UIVSms();
					  
					  ui = uiVSms;
					 break;
				case NAVI.VOYAGER_EVENTS:
					  if( !uiVEvents ) uiVEvents = new UIVojagerEvents();
					  
					  ui = uiVEvents;
					 break;
				case NAVI.HISTORY_STRUCTURE:
					if ( !uiHistoryStructure )
						uiHistoryStructure = new UIHistoryStructure;
					ui = uiHistoryStructure;
					break;
				case NAVI.ENGIN_NUMB:
					if ( !uiEngin )
						uiEngin = new UIEnginV;
					ui = uiEngin;
					break;
				case NAVI.GPRS_SIM:
					if ( !uiSim )
						uiSim = new UISimApn;
					ui = uiSim;
					break;
				case NAVI.GPRS_SIM_OLD:
					if ( !uiSimOld )
						uiSimOld = new UISim(false,false);
					ui = uiSimOld;
					break;
				case NAVI.CONNECT_SERVER:
					
					if( DS.isDevice( DS.V5 ) )
					{
						if ( !uiServerCoord )
							uiServerCoord = new UIServerCoordUNIV5();
						
					}
					else
					{
						if ( !uiServerCoord )
							uiServerCoord = new UIServerCoordUNI;
						
					}
					
					ui = uiServerCoord;
					
					break;
				case NAVI.VER_INFO:
					if ( !uiVerinfo )
						uiVerinfo = new UIVerInfo;
					ui = uiVerinfo;
					break;
				case NAVI.TRACK:
					if ( !uiTrack)
						uiTrack = new UITrack;
					ui = uiTrack;
					break;
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIServiceLocal;
					ui = uiService;
					break;
// V2	****************************************************************
				case NAVI.TANGENTA:
					if ( !uiTangenta)
						uiTangenta = new UITangenta;
					ui = uiTangenta;
					break;
				case NAVI.CAN:
					
					if( DS.isfam( DS.V2 ) && DS.release > 48 )
					{
						
						if( !uiCanIrma )uiCanIrma = new UICanIrma;
						
						ui = uiCanIrma;
					} 
					else if( DS.release >= 42 )
					{
						if( !uiCanR42 )uiCanR42 = new UICanR42;
						
						ui = uiCanR42;
					} 
					else 
					{
						if ( !uiCan)
							uiCan = new UICan;
						ui = uiCan;
					}
					break;
				case NAVI.INDICATION:
					if (DS.isDevice(DS.V3 ) 
						|| DS.isDevice(DS.V3L_3G )
						|| DS.isDevice(DS.V3L)) {
						if ( !uiIndicationV3)
							uiIndicationV3 = new UIIndicationV3;
						ui = uiIndicationV3;
					} else {
						if ( !uiIndication)
							uiIndication = new UIIndication;
						ui = uiIndication;
					}
					break;
				case NAVI.NAVI_RECEIVER:
					if ( !uiNaviReceiver)
						uiNaviReceiver = new UINaviReceiver;
					ui = uiNaviReceiver;
					break;
				case NAVI.AGPS:
					if ( !uiAgps)
						uiAgps = new UIAgps;
					ui = uiAgps;
					break;
				case NAVI.INPUT:
					if ( !uiIn)
						uiIn = new UIInput;
					ui = uiIn;
					break;
				case NAVI.OUT:
					if ( !uiOutput)
						uiOutput = new UIOutput;
					ui = uiOutput;
					break;
			/*	case NAVI.SENSOR_MENU:
					if ( !uiSensorMenu)
						uiSensorMenu = new UISensorMenu;
					ui = uiSensorMenu;
					break;*/
// V3	****************************************************************
				case NAVI.NOTIF:
					if ( !uiNotify)
						uiNotify = new UINotify;
					ui = uiNotify;
					break;
				case NAVI.BUTTONS:
					if ( !uiButtons)
						uiButtons = new UIButtons;
					ui = uiButtons;
					break;
// Debug **************************************************************
				case NAVI.DEBUG_ENERGYMODES:
					if ( !uiEModeDebug)
						uiEModeDebug = new UIEModeDebug;
					ui = uiEModeDebug;
					break;
				case NAVI.IMB_KEYS:
					if ( !uiImbKeys)
						uiImbKeys = new UIImbKeys;
					ui = uiImbKeys;
					break;
				case NAVI.AUTHORIZATION:
				
					if ( !uiAuthorization)
						uiAuthorization = new UIAuthorization;
					ui = uiAuthorization;
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