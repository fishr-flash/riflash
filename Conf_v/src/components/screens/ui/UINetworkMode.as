package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSRadioGroup;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.PAGE;
	
	public class UINetworkMode extends UI_BaseComponent
	{
		public function UINetworkMode()
		{
			super();
			
			/**"Команда MODEM_NETWORK_CTRL - режим сети модема
				Параметр 1 - режим сети модема (0 - Auto, 1 - GSM 2G, 2 - WCDMA 3G)"*/
			
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("ui_gprs_2g3g"), selected:false, id:0 },
				{label:loc("ui_gprs_2g"), selected:false, id:1 },
				{label:loc("ui_gprs_3g"), selected:false, id:2 }
			], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = PAGE.CONTENT_LEFT_SHIFT;
			fsRgroup.width = 200;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.MODEM_NETWORK_CTRL, 1);
			
			starterCMD = CMD.MODEM_NETWORK_CTRL;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			loadComplete();
		}
	}
}