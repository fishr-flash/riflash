package components.abstract.servants
{
	import components.interfaces.ITask;

	public class TaskManager
	{
		public static const DELAY_1SEC:int = 1000;
		public static const DELAY_2SEC:int = 2000;
		public static const DELAY_3SEC:int = 3000;
		public static const DELAY_5SEC:int = 5000;
		public static const DELAY_10SEC:int = 1000*10
		public static const DELAY_20SEC:int = 1000*20
		public static const DELAY_30SEC:int = 1000*30;
		public static const DELAY_1MIN:int = 1000*60;
		public static const DELAY_2MIN:int = 2000*60;
		
		private static var tasks:Vector.<TaskOnDemand>
		
		public static function callLater(f:Function, ms:int, args:Array=null):ITask
		{
			return new TaskTime(f, ms, args);
		}
		//	update means that task will be updated if there is one already
		public static function callOnDemand(id:int, f:Function, args:Object, update:Boolean=false):void
		{
			if (!tasks)
				tasks = new Vector.<TaskOnDemand>;
			var len:int = tasks.length;
			for (var i:int=0; i<len; ++i) {
				if (tasks[i].id == id ) {
					if (update) {
						tasks[i].delegate = f;
						tasks[i].args = args;
					} else
						trace("TaskManager: task "+id+" already exist");
					return;
				}
			}
			tasks.push( new TaskOnDemand(id,f,args) );
		}
		public static function demand(id:int):void
		{
			if (tasks) {
				var len:int = tasks.length;
				for (var i:int=0; i<len; ++i) {
					if (tasks[i].id == id ) {
						tasks[i].call();
						tasks.splice(i,1);
						return;
					}
				}
			}
			trace("TaskManager: task "+id+" doesn't exist");
		}
		public static function exist(id:int):Boolean
		{
			if (tasks) {
				var len:int = tasks.length;
				for (var i:int=0; i<len; ++i) {
					if (tasks[i].id == id ) {
						return true;
					}
				}
			}
			return false;
		}
	}
}
import components.interfaces.ITask;

import flash.events.TimerEvent;
import flash.utils.Timer;

class TaskTime implements ITask
{
	private var timer:Timer;
	private var delegate:Function;
	private var args:Array;
	
	public function TaskTime(f:Function, ms:int, arguments:Array)
	{
		delegate = f;
		args = arguments;
		timer = new Timer( ms, 1 );
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		timer.reset();
		timer.start();
	}
	public function kill():void
	{
		timer.stop();
		timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
	}
	public function repeat():void
	{
		timer.reset();
		timer.start();
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
	}
	public function stop():void
	{
		timer.stop();
	}
	public function set delay(value:Number):void
	{
		timer.delay = value;
	}
	public function running():Boolean
	{
		return timer.running;
	}
	private function onComplete(ev:TimerEvent):void
	{
		timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		if (args) {
			switch(args.length) {
				case 1:
					delegate(args[0]);
					break;
				case 2:
					delegate(args[0],args[1]);
					break;
				case 3:
					delegate(args[0],args[1],args[2]);
					break;
				case 4:
					delegate(args[0],args[1],args[2],args[3]);
					break;
				case 5:
					delegate(args[0],args[1],args[2],args[3],args[4]);
					break;
				default:
					delegate();
					break;
			}
		} else
			delegate();
	}
}
class TaskOnDemand
{
	public var id:int;
	public var delegate:Function;
	public var args:Object;
	
	public function TaskOnDemand(_id:int, f:Function, _args:Object)
	{
		id = _id;
		delegate = f;
		args = _args;
	}
	public function call():void
	{
		delegate(args);
	}
}