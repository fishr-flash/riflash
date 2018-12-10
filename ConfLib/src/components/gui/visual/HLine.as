package components.gui.visual
{
	import components.interfaces.IPositioner;
	
	import flash.display.Shape;
	
	public class HLine extends Shape implements IPositioner
	{
		private var w:int = 0;
		private var rotated:Boolean=false;
		
		public function HLine( _width:int=500 )
		{
			this.graphics.lineStyle( 1, 0xc4cccc );
			this.graphics.lineTo( _width, 0);
			w = _width;
		}
		public function getWidth():int
		{
			return w;
		}
		public function getHeight():int
		{
			return 10;
		}
		public function resize(value:int):void
		{
			this.graphics.clear();
			this.graphics.moveTo(0,0);
			this.graphics.lineStyle( 1, 0xc4cccc );
			if (rotated)
				this.graphics.lineTo( 0, value);
			else
				this.graphics.lineTo( value, 0);
			w = value;
		}
		public function rotate():void
		{
			rotated = !rotated;
			resize(w);
		}
	}
}