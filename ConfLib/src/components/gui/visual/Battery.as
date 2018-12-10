package components.gui.visual
{
	import flash.display.MovieClip;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	
	public class Battery extends UIComponent
	{
		private var signal:MovieClip;
		private var label:SimpleTextField;
		
		[Embed(source='../../../assets/graphic.swf', symbol="battery")]
		private var cBattery:Class;
		
		public function Battery()
		{
			super();
			signal = new cBattery;
			addChild( signal );
			signal.gotoAndStop(1);
			
			label = new SimpleTextField("", 150);
			addChild( label );
			label.x = 50;
			label.y = -3;
		}
		public function put(num:int, u:int):void
		{
			if (num >= 0 && num < 101 ) {
				signal.gotoAndStop( Math.ceil(num/16) );
				
				switch(Math.ceil(num/16)) {
					case 7:
					case 6:
						label.textColor = COLOR.GREEN_SIGNAL;
						break;
					case 5:
					case 4:
					case 3:
						label.textColor = COLOR.YELLOW_SIGNAL;
						break;
					default:
						label.textColor = COLOR.RED;
						break;
				}
				
				var ustring:String = (u/1000).toFixed(3);
				label.text = num+"% "+ustring.slice(0, ustring.search(/\./) + 3)+loc("measure_volt_1l");
			} else {
				signal.gotoAndStop( 1 );
				label.textColor = COLOR.RED;
				label.text = loc("g_invalid_value");
			}
		}
		public function putSimple(num:int):void
		{
			if (num >= 0 && num < 101 ) {
				signal.gotoAndStop( Math.ceil(num/16) );
				
				switch(Math.ceil(num/16)) {
					case 7:
					case 6:
						label.textColor = COLOR.GREEN_SIGNAL;
						break;
					case 5:
					case 4:
					case 3:
						label.textColor = COLOR.YELLOW_SIGNAL;
						break;
					default:
						label.textColor = COLOR.RED;
						break;
				}
			} else {
				signal.gotoAndStop( 1 );
				label.textColor = COLOR.RED;
				label.text = loc("g_invalid_value");
			}
		}
	}
}