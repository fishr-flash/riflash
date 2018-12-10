package components.gui.visual.deviceMap
{
	import mx.core.UIComponent;
	
	public class Sensor_line extends UIComponent
	{
		protected var num:Sensor_root;
		protected var main:Sensor_root;
		protected var tamper:Sensor_root;
		protected var signalAntenna1:Sensor_root;
		protected var signalAntenna2:Sensor_root;
		//protected var signalDevice:Sensor_root;
		
		protected var globalX:int;
		protected var globalY:int;
		protected var componentHeight:int;
		
		public function Sensor_line()
		{
			super();
		}
		public function labelMode():void {}
		protected function createConveyor( _sen:Sensor_root ):void 
		{
			addChild( _sen );
			_sen.x = globalX;
			globalX += _sen.getWidth();
			componentHeight = _sen.getHeight();
		}
		protected function getState( _bit:int, _offset:int ):int 
		{
			if ( (_bit & _offset) > 0 ) {
				return 2;
			}
			return 1;
		}
		public function insertData( _num:int, _arr:Array ):void	{}
		public function getHeight():int
		{
			return num.getHeight();
		}
		public function getWidth():int 
		{
			return globalX;
		}
		public function reset():void {}
	}
}