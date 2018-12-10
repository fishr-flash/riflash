package components.abstract
{
	public class SensorStatus
	{
		private var _status:int;
		public var struct:int; 
		
		public function SensorStatus( value:int, _struct:int=0 )
		{
			_status = value;
			struct = _struct;
		}
		public function get status():int {
			return _status;
		}
		public function set status( value:int ):void {
			_status = value;
		}
	}
}