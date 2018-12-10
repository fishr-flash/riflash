package components.screens.ui
{
	public class UIVerInfoRdk extends UIVersion
	{
		public function UIVerInfoRdk()
		{
			super(3,0xff);
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
	}
}