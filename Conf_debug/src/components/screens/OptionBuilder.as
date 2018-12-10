package components.screens
{
	import components.basement.UI_BaseComponent;
	import components.screens.ui.UIService;
	import components.static.NAVI;
	
	import mx.containers.Canvas;
	
	public class OptionBuilder
	{
		private var container:Canvas;
		private var subMenuContainer:Canvas;
		private var ui:UI_BaseComponent;

		private var uiService:UIService;
		
		public function OptionBuilder(c:Canvas, sm:Canvas)
		{
			container = c; 
			subMenuContainer = sm;
		}
		public function initProcess( cmd:int ):void 
		{
			ui = null;
			switch( cmd ) {
				case NAVI.SERVICE:
					if ( !uiService )
						uiService = new UIService;
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