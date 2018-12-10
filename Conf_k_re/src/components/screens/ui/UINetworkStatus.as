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
	
	public class UINetworkStatus extends UI_BaseComponent
	{
		public function UINetworkStatus()
		{
			super();
			
			/** Команда LAN_SNMP_SETTINGS - настройка параметров работы по SNMP протоколу
				Параметр 1 -  переключатель SNMP, 0 - отключен, 1 - включен
				Параметр 2 - разрешение периодических TRAP посылок, 0 - посылки отключены, 1 - включены с периодом (см.параметр 3)
				Параметр 3 - период периодических TRAP посылок, в секундах (от 10 до 60)
				Параметры 4 - 7 - IP адрес для отправки TRAP посылок
				Параметры 8 - 11 - IP адрес, с которого допускается управление по SNMP
				Параметр 12 - пароль (community string) SNMP	*/
			
			var sh:int = 270;
			var w:int = 100;
			var shcb:int = 270+170-12;
			
			var cmd:int = CMD.LAN_SNMP_SETTINGS;
			
			addui( new FSCheckBox, cmd, loc("snmp_use"), null, 1 );
			attuneElement( shcb );
			
			addui( new FSSimple, cmd, loc("snmp_auth"), null, 12, null, "A-z0-9", 8 );
			attuneElement( sh+70, w );
			
			addui( new FSSimple, 0, loc("snmp_trusted_ip"),
				onInput, 1, null, "0-9.", 15, new RegExp(RegExpCollection.REF_IP_ADDRESS) );
			attuneElement( sh, w+70, FSSimple.F_MULTYLINE );
			
			drawSeparator(480);
			
			addui( new FSCheckBox, cmd, loc("snmp_trap"), null, 2 );
			attuneElement( shcb );
			addui( new FSSimple, 0, loc("snmp_msg_to_ip"),
				onInput, 2, null, "0-9.", 15, new RegExp(RegExpCollection.REF_IP_ADDRESS) );
			attuneElement( sh, w+70);
			addui( new FSSimple, cmd, loc("snmp_period_trap_msg"), null, 3, null, "0-9", 2, new RegExp("^(([1-5]\\d)|60)$") );
			attuneElement( sh+110, 60, FSSimple.F_MULTYLINE );
			
			for (var i:int=4; i<12; i++) {
				addui( new FSShadow, cmd, "", null, i );
			}
			
			drawSeparator(480);
			
			addui( new FSCheckBox, CMD.LAN_ICMP_ENABLE, loc("snmp_use_icmp"), null, 1 );
			attuneElement( shcb );
			addui( new FSCheckBox, CMD.LAN_WEB_ENABLE, loc("snmp_webserver"), null, 1 );
			attuneElement( shcb );
			
			starterCMD = [CMD.LAN_SNMP_SETTINGS, CMD.LAN_WEB_ENABLE, CMD.LAN_ICMP_ENABLE];
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			switch(p.cmd) {
				case CMD.LAN_SNMP_SETTINGS:
					var a:Array = p.data[0];
					getField(0,1).setCellInfo( a[7]+"."+a[8]+"."+a[9]+"."+a[10] );
					getField(0,2).setCellInfo( a[3]+"."+a[4]+"."+a[5]+"."+a[6] );
					break;
				case CMD.LAN_ICMP_ENABLE:
					loadComplete();
					break;
			}
		}
		private function onInput(t:IFormString):void
		{
			if (t.valid) {
				var a:Array = String(t.getCellInfo()).split(".");
				var start:int;
				switch(t.param) {
					case 1:
						start = 8;
						break;
					case 2:
						start = 4;
						break;
				}
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					getField(CMD.LAN_SNMP_SETTINGS, start+i ).setCellInfo( a[i] );
				}
				remember( getField(CMD.LAN_SNMP_SETTINGS,1) );
			}
		}
	}
}