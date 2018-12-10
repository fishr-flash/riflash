package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.interfaces.IBaseComponent;
	import components.screens.opt.OptRelay;
	import components.screens.ui.abstract.UIDeviceOutput;
	import components.static.CMD;
	
	public final class UIRelayMenu extends UIDeviceOutput
	{
		public function UIRelayMenu()
		{
			super();
			
			
			lastcmd = CMD.CTRL_TEMPLATE_OUT;
			
			
			starterCMD = [
				CMD.CTRL_INIT_OUT
				, CMD.CTRL_TEMPLATE_REACT_ST_PART
				, CMD.CTRL_TEMPLATE_REACT_ST_ZONE
				, CMD.CTRL_TEMPLATE_ALL_FIRE
				, CMD.CTRL_TEMPLATE_REACT_ST_EXT
				, CMD.CTRL_TEMPLATE_MANUAL_TIME
				, CMD.CTRL_TEMPLATE_OUT];
			
			
		}
		
		
		override protected function getTitle():String
		{
			return loc("relay");
		}
		override protected function getClass(str:int):IBaseComponent
		{
			return new OptRelay(str);
		}
		
		
	}
}