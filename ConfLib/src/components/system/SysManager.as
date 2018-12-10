package components.system
{
	import flash.display.Stage;
	
	import mx.core.FlexGlobals;

	public class SysManager
	{
		public function SysManager()
		{
		}
		public static function clearFocus(s:Stage):void
		{
			if (s)
				s.focus = null;
		}
		public static function getStage():Stage
		{
			return FlexGlobals.topLevelApplication.stage;
		}
	}
}