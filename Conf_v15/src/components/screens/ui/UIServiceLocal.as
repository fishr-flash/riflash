package components.screens.ui
{
	import components.screens.page.FirmWareAutoLoader;

	public class UIServiceLocal extends UIServiceAdv
	{
		public static const SEPARATOR_WIDTH:int = 370+221;
		
		private var autoloader:FirmWareAutoLoader;
		
		public function UIServiceLocal()
		{
			super();
			
			
		//	height = 360;
			width = 640;
		}
		override public function open():void
		{
			super.open();
		}
		override protected function getModuls():Array 
		{
			return [addV15PartitionMagic,addConfig,addPhoneRequester,addRestarter];
		}
	}
}