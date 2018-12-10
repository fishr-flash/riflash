package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIZummer extends UI_BaseComponent
	{
		public function UIZummer()
		{
			super();
			
			var cblist:Array = ([{label:loc("g_no"),data:0}] as Array).concat( UTIL.comboBoxNumericDataGenerator(1,30));
			
			createUIElement( new FSComboBox, CMD.BUZZER_SIREN, loc("zummer_zum_signal"),
				null,1,cblist,"0-9",2, new RegExp( RegExpCollection.REF_1to30_none));
			attuneElement( 440, 60 );
				
			createUIElement( new FSComboBox, CMD.BUZZER_SIREN, loc("zummer_alarm_signal"),
				null,2,cblist,"0-9",2, new RegExp( RegExpCollection.REF_1to30_none));
			attuneElement( 440, 60 );
			
			drawSeparator(540);
			
			cblist = [{label:loc("g_no"),data:0},{label:loc("zummer_title"),data:1},{label:loc("zummer_siren"),data:2},{label:loc("zummer_title")+"+"+loc("zummer_siren").toLowerCase(),data:3}];
			
			createUIElement( new FSComboBox, CMD.BUZZER_SIREN, loc("zummer_frequent_delay"),
				null,3,cblist);
			attuneElement( 400, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSComboBox, CMD.BUZZER_SIREN, loc("zummer_rare_delay"),
				null,4,cblist);
			attuneElement( 400, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSSimple, CMD.BUZZER_SIREN, loc("zummer_config_signal"),
				null, 7, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) );
			attuneElement( 400 );
			
			drawSeparator(540);
				
			createUIElement( new FSComboBox, CMD.BUZZER_SIREN, loc("zummer_confirm_set_on"),
				null,5,cblist);
			attuneElement( 400, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSComboBox, CMD.BUZZER_SIREN, loc("zummer_confirm_set_off"),
				null,6,cblist);
			attuneElement( 400, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			
			drawSeparator(540);
			
			starterCMD = CMD.BUZZER_SIREN;
				
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(1), CMD.BUZZER_SIREN );
			loadComplete();
		}
	}
}