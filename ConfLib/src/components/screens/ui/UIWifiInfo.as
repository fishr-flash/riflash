package components.screens.ui
{
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptWiFi;
	import components.static.CMD;
	
	public class UIWifiInfo extends UI_BaseComponent
	{
		private var opts:Vector.<OptWiFi>;
		private var task:ITask;
		
		public function UIWifiInfo()
		{
			super();
			
			toplevel = false;
			
			/** Команда ESP_INFO - общая информация о работе модуля
				Структура 1 - информация о модуле
				....Параметр 1 - Версия SDK
				....Параметр 2 - Версия прошивки
				....Параметр 3 - резерв
				Структура 2 - информация о точке доступа WIFI
				....Параметр 1 - MAC адрес точки доступа
				....Парамтер 2 - IP адрес точки доступа
				....Параметр 3 - Режим работы, 0- Не работает, 1-Работает
				Структура 3 - информация о клиенте WIFI
				....Параметр 1 - MAC адрес клиента WIFI
				....Параметр 2 - IP адрес клиента
				....Параметр 3 - уровень сигнала точки доступа, к которой подключены, int8_t, 255 - нет подключения.	*/

			opts = new Vector.<OptWiFi>(3);
			
			for (var i:int=0; i<3; i++) {
				opts[i] = new OptWiFi(i+1);
				addChild( opts[i] );
				opts[i].x = globalX;
				opts[i].y = globalY;
				globalY += opts[i].complexHeight;
					
			}
			
			starterCMD = CMD.ESP_INFO;
		}
		override public function put(p:Package):void 
		{
			for (var i:int=0; i<3; i++) {
				opts[i].putData(p);
			}
			loadComplete();
			
			if (this.visible) {
				if (!task)
					task = TaskManager.callLater(request, TaskManager.DELAY_1SEC*5 );
				else
					task.repeat();
			}
		}
		override public function close():void
		{
			super.close();
			
			if (task)
				task.kill();
			task = null;
		}
		private function request():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.ESP_INFO,put));
		}
	}
}