package components.gui.visual.deviceMap
{
	import components.abstract.functions.loc;
	import components.system.UTIL;
	
	public class Sensor_line_sensor_rdk extends Sensor_line
	{
		private var additional:Sensor_root;
		protected var battery:Sensor_root;
		
		public function Sensor_line_sensor_rdk()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			createConveyor( num = new Sensor_root() );
			createConveyor( main = new Sensor_root() );
			createConveyor( additional = new Sensor_root() );
			createConveyor( tamper = new Sensor_root() );
			createConveyor( battery = new Sensor_root() );
			createConveyor( signalAntenna1 = new Sensor_root() );
			createConveyor( signalAntenna2 = new Sensor_root() );
				
		}
		private function checkBoard( _isEven:Boolean ):void 
		{
			switch( _isEven ) {
				case true:
					main.setDark();
					tamper.setDark();
					signalAntenna1.setDark();
					break;
				case false:
					num.setDark();
					additional.setDark();
					battery.setDark();
					signalAntenna2.setDark();
					break;
			}
		}
		override public function labelMode():void 
		{
			num.label = loc("g_number");
			main.label = loc("rfd_main_zone");
			additional.label = loc("rfd_additional_wire");
			tamper.label = loc("rfd_tamper");
			battery.label = loc("sensor_battery");
			signalAntenna1.label = loc("rfd_antenna_signal_dbm1");
			signalAntenna2.label = loc("rfd_antenna_signal_dbm2");
			componentHeight = signalAntenna2.getHeight();
		}
		override public function insertData( _num:int, _arr:Array ):void
		{
			checkBoard( Boolean( _num & 0x01 > 0 ));
			num.text = String(_num);
			num.setState( Sensor_root.STATE_NOTEXIST );
			
			var len:int = _arr.length;
			var sensorDisabled:Boolean = true;
			for( var i:int; i < len; ++i ) {
				if ( _arr[i] != 0 ) {
					sensorDisabled = false;
					break;
				}
			}
			
			if ( sensorDisabled ) {
				signalAntenna1.setState( Sensor_root.STATE_NOTEXIST );
				signalAntenna2.setState( Sensor_root.STATE_NOTEXIST );
				main.setState( Sensor_root.STATE_NOTEXIST );
				additional.setState( Sensor_root.STATE_NOTEXIST );
				tamper.setState( Sensor_root.STATE_NOTEXIST );
				battery.setState( Sensor_root.STATE_NOTEXIST );
				
				signalAntenna1.value = String( _arr[1] );
				signalAntenna2.value = String( _arr[2] );
			
			} else if ( (_arr[0] & 128) > 0 ) {
				
				signalAntenna1.setState( Sensor_root.STATE_LOST );
				signalAntenna2.setState( Sensor_root.STATE_LOST );
				main.setState( Sensor_root.STATE_LOST );
				additional.setState( Sensor_root.STATE_LOST );
				tamper.setState( Sensor_root.STATE_LOST );
				battery.setState( Sensor_root.STATE_LOST );
				
			} else {
				if( signalAntenna1.currentState == Sensor_root.STATE_LOST ) {
					signalAntenna1.setState( Sensor_root.STATE_NOTEXIST);
					signalAntenna2.setState( Sensor_root.STATE_NOTEXIST );
				}
				if (UTIL.isBit(6,_arr[0]))
					num.setState( Sensor_root.STATE_FOUND );
				
				signalAntenna1.value = String( _arr[1] );
				signalAntenna2.value = String( _arr[2] );
				
				main.setState( getState( _arr[0] , 1 ) );
				additional.setState( getState( _arr[0] , 2 ) );
				tamper.setState( getState( _arr[0] , 4 ) );
				battery.setState( getState( _arr[0] , 8 ) );
			}
		}
		override public function reset():void
		{
			main.setState( Sensor_root.STATE_NOTEXIST );
			additional.setState( Sensor_root.STATE_NOTEXIST );
			tamper.setState( Sensor_root.STATE_NOTEXIST );
			battery.setState( Sensor_root.STATE_NOTEXIST );
			signalAntenna1.setState( Sensor_root.STATE_NOTEXIST );
			signalAntenna2.setState( Sensor_root.STATE_NOTEXIST );
		}
	}
}