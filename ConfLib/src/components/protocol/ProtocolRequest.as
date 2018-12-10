package components.protocol
{
	import components.system.UTIL;

	public class ProtocolRequest
	{
		public var func:int;
		public var delegate:Function;
		public var size:int;
		public var serverAdr:int;
		public var functional:Boolean = false;
		
		private var number:int;			// во время создания посылки в ProtocolBinary посылке присваивается номер пакет. Несколько посылок могут идит с одним номером
		private var save:Boolean = false;// пакет на запись активирован кнопкой сохранение
		public var data:Vector.<Request> = new Vector.<Request>;
		private var _sent:int;		// сколько раз был послан
		
		public var current:int = 0;		// обрабатывапемый номер реквеста
		
		public var uid:int;
		
		public function ProtocolRequest(_func:int )
		{
			func = _func;
			
			uid = UTIL.generateUId();
		}
		
		public function get length():int
		{
			return data.length;
		}
		public function shift():Request
		{
			current++;
			return data[current-1];
		}
		public function getCurrent():Request
		{
			return data[--current];
		}
		public function put( re:Request, _size:int, _functional:Boolean=false ):void
		{
			if (serverAdr == 0)
				serverAdr = re.serverAdr;
			if (re.save)	// если хотябы одна команда идет с сохранения весь пакет помечается как "сохранение"
				save = true;
			if (_functional)
				data.splice(0,0, re );
			else
				data.push( re );
			
			size += _size;
			functional = _functional;
		}
		public function resend():void
		{
			_sent++;
			current=0;
		}
		public function get sent():int
		{
			return _sent;
		}
		public function getData(i:int):Request
		{
			data[i].complete = true;
			return data[i];
		}
		public function isComplete(i:int):Boolean
		{
			return data[i].complete;
		}
		public function getStruc(i:int):int
		{
			return data[i].structure;
		}
		public function getCmd(i:int):int
		{
			return data[i].cmd;
		}
		/** Убрать complete() запросы	*/
		private function clean():void
		{
			var len:int = data.length;
			for (var i:int=0; i<len; ++i) {
				if (data[i] && data[i].complete) {
					data.splice(i,1);
					i--;
					len--;
				}
			}
			current=0;
		}
		public function getStats():String
		{
			var txt:String = "ProRequest ---------------\n" +
				"length: "+data.length+ "\n";
			
			var len:int = data.length;
			for (var i:int=0; i<len; ++i) {
				txt += "Request #"+(i+1)+ " cmd:"+data[i].cmd + ", structure:" + data[i].structure+"\n";
			}
			
			return txt;
		}
	}
}