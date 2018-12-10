package components.screens.ui
{
	public class UIServiceSimple extends UIServiceAdv
	{
		public function UIServiceSimple()
		{
			super();
		}
		override protected function getModuls():Array 
		{
			return [addFirmware];
		}
	}
}