package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIAddress extends UI_BaseComponent
	{
		public function UIAddress()
		{
			super();
			
			addui( new FSSimple, CMD.SET_ADDR_DATA, loc("relay_adr"), null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) );
			attuneElement( 350, 60 )
			
			starterCMD = CMD.SET_ADDR_DATA;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			loadComplete();
		}
	}
}