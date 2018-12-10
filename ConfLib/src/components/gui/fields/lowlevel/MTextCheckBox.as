package components.gui.fields.lowlevel
{
	import components.gui.SimpleTextField;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.lowlevel.interfaces.IComboBoxItem;
	import components.static.COLOR;
	
	public class MTextCheckBox extends MCheckBox implements IComboBoxItem
	{
		private var nameField:SimpleTextField;
		
		public function MTextCheckBox(_name:String)
		{
			super(false);
			
			nameField = new SimpleTextField(_name);
			addChild( nameField );
			
			nameField.height = 20;
			nameField.x = ICON_WIDTH + 6;
			layer.y = 9;
			layer.x = 3;
		}
		override public function set height(value:Number):void
		{
			nameField.height = value;
		}
		public function set data(obj:Object):void 	
		{
			if ( obj.trigger is int && obj.trigger == FSComboCheckBox.TRIGGER_I_SEPERATOR ) {
				enabled = false;
				this.visible = false;
			} else
				selected = Boolean(int(obj.data) == 1);
		}
		override public function set enabled(b:Boolean):void
		{
			super.enabled = b;
			
			if (nameField) {
				if (!b)
					nameField.textColor = COLOR.SATANIC_INVERT_GREY;
				else
					nameField.textColor = COLOR.BLACK;
			}
		}
	}
}