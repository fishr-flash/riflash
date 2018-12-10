package components.static
{
	import flash.net.FileFilter;
	
	import mx.containers.Canvas;

	public class MISC
	{
		public static const EVENT_RESIZE_IMPACT:String = "EVENT_RESIZE_IMPACT";
		public static const EVENT_RESIZE_EVENT:String = "EVENT_RESIZE_EVENT";
		
		public static const PARTITION_CREATE_DELAY:int = 30;
		
		public static var SYSTEM_INACCESSIBLE:Boolean = true;
		public static var VERSION_MISMATCH:Boolean = false;
		
		public static var subMenuContainer:Canvas;
		public static var subMenu:Canvas;
		
		private static var _COPY_CLIENT_VERSION:String = "";
		public static function set COPY_CLIENT_VERSION(value:String):void
		{
			_COPY_CLIENT_VERSION = value;
		}
		public static function get COPY_CLIENT_VERSION():String 
		{
			return _COPY_CLIENT_VERSION;
		}
		public static var COPY_MENU:Array;
		public static var COPY_VER:String="";	// версия поддерживает мультиклиенты, с ней нельзя сравнивать ничего
		public static var COPY_DEBUG:Boolean=false;
		public static var COPY_LEVEL:int = 0;
		public static var COPY_TARGET_SOFTWARE:Object = null;
		
		public static var VINTAGE_BOOTLOADER_ACTIVE:Boolean = false;	// Только для старого протокола. Режим когда запуще будтоадер, необходимо прошить прибор
	//	public static var NEED_UPDATE:Boolean = false;	// Когда надо несмотря на версию обновить до хорошей 
		
		public static var EGTS:Boolean = true;
		// Сохранение в тихом режиме, используется Controller
		public static var SAVE_SILENT_MODE:Boolean=false;
		
		public static const DEBUG_KEY:String="og9WKHGV";
		public static var DEBUG_MAX_LENGTH:int=10;
		public static var DEBUG_CONSOLE_SIZE:int=300;
		public static var DEBUG_BIN:int=0;
		public static var DEBUG_BOUT:int=0;
		public static var DEBUG_BYTESINROW:int = 32;
		public static var DEBUG_TIMESTAMP:int = 0;
		public static var DEBUG_HIDEMENU_ON_CLICK:int = 0;
		public static var DEBUG_DO_PING:int = 1;
		public static var DEBUG_SHOW_PARSING:int = 0;
		public static var DEBUG_SHOW_SOCKETERRORS:int = 0;
		public static var DEBUG_OVERRIDE_ADR:int = 0;
		public static var DEBUG_ANSWER_PROTOCOL2:int = 1;
		public static var DEBUG_TRACE_HTTP:int = 0;
		public static var DEBUG_HISTORY_DIGITAL_VIEW:int = 0;
		public static var DEBUG_SHOW_HTTPERRORS:int = 0;
		public static var DEBUG_IGNORE_FIELD_ERRORS:int = 0;
		public static var DEBUG_K1_FAST_LOAD:int = 0;
		public static var DEBUG_SHOW_LBS_LOG:int = 0;
		public static var DEBUG_LANG:int = 0;
	//	public static var DEBUG_IGNORE_PACKET_DISCREPANCY:Boolean = false;
		
		public static var SAVE_PATH:String="";
		
		public static const FILE_TYPES:Array = [new FileFilter("Binary File", "*.rtm;")];
		public static const FILE_TYPES_CONFIG:Array = [new FileFilter("Ritm Configuration File", "*.rcf;")];
		
		/** CONTROL */
		public static function setSubmenuTopShift(shit:int=0):void
		{
			subMenuContainer.y = 60 + shit;
		}
		
		/** DEEP DEBUG */
		public static var DD:Boolean=false;
		public static var SPAM_DISABLED:Boolean = false; 
	}
}