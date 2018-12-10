package components.abstract.servants
{
	import components.interfaces.IQueueable;

	public class Queuebot
	{
		private var queue:Vector.<QueueItem>;
		private var current:IQueueable;
		
		private static var inst:Queuebot;
		public static function access():Queuebot
		{
			if(!inst)
				inst = new Queuebot;
			return inst;
		}
		
		public function Queuebot()
		{
			queue = new Vector.<QueueItem>;
		}
		public function got(...args):void
		{
			current.callback(args);
			current = null;
			check();
		}
		
		/** run function should contain callback to this.got, and callback to external final destination	*/
		public function add(run:Function, callback:Function):void
		{
			queue.push( new QueueItem(run, callback));
			check();
		}
		
		private function check():void
		{
			if (queue.length > 0 && !current) {
				current = queue.shift();
				current.run();
			}
		}
	}
}
import components.interfaces.IQueueable;

class QueueItem implements IQueueable
{
	private var frun:Function;
	private var fcb:Function;
	
	public function QueueItem(r:Function, cb:Function):void
	{
		frun = r;
		fcb = cb;
	}
	public function run():void
	{
		frun();
	}
	public function get callback():Function
	{
		return fcb;
	}
}