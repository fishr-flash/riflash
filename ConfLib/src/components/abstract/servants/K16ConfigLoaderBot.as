package components.abstract.servants
{
	import components.abstract.offline.OfflineProcessor;
	import components.interfaces.IConfigLoaderBot;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.NAVI;

	public class K16ConfigLoaderBot implements IConfigLoaderBot
	{
		private var important:Array;
		private var counterIncrease:Function;
		
		private var bottom:Boolean = false;
		private var top:Boolean = false;
		
		private var requests:Vector.<Request>;	// нужен для запоминания реквеста записи лан, чтобы впихивать его перед рестартом верхнего прибор
		
		public function K16ConfigLoaderBot(fCounterIncrease:Function):void
		{
			counterIncrease = fCounterIncrease;
		}
		
		public function checkImportant(n:int):Boolean
		{	// проверяем, нет ли команд которые надо отправить в конец списка
			// засекаем команды верхней и ниждней платы, если есть хотябы одна команда - надо посылать ребут сооответствующему прибору
			if (!bottom || !top ) {
				var a:Array = OfflineProcessor.getCMDsetByPage(n);
				var len:int = a.length;
				for (var i:int=0; i<len; ++i) {
					if ( OfflineProcessor.getAddress(a[i]) == SERVER.ADDRESS_BOTTOM)
						bottom = true;
					if ( OfflineProcessor.getAddress(a[i]) == SERVER.ADDRESS_TOP && SERVER.DUAL_DEVICE)
						top = true;
					if (top && bottom)
						break;
				}
			}
			// засекаем были ли загружены каналы связи чтобы послать HISTORY_DELETE  
			switch(n) {
				case NAVI.LINK_CHANNELS:
				case NAVI.PARAMS_LAN:
					if(!important)
						important = [];
					important.push( n );
					return true;
			}
			return false;
		}
		public function addImportant(a:Array):Array
		{	// добавляем в конец списка все найденные важные сборки команд
			if(important) {
				var len:int = important.length;
				// Прицепляем к основной очереди важные команды, в данном случае каналы связи, чтобы они шли в конце
				for (var i:int=0; i<len; ++i) {
					a = a.concat( OfflineProcessor.getCMDsetByPage(important[i]) );	
				}
			}
			return a;
		}
		public function doImportant(callBack:Function):void
		{	// выполнить какие либо действия после того как были отправлены команды на запись
			var len:int;
			var i:int;
			if(important) {
				len = important.length;
				for ( i=0; i<len; ++i) {
					switch(important[i]) {
						case NAVI.LINK_CHANNELS:
							if (DS.release < 6) {	// 6R+ RT1 не надо стирать историю
								RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, callBack, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
								counterIncrease();
							}
							break;
					}
				}
				important = null;
			}
			
			// отправляем ребут на соответствующие приборы
			if (bottom) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT, callBack, 1, [1], Request.NORMAL, Request.PARAM_SAVE, SERVER.ADDRESS_BOTTOM ));
				counterIncrease();
			}
			if (top ) {
				if (requests) {
					len = requests.length;
					for ( i=0; i<len; ++i) {
						RequestAssembler.getInstance().fireEvent( requests[i] );	// каунтер у запомненных реквестов увеличивать не надо, он уже увеличен из OfflineTaskManager						
					}
				}
				if (DS.release >= 6) {	// только с 6го релиза
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_UPDATE, callBack, 1, [1], Request.NORMAL, Request.PARAM_SAVE, SERVER.ADDRESS_TOP ));
					counterIncrease();
				} else {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT, callBack, 1, [1], Request.NORMAL, Request.PARAM_SAVE, SERVER.ADDRESS_TOP ));
					counterIncrease();
				}
			}
			requests = null;
		}
		public function doBeforeRead(a:Array):void
		{	// произвести какие либо действия если была выбрана определенная страница, передается массив NAVI
		}
		public function doActions(a:Array,f:Function, fcancel:Function):Boolean
		{
			bottom = false;
			top = false;
			return false;
		}
		
		public function fire(r:Request):void
		{
			if (r.cmd == CMD.SET_NET || r.cmd == CMD.SET_OPENED_PORT ) {
				if( !requests )
					requests = new Vector.<Request>;
				requests.push(r);
				top = true;
			} else
				RequestAssembler.getInstance().fireEvent(r);
		}
		public function interrupt():void	{}
		public function doRefine(cmd:int, a:Array, str:int):void	{}
		public function doSaveRefine(navi:int):void 		{		}
		public function doListIntegration(l:Array, selected:Array, f:IFormString):void {}
		public function needRestart():Boolean
		{	// если по каким то причинам необходимо рестартнуть клиент после загрузки информации, функция возвращает true;
			return top || bottom;
		}
	}
}