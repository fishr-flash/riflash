package components.abstract.servants
{
	import components.abstract.offline.OfflineProcessor;
	import components.interfaces.IConfigLoaderBot;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.static.CMD;
	import components.static.NAVI;

	public class K14ConfigLoaderBot implements IConfigLoaderBot
	{
		private var important:Array;
		private var counterIncrease:Function;
		
		public function K14ConfigLoaderBot(fCounterIncrease:Function)
		{
			counterIncrease = fCounterIncrease;
		}
		
		public function checkImportant(n:int):Boolean
		{	// проверяем, нет ли команд которые надо отправить в конец списка
			switch(n) {
				case NAVI.LINK_CHANNELS:
					if(!important)
						important = [];
					important.push( n );
					return true;
			}
			return false;
		}
		public function addImportant(a:Array):Array
		{	// добавляем в конец списка все найденные важные сборки команд
			if (important) {
				var len:int = important.length;
				for (var i:int=0; i<len; ++i) {
					//a = a.concat( OfflineProcessor.getCMDsetByPage( important[i] ).cmds );
					a = a.concat( OfflineProcessor.getCMDsetByPage( important[i] ) );
				}
			}
			return a;
		}
		/***** Костыль - восстановить после исправления прибора
		public function doImportant(callBack:Function):void
		{	// выполнить какие либо действия после того как были отправлены команды на запись
			if(important) {
				var len:int = important.length;
				for (var i:int=0; i<len; ++i) {
					switch(important[i]) {
						case NAVI.LINK_CHANNELS:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, callBack, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
							counterIncrease();
							break;
					}
				}
				important = null;
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT, callBack, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
			counterIncrease();
		}
		 * **/
		
		private var fCallBack:Function;
		
		public function doImportant(callBack:Function):void
		{	// выполнить какие либо действия после того как были отправлены команды на запись
			
			if(important) {
				var len:int = important.length;
				for (var i:int=0; i<len; ++i) {
					
					switch(important[i]) {
						case NAVI.LINK_CHANNELS:
							fCallBack = callBack;
							RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_UPDATE, increaseProgress, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
							RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, wts , 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
							if (task) {
								task.kill();
								task = null;
							}
								
							counterIncrease();
							counterIncrease();
							counterIncrease();
							break;
					}
				}
				important = null;
			} else {
		//		counterIncrease();
				RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT, restartAfterReboot, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
			}
		}
		
		private var task:ITask;
		
		private function increaseProgress(p:Package):void
		{
			fCallBack(p);
		}
		private function wts(p:Package):void
		{
			
			if (fCallBack == null && !task)	// обнуляются если был interrupt
				return;
			if (!task) {
				fCallBack(p);
				task = TaskManager.callLater( request, 9000 );
			} else {
				if (p.getStructure()[0] == 2) {
					task.kill();
					task = null;
					RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT, restartAfterReboot, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
				} else {
					task = TaskManager.callLater( request, 2000 );
				}
			}
		}
		private function restartAfterReboot(p:Package):void
		{
			if ( fCallBack is Function )
				fCallBack(p);
			//TaskManager.callLater( SocketProcessor.getInstance().disconnect, 200 );
			SocketProcessor.getInstance().disconnect();
		}
		private function request():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, wts ));
		}
		
		/** Костыль закончился */
		
		public function interrupt():void	
		{
			if (task)
				task.kill();
			task = null;
			fCallBack = null;
		}
		public function doBeforeRead(a:Array):void
		{	// произвести какие либо действия если была выбрана определенная страница, передается массив NAVI
		}
		public function doActions(a:Array,f:Function, fcancel:Function):Boolean
		{
			return false;
		}
		public function fire(r:Request):void
		{
			RequestAssembler.getInstance().fireEvent(r);
		}
		public function doRefine(cmd:int, a:Array, str:int):void	{}
		public function doSaveRefine(cmd:int):void {}
		public function doListIntegration(l:Array, selected:Array, f:IFormString):void {}
		public function needRestart():Boolean
		{
			return false;
		}
	}
}