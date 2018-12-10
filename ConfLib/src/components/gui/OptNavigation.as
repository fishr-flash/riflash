package components.gui
{
	import components.interfaces.IFocusable;
	import components.interfaces.INavigationItem;
	import components.static.PAGE;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.core.UIComponent;

	public class OptNavigation extends NavigationList
	{
		public var generated:Boolean=false;
		public var _disabled:Boolean;
		
		public function OptNavigation()
		{
			super();
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.width = PAGE.SECONDMENU_WIDTH;
		}
		public function disable(value:Boolean):void
		{
			if (_disabled != value) {
				block(value);
				_disabled = value;
			}
		}
		public function addOn(ui:UIComponent):void
		{
			menuAddon = ui;
			addChild( menuAddon );
			localResize();
		}
		public function setXOffset(value:int):void
		{
			buttonsXoffest = value;
		}
		public function permanentSelection(num:int=-1):void
		{
			
			if (num < 0)
				(aButtonList[aButtonList.length-1] as INavigationItem).drawPermanent();
			else {
				var len:int = aButtonList.length;
				for (var i:int=0; i<len; ++i) {
					if ((aButtonList[i] as INavigationItem).getId() == num) {
						(aButtonList[i] as INavigationItem).drawPermanent();
						break;
					}
				}
			}
		}
		public function resetPermanentSelection(num:int=-1):void
		{
			if (num < 0)
				(aButtonList[aButtonList.length-1] as INavigationItem).drawPermanent();
			else {
				var len:int = aButtonList.length;
				for (var i:int=0; i<len; ++i) {
					if (aButtonList[i] is INavigationItem && (aButtonList[i] as INavigationItem).getId() == num) {
						(aButtonList[i] as INavigationItem).drawPermanent(false);
						break;
					}
				}
			}
		}
		public function set focusable(b:Boolean):void
		{
			var len:int = aButtonList.length;
			for (var i:int=0; i<len; ++i) {
				(aButtonList[i] as IFocusable).focusable = b;
			}
		}
		public function getButtonById(value:int):IFocusable
		{
			var len:int = aButtonList.length;
			for (var i:int=0; i<len; ++i) {
				if( (aButtonList[i] as INavigationItem).getId() == value )
					return aButtonList[i] as IFocusable;
			}
			return null;
		}
	}
}