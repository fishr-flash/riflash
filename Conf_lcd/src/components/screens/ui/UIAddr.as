package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIAddr extends UI_BaseComponent
	{
		public function UIAddr()
		{
			super();
			
			createUIElement( new FSSimple, CMD.SET_ADDR_DATA, loc("lcdkey_adr"), null, 1, null, "0-9",2, new RegExp(RegExpCollection.COMPLETE_1to16) );
			attuneElement( 400, 50 );
			
			starterCMD = CMD.SET_ADDR_DATA;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			loadComplete();
		}
	}
}