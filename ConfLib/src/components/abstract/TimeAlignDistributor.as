package components.abstract
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class TimeAlignDistributor
	{
		private var queue:Vector.<Object>;
		private var f:Function;
		private var t:Timer;
		private var delay:int;
		
		public static const PRESET_DEFAULT:int= 0x00;
		public static const PRESET_ACC_VECTOR:int= 0x01;
		private var preset:int;
		
		public function TimeAlignDistributor(delegate:Function, delayMS:int, _preset:int=0x00)
		{
			preset = _preset;
			f = delegate;
			t = new Timer(delayMS);
			delay = delayMS;
			t.addEventListener( TimerEvent.TIMER, onComplete );
		}
		public function add(o:Object):void
		{
			if (!queue)
				queue = new Vector.<Object>;
			queue.push( o );
			if (!t.running) {
				t.reset();
				t.start();
			}
		}
		public function stop():void
		{
			t.stop();
			queue.length = 0;
		}
		public function destroy():void
		{
			t.stop();
			if (queue)
				queue.length = 0;
			f = null;
			t.removeEventListener( TimerEvent.TIMER, onComplete );
		}
		private function onComplete(e:TimerEvent):void
		{
			switch(preset) {
				case PRESET_DEFAULT:
					if (queue.length > 0) {
						f( queue.shift() );
						if (queue.length > 10)
							queue.length = 1;
					} else
						t.stop();
					break;
				case PRESET_ACC_VECTOR:
					if (queue.length > 0) {
						
						f( queue.shift() );
						
						switch (queue.length) {
							case 0:
								t.delay = delay;
								break;
							case 5:
								t.delay = delay - 5;
								break;
							case 10:
								t.delay = delay - 10;
								break;
							case 15:
								t.delay = delay - 15;
								break;
						}
						if (queue.length > 20 && t.delay > 10)
							t.delay -= 10;
					} else
						t.stop();
					break;
			}
		}
	}
}