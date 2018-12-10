package components.gui.visual.wire
{
	import flash.display.GradientType;

	public class WireUnitBigSimple extends WireUnit
	{
		public function WireUnitBigSimple(_color:uint)
		{
			super(_color);
			
			tfLabel.visible = false;
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
		}
	}
}