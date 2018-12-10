package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.static.CMD;

	public class OptSms_zone extends OptSms_line
	{
		public function OptSms_zone(_struct:int)
		{
			title = loc("g_zone");
			num_len = 2;
			operatingCMD = CMD.SMS_ZONE;
			
			super(_struct);
		}
		override protected function getGroup():Number
		{
			return 1050;
		}
	}
}