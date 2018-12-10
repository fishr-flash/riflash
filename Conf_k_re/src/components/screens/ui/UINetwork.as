package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Balloon;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.SavePerformer;
	
	public class UINetwork extends UI_BaseComponent
	{
		public function UINetwork()
		{
			super();
			
			var sh:int = 250;
			var w:int = 170;
			
			/** Команда LAN_MAC - MAC адрес панели
			Параметр 1 - 6 - значения байтов MAC адреса, от старшего к младшему	*/
			
		/*	addui( new FSMac, 0, "MAC-адрес", onMac, 1, null, "A-Fa-f0-9:", 17, new RegExp(RegExpCollection.REF_MAC_ADDRESS) );
			attuneElement( sh, w );
			*/
			FLAG_VERTICAL_PLACEMENT = false;
			var shiftx:int = globalX + 140;
			
			addui( new FSSimple, CMD.LAN_MAC, loc("lan_mac_adress"), null, 1, null, "A-Fa-f0-9",2 );
			if (MISC.COPY_DEBUG)
				attuneElement( 100, 30, FSSimple.F_CELL_ALIGN_CENTER );
			else
				attuneElement( 100, 30, FSSimple.F_CELL_ALIGN_CENTER | FSSimple.F_CELL_NOTSELECTABLE );
			getLastElement().setAdapter( new MacAdapter(getLastElement()) );
			getLastElement().addEventListener( GUIEvents.EVOKE_TOGLE, onMacTogle );
			
			var tf:SimpleTextField = new SimpleTextField(":");
			addChild( tf );
			tf.x = shiftx - 9;
			tf.y = globalY;
			
			for (i=1; i<6; i++) {
				addui( new FormString, CMD.LAN_MAC, "", null, i+1, null, "A-Fa-f0-9",2 ).x = shiftx;
				if (MISC.COPY_DEBUG)
					attuneElement( 30, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
				else
					attuneElement( 30, NaN, FormString.F_ALIGN_CENTER );
				
				shiftx += 40;
				getLastElement().setAdapter( new MacAdapter(getLastElement()) );
				getLastElement().addEventListener( GUIEvents.EVOKE_TOGLE, onMacTogle );
				
				if (i != 5 ) {
					tf = new SimpleTextField(":");
					addChild( tf );
					tf.x = shiftx - 9;
					tf.y = globalY;
				}
				
				if (i == 4 )
					FLAG_VERTICAL_PLACEMENT = true;
			}
			
			
			drawSeparator(500-39);
			
			/**"Команда LAN_DHCP_SETTINGS - настройка параметров DHCP
				Параметр 1 - переключатель DHCP, 0 - использовать настройки IP адреса, 1 - получить IP адрес автоматически
				Параметры 2 - 5  - IP адрес 
				Параметры 6 - 9 - маска подсети
				Параметры 10 - 13 - IP адрес шлюза	*/
			
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("lan_k5_dhcp"), selected:false, id:0x01 },
				{label:loc("lan_k5_manual"), selected:false, id:0 }], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = globalX;
			fsRgroup.width = sh+158;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.LAN_DHCP_SETTINGS, 1, onDhcp);
			
			globalY += 62;
			
			addui( new FSSimple, 0, loc("lan_ipadr"), onInput, 2, null, "0-9.", 15, new RegExp(RegExpCollection.REF_IP_ADDRESS) );
			attuneElement( sh, w );
			addui( new FSSimple, 0, loc("lan_subnet_mask"), onInput, 3, null, "0-9.", 15, new RegExp(RegExpCollection.REF_IP_ADDRESS) );
			attuneElement( sh, w );
			addui( new FSSimple, 0, loc("lan_k5_gateway"), onInput, 4, null, "0-9.", 15, new RegExp(RegExpCollection.REF_IP_ADDRESS) );
			attuneElement( sh, w );
			
			addui( new FSSimple, 0, loc("lan_preferred_dns"), onInput, 5, null, "0-9.", 15, new RegExp(RegExpCollection.REF_IP_ADDRESS) );
			attuneElement( sh, w );
			addui( new FSSimple, 0, loc("lan_alternate_dns"), onInput, 6, null, "0-9.", 15, new RegExp(RegExpCollection.REF_IP_ADDRESS) );
			attuneElement( sh, w );
			
			for (var i:int=1; i<21; i++) {
				addui( new FSShadow, CMD.LAN_DHCP_SETTINGS, "", null, i+1 );
			}
			
			starterCMD = [CMD.LAN_MAC, CMD.LAN_DHCP_SETTINGS];
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			var a:Array = p.data[0];
			switch(p.cmd) {
				case CMD.LAN_DHCP_SETTINGS:
					getField(0,2).setCellInfo( a[1]+"."+a[2]+"."+a[3]+"."+a[4] );
					getField(0,3).setCellInfo( a[5]+"."+a[6]+"."+a[7]+"."+a[8] );
					getField(0,4).setCellInfo( a[9]+"."+a[10]+"."+a[11]+"."+a[12] );
					getField(0,5).setCellInfo( a[13]+"."+a[14]+"."+a[15]+"."+a[16] );
					getField(0,6).setCellInfo( a[17]+"."+a[18]+"."+a[19]+"."+a[20] );
					onDhcp(null);
					
					SavePerformer.trigger({"after":after});
					
					loadComplete();
					break;
			}
		}
		private function onDhcp(t:IFormString):void
		{
			var b:Boolean = int(getField(CMD.LAN_DHCP_SETTINGS, 1).getCellInfo())==1;
			
			if (b) {
				(getField(0,2) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
				(getField(0,3) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
				(getField(0,4) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
				(getField(0,5) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
				(getField(0,6) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
			} else {
				(getField(0,2) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(getField(0,3) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(getField(0,4) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(getField(0,5) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(getField(0,6) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
			}
				
			if (t)
				remember(t);
		}
		private function onInput(t:IFormString):void
		{
			if (t.valid) {
				var a:Array = String(t.getCellInfo()).split(".");
				var start:int;
				switch(t.param) {
					case 2:
						start = 2;
						break;
					case 3:
						start = 6;
						break;
					case 4:
						start = 10;
						break;
					case 5:
						start = 14;
						break;
					case 6:
						start = 18;
						break;
				}
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					getField(CMD.LAN_DHCP_SETTINGS, start+i ).setCellInfo( a[i] );
				}
				remember( getField(CMD.LAN_DHCP_SETTINGS,1) );
			}
		}
		private function onMac(t:IFormString):void
		{
			if (t.valid) {
				var a:Array = String(t.getCellInfo()).split(":");
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					getField(CMD.LAN_MAC, i+1 ).setCellInfo( "0x"+a[i] );
				}
				remember( getField(CMD.LAN_MAC,1) );
			}
		}
		private function onMacTogle(e:Event):void
		{
			var p:int = (e.currentTarget as IFormString).param + 1;
			if (p != 7) {
				var f:FormString = getField(CMD.LAN_MAC,p) as FormString;
				TabOperator.getInst().iNeedFocus( f );
				f.selectAll();
			}
		}
		private function after():void
		{
			Balloon.access().show("sys_attention","misc_need_restart_to_apply");
		}
	}
}
import flash.events.Event;
import flash.events.EventDispatcher;

import components.events.GUIEvents;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;

class MacAdapter implements IDataAdapter
{
	private var edispathcher:EventDispatcher;
	
	public function MacAdapter(ed:EventDispatcher=null)
	{
		edispathcher = ed;
	}
	public function change(value:Object):Object
	{
		if (String(value).length == 2 && edispathcher)
			edispathcher.dispatchEvent(new Event(GUIEvents.EVOKE_TOGLE));
		return value;
	}
	public function adapt(value:Object):Object
	{
		return UTIL.fz( int(value).toString(16).toUpperCase(),2);
	}
	public function recover(value:Object):Object
	{
		return int("0x"+value);
	}
	public function perform(field:IFormString):void
	{
	}
}