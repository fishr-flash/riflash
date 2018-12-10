package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.interfaces.IBaseComponent;
	import components.screens.opt.OptOutRdk;
	import components.screens.ui.abstract.UIDeviceOutput;
	import components.static.CMD;
	
	public final class UIOutMenuRdk extends UIDeviceOutput
	{
		public function UIOutMenuRdk()
		{
			super();
			
			lastcmd = CMD.CTRL_TEMPLATE_RFSENSSTATE;
			
			starterCMD = [CMD.CTRL_INIT_OUT, CMD.CTRL_NAME_OUT, CMD.CTRL_TEST_OUT, 
				CMD.CTRL_TEMPLATE_OUT, CMD.CTRL_TEMPLATE_RCTRL,
				CMD.CTRL_GET_SENSOR, CMD.CTRL_DOUT_SENSOR,
				CMD.CTRL_TEMPLATE_RFSENSALARM, CMD.CTRL_TEMPLATE_RFSENSSTATE];
		}
		override protected function getTitle():String
		{
			return loc("relay");
		}
		override protected function getClass(str:int):IBaseComponent
		{
			return new OptOutRdk(str);
		}
	}
}