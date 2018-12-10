package components.gui.visual.deviceMap
{
	import mx.core.UIComponent;
	
	import components.abstract.functions.dtrace;
	
	public class RadioDevicePanel extends UIComponent
	{
		private var aSensors:Array;
		private var labels:Sensor_line;
		
		private var radioDeviceType:int;
		
		public static var RADIOD_SENSORS:int = 0;
		public static var RADIOD_KEYBOARD:int = 1;
		public static var RADIOD_RELE:int = 2;
		public static var RADIOD_SENSORS_RDK:int = 3;
		public static var RADIOD_MODULE:int = 4	;
		
		public function RadioDevicePanel( _type:int )
		{
			super();
		
			switch( _type ) {
				case RADIOD_KEYBOARD:
					labels = new Sensor_line_keyboard;
					break;
				case RADIOD_SENSORS:
					labels = new Sensor_line_sensor;
					break;
				case RADIOD_RELE:
					labels = new Sensor_line_rele;
					break;
				case RADIOD_SENSORS_RDK:
					labels = new Sensor_line_sensor_rdk;
					break;
				case RADIOD_MODULE:
					labels = new Sensor_line_module;
					break;
			}
			
			addChild( labels );
			labels.labelMode();
			
			radioDeviceType = _type;
			
			
		}
		public function getWidth():int
		{
			return labels.getWidth();
		}
		public function reset():void
		{
			if (aSensors) {
				var len:int = aSensors.length;
				for (var i:int=0; i<len; ++i) {
					(aSensors[i] as Sensor_line).reset();
				}
			}
		}
		public function getHeight():int 
		{
			if ( aSensors ) {
				return labels.getHeight() + aSensors.length*aSensors[0].getHeight();
			}
			return labels.getHeight();
		}
		public function insertData( _arr:Array, _offset:int=1 ):void {
			
			var sen:Sensor_line;
			var len:int;
			var i:int;
			
			if ( !aSensors ) {
				aSensors = new Array;
				len = _arr.length;
				for( i=0; i < len; ++i ) {
					
					switch( radioDeviceType ) {
						case RADIOD_KEYBOARD:
							sen = new Sensor_line_keyboard;
							break;
						case RADIOD_SENSORS:
							sen = new Sensor_line_sensor;
							break;
						case RADIOD_RELE:
							sen = new Sensor_line_rele;
							break;
						case RADIOD_SENSORS_RDK:
							sen = new Sensor_line_sensor_rdk;
							break;
						case RADIOD_MODULE:
							sen = new Sensor_line_module;
							break;
					}
					
					
				//	sen = new Sensor_line_sensor;
					sen.insertData( i + _offset, _arr[i] );
					addChild( sen );
					sen.y = i*sen.getHeight()+ labels.getHeight();
					aSensors.push( sen );
				}
			} else {
				len = _arr.length;
				
				if ( len != aSensors.length ) {
					dtrace( "Не совпадает количество сенсоров и количество мест для них, страница будет перестроена" );
					undrawSensors();
					return;
				}
				
				for( i=0; i < len; ++i ) {
					sen = aSensors[i];
					sen.insertData( i + _offset, _arr[i] );
				}
			}
		}
		private function undrawSensors():void
		{
			var sen:Sensor_line;
			var len:int = aSensors.length;
			for (var i:int=0; i<len; ++i) {
				removeChild( aSensors[i] );
			}
			aSensors.length = 0;
			aSensors = null;
		}
	}
}