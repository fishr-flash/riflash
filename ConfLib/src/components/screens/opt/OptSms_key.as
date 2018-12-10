package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.gui.fields.FormString;
	import components.static.CMD;

	public class OptSms_key extends OptSms_line
	{
		public function OptSms_key(_struct:int)
		{
			title = loc("rfd_tmkey");
			num_len = 3;
			operatingCMD = CMD.SMS_TM;
			
			super(_struct);
			
			(getField(operatingCMD,1) as FormString).rule = new RegExp(RegExpCollection.REF_1to255);
		}
		override protected function getGroup():Number
		{
			return 1550;
		}
	}
}