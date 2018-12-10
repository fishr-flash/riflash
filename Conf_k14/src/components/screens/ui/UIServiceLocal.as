package components.screens.ui
{
	import components.protocol.statics.CLIENT;
	import components.static.MISC;

	public class UIServiceLocal extends UIServiceAdv
	{
		public static const SEPARATOR_WIDTH:int = 370;
		
		public function UIServiceLocal()
		{
			super();
		}
		override public function open():void
		{
			super.open();
			CLIENT.NO_DELAY_PROGRESSION = true;
		}
		override public function close():void
		{
			super.close();
			CLIENT.NO_DELAY_PROGRESSION = false;
		}
		override protected function getModuls():Array 
		{
			
			if (MISC.COPY_DEBUG)
				return [addFirmware, addConfig,addPhoneRequester, getForceSwitcher ];
			return [addConfig,addPhoneRequester, getForceSwitcher];
			
			function getForceSwitcher():ForceSwitcherGPRS
			{
				
				const fSwitch:ForceSwitcherGPRS = new ForceSwitcherGPRS( SEPARATOR_WIDTH );
				addChild( fSwitch );
				return  fSwitch;
			}
		}
	}
}