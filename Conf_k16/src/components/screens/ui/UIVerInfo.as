package components.screens.ui
{
	/*******************************************
	 * Редакция для 16го контакта, без сим карты
	 *******************************************/
	
	public class UIVerInfo extends UIVersion
	{
		public function UIVerInfo()
		{
			super(7);
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
	}
}