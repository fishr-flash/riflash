package components.abstract.servants
{
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.system.SensorConst;

	public class WatchDog
	{
		private var task:ITask;
		
		private static var inst:WatchDog;
		public static function access():WatchDog
		{	// 
			if(!inst)
				inst = new WatchDog;
			return inst;
		}
		public function start():void
		{
			if (!task)
				task = TaskManager.callLater( onTick, TaskManager.DELAY_1SEC*5 );
			else
				task.repeat();
		}
		public function stop():void
		{
			if (task)
				task.stop();
		}
		private function onTick():void
		{
			start();
			if (MISC.VINTAGE_BOOTLOADER_ACTIVE)
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_un_BOOTLOADER_VER, putun ));
			else
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_v_VER_INFO, putv ));
		}
		private function putv(p:Package):void
		{
			if( !SensorConst.isSameVersion(p) )
				SocketProcessor.getInstance().disconnect();
		}
		private function putun(p:Package):void
		{
			var v:String = SensorConst.getBootLoaderVersion(p);
			if (DS.deviceAlias != v)
				SocketProcessor.getInstance().disconnect();
		}
	}
}