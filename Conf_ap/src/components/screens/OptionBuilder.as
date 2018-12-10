package components.screens
{
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIAlarmKeys;
	import components.screens.ui.UIConfig;
	import components.screens.ui.UIEngin;
	import components.screens.ui.UIGeneralOptions;
	import components.screens.ui.UIHistory;
	import components.screens.ui.UILinkChannels;
	import components.screens.ui.UIParamGPRS;
	import components.screens.ui.UISensorInfo;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UISms;
	import components.screens.ui.UISysEvents;
	import components.screens.ui.UIVUpdate;
	import components.static.NAVI;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		// k1
		private var uiGeneralOptions:UIGeneralOptions;
		private var uiSysEvents:UISysEvents;
		private var uiParamGPRS:UIParamGPRS;
		private var uiLinkChannels:UILinkChannels;
		private var uiAlarmKeys:UIAlarmKeys;
		private var uiEngin:UIEngin;
		private var uiSms:UISms;
		private var uiHistory:UIHistory;
		private var uiService:UIServiceLocal;
		// sensors
		private var uiConfig:UIConfig;
		private var uiUpdate:UIVUpdate;
		private var uiSensorInfo:UISensorInfo;
		
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
					if ( !uiSensorInfo )
						uiSensorInfo = new UISensorInfo;
					ui = uiSensorInfo;
					break;
				case NAVI.CONFIG:
					if ( !uiConfig )
						uiConfig = new UIConfig;
					ui = uiConfig;
					break;
				case NAVI.UPDATE:
					if ( !uiUpdate )
						uiUpdate = new UIVUpdate;
					ui = uiUpdate;
					break;
				// K1
				case NAVI.GENERAL_OPTIONS:
					if ( !uiGeneralOptions )
						uiGeneralOptions = new UIGeneralOptions;
					ui = uiGeneralOptions;
					break;
				case NAVI.SYS_EVENTS:
					if ( !uiSysEvents )
						uiSysEvents = new UISysEvents;
					ui = uiSysEvents;
					break;
				case NAVI.GPRS_SIM:
					if ( !uiParamGPRS )
						uiParamGPRS = new UIParamGPRS;
					ui = uiParamGPRS;
					break;
				case NAVI.LINK_CHANNELS:
					if ( !uiLinkChannels )
						uiLinkChannels = new UILinkChannels;
					ui = uiLinkChannels;
					break;
				case NAVI.ALARM_KEY:
					if ( !uiAlarmKeys )
						uiAlarmKeys = new UIAlarmKeys;
					ui = uiAlarmKeys;
					break;
				case NAVI.ENGIN_NUMB:
					if ( !uiEngin )
						uiEngin = new UIEngin;
					ui = uiEngin;
					break;
				case NAVI.SMS:
					if ( !uiSms )
						uiSms = new UISms;
					ui = uiSms;
					break;
				case NAVI.HISTORY:
					if ( !uiHistory )
						uiHistory = new UIHistory;
					ui = uiHistory;
					break;
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIServiceLocal;
					ui = uiService;
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