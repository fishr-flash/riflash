package components.gui.fields
{
	import components.abstract.servants.TabOperator;
	import components.gui.fields.lowlevel.MComboBox;

	public class FSListCheckBox extends FSComboCheckBox
	{
		public function FSListCheckBox()
		{
			super();
		}
		override protected function construct():void
		{
			cell = new MComboBox(MComboBox.S_ListCheckBox);
			addChild( cell );
			cell.width = 100;
			configureListeners();
			
			attune( F_RETURNS_RAW_LABEL );
		}
		public function open(w:int, h:int, gx:int=0, gy:int=0):void
		{
			cell.open(w,h,gx,gy);
		}
		override public function getType():int
		{
			if (!cell.enabled || !cell.isOpened() )
				return TabOperator.TYPE_DISABLED;  
			return TabOperator.TYPE_ACTION;
		}
	}
}