package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIObject extends UI_BaseComponent
	{
		public function UIObject()
		{
			super();
			
			createUIElement( new FSSimple, CMD.OBJECT, loc("object_connect_srv"), null, 1, 
				null, "B-Fb-f0-9", 4, new RegExp( RegExpCollection.REF_CODE_OBJECT));
			attuneElement( 350, 60, FSSimple.F_TEXT_RETURNS_HEXDATA );
			
			width = 460;
			starterCMD = CMD.OBJECT;
		}
		override public function put(p:Package):void
		{
			getField(p.cmd,1).setCellInfo( int(p.getStructure()[0]).toString(16).toUpperCase());
			loadComplete();
		}
	}
}