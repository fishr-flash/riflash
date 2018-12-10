package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.static.CMD;

	public class OptSms_Rctrl extends OptSms_line
	{
		public function OptSms_Rctrl(_struct:int)
		{
			title = loc("g_trinket");
			num_len = 2;
			operatingCMD = CMD.SMS_R_CTRL;
			
			super(_struct);
		}
		override protected function getGroup():Number
		{
			return 2050;
		}
	}
}