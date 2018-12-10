package components.screens.ui
{
	import flash.system.System;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.Controller;
	import components.system.UTIL;
	
	public class UIServer extends UI_BaseComponent
	{
		private var ruleIpAdr:RegExp;
		private var ruleDomain:RegExp;

		private var _encryptKey:*;

		private var _copyButton:*;
		
		public function UIServer()
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
			
			drawSeparator();
			const wlabel:int = 310;
			const secw:int = 300;
			
			addui( new FSCheckBox, CMD.GPRS_ENCRYPTION, loc("encrypt_exchange_of_server"), null, 1 );
			attuneElement( 600 );
			
			FLAG_SAVABLE = false;
			const regexp:RegExp = /^\w{32}$/;
			_encryptKey = addui( new FSSimple, 0, loc( "key_encrypt_xtea" ), dlgtEnctyptKey, 1, null, "0-9 A-F", 32, regexp ) as FSSimple;
			attuneElement( wlabel, secw );
			FLAG_SAVABLE = true;
			
			var len:int = OPERATOR.getSchema( CMD.GPRS_ENCRYPTION ).Parameters.length + 1;
			for (var j:int=2; j<len; j++) {
				addui( new FSShadow, CMD.GPRS_ENCRYPTION, "", null, j, null, "0-9 A-F", 3 );
			}
			
			_copyButton = new TextButton();
			_copyButton.setUp( loc("g_copy_to_clip" ), onCopyCriptKey );
			_copyButton.x = 660;
			_copyButton.y = _encryptKey.y;
			this.addChild( _copyButton );
			starterCMD = [ cmd, CMD.GPRS_ENCRYPTION ];
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.LAN_SERVER_CONNECT:
					pdistribute(p);
					
					if (!ruleDomain)
						ruleDomain = new RegExp(RegExpCollection.REF_DOMEN);
					
					var a:Array = p.data[0];
					if( a[7] == "" || !ruleDomain.test(a[7]) )
						getField(0,1).setCellInfo( a[1]+"."+a[2]+"."+a[3]+"."+a[4] );
					else
						getField(0,1).setCellInfo( a[7] );
					loadComplete();
					
					break;
				case CMD.GPRS_ENCRYPTION:
					pdistribute( p );
					updateEncryptionField();
					break;
				default:
					break;
			}
			
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
		
		private function dlgtEnctyptKey( ):void
		{
			_copyButton.disabled = !_encryptKey.isValid(); 
			if( !_encryptKey.isValid() )
			{
				Controller.getInstance().showSave( false );
				return;
			}
			var hexWord:String = _encryptKey.getCellInfo() as String;
			var hex:String = "";
			
			var len:int = OPERATOR.getSchema( CMD.GPRS_ENCRYPTION ).Parameters.length;
			var it:int = 0;
			for (var j:int=1; j<len; j++) {
				it = j * 2;
				hex = hexWord.charAt( it - 2 ) + hexWord.charAt( it - 1 );
				
				getField( CMD.GPRS_ENCRYPTION, j + 1 ).setCellInfo( UTIL.hexToDec( hex ) );
				remember( getField( CMD.GPRS_ENCRYPTION, j + 1 ) );
				
				
				
			}
			
			
			
		}
		
		private function updateEncryptionField():void
		{
			var hexWord:String = "";
			var len:int = OPERATOR.getSchema( CMD.GPRS_ENCRYPTION ).Parameters.length + 1;
			for (var j:int=2; j<len; j++) {
				
				hexWord += Number( getField( CMD.GPRS_ENCRYPTION, j ).getCellInfo() ).toString( 16 ).toLocaleUpperCase();
			}
			
			_encryptKey.setCellInfo( hexWord );
		}
		private function onCopyCriptKey():void
		{
			System.setClipboard( _encryptKey.getCellInfo().toString() );
			
		}	
	}
}