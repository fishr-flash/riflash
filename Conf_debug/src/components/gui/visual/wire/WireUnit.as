package components.gui.visual.wire
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class WireUnit extends Sprite
	{
		protected var default_text_y:int;
		protected var tfLabel:TextField;
		
		public function WireUnit(_color:uint)
		{
			super();
			
			var tf:TextFormat= new TextFormat;
		//	tf.color = _color;
			tf.size = 10;
			tf.font = "Verdana";
			tf.align = "center";
			tf.leading = -2;
			tf.bold = true;
			
			tfLabel = new TextField;
			addChild( tfLabel );
			tfLabel.defaultTextFormat = tf;
			tfLabel.y = 10;
			default_text_y = 10;
			tfLabel.x = -35;
			tfLabel.width = 70;
			tfLabel.height = 20;
			tfLabel.selectable = false;
			tfLabel.textColor = _color;
			tfLabel.multiline = true;
			tfLabel.text = "0";
			
			draw(_color);
		}
		public function draw(_color:uint):void
		{
			tfLabel.textColor = _color;
			graphics.beginGradientFill( GradientType.RADIAL, [ doBrightness(_color), _color ], [1,1], [0,20]);
			graphics.moveTo(-10, 10);
			graphics.lineTo(0, -10);
			graphics.lineTo(10, 10);
			graphics.lineTo(-10, 10);
			graphics.endFill();
		}
		protected function doBrightness( color:uint ):uint {
			var r:uint = (color >> 16) & 0xFF;
			var g:uint = (color >> 8) & 0xFF;
			var b:uint = color & 0xFF;
			
			r = r + uint((0xFF - r)/2);
			g = g + uint((0xFF - g)/2);
			b = b + uint((0xFF - b)/2);
			
			return (r << 16 | g << 8 | b);
		}
		public function set label(value:String):void
		{
			tfLabel.text = value;
			if (tfLabel.numLines > 1 ) {
				tfLabel.height = tfLabel.textHeight+10;
				tfLabel.y = -(tfLabel.height+5); 
			} else {
				tfLabel.y = default_text_y;
				tfLabel.height = 20;
			}
		}
	}
}