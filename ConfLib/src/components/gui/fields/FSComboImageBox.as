package components.gui.fields
{
	import components.gui.fields.lowlevel.MComboBox;
	import components.interfaces.IFocusable;
	
	import mx.collections.ArrayList;

	public class FSComboImageBox extends FSComboBox implements IFocusable
	{
		public function FSComboImageBox()
		{
			super();
		}
		override protected function construct():void
		{
			cell = new MComboBox(MComboBox.S_ListImageBox);
			addChild( cell );
			cell.width = 100;
			attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			configureListeners();
		}
		override public function setList( _arr:Array, _selectedIndex:int=-1 ):void
		{
			var al:ArrayList = new ArrayList;
			al.source = _arr;
			cell.dataProvider = al;
			cell.selectedIndex = _selectedIndex;
			if (!EDITABLE)
				installDefaultRegExp();
			trace("FSComboImageBox.setList(_arr, _selectedIndex)");
			
		}
		override public function setCellInfo( value:Object ):void
		{
			cellInfo = String(value);
			cell.data = cellInfo;
			validate(cellInfo);
		}
	}
}