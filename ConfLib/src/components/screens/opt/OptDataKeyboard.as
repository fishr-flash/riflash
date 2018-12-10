package components.screens.opt
{
	import components.interfaces.IFormString;
	import components.static.CMD;

	public class OptDataKeyboard extends OptKeyboard
	{
		public function OptDataKeyboard()
		{
			super(false);
		}
		override protected function init_commands():void
		{
			cmd_keyboard = CMD.DATA_KEY;
			cmd_bzi = CMD.DATA_KEY_BZI;
			cmd_bzp = CMD.DATA_KEY_BZP;
			isRfKey = false;
		}
		override protected function onCall(t:IFormString):void
		{
			if (t) {
				var disable:Boolean = Boolean(int(t.getCellInfo()) == 0 || int(t.getCellInfo()) == 1);
				if (t == cbZummerOnFire)
					cbZummerOnFireTime.disabled = disable;
				if (t == cbZummerOnPanic)
					cbZummerOnPanicTime.disabled = disable;
			} else {
				cbZummerOnFireTime.disabled = Boolean(int(cbZummerOnFire.getCellInfo()) == 0 || int(cbZummerOnFire.getCellInfo()) == 1);
				cbZummerOnPanicTime.disabled = Boolean(int(cbZummerOnPanic.getCellInfo()) == 0 || int(cbZummerOnPanic.getCellInfo()) == 1);
			}
			super.onCall(t);
		}
	}
}