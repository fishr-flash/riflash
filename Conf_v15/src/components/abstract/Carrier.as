package components.abstract
{
	import components.interfaces.ICarrier;
	import components.system.UTIL;
	
	import mx.core.UIComponent;
	
	public class Carrier extends UIComponent implements ICarrier
	{
		public var isMoving:Boolean = false;
		
		private var _desired_x:int;
		private var _desired_y:int;
		
		public function Carrier()
		{
			super();
		}
		public function set desired_x(n:int):void
		{
			_desired_x = n;
		}
		public function set desired_y(n:int):void
		{
			_desired_y = n;
		}
		public function get desired_x():int
		{
			return _desired_x;
		}
		public function get desired_y():int
		{
			return _desired_y;
		}
		public function start(dx:int, dy:int):void
		{
			desired_x = dx;
			desired_y = dy;
			isMoving = true;
		}
		public function slide():void
		{
			this.x = this.x - int((this.x-desired_x)/3); 
			this.y = this.y - int((this.y-desired_y)/3);
			
			if ( UTIL.mod(this.x - desired_x) <3 )
				this.x = desired_x;
			
			if ( UTIL.mod(this.y - desired_y) <3 )
				this.y = desired_y;
			
			if ( this.x == desired_x && this.y == desired_y ) {
				desired_x = 0;
				desired_y = 0;
				isMoving = false;
			}
		}
	}
}