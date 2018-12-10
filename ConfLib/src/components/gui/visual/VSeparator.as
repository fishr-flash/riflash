package components.gui.visual
{
	import components.interfaces.IPositioner;
	
	import flash.display.Shape;
	
	public class VSeparator extends Shape implements IPositioner
	{
		private var h:int = 0;
		private var color:int = 0x9fc9eb;
		public function VSeparator( _height:int=500 )
		{
			this.graphics.lineStyle( 1, color );
			this.graphics.lineTo( 0, _height);
			h = _height;
		}
		public function getWidth():int
		{
			return 10;
		}
		public function getHeight():int
		{
			return h;
		}
		public function resize(value:int):void
		{
			this.graphics.clear();
			this.graphics.moveTo(0,0);
			this.graphics.lineStyle( 3, color );
			this.graphics.lineTo( 0, value);
			h = value;
		}
	}
}