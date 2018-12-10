package components.gui.fields.lowlevel
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import components.gui.fields.lowlevel.interfaces.IComboBoxItem;
	import components.static.PAGE;
	
	public class MCButton extends TextField implements IComboBoxItem
	{
		private var textFormat:TextFormat;
		
		public function MCButton(label:String)
		{
			super();
			
			textFormat = new TextFormat;
			textFormat.font = PAGE.MAIN_FONT;
			textFormat.underline = true;
			defaultTextFormat = textFormat;
			
			border = false;
			selectable = false;
			textColor = 0x287bbf;
			text = label;
			width = textWidth + 10;
		}
		
		public function set data(obj:Object):void
		{
		}
		public function set enabled(b:Boolean):void
		{
		}
	}
}