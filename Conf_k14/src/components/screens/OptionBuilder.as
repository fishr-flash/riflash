package components.screens
{
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIAOut;
	import components.screens.ui.UIAlarmKey;
	import components.screens.ui.UIAlarmKeyA;
	import components.screens.ui.UICertificate;
	import components.screens.ui.UIDate;
	import components.screens.ui.UIDevicePowerK14;
	import components.screens.ui.UIEngin;
	import components.screens.ui.UIFourthKeyboard;
	import components.screens.ui.UIHistoryExt;
	import components.screens.ui.UIIndSound;
	import components.screens.ui.UIKeyboard;
	import components.screens.ui.UILinkChannels;
	import components.screens.ui.UILockFromWriters;
	import components.screens.ui.UIMap;
	import components.screens.ui.UIOut;
	import components.screens.ui.UIPartition;
	import components.screens.ui.UIRFRele;
	import components.screens.ui.UIRFSensor;
	import components.screens.ui.UIRadioSystem;
	import components.screens.ui.UIRadiodeviceMap;
	import components.screens.ui.UIRctrl;
	import components.screens.ui.UIRfModule;
	import components.screens.ui.UISMS;
	import components.screens.ui.UIScreenKeyboard;
	import components.screens.ui.UISensorTemperatureK14;
	import components.screens.ui.UISensorTemperatureV2;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UISimApn;
	import components.screens.ui.UISysEvents;
	import components.screens.ui.UITrmSens;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIUserPass;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIWifiMenu;
	import components.static.DS;
	import components.static.NAVI;
	import components.system.CONST;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiDate:UIDate;
		private var uiSysEvents:UISysEvents;
		private var uiSystem:UIRadioSystem;
		private var uiDevideMap:UIRadiodeviceMap;
		private var uiRfSensor:UIRFSensor;
		private var uiPartition:UIPartition;
		private var uiOut:UIOut;
		private var uiRctrl:UIRctrl;
		private var uiHistory:UIHistoryExt;
		private var uiLinkChannels:UILinkChannels;
		private var uiUserPass:UIUserPass;
		private var uiEngin:UIEngin;
		private var uiSms:UISMS;
		private var uiIndSound:UIIndSound;
		private var uiService:UIServiceLocal;
		private var uiVerInfo:UIVerInfo;
		private var uiAlarmKey:UIAlarmKey;
		private var uiSim:UISimApn;
		private var uiKeyboard:UIKeyboard;
		private var uiRfModule:UIRfModule;
		private var uiFourthKeyboard:UIFourthKeyboard;
		private var uiRfRele:UIRFRele;
		private var uiAlarmKeyA:UIAlarmKeyA;
		private var uiCertificate:UICertificate;
		private var uiMap:UIMap;
		private var uiTemperature:UITrmSens;
		private var uiScreenKeyboard:UIScreenKeyboard;
		private var uiUpdate:UIUpdate;
		private var uiWIfiMenu:UIWifiMenu;
		private var uiDevicePower:UIDevicePowerK14;
		// K15A
		private var uiAOut:UIAOut;
		private var uiLockFromWriters:UILockFromWriters;
		
		public function OptionBuilder(c:Canvas, sm:Canvas)
		{
			container = c; 
			subMenuContainer = sm;
		}
		public function initProcess( cmd:int ):void 
		{
			ui = null;
			switch( cmd ) {
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
				case NAVI.SCREEN_KEYBOARD:
					if ( !uiScreenKeyboard )
						uiScreenKeyboard = new UIScreenKeyboard;
					ui = uiScreenKeyboard;
					break;
				case NAVI.TEMPERATURE:
					if ( !uiTemperature )
						//uiTemperature = new UISensorTemperatureK14;
						//uiTemperature = new UISensorTemperatureV2;
						uiTemperature = new UITrmSens;
					ui = uiTemperature;
					break;
				case NAVI.MAP:
					if ( !uiMap )
						uiMap = new UIMap;
					ui = uiMap;
					break;
				case NAVI.CERTIFICATE:
					if ( !uiCertificate )
						uiCertificate = new UICertificate;
					ui = uiCertificate;
					break;
				case NAVI.SYS_EVENTS:
					if ( !uiSysEvents )
						uiSysEvents = new UISysEvents;
					ui = uiSysEvents;
					break;
				case NAVI.ALARM_KEY:
					
					if( DS.isfam( DS.asAKAW ) ){
						
						if( !uiAlarmKeyA )
							uiAlarmKeyA = new UIAlarmKeyA;
						ui = uiAlarmKeyA;
					}
					else{
						if ( !uiAlarmKey )
							uiAlarmKey = new UIAlarmKey;
						ui = uiAlarmKey;	
					}
					
					break;
				case NAVI.GPRS_SIM:
					if ( !uiSim )
						uiSim = new UISimApn;
					ui = uiSim;
					break;
				case NAVI.RF_SYSTEM:
					if ( !uiSystem )
						uiSystem = new UIRadioSystem;
					ui = uiSystem;
					break;
				case NAVI.DEVICE_POWER:
					
					if ( !uiDevicePower )
						uiDevicePower = new UIDevicePowerK14;
					ui = uiDevicePower;
					
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
					switch(DS.alias) {
						case DS.K14A:
						case DS.K14L:
						case DS.K14AW:
						case DS.K14K:
						case DS.K14KW:
							if ( !uiAOut )
								uiAOut = new UIAOut;
							ui = uiAOut;
							break;
						
							/*if ( !uiOut )
								uiOut = new UIOut(3);
							ui = uiOut;
							break;*/
						default:
							if ( !uiOut )
								uiOut = new UIOut(1);
							ui = uiOut;
							break;
					}
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
				
				case NAVI.RF_MODULE:
					if ( !uiRfModule )
						uiRfModule = new UIRfModule(CONST.RFMODULE_NUM);
					ui = uiRfModule;
					break;
				
				case NAVI.FOURTH_KEYBOARD:
					if ( !uiFourthKeyboard )
						uiFourthKeyboard = new UIFourthKeyboard();
					ui = uiFourthKeyboard;
					break;
				
				case NAVI.RF_RELE:
					if ( !uiRfRele )
						uiRfRele = new UIRFRele;
					ui = uiRfRele;
					break;
				case NAVI.HISTORY:
					if ( !uiHistory )
						uiHistory = new UIHistoryExt;
					ui = uiHistory;
					break;
				case NAVI.LINK_CHANNELS:
					if ( !uiLinkChannels )
						uiLinkChannels = new UILinkChannels;
					ui = uiLinkChannels;
					break;
				case NAVI.USER_PASS:
					if ( !uiUserPass )
						uiUserPass = new UIUserPass;
					ui = uiUserPass;
					break;
				case NAVI.ENGIN_NUMB:
					if ( !uiEngin )
						uiEngin = new UIEngin;
					ui = uiEngin;
					break;
				case NAVI.IND_SOUND:
					if ( !uiIndSound )
						uiIndSound = new UIIndSound;
					ui = uiIndSound;
					break;
				case NAVI.SMS:
					if ( !uiSms )
						uiSms = new UISMS;
					ui = uiSms;
					break;
				case NAVI.RF_MAP:
					if ( !uiDevideMap )
						uiDevideMap = new UIRadiodeviceMap;
					ui = uiDevideMap;
					break;
				case NAVI.DATE:
					if ( !uiDate )
						uiDate = new UIDate;
					ui = uiDate;
					break;
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIServiceLocal;
					ui = uiService;
					break;
				case NAVI.VER_INFO:
					if ( !uiVerInfo )
						uiVerInfo = new UIVerInfo;
					ui = uiVerInfo;
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