package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIDate extends UI_BaseComponent
	{
		public function UIDate()
		{
			super();
			
			addui( new FSSimple, CMD.SERVER_NTP, loc("ui_date_server_ntp"), null, 1, null,"",30, new RegExp( "^"+RegExpCollection.RE_DOMEN + "$") );
			attuneElement(274,220);
			
			starterCMD = CMD.SERVER_NTP;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			loadComplete();
		}
	}
}