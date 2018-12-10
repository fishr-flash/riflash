package components.gui.visual
{
	import components.interfaces.IPositioner;
	import components.static.COLOR;
	
	import flash.display.Shape;
	
	public class Separator extends Shape implements IPositioner
	{
		private var w:int = 0;
		private var color:int = 0x9fc9eb;
		public function Separator( _length:int=500, debug:Boolean=false )
		{
			if (debug)
				color = COLOR.RED;
			width = _length;
		}
		public function getWidth():int
		{
			return w;
		}
		public function getHeight():int
		{
			return 10;
		}
		override public function set width(value:Number):void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1,color  );
			this.graphics.lineTo( value, 0);
			this.graphics.endFill();
			
			w = value;
		}
		override public function get height():Number
		{
			return 1;
		}
		public function change(c:uint):void
		{
			color = c;
			width = w;
		}
	}
}
