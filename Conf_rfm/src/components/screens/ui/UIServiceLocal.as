package components.screens.ui
{
	import components.static.DS;
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
			//if (DEVICES.isDevice(DEVICES.)
			//return [addFirmware,addConfig,addMasterCodeWriter];
			
			var moduls:Array = [addConfig];
			
			
			if (MISC.COPY_DEBUG)
				moduls = moduls.concat( [addFirmware] );

			
			
			
			
			
			return moduls;

		}
	}
}