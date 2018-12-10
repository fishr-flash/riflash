package components.screens.ui
{
	public class UIDstVerInfo extends UIVersion
	{
		public function UIDstVerInfo()
		{
			super(3);
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
	}
}