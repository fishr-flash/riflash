package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.static.CMD;

	public class OptSms_part extends OptSms_line
	{
		public function OptSms_part(_struct:int)
		{
			title = loc("g_partition");
			num_len = 2;
			operatingCMD = CMD.SMS_PART;
			
			super(_struct);
		}
		override protected function getGroup():Number
		{
			return 550;
		}
	}
}