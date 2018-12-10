package components.gui.fields.lowlevel
{
	import components.gui.fields.lowlevel.interfaces.IComboBoxItem;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class MImage extends Sprite implements IComboBoxItem
	{
		private var img:Bitmap;
		
		public function MImage(b:Class)
		{
			img = new b;
			addChild( img );
		}
		
		override public function set height(value:Number):void
		{
		}
		
		override public function set width(value:Number):void
		{
		}
		
		override public function set y(value:Number):void
		{
			img.y = value;
		}
		
		override public function get width():Number
		{
			return 0;
		}
		
		public function set enabled(b:Boolean):void
		{
		}
		
		public function set data(obj:Object):void
		{
		}
	}
}