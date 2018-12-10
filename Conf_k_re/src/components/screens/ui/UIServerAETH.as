package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIServerAETH extends UI_BaseComponent
	{
		private var ruleIpAdr:RegExp;
		private var ruleDomain:RegExp;
		
		public function UIServerAETH()
		{
			super();
			
			var sh:int = 130;
			var w:int = 170;
			
			/** Команда LAN_SERVER_CONNECT - настройка параметров подключения к серверу
			 Параметр 1 -  переключатель работы с сервером, 0 - отключен, 1 - включен
			 Параметры 2-5 - IP адрес сервера
			 Параметр 6 - порт сервера
			 Параметр 7 - пароль подключения к серверу	*/
			
			addui( new FSSimple, 0, loc("g_ipdomen"), onInput, 1, null, "", 15, new RegExp("^"+RegExpCollection.RE_IP_ADDRESS+"|"+RegExpCollection.RE_DOMEN + "$") );
			attuneElement( sh, w );
			
			var cmd:int = CMD.LAN_SERVER_CONNECT;
			
			addui( new FSSimple, cmd, loc("g_port"), null, 6, null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT) );
			attuneElement( sh+110, 60 );
			addui( new FSSimple, cmd, loc("g_pass"), null, 7, null, "A-z0-9", 8, new RegExp(RegExpCollection.REF_8SYMBOL) );
			attuneElement( sh+70, 100 );
			addui( new FSShadow, cmd, "", null, 8, null, "A-z0-9", 8, new RegExp(RegExpCollection.REF_8SYMBOL) );
			
			/*addui( new FSSimple, cmd, loc("network_domain"), null, 8, null, "A-z0-9.", 63, new RegExp( "^$|" +RegExpCollection.RE_DOMEN + "$") );
			attuneElement( sh+70, 100 );*/
			
			drawSeparator();
			
			addui( new FSCheckBox, cmd, loc("k5_lan_server_events_on"), null, 1 );
			attuneElement( sh + w - 12, NaN, FSCheckBox.F_MULTYLINE );
			
			for (var i:int=0; i<4; i++) {
				addui( new FSShadow, cmd, "", null, i+2 );
			}
			
			starterCMD = cmd;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			
			if (!ruleDomain)
				ruleDomain = new RegExp(RegExpCollection.REF_DOMEN);
			
			var a:Array = p.data[0];
			if( a[7] == "" || !ruleDomain.test(a[7]) )
				getField(0,1).setCellInfo( a[1]+"."+a[2]+"."+a[3]+"."+a[4] );
			else
				getField(0,1).setCellInfo( a[7] );
			loadComplete();
		}
		private function onInput(t:IFormString):void
		{
			if (t.valid) {
				
				var s:String = String(t.getCellInfo());
				
				if (!ruleIpAdr)
					ruleIpAdr = new RegExp(RegExpCollection.REF_IP_ADDRESS);
				
				var domain:String = "";
				var ips:Array;
				if( ruleIpAdr.test(s) ) {
					ips = String(t.getCellInfo()).split(".");
				} else {
					ips = [0,0,0,0];
					domain = s;
				}
				for (var i:int=0; i<4; i++) {
					getField(CMD.LAN_SERVER_CONNECT, i+2 ).setCellInfo( ips[i] );
				}
				getField(CMD.LAN_SERVER_CONNECT, 8 ).setCellInfo(domain);
				
				remember( getField(CMD.LAN_SERVER_CONNECT,1) );
			}
		}
	}
}