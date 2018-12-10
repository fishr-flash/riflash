package components.gui.visual.deviceMap
{
	import components.abstract.functions.loc;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;

	public class Sensor_line_keyboard extends Sensor_line
	{
		public function Sensor_line_keyboard()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			createConveyor( num = new Sensor_root() );
			createConveyor( tamper = new Sensor_root() );
			createConveyor( signalAntenna1 = new Sensor_root() );
			createConveyor( signalAntenna2 = new Sensor_root() );
		}
		private function checkBoard( _isEven:Boolean ):void 
		{
			switch( _isEven ) {
				case true:
					signalAntenna2.setDark();
					tamper.setDark();
					break;
				case false:
					num.setDark();
					signalAntenna1.setDark();
					break;
			}
		}
		override public function labelMode():void 
		{
			num.label = loc("rfd_number");
			tamper.label = loc("rfd_tamper");
			signalAntenna1.label = loc("rfd_antenna_signal_dbm1");
			signalAntenna2.label = loc("rfd_antenna_signal_dbm2");
			componentHeight = signalAntenna2.getHeight();
		}
		override public function insertData( _num:int, _arr:Array ):void
		{
			checkBoard( Boolean( _num & 0x01 > 0 ));
			
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			/*if (a[_num-1][0] == 1)
				num.text = String(_num) + "-"+a[_num-1][1];
			else*/
			num.text = String(_num);
			
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
				
				tamper.setState( Sensor_root.STATE_NOTEXIST );
				
				signalAntenna1.value = String( _arr[1] );
				signalAntenna2.value = String( _arr[2] );
				
			} else if ( (_arr[0] & 128) > 0 ) {
				signalAntenna1.setState( Sensor_root.STATE_LOST );
				signalAntenna2.setState( Sensor_root.STATE_LOST );
				
				tamper.setState( Sensor_root.STATE_LOST );
			} else {
				if( signalAntenna1.currentState == Sensor_root.STATE_LOST ) {
					signalAntenna1.setState( Sensor_root.STATE_NOTEXIST);
					signalAntenna2.setState( Sensor_root.STATE_NOTEXIST );
				}
				signalAntenna1.value = String( _arr[1] );
				signalAntenna2.value = String( _arr[2] );
				
				tamper.setState( getState( _arr[0] , 4 ) );
			}
		}
	}
}