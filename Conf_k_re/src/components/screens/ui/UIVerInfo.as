package components.screens.ui
{
	
	
	public class UIVerInfo extends UIVersion
	{
		public function UIVerInfo()
		{
			super(7, 15);
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
	}
}