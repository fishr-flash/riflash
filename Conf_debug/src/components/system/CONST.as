package components.system
{
	import components.abstract.sysservants.LoaderServant;
	import components.static.CMD;
	import components.static.NAVI;

	public class CONST
	{
/** GLOBAL CONST	*/
		public static const CLIENT_BUILD_VERSION:String = "Dbg.001.001";
		public static const VERSION:String = "Debug";
		public static const DEBUG:Boolean = true;
/** LOAD SWITCHES */
		public static const NEED_SIZE_CMD:Boolean = false;
		public static const NEED_PARTITION:Boolean = false;
		public static const NEED_SYSTEM:Boolean = false;
		public static const NEED_VER_INFO1:Boolean = false;
		public static const USE_GPRS_COMPR:Boolean = false;
		public static const USE_GPRS_ROUMING:Boolean = false;
		public static var LEVEL:int = 1;
		public static var TARGET_SOFTWARE:Object="000.001";
/** GLOBAL SWITCHES */
		public static var FLASH_VARS:Object;
		public static var CLIENT_DEFAULT_STRING_HEIGHT:int = 25;
		public static const SAVE_PATH:String = "";
	//	public static const USE_OUTDATED_PROTOCOL:Boolean= false;
/** CONSTANTS */
		public static var LINK_CHANNELS_NUM:int = 8;
		public static var RFKEY_NUM:int = 3;
	// MENU	ALIGNED
		public static const MENU:Array = [
			{label:"Сервис", data:NAVI.SERVICE, binary:true},
		];
		
		public static const MENU_UNDEFINED:Array = [{label:"Сервис", data:NAVI.SERVICE, binary:true}];
		public static function initHardwareConst():void	{
		
		}
		public static const LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD,
			LoaderServant.NEED_PARTITION, 
			LoaderServant.NEED_SYSTEM
		];
	}
}
