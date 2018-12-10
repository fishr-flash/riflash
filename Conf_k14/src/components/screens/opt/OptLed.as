package components.screens.opt
{
	import components.abstract.LOC;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public final class OptLed extends OptionsBlock
	{
		private var selected_led:int;
		private var have_to_save:Boolean=false;
		
		public function OptLed(_str:int, _name:String )
		{
			super();
			
			structureID = _str;
			
			FLAG_VERTICAL_PLACEMENT = false;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, _name, null, 1 );
			createUIElement( new FormString, 0, LOC.loc("ui_led_partition"), null, 2 );
			getLastElement().x = 380;
			
			operatingCMD = CMD.LED14_IND;
			FLAG_SAVABLE = true;
			globalX = 150;
			
			var list:Array = [{label:LOC.loc("ui_led_noind"),data:0x00},{label:LOC.loc("ui_led_partition_state"),data:0x01},
				{label:LOC.loc("ui_led_unsend_events"),data:0x02},{label:LOC.loc("ui_led_power"),data:0x03},
				{label:LOC.loc("ui_led_gsm"),data:0x04}];
			
			createUIElement( new FSComboBox, operatingCMD, "", changeLed, 1,list );
			attuneElement( 200,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX = 450;
			createUIElement( new FSComboBox, operatingCMD, "", null, 2, PartitionServant.getPartitionList() );
			attuneElement( 60,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().disabled = true;
			
			complexHeight = 25;
		}
		override public function putRawData(re:Array):void
		{
			getField( operatingCMD,1).setCellInfo( String(re[0]) );
			(getField( operatingCMD,2) as FSComboBox).setList( PartitionServant.getPartitionList() );
			getField( operatingCMD,2).setCellInfo( String(re[1]) );
			changeLed();
		}
		private function changeLed(target:IFormString=null):void
		{
			selected_led = int(getField( operatingCMD,1).getCellInfo());
			
			var field:FSComboBox = getField( operatingCMD,2) as FSComboBox;
			field.disabled = Boolean(selected_led != 1);
			
			if (target) {
				if (selected_led == 1)
					field.setCellInfo( String(PartitionServant.getFirstPartition()) );
				else
					field.setCellInfo( "0" );
				SavePerformer.remember( getStructure(), field );
			}
		}
	}
}