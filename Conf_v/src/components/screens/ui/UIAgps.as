package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIAgps extends UI_BaseComponent
	{
		public function UIAgps()
		{
			super();
			
			createUIElement( new FSCheckBox, CMD.VR_AGPS_ENABLE, loc("agps_use"), null, 1 );
			attuneElement( 350 );
			globalY += 10;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("agps_use_technolgy"), null, 1 );
			attuneElement( 610, NaN, FormString.F_MULTYLINE );
			
			starterCMD = CMD.VR_AGPS_ENABLE;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			loadComplete();
		}
	}
}