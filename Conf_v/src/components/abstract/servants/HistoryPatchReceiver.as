package components.abstract.servants
{
	import components.abstract.functions.dtrace;
	import components.abstract.gearboxes.HistoryBox;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class HistoryPatchReceiver
	{
		public var working:Boolean;
		
		private var index_start:uint;
		private var index_end:uint;
		private var total:int;
		private var totalgot:int;
		private var lines:Array;
		private var task:ITask;
		
		private var gearbox:HistoryBox;
		private var servant:HistoryTableServant;
		private var fcallback:Function;
		private var queue:Array;
		private var parts:Array;	// части запроса 123-234 [0]=123 [1]=234
		private var partsgot:Array;	// пришедшие части
		public var list:String;	// записываются части, которые не дошли
		
		public function init(gb:HistoryBox, htservant:HistoryTableServant):void
		{
			gearbox = gb;
			servant = htservant;
		}
		public function start(a:Array,callback:Function):void
		{
			fcallback = callback;
			queue = a;
			list = "";
			pushQueue();
		}
		private function pushQueue():void
		{
			if (queue && queue.length > 0) {
				parts = null;
				try {
					parts = (queue.shift() as String).split("-");
				} catch(error:Error) {}
				
				if (parts) {
					var low:int = parts[0];
					var hi:int = parts[1];
					working = true;
					partsgot = [];
					if (hi > low)
						RequestAssembler.getInstance().fireEvent( new Request(CMD.SELECT_HISTORY_BY,null, 1, [int(low),int(hi),1]));
					else
						RequestAssembler.getInstance().fireEvent( new Request(CMD.SELECT_HISTORY_BY,null, 1, [int(hi),int(low),1]));
					
					if(!task)
						task = TaskManager.callLater( stop, TaskManager.DELAY_10SEC*2 );
					else
						task.repeat();
				} else {
					dtrace("error@HistoryPatchReceiver.pushQueue(): ошибка в обработке запроса");
					finish();
				}
			} else
				finish();
		}
		public function put(p:Package):void
		{
			/**	Команда SEND_SELECT_HISTORY_INDEX - прибор отправляет выбранные индексы начала и конца истории, по которым можно судить о количестве передаваемых записей.
			 Параметр 1 - Индекс начала выбранной для передачи истории;
			 Параметр 2 - Индекс конца выбранной для передачи истории;
			 Параметр 3 - Количество записей истории, которые будут отправлены из прибора.
			 *Вояджер отправляет историю командой SEND_RUBBER_HISTORY_SERVER(1454) в Ritm-bin2 NO ACK протоколе (без сжатия?). Программа конфигурации сама контролирует количество и правильность переданной истории через индексы.*/													
			
			/**	Команда SELECT_HISTORY_BY - выбрать и получить от прибора историю по выбранным дате и времени или индексам - запрос к прибору от сервера или программы конфигурации
			 
			 Если параметр 3 = 0:
			 Параметр 1 - Дата и время в POSIX формате, с которого необходимо получить историю.
			 Параметр 2 - Дата и время в POSIX формате, до которого необходимо получить историю.
			 Если параметр 3 = 1:
			 Параметр 1 - индекс, с которого необходимо получить историю.
			 Параметр 2 - индекс, до которого необходимо получить историю */
			
			switch(p.cmd) {
				case CMD.SEND_SELECT_HISTORY_INDEX:
					index_start = p.getParamInt(1);
					index_end = p.getParamInt(2);
					total = p.getParamInt(3);
					
					if (index_start == 0xffffffff && index_end == 0xffffffff ) {	// значит запрошены невалидные данные
						task.stop();
						pushQueue();
					} else if (index_start == 0 && index_end == 0 && total == 0) {	// значит прибор перегружен, но работает над задачей
						task.repeat();
					} else {
						task.repeat();
						lines = [];
						totalgot = 0;
					}
					break;
				case CMD.SEND_RUBBER_HISTORY_SERVER:
				case CMD.SEND_SELECT_HISTORY:	
					var startindex:int = lines.length;	// при запросе нескольких пакетов, сдвиг чтобы не перезаписать уже принятые записи
					var index:int = startindex;
					var len:int = p.data.length;
					var packettotal:int = len/gearbox.HIS_BLOCK_SIZE_BYTE;	// всего записей в этой посылке
					var trans:Array = [];
					for (var i:int=0; i<len; i++) {
						if( !trans[index] )
							trans[index] = [];
						(trans[index] as Array).push( p.data[i] );
						index++;
						if( index == packettotal )
							index = 0;
					}
					totalgot += trans.length;
					var a:Array = servant.getContent(trans);
					
					len = trans.length;
					for (i=0; i<len; i++) {
						partsgot.push( int(a[i][2]) );
					}
					
					if (total == totalgot) {
						task.stop();
						checkIntegrity();
					} else
						task.repeat();
					break;
			}
		}
		private function checkIntegrity():void
		{
			if (partsgot.length > 0) {
				if (list.length > 0)
					list += ", ";
				if (parts[0] != parts[1])
					list += parts[0]+"-"+parts[1];
				else
					list += parts[0];;
			}
			pushQueue();
		}
		private function stop():void
		{
			pushQueue();
		}
		private function finish():void
		{
			working = false;
			fcallback();
		}
	}
}