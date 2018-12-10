package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSSimple;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class UIReader extends UI_BaseComponent
	{
		public function UIReader()
		{
			super();
			globalY = 20;
			var list:Array = [{label:loc("g_disabled_m"), data:0},{label:loc("ui_reader"), data:1},{label:loc("ui_reader_external_control"), data:2}];
			createUIElement( new FSComboBox, CMD.READER_TM2, loc("ui_reader_tm_output"),
				callLogic,1,list );
			attuneElement( 360,150, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			drawSeparator( 550 );
			createUIElement( new FSCheckBox, CMD.READER_TM2, loc("ui_reader_allow_guard_with_short_circuit"),
				null,2);
			attuneElement( 410+86, NaN, FSCheckBox.F_MULTYLINE );
			drawSeparator( 550 );

			var rg:FSRadioGroup = new FSRadioGroup( [ {label:loc("ui_reader_rg1"), selected:false, id:0x01 },
				 	{label:loc("ui_reader_rg2"), selected:false, id:0x02 },
					{trigger:FSRadioGroup.TRIGGER_SPACE},
				 	{label:loc("ui_reader_rg3"), selected:true, id:0x03 },
					{label:loc("ui_reader_rg4"), selected:true, id:0x04 }], 1 );
			rg.y = globalY;
			rg.x = globalX;
			rg.width = 496;
			addChild( rg )
			globalY += 175;
			addUIElement( rg, CMD.READER_TM2,3,callLogic);
			
			var sep:Separator = drawSeparator( 550 );
			sep.y -= 100;
			
			createUIElement( new FSSimple, CMD.READER_TM2, loc("reader_time_ext_circuit"),
				null,4, null, "0-9", 5, new RegExp( RegExpCollection.REF_300to10k ));
			attuneElement( 459, 50, FSSimple.F_MULTYLINE );
			
			height = 400;
		}
		override public function open():void
		{
			super.open();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.READER_TM2, put ));
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(1), CMD.READER_TM2 );
			callLogic();
			loadComplete();
		}
		private function callLogic(target:IFormString=null):void
		{
			var external_management:Boolean = int(getField( CMD.READER_TM2, 1 ).getCellInfo()) == 2;
			
			getField( CMD.READER_TM2,2).disabled = int(getField( CMD.READER_TM2, 1 ).getCellInfo()) != 1; 
			
			 getField( CMD.READER_TM2,3).disabled = !external_management;
			var selection:int = int(getField( CMD.READER_TM2,3).getCellInfo());
			//getField( CMD.READER_TM2,4).disabled = Boolean( !(selection == 3 || selection == 4) || !external_management);
			
			var isParam6disabled:Boolean = Boolean( !(selection == 3 || selection == 4) || !external_management);
			var param4:IFormString = getField( CMD.READER_TM2,4); 
			if (isParam6disabled == true && !param4.isValid( param4.getCellInfo().toString() ) )
				param4.setCellInfo("300");
			param4.disabled = isParam6disabled;
			
			
			if(target)
				remember( target );
		}
	}
}