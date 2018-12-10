package components.gui.debug
{
	import flash.text.TextField;
	
	public class TextFieldDebug extends TextField
	{
		public function TextFieldDebug()
		{
			super();
		}
		override public function set text(value:String):void
		{
			super.text = value;
		}
	}
}