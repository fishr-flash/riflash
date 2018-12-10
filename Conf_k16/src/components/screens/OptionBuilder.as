package components.screens
{
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.screens.ui.UIDataKeyboard;
	import components.screens.ui.UIDate;
	import components.screens.ui.UIDateBottom;
	import components.screens.ui.UIDevicePower;
	import components.screens.ui.UIDevicePowerOld;
	import components.screens.ui.UIEngin;
	import components.screens.ui.UIHistoryBottom;
	import components.screens.ui.UIHistoryExt;
	import components.screens.ui.UIKeyboard;
	import components.screens.ui.UIKeys;
	import components.screens.ui.UILinkChannels;
	import components.screens.ui.UILockFromWriters;
	import components.screens.ui.UIMap;
	import components.screens.ui.UIObject;
	import components.screens.ui.UIOutK16;
	import components.screens.ui.UIParamsLan;
	import components.screens.ui.UIPartition;
	import components.screens.ui.UIPhoneLine;
	import components.screens.ui.UIRFRele;
	import components.screens.ui.UIRFSensor;
	import components.screens.ui.UIRadioSystem;
	import components.screens.ui.UIRadiodeviceMap;
	import components.screens.ui.UIRctrl;
	import components.screens.ui.UIReader;
	import components.screens.ui.UIRele;
	import components.screens.ui.UIRfModule;
	import components.screens.ui.UISMS;
	import components.screens.ui.UIScreenKeyboard;
	import components.screens.ui.UISensorTemperature;
	import components.screens.ui.UISensorTemperatureV2;
	import components.screens.ui.UIServiceHybrid;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UISimApn;
	import components.screens.ui.UISysEvents;
	import components.screens.ui.UITrmSens;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIUpdateBottom;
	import components.screens.ui.UIUserPass;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIVerInfoHybrid;
	import components.screens.ui.UIWire;
	import components.static.DS;
	import components.static.NAVI;
	import components.system.CONST;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiDateBottom:UIDateBottom;
		private var uiSysEvents:UISysEvents;
		private var uiSystem:UIRadioSystem;
		private var uiDevideMap:UIRadiodeviceMap;
		private var uiRfSensor:UIRFSensor;
		private var uiPartition:UIPartition;
		private var uiRctrl:UIRctrl;
		private var uiHistory:UIHistoryExt;
		private var uiHistoryBottom:UIHistoryBottom;
		private var uiUserPass:UIUserPass;
		private var uiService:UIServiceLocal;
		private var uiVerInfo:UIVerInfo;
		private var uiKeyboard:UIKeyboard;
		private var uiRfRele:UIRFRele;
		private var uiDataKeyboard:UIDataKeyboard;
		private var uiRele:UIRele;
		private var uiOut:UIOutK16;
		private var uiKeys:UIKeys;
		private var uiWire:UIWire;
		private var uiReader:UIReader;
	//	private var uiUpdateDual:UIUpdateDual;
		private var uiSms:UISMS;
		private var uiTemperatureV2:UISensorTemperatureV2;
		private var uiTemperature:UISensorTemperature;
		//private var uiTemperature:UITrmSens;
		
		private var uiMap:UIMap;
		private var uiDate:UIDate;
		private var uiLinkChannels:UILinkChannels;
		private var uiSim:UISimApn;
		private var uiEngin:UIEngin;
		private var uiParamsLan:UIParamsLan;
		private var uiObject:UIObject;
		private var uiPhoneLine:UIPhoneLine;
		private var uiVerInfoHybrid:UIVerInfoHybrid;
		private var uiServiceHybrid:UIServiceHybrid;
	//	private var uiUpdate:components.screens.ui.UIUpdateDual;
		private var uiDevicePowerOld:UIDevicePowerOld;
		private var uiDevicePower:UIDevicePower;
		
		private var uiUpdate:UIUpdate;
		private var uiUpdateBottom:UIUpdateBottom;
		private var uiLockFromWriters:UILockFromWriters;
		private var uiRfModule:UIRfModule;

		private var uiScreenKeyboard:UIScreenKeyboard;
		
		public function OptionBuilder(c:Canvas, sm:Canvas)
		{
			container = c; 
			subMenuContainer = sm;
		}
		public function initProcess( cmd:int ):void 
		{
			ui = null;
			switch( cmd ) {
				case NAVI.DEVICE_POWER:
					
					if( SERVER.BOTTOM_RELEASE < 17 )
					{
						
						if ( !uiDevicePowerOld )
							uiDevicePowerOld = new UIDevicePowerOld;
						ui = uiDevicePowerOld;
					}
					else
					{
						if ( !uiDevicePower )
							uiDevicePower = new UIDevicePower;
						ui = uiDevicePower;
					}
					break;
				case NAVI.MAP:
					if ( !uiMap )
						uiMap = new UIMap;
					ui = uiMap;
					break;
				case NAVI.SMS:
					if ( !uiSms )
						uiSms = new UISMS;
					ui = uiSms;
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
				case NAVI.SCREEN_KEYBOARD:
					if ( !uiScreenKeyboard )
						uiScreenKeyboard = new UIScreenKeyboard;
					ui = uiScreenKeyboard;
					break;
				case NAVI.TEMPERATURE:
					
					
					if( DS.release > 12)
					{
						if ( !uiTemperatureV2 )
							uiTemperatureV2 = new UISensorTemperatureV2;
						ui = uiTemperatureV2;
					}
					else if ( !uiTemperature )
					{
						
						uiTemperature = new UISensorTemperature;
						ui = uiTemperature;
					}
					
						/*uiTemperature = new UITrmSens;
						ui = uiTemperature;*/
					
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
				case NAVI.RF_RELE:
					if ( !uiRfRele )
						uiRfRele = new UIRFRele;
					ui = uiRfRele;
					break;
				case NAVI.RF_MODULE:
					if ( !uiRfModule )
						uiRfModule = new UIRfModule(CONST.RFMODULE_NUM);
					ui = uiRfModule;
					break;
				case NAVI.UPDATE:
					if ( !uiUpdate )
						uiUpdate = new UIUpdate;
					ui = uiUpdate;
					break;
				case NAVI.UPDATE_SECOND:
					if ( !uiUpdateBottom )
						uiUpdateBottom = new UIUpdateBottom;
					ui = uiUpdateBottom;
					break;
				case NAVI.HISTORY:
					if ( SERVER.DUAL_DEVICE ) {
						if ( !uiHistory )
							uiHistory = new UIHistoryExt;
						ui = uiHistory;
					} else {
						if ( !uiHistoryBottom )
							uiHistoryBottom = new UIHistoryBottom;
						ui = uiHistoryBottom;
					}
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
				case NAVI.DATE:
					if ( SERVER.DUAL_DEVICE ) {
						if ( !uiDate )
							uiDate = new UIDate;
						ui = uiDate;
					} else {
						if ( !uiDateBottom )
							uiDateBottom = new UIDateBottom;
						ui = uiDateBottom;
					}
					break;
				case NAVI.SERVICE:
					if ( SERVER.DUAL_DEVICE ) {
						if ( !uiServiceHybrid)
							uiServiceHybrid = new UIServiceHybrid;
						ui = uiServiceHybrid;
					} else {
						if ( !uiService )
							uiService = new UIServiceLocal;
						ui = uiService;
					}
					break;
				case NAVI.VER_INFO:
					if ( !uiVerInfo )
						uiVerInfo = new UIVerInfo;
					ui = uiVerInfo;
					break;
				case NAVI.DATA_KEY:
					if ( !uiDataKeyboard )
						uiDataKeyboard = new UIDataKeyboard(CONST.DATAKEY_NUM);
					ui = uiDataKeyboard;
					break;
				case NAVI.DATA_RELE:
					if ( !uiRele )
						uiRele = new UIRele;
					ui = uiRele;
					break;
				case NAVI.OUT:
					if ( !uiOut )
						uiOut = new UIOutK16;
					ui = uiOut;
					break;
				case NAVI.ALARM_WIRE:
					if ( !uiWire)
						uiWire = new UIWire;
					ui = uiWire;
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
				/** K16m	*/
				case NAVI.LINK_CHANNELS:
					if ( !uiLinkChannels )
						uiLinkChannels = new UILinkChannels;
					ui = uiLinkChannels;
					break;
				/*case NAVI.GPRS_SIM:
				*	if ( !uiSim )
						uiSim = new UISim(CONST.USE_GPRS_COMPR, CONST.USE_GPRS_ROAMING);
					ui = uiSim;
					break;*/
				case NAVI.GPRS_SIM:
					if ( !uiSim )
						uiSim = new UISimApn;
					ui = uiSim;
					break;
				case NAVI.ENGIN_NUMB:
					if ( !uiEngin )
						uiEngin = new UIEngin;
					ui = uiEngin;
					break;
				case NAVI.PARAMS_LAN:
					if ( !uiParamsLan )
						uiParamsLan = new UIParamsLan;
					ui = uiParamsLan;
					break;
				case NAVI.OBJECT:
					if ( !uiObject )
						uiObject = new UIObject;
					ui = uiObject;
					break;
				case NAVI.PHONE_LINE:
					if ( !uiPhoneLine )
						uiPhoneLine = new UIPhoneLine;
					ui = uiPhoneLine;
					break;
				case NAVI.VER_INFO_HYBRID:
					if ( !uiVerInfoHybrid)
						uiVerInfoHybrid = new UIVerInfoHybrid;
					ui = uiVerInfoHybrid;
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