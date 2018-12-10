package components.gui.visual.deviceMap
{
	public class Sensor_root_module extends Sensor_root
	{
		public function Sensor_root_module()
		{
			super();
			
		}
		
		override public function setState( _state:int ):void 
		{
		
			switch( _state ) 
			{
				case Sensor_root.STATE_NORMAL:
				this.backgroundColor = colorNormal;
				break;
				case Sensor_root.STATE_TRIGGER:
				
				this.backgroundColor = colorTrigger;
				break;
				case Sensor_root.STATE_LOST:
				this.backgroundColor = colorLost;
				break;
				case Sensor_root.STATE_NOTEXIST:
				this.backgroundColor = colorNotExist;
				break;
				case Sensor_root.STATE_LABEL:
				this.background = false;
				break;
				case Sensor_root.STATE_FOUND:
				this.backgroundColor = colorFound;
				break;
				case Sensor_root.STATE_LOWLEVEL:
				this.backgroundColor = colorTrigger;
				break;
			}
				currentState = _state;
		}
		
	}
}