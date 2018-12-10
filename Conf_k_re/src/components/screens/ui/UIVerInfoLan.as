package components.screens.ui
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.Balloon;
	import components.gui.fields.FSButton;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UIVerInfoLan extends UI_BaseComponent
	{
		public function UIVerInfoLan()
		{
			super();
			
			var shift:int = 220;
			
			var clr:uint = COLOR.GREEN_DARK;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_device_name"),null,1);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			createUIElement( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_fw_ver"),null,2);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			
			globalY -= 10;
			drawSeparator(400);
			
			addui( new FSShadow, CMD.VER_INFO1, "", null, 1 );
			addui( new FSShadow, CMD.VER_INFO1, "", null, 2 );
			addui( new FSShadow, CMD.VER_INFO1, "", null, 3 );
			
			addui( new FSButton, CMD.VER_INFO1, loc("ui_verinfo_imei"), onClick, 4 );
			attuneElement( shift );
			
			/*createUIElement( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_imei"),null,4);
			attuneElement( shift, 170, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );*/
			addui( new FSShadow, CMD.VER_INFO1, "", null, 5 );
			addui( new FSShadow, CMD.VER_INFO1, "", null, 6 );
			
			drawSeparator(400);
			
			addui( new FSSimple, 0, loc("k5_lan_mac"), null, 1 );
			attuneElement( shift, 170, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( clr );
			addui( new FSSimple, 0, loc("k5_lan_ip"), null, 2 );
			attuneElement( shift, 170, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( clr );
			
			starterCMD = [CMD.VER_INFO1, CMD.LAN_MAC, CMD.LAN_DHCP_SETTINGS];
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VER_INFO1:
					pdistribute(p);
					
					getField(CMD.VER_INFO,1).setCellInfo( DS.name );
					getField(CMD.VER_INFO,2).setCellInfo( OPERATOR.dataModel.getData(CMD.VER_INFO)[0][1] );
					break;
				case CMD.LAN_MAC:
					getField(0,1).setCellInfo( getMac(p.getStructure()) );
					break;
				case CMD.LAN_DHCP_SETTINGS:
					getField(0,2).setCellInfo( getIp(p.getStructure()) );
					loadComplete();
					break;
			}
		}
		private function getMac(a:Array):String
		{
			var k:String = "";
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				
				if (i>0)
					k += ":";
				k+= UTIL.fz(int(a[i]).toString(16),2);
			}
			return k.toUpperCase();
		}
		private function getIp(a:Array):String
		{
			return a[1]+"."+a[2]+"."+a[3]+"."+a[4];
		}
		private function onClick():void
		{
			var s:String = String(getField(CMD.VER_INFO1,4).getCellInfo());
			Clipboard.generalClipboard.clear();
			var result:Boolean = Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, s);
			
			if (result)
				Balloon.access().shownote( loc("ui_verinfo_imei") + " "+ loc("options_in_buffer") );
			else
				Balloon.access().shownote( loc("sys_error_happens") );
		}
	}
}