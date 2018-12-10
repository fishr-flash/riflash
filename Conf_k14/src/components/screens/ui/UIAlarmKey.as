package components.screens.ui
{
	import components.abstract.LOC;
	import components.abstract.servants.CIDServant;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIAlarmKey extends UI_BaseComponent
	{
		public function UIAlarmKey()
		{
			super();
			
			var label:String;
			if (DS.isDevice(DS.K14A))
				label = LOC.loc("ui_alarmkey_phrase1");
			else
				label = LOC.loc("ui_alarmkey_phrase2")
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, label,null,1);
			attuneElement(500,NaN, FormString.F_MULTYLINE );
			globalY += 10;
			FLAG_SAVABLE = true;
			
			createUIElement( new FSComboBox, CMD.ALARM_KEY, LOC.loc("ui_alarmkey_event"), null, 1, CIDServant.getEvent(CIDServant.CID_ALARM_KEY) );
			attuneElement( 300, 300, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_RETURNS_HEXDATA );
			
			var list:Array = [{label:LOC.loc("ui_alarmkey_immediatley"),data:0x01}, {label:LOC.loc("ui_alarmkey_hold1sek"),data:0x02},
				{label:LOC.loc("ui_alarmkey_hold2sek"),data:0x04}, {label:LOC.loc("ui_alarmkey_hold3sek"),data:0x06}];
			
			createUIElement( new FSComboBox, CMD.ALARM_KEY, LOC.loc("ui_alarmkey_button_press"), null, 2, list );
			attuneElement( 300, 300, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			starterCMD = CMD.ALARM_KEY;
			
			width = 650;
		}
		
		override public function put(p:Package):void
		{
			getField( CMD.ALARM_KEY,1).setCellInfo( p.getStructure()[0].toString(16) );
			getField( CMD.ALARM_KEY,2).setCellInfo( p.getStructure()[1] );
			loadComplete();
		}
	}
}