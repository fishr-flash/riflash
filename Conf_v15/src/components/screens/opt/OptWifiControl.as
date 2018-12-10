package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.static.CMD;
	
	public class OptWifiControl extends OptionsBlock
	{
		public function OptWifiControl()
		{
			super();
			
			operatingCMD = CMD.SETTINGS_WIFI_NETS;
			
			createUIElement( new FSCheckBox, operatingCMD, loc("wifi_connect_best"), null, 1 );
			attuneElement( 300 );
			createUIElement( new FSCheckBox, operatingCMD, loc("wifi_connect_open"), null, 2 );
			attuneElement( 300 );
		}
		
		override public function putRawData(a:Array):void
		{
			distribute( a, operatingCMD );
		}
	}
}