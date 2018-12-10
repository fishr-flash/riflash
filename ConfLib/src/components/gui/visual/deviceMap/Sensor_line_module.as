package components.gui.visual.deviceMap
{
	import components.abstract.functions.loc;
	import components.system.UTIL;
	
	public class Sensor_line_module extends Sensor_line
	{
		//private var shleif:Sensor_root_module;
		private var exit1:Sensor_root_module;
		private var exit2:Sensor_root_module;
		private var exit3:Sensor_root_module;
		private var batteryI:Sensor_root_module;
		private var batteryII:Sensor_root_module;
		private var outPower:Sensor_root_module;
		private var lostLine:Boolean = false;
		//private var exit4:Sensor_root_module;
		//private var exit5:Sensor_root_module;
		//private var exit6:Sensor_root_module;
		
		public function Sensor_line_module()
		{
			super();
			
			construct();
			
			
		}
		private function construct():void 
		{
			createConveyor( num = new Sensor_root_module() );
			createConveyor( exit1 = new Sensor_root_module() );
			createConveyor( exit2 = new Sensor_root_module() );
			createConveyor( exit3 = new Sensor_root_module() );
			createConveyor( tamper = new Sensor_root_module() );
			createConveyor( batteryI = new Sensor_root_module() );
			createConveyor( batteryII = new Sensor_root_module() );
			createConveyor( outPower = new Sensor_root_module() );
			createConveyor( signalAntenna1 = new Sensor_root_module() );
			createConveyor( signalAntenna2 = new Sensor_root_module() );
			
			
			
		}
		
		/**
		 *  Раскраска клеточек в шахматном порядке
		 * 
		 */
		private function checkBoard( _isEven:Boolean ):void 
		{
			switch( _isEven ) {
				case true:
					exit1.setDark();
					exit3.setDark();
					batteryI.setDark();
					outPower.setDark();
					signalAntenna2.setDark();
					break;
				case false:
					num.setDark();
					exit2.setDark();
					tamper.setDark();
					batteryII.setDark();
					signalAntenna1.setDark();
					break;
			}
		}
		override public function labelMode():void 
		{
			num.label = loc("rfd_number");
			exit1.label = loc("rfd_output")+" 1";
			exit2.label = loc("rfd_output")+" 2";
			exit3.label = loc("rfd_output")+" 3";
			tamper.label = loc("rfd_tamper");
			batteryI.label = loc("sensor_battery")+" 1";
			batteryII.label = loc("sensor_battery")+" 2";
			outPower.label = loc("out_power");
			
			signalAntenna1.label = loc("rfd_antenna_signal_dbm1");
			signalAntenna2.label = loc("rfd_antenna_signal_dbm2");
			
			componentHeight = signalAntenna2.getHeight();
		}
		override public function insertData( _num:int, _arr:Array ):void
		{
			
			
			checkBoard( Boolean( _num & 0x01 > 0 ));
			
			 
			/*var a:Array = OPERATOR.dataModel.getData(CMD.RF_CTRL );
			
			if (a[_num-1][0] == 1)
				num.text = String(_num) + "-"+a[_num-1][1];
			else*/
				num.text = String(_num);
			
			
			var len:int = _arr.length;
			var sensorDisabled:Boolean = true;
			for( var i:int; i < len; ++i ) 
			{
				if ( _arr[i] != 0 ) {
					sensorDisabled = false;
					break;
				}
			}
			if ( sensorDisabled ) {
				
				signalAntenna1.setState( Sensor_root.STATE_NOTEXIST );
				signalAntenna2.setState( Sensor_root.STATE_NOTEXIST );
				exit1.setState( Sensor_root.STATE_NOTEXIST );
				exit2.setState( Sensor_root.STATE_NOTEXIST );
				exit3.setState( Sensor_root.STATE_NOTEXIST );
				tamper.setState( Sensor_root.STATE_NOTEXIST );
				batteryI.setState( Sensor_root.STATE_NOTEXIST );
				batteryII.setState( Sensor_root.STATE_NOTEXIST );
				outPower.setState( Sensor_root.STATE_NOTEXIST );
				signalAntenna1.value = String( _arr[5] );
				signalAntenna2.value = String( _arr[6] );
				
			} else if ( (_arr[0] & 128) > 0 ) {
				
				
				
				num.setState( Sensor_root.STATE_LOST );
				signalAntenna1.setState( Sensor_root.STATE_LOST);
				signalAntenna2.setState( Sensor_root.STATE_LOST );
				
				signalAntenna1.value = String( "" );
				signalAntenna2.value = String( "" );
				exit1.setState(  Sensor_root.STATE_LOST  );
				exit2.setState(  Sensor_root.STATE_LOST  );
				exit3.setState(   Sensor_root.STATE_LOST  );
				tamper.setState( Sensor_root.STATE_LOST );
				batteryI.setState( Sensor_root.STATE_LOST );
				batteryII.setState( Sensor_root.STATE_LOST );
				outPower.setState( Sensor_root.STATE_LOST );
			}
			else
			{
		
				signalAntenna1.setState( Sensor_root.STATE_NOTEXIST);
				signalAntenna2.setState( Sensor_root.STATE_NOTEXIST );
				
				signalAntenna1.value = String( _arr[5] );
				signalAntenna2.value = String( _arr[6] );
				exit1.setState(  getStateExits( _arr[ 1 ] ) );
				exit2.setState(  getStateExits( _arr[ 2 ] ) );
				exit3.setState(  getStateExits( _arr[ 3 ] ) );
				tamper.setState( UTIL.isBit( 1,_arr[ 4 ] )?Sensor_root.STATE_TRIGGER:Sensor_root.STATE_NORMAL );
				batteryI.setState( getStateBattery( 1, _arr[ 4 ] ) );
				batteryII.setState( getStateBattery( 2, _arr[ 4 ] ) );
				outPower.setState( UTIL.isBit( 0,_arr[ 4 ] )?Sensor_root.STATE_NORMAL:Sensor_root.STATE_TRIGGER );
			}
				
				
				
			if(  (_arr[0] & 64 ) > 0 )
			{
				num.setState( Sensor_root.STATE_FOUND );	
			}
			else
			{
				num.setState( Sensor_root.STATE_NOTEXIST );	
			}
			
				
				
				
				
			
			
			
		}
		
		
		
		private function getStateBattery( inx:int, bitmask:int ):int
		{
			
			const shift:int = inx == 1?2:4;
			
			
			const control:int = bitmask >> shift & 3;
			var condition:int = Sensor_root.STATE_NOTEXIST;
			
			
			switch( control & 3 ) 
			{
				case 1:
					
					condition = Sensor_root.STATE_TRIGGER;
					break;
				
				case 2:
					
					condition = Sensor_root.STATE_NORMAL;
					break;
				
				case 0:
					
					condition = Sensor_root.STATE_NOTEXIST;
					break;
				
				
			}
			
			
			return condition;
			
		}
		
		private function getStateExits( inv:int ):int
		{
			var outv:int = Sensor_root.STATE_TRIGGER;
			
			switch( inv ) {
				case 0xFF:
					outv = Sensor_root.STATE_NORMAL;
					break;
				
				case 0x04:
					outv = Sensor_root.STATE_NORMAL;
					break;
				
				
				default:
					outv = Sensor_root.STATE_TRIGGER;
					break;
			}
			
			
			return outv;
		}
		
		
		
	}
	
	
}