package components.screens.ui
{
	import components.static.MISC;

	public class UIServiceLocal extends UIServiceAdv
	{
		public static const SEPARATOR_WIDTH:int = 370;
		
		public function UIServiceLocal()
		{
			super();
		}
		override protected function getModuls():Array 
		{
			
			if (MISC.COPY_DEBUG)
				return [addFirmware,addConfig];
			return [addConfig];
		}
	}
}