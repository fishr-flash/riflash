package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.static.CMD;

	public class OptSms_user extends OptSms_line
	{
		public function OptSms_user(_struct:int)
		{
			title = loc("g_user_cut");
			num_len = 3;
			operatingCMD = CMD.SMS_USER;
			
			super(_struct);
		}
		override protected function getGroup():Number
		{
			return 2550;
		}
	}
}


