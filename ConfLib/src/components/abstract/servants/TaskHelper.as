package components.abstract.servants
{
	import components.interfaces.ITask;

	public final class TaskHelper
	{
		private static var inst:TaskHelper;
		public static function access():TaskHelper
		{
			if(!inst)
				inst = new TaskHelper;
			return inst;
		}
		
		private var tasks:Vector.<ITask>;
		private var tasksLocal:Object;
		
		public function TaskHelper()
		{
			tasks = new Vector.<ITask>;
			tasksLocal = new Object;
		}
		public function close():void
		{
			var len:int = tasks.length;
			for (var i:int=0; i<len; i++) {
				tasks[i].kill();
			}
			tasks.length = 0;
			
			for( var key:String in tasksLocal) {
				(tasksLocal[key] as ITask).kill();
			}
			tasksLocal = {};
		}
		public function run(f:Function, ms:int, n:int=0):ITask
		{
			if (tasks.length <= n)
				tasks.length = n + 1;
			if( !tasks[n])
				tasks[n] = TaskManager.callLater(f,ms);
			else
				tasks[n].repeat();
			return tasks[n];	
		}
		public function runLocal(f:Function, ms:int, n:int, uid:String):ITask
		{
			if( !tasksLocal[n+"."+uid])
				tasksLocal[n+"."+uid] = TaskManager.callLater(f,ms);
			else
				tasksLocal[n+"."+uid].repeat();
			return tasksLocal[n+"."+uid];	
		}
	}
}