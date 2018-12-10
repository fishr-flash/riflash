package components.protocol.statics
{
	import components.abstract.functions.loc;

	public class SERVER
	{
		public static var ADDRESS:int = 0xFF;
		public static var ADDRESS_TOP:int = 0xFF;
		public static var ADDRESS_BOTTOM:int = 0xFF;
		
		public static var BUF_SIZE_SEND:int = 0;
		public static var BUF_SIZE_RECEIVE:int = 0;
		public static var MAX_IND_CMDS:int = -1;
		
	/*	public static function set MAX_IND_CMDS(value:int):void
		{
			//_MAX_IND_CMDS = value;
		}
		public static function get MAX_IND_CMDS():int 
		{
			return 1;
		}*/
		
		public static var TOP_BUF_SIZE_SEND:int = 0;
		public static var TOP_BUF_SIZE_RECEIVE:int = 0;
		public static var TOP_MAX_IND_CMDS:int = -1;
		public static var BOTTOM_BUF_SIZE_SEND:int = 0;
		public static var BOTTOM_BUF_SIZE_RECEIVE:int = 0;
		public static var BOTTOM_MAX_IND_CMDS:int = -1;
		
		// Группа переменных для коннекта через Java прослойку в интернете
		public static const REMOTE_ADDRESS:int = 0xFD;
		public static var REMOTE_HOST:String;
		public static var REMOTE_PORT:int = 0;
		public static var REMOTE_TOKEN:String;
		public static var REMOTE_TOKEN_PASSED:Boolean = false;	// true выставляется как только токен был запрошен, вне зависимости от результата.  false - при уходе в офф
		
		public static var UPDATE_SERVER_ADR:String = "http://device.ritm.ru";//"http://192.168.104.208";
		public static var UPDATE_SERVER_PORT:int = 80;
		
		public static const REQUEST_READ:int = 0x01;	// функция чтение структуры параметров;
		public static const ANSWER_READ:int = 0x02;		// функция подтверждения чтения структуры параметров;
		public static const REQUEST_WRITE:int = 0x03;	// функция записи структуры параметров;
		public static const ANSWER_WRITE:int = 0x04;	// функция подтверждения записи структуры параметров;
		public static const REQUEST_COMPRESSED_WRITE:int = 0x05;	// функция сжатой записи
		public static const ANSWER_COMPRESSED_WRITE:int = 0x06;	// функция подтверждения сжатой записи
		public static const ONE_WAY_WRITE:int = 0x07;	// функция записи не требующая подтверждения
		public static const ONE_WAY_COMPRESSED_WRITE:int = 0x09;	// функция записи не требующая подтверждения
		public static const BROKEN:int = 0xFF;	// функция подтверждения записи структуры параметров;
		public static const ERROR:int = 0xF1;	// функция подтверждения записи структуры параметров;
		
		public static var VER:String;
		public static var HARDWARE_VER:String;
		public static var READABLE_VER:String = "";
		
		private static var _VER_FULL:String;		// ver_info=1, param 2
		public static function set VER_FULL(value:String):void
		{
			_VER_FULL = value;
		}
		public static function get VER_FULL():String 
		{
			if (_VER_FULL is String)
				return _VER_FULL;
			return loc("sys_unidentified").toLowerCase();
		}
		
		public static var VER_SOFTWARE:String="";			// ver_info=2, param 1
		public static var DUAL_DEVICE:Boolean=false	// когда прибор подключен по цепи или как двойная плата (нужно менять ардеса)
		
		public static var BOTTOM_VERSION_MISMATCH:Boolean=false;	// когда нижний прибор не подошел версией
		public static var BOTTOM_LEVEL:Object;				// дублирование информации для роботов
		public static var BOTTOM_SOFTWARE:Object;		// дублирование информации для роботов
		public static var BOTTOM_APP:String;		// дублирование информации для роботов
		public static var BOTTOM_VER_INFO:Array;
		public static var BOTTOM_RELEASE:int;
		
		public static var CONNECTION_TYPE:String = "";
		public static const CONNECTION_COM:String="com";
		public static const CONNECTION_CSD:String="csd";
		public static const CONNECTION_USB:String="usb";
		public static const CONNECTION_LAN:String="lan";
		public static const CONNECTION_GPRS:String="gprs";
		public static const CONNECTION_WIFI:String="wifi";
		public static function isSlowConnection():Boolean
		{
			
			if (CONNECTION_TYPE == CONNECTION_GPRS || CONNECTION_TYPE == CONNECTION_CSD )
				return true;
			return false;
		}
		public static function isUSBConnection():Boolean
		{
			return REMOTE_TOKEN == null;
		}
		public static function isGeoritm():Boolean
		{
			return REMOTE_TOKEN_PASSED;
		}
	}
}