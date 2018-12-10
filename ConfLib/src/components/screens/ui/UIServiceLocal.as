package components.screens.ui
{
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