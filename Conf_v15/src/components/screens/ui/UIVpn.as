package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIVpn extends UI_BaseComponent
	{
		private const cblist:Array = ["","Mutual PSK + XAuth","Certificate + XAuth"];
		
		public function UIVpn()
		{
			super();
			
			var fshift:int = 250;
			var fwidth:int = 209;
			var cbdistance:int = 197;
			
			addui( new FSCheckBox, CMD.VPN_SERVER, loc("lan_connect_vpn"), null, 1 );
			attuneElement( fshift+cbdistance ); 
			FLAG_VERTICAL_PLACEMENT = false;
			addui( new FSSimple, CMD.VPN_SERVER, loc("lan_domen_ip"), null, 2, null, "", 63,
				new RegExp("^" + RegExpCollection.RE_IP_ADDRESS + "|" + RegExpCollection.RE_DOMEN + "$"));
			attuneElement( fshift, 150, FSSimple.F_MULTYLINE );
			FLAG_VERTICAL_PLACEMENT = true;
			addui( new FormString, CMD.VPN_SERVER, "", null, 3, null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT) ).x = 440;
			attuneElement( 50, NaN, FormString.F_EDITABLE );
			
			drawSeparator();
			
			addui( new FSComboBox, CMD.VPN_SET_TYPE_AUTH, loc("lan_auth_type"), null, 1 );
			attuneElement( fshift, fwidth, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator();
			
			addui( new FSSimple, CMD.VPN_GROUP_ID, loc("lan_group_id"), null, 1, null, "", 32 );
			attuneElement( fshift, fwidth );
			addui( new FSSimple, CMD.VPN_GROUP_ID, loc("lan_group_pass"), null, 2, null, "", 32 );
			attuneElement( fshift, fwidth );
			FLAG_SAVABLE = false;
			addui( new FSCheckBox, 0, loc("g_show_pass"), onShowGroupPass, 1 );
			attuneElement( fshift+cbdistance );
			FLAG_SAVABLE = true;
			
			drawSeparator();
			
			addui( new FSSimple, CMD.VPN_USER_ID, loc("g_user"), null, 1, null, "", 32 );
			attuneElement( fshift, fwidth );
			addui( new FSSimple, CMD.VPN_USER_ID, loc("g_pass"), null, 2, null, "", 32 );
			attuneElement( fshift, fwidth );
			FLAG_SAVABLE = false;
			addui( new FSCheckBox, 0, loc("g_show_pass"), onShowUserPass, 2 );
			attuneElement( fshift+cbdistance );
			FLAG_SAVABLE = true;
			
			drawSeparator();
			
			starterCMD = [CMD.VPN_SERVER, CMD.VPN_GET_TYPE_AUTH, CMD.VPN_SET_TYPE_AUTH, CMD.VPN_GROUP_ID, CMD.VPN_USER_ID];
		}
		override public function open():void
		{
			super.open();
			
			onShowUserPass();
			onShowGroupPass();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VPN_GET_TYPE_AUTH:
					var len:int = p.length;
					var lst:Array = [];
					for (var i:int=0; i<len; ++i) {
						if (p.getStructure(i+1)[0] == 1)
							lst.push( {label:cblist[i+1], data:(i+1)} );
					}
					(getField(CMD.VPN_SET_TYPE_AUTH,1) as FSComboBox).setList( lst );
					break;
				case CMD.VPN_USER_ID:
					loadComplete();
				case CMD.VPN_SET_TYPE_AUTH:
				case CMD.VPN_SERVER:
				case CMD.VPN_GROUP_ID:
					distribute(p.getStructure(), p.cmd);
					break;
			}
		}
		private function onShowUserPass():void
		{
			var b:Boolean = getField(0,2).getCellInfo() == 0;
			(getField(CMD.VPN_USER_ID,2) as FSSimple).displayAsPassword( b );
		}
		private function onShowGroupPass():void
		{
			var b:Boolean = getField(0,1).getCellInfo() == 0;
			(getField(CMD.VPN_GROUP_ID,2) as FSSimple).displayAsPassword( b );
		}
	}
}