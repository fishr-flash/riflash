package components.screens.ui
{
	import components.static.DEVICES;

	public class UIServiceLocal extends UIServiceAdv
	{
		public static const SEPARATOR_WIDTH:int = 370;
		
		public function UIServiceLocal()
		{
			super();
		}
		override protected function getModuls():Array 
		{
			return [addConfig];
		}
	}
}