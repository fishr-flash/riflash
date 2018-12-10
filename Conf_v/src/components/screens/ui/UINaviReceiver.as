package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UINaviReceiver extends UI_BaseComponent
	{
		public function UINaviReceiver()
		{
			super();

			globalY += 10;
			
			var list:Array = UTIL.getComboBoxList( [ [0,loc("g_no")],[1,"RS232"]] );
			createUIElement( new FSComboBox, 0, 
				loc("gps_to_rs232"), null, 1, list );
			attuneElement( 350, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			starterCMD = 0;
		}
		override public function put(p:Package):void
		{
			distribute(p.getStructure(), p.cmd);
			loadComplete();
		}
	}
}