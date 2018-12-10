package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIIndication extends UI_BaseComponent
	{
		public function UIIndication()
		{
			super();
			
			createUIElement( new FSComboBox, CMD.VR2_IND_MODE, loc("indication_modes"), null, 1, UTIL.getComboBoxList([[0,loc("indication_standart")],[1,loc("indication_const")]]) );
			attuneElement( 300, 120, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			starterCMD = CMD.VR2_IND_MODE;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			loadComplete();
		}
	}
}