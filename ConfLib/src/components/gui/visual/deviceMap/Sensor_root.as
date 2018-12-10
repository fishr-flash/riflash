package components.gui.visual.deviceMap
{
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Sensor_root extends TextField
	{
		public static var TYPE_COLOR:int = 0;
		public static var TYPE_NUMERIC:int = 1;
		
		public static var STATE_NOTEXIST:int = 0;
		public static var STATE_NORMAL:int = 1;
		public static var STATE_TRIGGER:int = 2;
		public static var STATE_LOST:int = 3;
		public static var STATE_LABEL:int = 4;
		public static var STATE_FOUND:int = 5;
		public static var STATE_LOWLEVEL:int = 6;
		public var currentState:int;
		
		//фиолет
		protected var colorTrigger:int = 0xd394bf;
		//зелень
		protected var colorNormal:int = 0xadd72b;
		// серый
		protected var colorLost:int = 0xc6c6c6;
		// серый
		protected var colorNotExist:int = 0xe9e9e9;
		// светло коричневый
		protected var colorFound:int = 0xf1c232;
		
		protected var exits_noWay:int = 0xadd72b;
		protected var exits_on:int = 0xd394bf;
		
		protected var sWidth:int = 60;
		protected var sHeight:int = 20;
		
		public function Sensor_root():void
		{
			super();
			
			var tf:TextFormat = new TextFormat;
			tf.align="center";
			tf.font = "Verdana";
			tf.size = 10;
			//tf.leading = -7;
			
			this.selectable = false;
			this.defaultTextFormat = tf;
			this.width = sWidth;
			this.height = sHeight;
			this.background = true;
			
			setState( STATE_NOTEXIST );
		}
		public function setDark():void 
		{
			colorTrigger = 0xb47ea3;
			colorNormal = 0x90b324;
			colorLost = 0xa3a3a3;
			colorNotExist = 0xd4d4d4;
			colorFound = 0xbf9000;
			
			setState( currentState );
		}
		public function getWidth():int
		{
			return sWidth;
		}
		public function getHeight():int
		{
			return sHeight;
		}
		public function setState( _state:int ):void 
		{
			
			switch( _state ) {
				case STATE_NORMAL:
					this.backgroundColor = colorNormal;
					break;
				case STATE_TRIGGER:
					this.backgroundColor = colorTrigger;
					break;
				case STATE_LOST:
					this.backgroundColor = colorLost;
					break;
				case STATE_NOTEXIST:
					this.backgroundColor = colorNotExist;
					break;
				case STATE_LABEL:
					this.background = false;
					break;
				case STATE_FOUND:
					this.backgroundColor = colorFound;
					break;
				case STATE_LOWLEVEL:
					this.backgroundColor = colorTrigger;
					break;
			}
			currentState = _state;
		}
		public function set label( _value:String ):void 
		{
			this.wordWrap = false;
			this.multiline = true;
			
			sHeight = 40;
			this.height = sHeight;
			
			setState( Sensor_root.STATE_LABEL );
			this.text = _value;
		}
		public function set value( _value:String ):void {
			if ( _value == "0" ) {
				text = "";	
			} else {
				text = "-"+_value;
			}
		}
	}
}