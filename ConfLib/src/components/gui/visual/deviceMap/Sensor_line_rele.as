package components.gui.visual.deviceMap
{
	import components.abstract.functions.loc;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	
	public class Sensor_line_rele extends Sensor_line
	{
		private var shleif:Sensor_root;
		private var exit1:Sensor_root;
		private var exit2:Sensor_root;
		private var exit3:Sensor_root;
		private var exit4:Sensor_root;
		private var exit5:Sensor_root;
		private var exit6:Sensor_root;
		
		public function Sensor_line_rele()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			createConveyor( num = new Sensor_root() );
			createConveyor( main = new Sensor_root() );
			createConveyor( shleif= new Sensor_root() );
			createConveyor( tamper = new Sensor_root() );
			createConveyor( exit1 = new Sensor_root() );
			createConveyor( exit2 = new Sensor_root() );
			createConveyor( exit3 = new Sensor_root() );
			createConveyor( exit4 = new Sensor_root() );
			createConveyor( exit5 = new Sensor_root() );
			createConveyor( exit6 = new Sensor_root() );
			createConveyor( signalAntenna1 = new Sensor_root() );
			createConveyor( signalAntenna2 = new Sensor_root() );
		}
		private function checkBoard( _isEven:Boolean ):void 
		{
			switch( _isEven ) {
				case true:
					main.setDark();
					tamper.setDark();
					exit2.setDark();
					exit4.setDark();
					exit6.setDark();
					signalAntenna2.setDark();
					break;
				case false:
					num.setDark();
					shleif.setDark();
					exit1.setDark();
					exit3.setDark();
					exit5.setDark();
					signalAntenna1.setDark();
					break;
			}
		}
		override public function labelMode():void 
		{
			num.label = loc("rfd_number");
			main.label = loc("rfd_cpw");
			shleif.label = loc("rfd_wire");
			tamper.label = loc("rfd_tamper");
			exit1.label = loc("rfd_output")+" 1";
			exit2.label = loc("rfd_output")+" 2";
			exit3.label = loc("rfd_output")+" 3";
			exit4.label = loc("rfd_output")+" 4";
			exit5.label = loc("rfd_output")+" 5";
			exit6.label = loc("rfd_output")+" 6";
			signalAntenna1.label = loc("rfd_antenna_signal_dbm1");
			signalAntenna2.label = loc("rfd_antenna_signal_dbm2");
			componentHeight = signalAntenna2.getHeight();
		}
		override public function insertData( _num:int, _arr:Array ):void
		{
			checkBoard( Boolean( _num & 0x01 > 0 ));
			
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			if (a[_num-1][0] == 1)
				num.text = String(_num) + "-"+a[_num-1][1];
			else
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
				main.setState( Sensor_root.STATE_NOTEXIST );
				shleif.setState( Sensor_root.STATE_NOTEXIST );
				tamper.setState( Sensor_root.STATE_NOTEXIST );
				
				exit1.setState( Sensor_root.STATE_NOTEXIST );
				exit2.setState( Sensor_root.STATE_NOTEXIST );
				exit3.setState( Sensor_root.STATE_NOTEXIST );
				exit4.setState( Sensor_root.STATE_NOTEXIST );
				exit5.setState( Sensor_root.STATE_NOTEXIST );
				exit6.setState( Sensor_root.STATE_NOTEXIST );
				
				signalAntenna1.value = String( _arr[2] );
				signalAntenna2.value = String( _arr[3] );
				
			} else if ( (_arr[0] & 128) > 0 ) {
				signalAntenna1.setState( Sensor_root.STATE_LOST );
				signalAntenna2.setState( Sensor_root.STATE_LOST );
				main.setState( Sensor_root.STATE_LOST );
				shleif.setState( Sensor_root.STATE_LOST );
				tamper.setState( Sensor_root.STATE_LOST );

				exit1.setState( Sensor_root.STATE_LOST );
				exit2.setState( Sensor_root.STATE_LOST );
				exit3.setState( Sensor_root.STATE_LOST );
				exit4.setState( Sensor_root.STATE_LOST );
				exit5.setState( Sensor_root.STATE_LOST );
				exit6.setState( Sensor_root.STATE_LOST );
				
			} else {
				if( signalAntenna1.currentState == Sensor_root.STATE_LOST ) {
					signalAntenna1.setState( Sensor_root.STATE_NOTEXIST);
					signalAntenna2.setState( Sensor_root.STATE_NOTEXIST );
				}
				signalAntenna1.value = String( _arr[2] );
				signalAntenna2.value = String( _arr[3] );
				
				main.setState( getState( _arr[0] , 8 ) );
				shleif.setState( getState( _arr[0] , 2 ) );
				tamper.setState( getState( _arr[0] , 4 ) );
				
				exit1.setState( getState( _arr[1] , 1 ) );
				exit2.setState( getState( _arr[1] , 2 ) );
				exit3.setState( getState( _arr[1] , 4 ) );
				exit4.setState( getState( _arr[1] , 8 ) );
				exit5.setState( getState( _arr[1] , 16 ) );
				exit6.setState( getState( _arr[1] , 32 ) );
			}
		}
	}
}