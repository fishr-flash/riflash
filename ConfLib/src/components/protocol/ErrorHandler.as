package components.protocol
{
	import components.abstract.functions.loc;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.IActiveErrorHandler;
	import components.interfaces.IActiveErrorSupporter;

	public class ErrorHandler
	{
		public static const WRONG_PROTOCOL:int = 100;
		public static const WRONG_CRC:int = 101;
		public static const STRING_TOO_LONG:int = 102;
		public static const STRING_END_NOT_FOUND:int = 103;
		
		public static const PROTOCOL_UNKNOWN:int = 0;
		public static const PROTOCOL_CMD_NOT_EXIST:int = 1;
		public static const PROTOCOL_STR_NOT_EXIST:int = 2;
		public static const PROTOCOL_WRONG_PARAM:int = 3;
		public static const PROTOCOL_WRONG_DATA_TYPE:int = 4;
		public static const PROTOCOL_WRONG_DATA_SIZE:int = 5;
		public static const PROTOCOL_RO_WRITE:int = 6;
		public static const PROTOCOL_MEMORY:int = 7;
		public static const PROTOCOL_CRC:int = 8;

		// Коды ошибок в протоколе:
		public static const protocolErrors:Array = [ 
			"нет ошибкии",
			"0x01 - "+loc("sys_binerror1"),
			"0x02 - "+loc("sys_binerror2"),
			"0x03 - "+loc("sys_binerror3"),
			"0x04 - "+loc("sys_binerror4"),
			"0x05 - "+loc("sys_binerror5"),
			"0x06 - "+loc("sys_binerror6"),
			"0x07 - "+loc("sys_binerror7"),
			"0x08 - "+loc("sys_binerror8")
		];
			
		private var fResend:Function;
		private var fClear:Function;
		private var fStopAndFree:Function;
		private var handler:IActiveErrorHandler;
		private var supporter:IActiveErrorSupporter;
		
		public function ErrorHandler()
		{
			
		}
		public function register(fresend:Function, fclear:Function, fstopandfree:Function):void
		{
			fResend = fresend;
			fClear = fclear;
			fStopAndFree = fstopandfree;
		}
		/** Если передаваемый handler==null это сигнал к очистке зарегистрированного хэндлера	*/
		public function activeHandler(h:IActiveErrorHandler=null):void
		{
			if (!h)
				handler = null;
			else
				handler = h;
		}
		/** Если передаваемый supporter==null это сигнал к очистке зарегистрированного хэндлера	*/
		public function activeSupporter(s:IActiveErrorSupporter=null):void
		{
			if (!s)
				supporter = null;
			else
				supporter = s;
		}
		public function onError(e:int):void
		{
			trace("ErrorHandler.onError(e) Error #"+e);
			
			// если есть зарегистрированный хэндлер - обрабатывает он, если нет - включается стандартная обработка
			if (handler)
				handler.handle(e);
			else {
				if (supporter)
					supporter.handle(e);
				switch(e) {
					case PROTOCOL_CMD_NOT_EXIST:
						fStopAndFree();//fClear();
						GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
							{getScreenMode:ScreenBlock.MODE_WARNING, getScreenMsg:loc("sys_cmd_not_supported"), getLink:null} );
						GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.menuReset );
						break;
					case PROTOCOL_STR_NOT_EXIST:
						fStopAndFree();//fClear();
						GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
							{getScreenMode:ScreenBlock.MODE_WARNING, getScreenMsg:loc("sys_requested_nonexistend_structure"), getLink:null} );
						GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.menuReset );
						break;
					default:
						fResend();
						break;
				}
			}
		}
	}
}