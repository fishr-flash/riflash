package components.gui.visual.wire
{
	import flash.display.GradientType;

	public class WireUnitBig extends WireUnit
	{
		public function WireUnitBig(_color:uint)
		{
			super(_color);
			
			var widthvalue:int = 35;
			tfLabel.x = -widthvalue;
			tfLabel.width = widthvalue*2;			
			tfLabel.y = -30;
			default_text_y = -30;
		}
		override public function draw(_color:uint):void
		{
			graphics.beginGradientFill( GradientType.RADIAL, [ doBrightness(_color), _color ], [1,1], [0,20]);
			graphics.moveTo(-15, -10);
			graphics.lineTo(15, -10);
			graphics.lineTo(0, 20);
			graphics.lineTo(-15, -10);
			graphics.endFill();
		}
		public function reDraw(_color:uint):void
		{
			graphics.clear();
			draw(_color);
			
			tfLabel.textColor = _color;
		}
	}
}