package components.gui
{
	import components.abstract.servants.TaskManager;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class MovingTextField extends TextField
	{
		private var strings:Vector.<String>;
		private var position:int;
		private var timer:Timer;
		
		public function MovingTextField(txt:Array)
		{
			super();
			
			strings = new Vector.<String>;
			var len:int = txt.length;
			for (var i:int=0; i<len; ++i) {
				strings.push( txt[i] );
			}
			
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.reset();
			timer.start();
			htmlText = strings[0];
		}
		private function onTimer(e:Event):void
		{
			if (++position >= strings.length)
				position = 0
			htmlText = strings[position];
		}
		override public function set visible(value:Boolean):void
		{
			if (visible != value) {
				super.visible = value;
				if(value) {
					timer.reset();
					timer.start();
				} else
					timer.stop();
			}
		}
	}
}