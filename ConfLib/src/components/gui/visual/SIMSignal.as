package components.gui.visual
{
	import flash.display.MovieClip;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	import components.static.GuiLib;
	
	public class SIMSignal extends UIComponent
	{
		private var signal:MovieClip;
		private var label:SimpleTextField;
		
		public var title:String = loc("g_no_net_registration");
		public var notdefined:String = loc("g_unidentified");
		public var attach:String = "%";
		
		public function SIMSignal()
		{
			super();
			signal = new GuiLib.cSignal;
			addChild( signal );
			signal.gotoAndStop(1);
			
			label = new SimpleTextField("", 200);
			addChild( label );
			label.x = 50;
			label.y = -3;
		}
		public function hideLabel():void
		{
			label.visible = false;
		}
		
		public function putStraight(num:int, simple:Boolean=false):void
		{
			if (num > 90) {
				signal.gotoAndStop(6);
				label.textColor = COLOR.GREEN_SIGNAL;
			} else if (num > 75) {
				signal.gotoAndStop(5);
				label.textColor = COLOR.GREEN_SIGNAL;
			} else if (num > 50) { 
				signal.gotoAndStop(4);
				label.textColor = COLOR.YELLOW_SIGNAL;
			} else if (num > 25) {
				signal.gotoAndStop(3);
				label.textColor = COLOR.YELLOW_SIGNAL;
			} else if (num > 10) { 
				signal.gotoAndStop(2);
				label.textColor = COLOR.RED;
			} else {
				signal.gotoAndStop(1);
				label.textColor = COLOR.RED;
			}
			
			label.text = num+attach;
			
			if (num == 0 && !simple)
				label.text = title;
		}
		public function put31(num:int):void
		{
			if (num == 99) {
				signal.gotoAndStop(1);
				label.textColor = COLOR.RED;
			} else if (num > 30) {
				signal.gotoAndStop(6);
				label.textColor = COLOR.GREEN_SIGNAL;
			} else if (num > 24) {
				signal.gotoAndStop(5);
				label.textColor = COLOR.GREEN_SIGNAL;
			} else if (num > 14) { 
				signal.gotoAndStop(4);
				label.textColor = COLOR.YELLOW_SIGNAL;
			} else if (num > 7) {
				signal.gotoAndStop(3);
				label.textColor = COLOR.YELLOW_SIGNAL;
			} else if (num < 8) { 
				signal.gotoAndStop(2);
				label.textColor = COLOR.RED;
			} else {
				signal.gotoAndStop(1);
				label.textColor = COLOR.RED;
			}
			if (num > 30)
				label.text = "100"+attach;
			else
				label.text = ((num/31)*100).toFixed()+attach;
			
			if (num == 99)
				label.text = notdefined;
		}
		public function put(num:int):void
		{
			if (num == 99) {
				signal.gotoAndStop(1);
				label.textColor = COLOR.RED;
			} else if (num > 24) {
				signal.gotoAndStop(6);
				label.textColor = COLOR.GREEN_SIGNAL;
			} else if (num > 18) {
				signal.gotoAndStop(5);
				label.textColor = COLOR.GREEN_SIGNAL;
			} else if (num > 12) { 
				signal.gotoAndStop(4);
				label.textColor = COLOR.YELLOW_SIGNAL;
			} else if (num > 6) {
				signal.gotoAndStop(3);
				label.textColor = COLOR.YELLOW_SIGNAL;
			} else if (num < 7) { 
				signal.gotoAndStop(2);
				label.textColor = COLOR.RED;
			} else {
				signal.gotoAndStop(1);
				label.textColor = COLOR.RED;
			}
			if (num > 24)
				label.text = "100"+attach;
			else
				label.text = (num*4)+attach;
			
			if (num == 99)
				label.text = notdefined;
		}
	}
}