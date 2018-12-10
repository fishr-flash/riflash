package components.screens
{
	import mx.containers.Canvas;
	
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIAccCalibrate;
	import components.screens.ui.UIAccOut;
	import components.screens.ui.UIAddr;
	import components.screens.ui.UIDisplay;
	import components.screens.ui.UIDstVerInfo;
	import components.screens.ui.UILogo;
	import components.screens.ui.UISensorMenu;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIVerInfo;
	import components.static.NAVI;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiService:UIServiceLocal;
		private var uiUpdate:UIUpdate;
	
		// ACC2
		private var uiVerinfoAcc:UIDstVerInfo;
		private var uiAccCalibrate:UIAccCalibrate;
		private var uiAccOut:UIAccOut;
		private var uiSensorMenu:UISensorMenu;
		// LCD
		private var uiVerinfo:UIVerInfo;
		private var uiLogo:UILogo;
		private var uiAddr:UIAddr;
		private var uiDisplay:UIDisplay;
		
		public function OptionBuilder(c:Canvas, sm:Canvas)
		{
			container = c; 
			subMenuContainer = sm;
		}
		public function initProcess( cmd:int ):void 
		{
			ui = null;
// LCD	****************************************************************	
			switch( cmd ) {
				case NAVI.VER_INFO:
					if ( !uiVerinfo )
						uiVerinfo = new UIVerInfo;
					ui = uiVerinfo;
					break;
				case NAVI.DISPLAY:
					if ( !uiDisplay)
						uiDisplay = new UIDisplay;
					ui = uiDisplay;
					break;
				case NAVI.LOGO:
					if ( !uiLogo )
						uiLogo = new UILogo;
					ui = uiLogo;
					break;
				case NAVI.ADDRESS:
					if ( !uiAddr )
						uiAddr = new UIAddr;
					ui = uiAddr;
					break;
// ACC	****************************************************************			
				case NAVI.VER_INFO_ACC:
					if ( !uiVerinfoAcc )
						uiVerinfoAcc = new UIDstVerInfo;
					ui = uiVerinfoAcc;
					break;
				case NAVI.CONFIG:
					if ( !uiAccCalibrate )
						uiAccCalibrate = new UIAccCalibrate;
					ui = uiAccCalibrate;
					break;
				case NAVI.VSENSORS:
					if ( !uiSensorMenu )
						uiSensorMenu = new UISensorMenu;
					ui = uiSensorMenu;
					break;
				case NAVI.OUT:
					if ( !uiAccOut)
						uiAccOut = new UIAccOut;
					ui = uiAccOut;
					break;
// Service	***********************************************************				
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