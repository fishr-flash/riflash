package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIRctrl;
	import components.static.CMD;
	
	public class OptRctrl extends OptionListBlock
	{
		public function OptRctrl(s:int)
		{
			super();
			
			SELECTION_Y_SHIFT -= 1;
			
			operatingCMD = CMD.RF_RCTRL2;
			structureID = s;
			FLAG_VERTICAL_PLACEMENT = false;
			createUIElement( new FSShadow, operatingCMD, "1", null, 1 );
			createUIElement( new FormString, operatingCMD, "", null, 2, null, "", 30 );
			attuneElement( 250,NaN, FormString.F_EDITABLE );
			createUIElement( new FSComboBox, operatingCMD, "", null, 3, [{label:loc("rf_arm"), data:1},{label:loc("rf_button_disabled"), data:0}] ).x = 255;
			
			attuneElement( 250, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			createUIElement( new FSComboBox, operatingCMD, "", null, 4, [{label:loc("rf_disarm"), data:1},{label:loc("rf_button_disabled"), data:0}] ).x = 510;
			attuneElement( 250, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			createUIElement( new FSComboBox, operatingCMD, "", null, 5, [{label:loc("rctrl_panic_button"), data:1},{label:loc("rf_button_disabled"), data:0}] ).x = 765;
			attuneElement( 250, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSelection( 1025 );
			drawLoading(1025,loc("rctrl_adding"), cancel);
		}
		override public function putRawData(data:Array):void
		{
			distribute( data, operatingCMD );
			loadingVisible(false);
		}
		override public function call(value:Object, param:int):Boolean
		{
			if (param == structureID)
				loadingVisible(true);
			return true;
		}
		private function cancel():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_FUNCT, null, 1, [UIRctrl.TYPE,structureID,UIRctrl.FUNCT_CANCEL,0] ));
		}
	}
}