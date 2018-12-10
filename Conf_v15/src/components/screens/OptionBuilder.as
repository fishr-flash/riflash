package components.screens
{
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UICan;
	import components.screens.ui.UICert;
	import components.screens.ui.UIDataKeyboard;
	import components.screens.ui.UIDate;
	import components.screens.ui.UIEgtsParams;
	import components.screens.ui.UIEgtsStats;
	import components.screens.ui.UIEngin;
	import components.screens.ui.UIHistoryExt;
	import components.screens.ui.UIHistoryStructure;
	import components.screens.ui.UIHistoryTableV15;
	import components.screens.ui.UIIVideoCheckIpCams;
	import components.screens.ui.UIIVideon;
	import components.screens.ui.UIInput;
	import components.screens.ui.UIKeyboard;
	import components.screens.ui.UIKeys;
	import components.screens.ui.UIMap;
	import components.screens.ui.UIModemXG;
	import components.screens.ui.UIOut;
	import components.screens.ui.UIParamsLan;
	import components.screens.ui.UIPartition;
	import components.screens.ui.UIRFSensor;
	import components.screens.ui.UIRadioSystem;
	import components.screens.ui.UIRadiodeviceMap;
	import components.screens.ui.UIRctrl;
	import components.screens.ui.UIReader;
	import components.screens.ui.UIServerConf;
	import components.screens.ui.UIServerCoordUNI;
	import components.screens.ui.UIServers;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UISimApn;
	import components.screens.ui.UISysEvents;
	import components.screens.ui.UITrack;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIUserPass;
	import components.screens.ui.UIVSensors;
	import components.screens.ui.UIVerInfoCam;
	import components.screens.ui.UIVerInfoTrakker;
	import components.screens.ui.UIVerInfoVPN;
	import components.screens.ui.UIVideoConfig;
	import components.screens.ui.UIVideoConfigCam;
	import components.screens.ui.UIVideoIPCofigCams;
	import components.screens.ui.UIVideoRecConfig;
	import components.screens.ui.UIVpn;
	import components.screens.ui.UIWifi;
	import components.screens.ui.UIWifiAP;
	import components.screens.ui.UIWire;
	import components.static.DS;
	import components.static.NAVI;
	import components.system.CONST;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiVideoConfig:UIVideoConfig;
		private var uiSim:UISimApn;
		private var uiParamsLan:UIParamsLan;
		private var uiService:UIServiceLocal;
		private var uiMap:UIMap;
		private var uiDate:UIDate;
		private var uiEgtsParams:UIEgtsParams;
		private var uiEgtsStats:UIEgtsStats;
		
		//	A10
		private var uiVerInfo:UIVerInfoVPN;
		private var uiEngin:UIEngin;
		private var uiTrack:UITrack;
		private var uiVSensors:UIVSensors;
		private var uiHistoryk15:UIHistoryExt;
		private var uiHistoryTablev15:UIHistoryTableV15;
		
		private var uiHistoryStructure:UIHistoryStructure;
		private var uiWifi:UIWifi;
		private var uiServerCoord:UIServerCoordUNI;
		private var uiVpn:UIVpn;
		private var uiModemXG:UIModemXG;
		private var uiWifiAp:UIWifiAP;
		private var uiUpdate:UIUpdate;
		private var uiCan:UICan;
		// Контакт
		private var uiSystem:UIRadioSystem;
		private var uiDevideMap:UIRadiodeviceMap;
		private var uiRfSensor:UIRFSensor;
		private var uiPartition:UIPartition;
		private var uiOut:UIOut;
		private var uiRctrl:UIRctrl;
		private var uiUserPass:UIUserPass;
		private var uiKeyboard:UIKeyboard;
		private var uiSysEvents:UISysEvents;
		private var uiDataKeyboard:UIDataKeyboard;
		private var uiWire:UIWire;
		private var uiIVideon:UIIVideon;
		private var uiServers:UIServers;
		private var uiReader:UIReader;
		private var uiKeys:UIKeys;
		
		// Cam
		private var uiVideoConfigCam:UI_BaseComponent;
		private var uiVerInfoCam:UIVerInfoCam;
		private var uiServerConf:UIServerConf;
		// Android Trakker
		private var uiVerInfoTrakker:UIVerInfoTrakker;
		private var uiIn:UIInput;
		private var uiCertificate:UICert;
		private var uiVideoRecConfig:UIVideoRecConfig;
		private var uIVideoConfigIpCam:UIVideoIPCofigCams;
		private var uIVideoCheckIpCam:UIIVideoCheckIpCams;
		
		public function OptionBuilder(c:Canvas, sm:Canvas)
		{
			container = c; 
			subMenuContainer = sm;
		}
		public function initProcess( cmd:int ):void 
		{
			ui = null;
		
			
			switch( cmd ) {
				case NAVI.MAP:
					if ( !uiMap )
						uiMap = new UIMap;
					ui = uiMap;
					break;
				case NAVI.IVIDEO:
					if ( !uiIVideon )
						uiIVideon = new UIIVideon;
					ui = uiIVideon;
					break;
				case NAVI.DATE:
					if ( !uiDate )
						uiDate = new UIDate;
					ui = uiDate;
					break;
				case NAVI.UPDATE:
					if ( !uiUpdate )
						uiUpdate = new UIUpdate;
					ui = uiUpdate;
					break;
				case NAVI.PARAMS_WIFIAP:
					if ( !uiWifiAp )
						uiWifiAp = new UIWifiAP;
					ui = uiWifiAp;
					break;
				case NAVI.PARAMS_VPN:
					if ( !uiVpn )
						uiVpn = new UIVpn;
					ui = uiVpn;
					break;
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
				case NAVI.MODEM_XG:
					if ( !uiModemXG )
						uiModemXG = new UIModemXG;
					ui = uiModemXG;
					break;
				case NAVI.VIDEO_CAMS_CONFIG:
					if (DS.isDevice(DS.C15)) 
					{
						if ( !uiVideoConfigCam )
							uiVideoConfigCam = new UIVideoConfigCam;
						ui = uiVideoConfigCam;
					} 
					/*else if(DEVICES.isDevice(DEVICES.V15) || DEVICES.isDevice(DEVICES.V15IP)) {
					
						if ( !uiVideoConfigCam )
							if( int( DEVICES.release ) < 10 )uiVideoConfigCam = new UIVideoConfigV15Old();
							else uiVideoConfigCam = new UIVideoConfigV15();
							
						ui = uiVideoConfigCam;
					}*/
					else
					{
						if ( !uiVideoConfig )
							uiVideoConfig = new UIVideoConfig;
						ui = uiVideoConfig;
					}
					break;
				
				case NAVI.VIDEO_RECORD_CONFIG:
					
						if ( !uiVideoRecConfig )
							uiVideoRecConfig = new UIVideoRecConfig();
						ui = uiVideoRecConfig;
					
					break;
				
				case NAVI.CONFIG_IP_CAMS:
					
					if( !uIVideoConfigIpCam )
						uIVideoConfigIpCam = new UIVideoIPCofigCams();
					ui = uIVideoConfigIpCam;
					
					break;
				case NAVI.CHECK_IP_CAMS:
					
					if( !uIVideoCheckIpCam )
						uIVideoCheckIpCam = new UIIVideoCheckIpCams();
					ui = uIVideoCheckIpCam;
					
					break;
				case NAVI.CONNECT_SERVER:
					if (DS.isDevice(DS.C15)) {
						if ( !uiServerConf )
							uiServerConf = new UIServerConf;
						ui = uiServerConf;
					} else {
						if ( !uiServerCoord )
							uiServerCoord = new UIServerCoordUNI;
						ui = uiServerCoord;
					}
					break;
				case NAVI.INPUT:
					if ( !uiIn)
						uiIn = new UIInput;
					ui = uiIn;
					break;
				case NAVI.SERVER:
					if ( !uiServers )
						uiServers = new UIServers;
					ui = uiServers;
					break;
				case NAVI.GPRS_SIM:
					if ( !uiSim )
						uiSim = new UISimApn;//UISim(CONST.USE_GPRS_COMPR, CONST.USE_GPRS_ROAMING);
					ui = uiSim;
					break;
				case NAVI.PARAMS_LAN:
					if ( !uiParamsLan )
						uiParamsLan = new UIParamsLan;
					ui = uiParamsLan;
					break;
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIServiceLocal;
						ui = uiService;
					break;
				// A10
				case NAVI.CAN:
					
					if ( !uiCan)
						uiCan = new UICan;
					ui = uiCan;
					break;
				case NAVI.VER_INFO:
					
					switch(DS.alias) {
						case DS.C15:
							if ( !uiVerInfoCam )
								uiVerInfoCam = new UIVerInfoCam;
							ui = uiVerInfoCam;
							break;
						case DS.VM:
							if ( !uiVerInfoTrakker )
								uiVerInfoTrakker = new UIVerInfoTrakker;
							ui = uiVerInfoTrakker;
							break;
						default:
							if ( !uiVerInfo )
								uiVerInfo = new UIVerInfoVPN;
							ui = uiVerInfo;
							break;
					}
					break;
				case NAVI.ENGIN_NUMB:
					if ( !uiEngin )
						uiEngin = new UIEngin;
					ui = uiEngin;
					break;
				case NAVI.TRACK:
					if ( !uiTrack)
						uiTrack = new UITrack;
					ui = uiTrack;
					break;
				case NAVI.VSENSORS:
					if ( !uiVSensors )
						uiVSensors = new UIVSensors;
					ui = uiVSensors;
					break;
				case NAVI.HISTORY_EXT:
					switch(DS.alias) {
						case DS.V15:
						case DS.V15IP:
						case DS.VM:
							if ( !uiHistoryTablev15 )
								uiHistoryTablev15 = new UIHistoryTableV15;
							ui = uiHistoryTablev15;
							break;
						default:
							if ( !uiHistoryk15 )
								uiHistoryk15 = new UIHistoryExt;
							ui = uiHistoryk15;
							break;
					}
					break;
				case NAVI.HISTORY_STRUCTURE:
					if ( !uiHistoryStructure )
						uiHistoryStructure = new UIHistoryStructure;
					ui = uiHistoryStructure;
					break;
				case NAVI.PARAMS_WIFI:
					if ( !uiWifi )
						uiWifi = new UIWifi;
					ui = uiWifi;
					break;
				// Kontakt
				case NAVI.ALARM_WIRE:
					if ( !uiWire )
						uiWire = new UIWire;
					ui = uiWire;
					break
				case NAVI.DATA_KEY:
					if ( !uiDataKeyboard )
						uiDataKeyboard = new UIDataKeyboard(CONST.DATAKEY_NUM);
					ui = uiDataKeyboard;
					break;
				case NAVI.SYS_EVENTS:
					if ( !uiSysEvents )
						uiSysEvents = new UISysEvents;
					ui = uiSysEvents;
					break;
				case NAVI.RF_SYSTEM:
					if ( !uiSystem )
						uiSystem = new UIRadioSystem;
					ui = uiSystem;
					break;
				case NAVI.RF_SENSOR:
					if ( !uiRfSensor )
						uiRfSensor = new UIRFSensor;
					ui = uiRfSensor;
					break;
				case NAVI.PARTITION:
					if ( !uiPartition )
						uiPartition = new UIPartition;
					ui = uiPartition;
					break;
				case NAVI.OUT:
					if ( !uiOut )
						uiOut = new UIOut(2);
					ui = uiOut;
					break;
				case NAVI.RF_RCTRL:
					if ( !uiRctrl )
						uiRctrl = new UIRctrl;
					ui = uiRctrl;
					break;
				case NAVI.RF_KEY:
					if ( !uiKeyboard )
						uiKeyboard = new UIKeyboard(CONST.RFKEY_NUM);
					ui = uiKeyboard;
					break;
				case NAVI.USER_PASS:
					if ( !uiUserPass )
						uiUserPass = new UIUserPass;
					ui = uiUserPass;
					break;
				case NAVI.RF_MAP:
					if ( !uiDevideMap )
						uiDevideMap = new UIRadiodeviceMap;
					ui = uiDevideMap;
					break;
				case NAVI.CERTIFICATE:
					if ( !uiCertificate )
						uiCertificate = new UICert;
					ui = uiCertificate;
					break;
				case NAVI.TM_KEYS:
					if ( !uiKeys)
						uiKeys = new UIKeys;
					ui = uiKeys;
					break;
				case NAVI.TM_READER:
					if ( !uiReader)
						uiReader = new UIReader;
					ui = uiReader;
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