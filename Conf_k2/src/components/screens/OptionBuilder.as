package components.screens
{
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIDate;
	import components.screens.ui.UIDateK2M;
	import components.screens.ui.UIEnergySave;
	import components.screens.ui.UIHistory;
	import components.screens.ui.UIKeysK2;
	import components.screens.ui.UINotify;
	import components.screens.ui.UIRctrl;
	import components.screens.ui.UIReader;
	import components.screens.ui.UISensor;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UISim;
	import components.screens.ui.UISms;
	import components.screens.ui.UISysEvents;
	import components.screens.ui.UITest;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIZummer;
	import components.static.DS;
	import components.static.NAVI;
	import components.system.CONST;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiService:UIServiceLocal;
		private var uiVerinfo:UIVerInfo;
		private var uiDate:UI_BaseComponent;
		private var uiSensor:UISensor;
		private var uiZummer:UIZummer;
		private var uiNotify:UINotify;
		private var uiReader:UIReader;
		private var uiSim:UISim;
		private var uiEnergySave:UIEnergySave;
		private var uiSms:UISms;
		private var uiSysEvents:UISysEvents;
		private var uiKeys:UIKeysK2;
		private var uiRctrl:UIRctrl;
		private var uiHistory:UIHistory;
		private var uiTest:UITest;
		private var uiUpdate:UIUpdate;
		
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
					if ( !uiVerinfo )
						uiVerinfo = new UIVerInfo;
					ui = uiVerinfo;
					break;
				case NAVI.DATE:
					
					if ( !uiDate )
						if( DS.alias == DS.K2 )uiDate = new UIDate;
						else uiDate = new UIDateK2M();
					ui = uiDate;
					break;
				case NAVI.SENSOR:
					if ( !uiSensor )
						uiSensor = new UISensor;
					ui = uiSensor;
					break;
				case NAVI.BUZZER_SIREN:
					if ( !uiZummer )
						uiZummer = new UIZummer;
					ui = uiZummer;
					break;
				case NAVI.NOTIF:
					if ( !uiNotify )
						uiNotify = new UINotify;
					ui = uiNotify;
					break;
				case NAVI.TM_READER:
					if ( !uiReader )
						uiReader = new UIReader;
					ui = uiReader;
					break;
				case NAVI.GPRS_SIM:
					if ( !uiSim )
						uiSim = new UISim(CONST.USE_GPRS_COMPR, CONST.USE_GPRS_ROAMING);
					ui = uiSim;
					break;
				case NAVI.POWER_SAVE:
					if ( !uiEnergySave )
						uiEnergySave = new UIEnergySave;
					ui = uiEnergySave;
					break;
				case NAVI.SMS_SETTING:
					if ( !uiSms )
						uiSms = new UISms;
					ui = uiSms;
					break;
				case NAVI.SYS_EVENTS:
					if ( !uiSysEvents )
						uiSysEvents = new UISysEvents;
					ui = uiSysEvents;
					break;
				case NAVI.TM_KEYS:
					if ( !uiKeys )
						uiKeys = new UIKeysK2;
					ui = uiKeys;
					break;
				case NAVI.RF_RCTRL:
					if ( !uiRctrl )
						uiRctrl = new UIRctrl;
					ui = uiRctrl;
					break;
				case NAVI.HISTORY:
					if ( !uiHistory )
						uiHistory = new UIHistory;
					ui = uiHistory;
					break;
				case NAVI.TEST:
					if ( !uiTest )
						uiTest = new UITest;
					ui = uiTest;
					break;
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIServiceLocal;
					ui = uiService;
					break;
				case NAVI.UPDATE:
					if ( !uiUpdate )
						uiUpdate = new UIUpdate;
					ui = uiUpdate;
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