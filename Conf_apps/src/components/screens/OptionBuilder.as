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
	import components.screens.ui.UILogoUploaderLCD3;
	import components.screens.ui.UIPartitions;
	import components.screens.ui.UIRedrawIcons;
	import components.screens.ui.UISensTermWTSOfFourParam;
	import components.screens.ui.UISensorMenu;
	import components.screens.ui.UIServiceLocal;
	import components.screens.ui.UIUpdate;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIZones;
	import components.static.DS;
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
		private var uiLogoLcd3:UILogoUploaderLCD3;
		private var uiLogo:UILogo;
		private var uiRedrawIcons:UIRedrawIcons;
		private var uiAddr:UIAddr;
		private var uiDisplay:UIDisplay;
		private var uIPartitions:UIPartitions;
		private var uIZones:UIZones;

		private var uiTemperature:UISensTermWTSOfFourParam;
		private var uiTemperature_II:UISensTermWTSOfFourParam;
		
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
					if( DS.isfam( DS.LCD3 ) )
					{
						if ( !uiLogoLcd3 )
							uiLogoLcd3 = new UILogoUploaderLCD3 ;
						ui = uiLogoLcd3;
					}
					else
					{
						if( !uiLogo )
							uiLogo = new UILogo;
						ui = uiLogo;
					}
					
					break;
				case NAVI.REDRAW_ICONS:
					if ( !uiRedrawIcons )
						uiRedrawIcons = new UIRedrawIcons();
					ui = uiRedrawIcons;
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
				case NAVI.PARTITIONS:
					if ( !uIPartitions )
						uIPartitions = new UIPartitions;
					ui = uIPartitions;
					break;
				case NAVI.TEMPERATURE:
					if ( !uiTemperature )
						uiTemperature = new UISensTermWTSOfFourParam;
					ui = uiTemperature;
					break;
				
				case NAVI.ZONES:
					if ( !uIZones )
						uIZones = new UIZones;
					ui = uIZones;
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