package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	/** Редакция для 1 Контакта */
	
	public class OptLinkChannel extends OptionsBlock
	{
		private var comLink:Array;
		private var channel:FSComboBox;
		private var tel:FormString;
		
		private var LOADING:Boolean=false;	// если false то будут очищаться поля Телефон/ип адрес при загрузке
		
		public function OptLinkChannel(struct:int)
		{
			super();
			
			structureID = struct;
			complexHeight = 25;
			FLAG_VERTICAL_PLACEMENT = false;
			
			comLink = [
				{label:loc("ui_linkch_not_in_use"),data:int(structureID-1)+"00"},
				{label:loc("ui_linkch_gsm"),data:int(structureID-1)+"01"},
				{label:"SMS",data:int(structureID-1)+"31"},
				{label:loc("ui_linkch_gprs_offline")+"1",data:int(structureID-1)+"11"},
				{label:loc("ui_linkch_gprs_offline")+"2",data:int(structureID-1)+"21"},
				{label:loc("ui_linkch_iserver"),data:int(structureID-1)+"41"}
			];
			
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, loc("g_number")+" " + structureID, null, 1 );
			FLAG_SAVABLE = true;
			
			/**	Параметр 2 - Телефонный номер или IP адрес или доменное имя */
			tel = createUIElement( new FormString, CMD.OP_h_CH_TEL,"",null,1,null,"+0-9",32,new RegExp("^" + RegExpCollection.RE_TEL_LC + "$")) as FormString;
			attuneElement( 250,NaN, FormString.F_EDITABLE );
			tel.x = 280;
			tel.disabled = true;
			var first:int = tel.focusorder;
			tel.focusorder++;
			
			/**	Параметр 5 - Канал связи */
			channel = createUIElement( new FSComboBox, CMD.OP_D_LINK_CHANNEL,"",changeChannel,1,comLink) as FSComboBox;
			attuneElement( 200,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			channel.x = 70;
			channel.focusorder = first;
		}
		override public function putData(p:Package):void
		{
			distribute(p.getStructure(p.structure), p.cmd );
		}
		override public function putRawData(a:Array):void
		{
			var len:int = comLink.length;
			var value:String = getChannelEvent("00");
			for (var i:int=0; i<len; i++) {
				if (comLink[i].data == a[0] ) {
					//distribute( a, CMD.OP_D_LINK_CHANNEL );
					value = a[0];
					break;
				}
			}
			
			distribute( [value], CMD.OP_D_LINK_CHANNEL );
			tel.disabled = (value == getChannelEvent("00") || value == getChannelEvent("11") || value == getChannelEvent("21") );
			if (!tel.disabled)
				tel.isValid();
		}
		private function changeChannel(target:IFormString):void
		{
			var value:String = String(target.getCellInfo());
			tel.disabled = (value == getChannelEvent("00") || value == getChannelEvent("11") || value == getChannelEvent("21") );
			if (!tel.disabled)
				tel.isValid();
			else {
				tel.setCellInfo("");
				remember( tel );
			}
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onGPRSOnline, {"isGPRSOnline":false, "getStructure":getStructure()} );
			remember( target );
		}
		public function get chEnabled():Boolean
		{
			var s:String = String(channel.getCellInfo());
			return String(channel.getCellInfo()) != getChannelEvent("00"); 
		}
		
		public function set chEnabled(value:Boolean):void
		{
			if (!value) {
				channel.setCellInfo( getChannelEvent("00") );
				remember(channel);
			}
			channel.disabled = !value;
		}
		private function getChannelEvent(s:String):String
		{
			return (structureID-1) + s;
		}
	}
}