package components.protocol
{
	import mx.utils.StringUtil;
	
	import components.abstract.sysservants.Smoothloader;
	import components.protocol.statics.SERVER;

	public class Request
	{
		public static const NORMAL:int = 0;
		public static const URGENT:int = 1;
		public static const EXTREME:int = 2;
		public static const SYSTEM:int = 3;

		public static const PARAM_NONE:int = 0x00;
		public static const PARAM_DONT_CLEAN:int = 0x01;
		public static const PARAM_SAVE:int = 0x02;	// true отобразит надпись "идет запись в прибор" в статусной строке
		public static const PARAM_MUST_BE_LAST:int = 0x04;	// натыкаясь на этот параметр очередь отправляет его сразу на прибор, не смотря есть за ним посылки или нет
		
		public var structure:int;
		public var data:Array;
		public var cmd:int;
		public var func:int;
		public var delegate:Function;
		public var complete:Boolean = false;	//	true ставится когда на запрос пришел ответ и ответ отослан
		public var priority:int;
		public var dontClean:Boolean= false;	// true не позволит RequestAssember'у удалить из очереди такой запрос при находждении клона
		public var save:Boolean=false;			// true отобразит надпись "идет запись в прибор" в статусной строке
		public var mustBeLast:Boolean=false;	// true отправит запрос на прбир, не присоединяя остальные команды влезющие по буферу
		public var serverAdr:int = SERVER.ADDRESS;
		public var param:int;
		
		public var oldprotocol:Boolean = true;
		
		public var smoothloader:Smoothloader;

		public function Request( _cmd:int, _delegate:Function=null, _struc:int=0, _data:Array=null, _priority:int=0, _param:int=0, adr:int=0 ):void
		{
			cmd = _cmd;
			delegate = _delegate;
			// если нет массива на запись значит запрос на чтение
			func = _data ? SERVER.REQUEST_WRITE : SERVER.REQUEST_READ;
			structure = _struc;
			data = trim( _data );
			
			priority = _priority;
			if (adr > 0)
				serverAdr = adr;
			param = _param;
			var result:int;
			for(var i:int; i<param; ++i ) {
				result = param & (1 << i);
				if (result>0) {
					switch(result) {
						case PARAM_DONT_CLEAN:
							dontClean = true;
							break;
						case PARAM_SAVE:
							save = true;
							break;
						case PARAM_MUST_BE_LAST:
							mustBeLast = true;
							break;
					}
				}
			}
			
			
		}
		
		/**
		 *  Удаляет начальные и концевые пробелы в запросах, т.к. не
		 * бывает ситуации когда они являются значащами данными
		 */
		private function trim( dt:Array ):Array
		{
			
			
			
			if( dt )
			{
				var len:int = dt.length;
				for (var i:int=0; i<len; i++) 
				{
					if( dt[ i ] is Array )
					{
						dt[ i ] = trim( dt[ i ] );
					}
					else
					{
						
						dt[ i ] = StringUtil.trim( dt[ i ] );
						
					}
						 
				}
			}
			
			
			
			return dt;
		}
	}
}