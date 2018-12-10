package components.system
{
	import components.abstract.functions.loc;
	import components.static.COLOR;
	import components.static.NAVI;

	public class CONST
	{
		// 1 - К 1
		// 2 - Sensors
		public static const PRESET_NUM:int=1;
/** GLOBAL CONST	*/
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = "";
		private static const BUILDVER:String = "004.007";
		public static const DEBUG:Boolean = 1 == 1;

		public static const PRESET:Array = [ {},
			{	// 1 - К 1
				CLIENT_BUILD_VERSION:"K-1."+BUILDVER,
				VERSION:"K-1",
				RELEASE:"VER 101.003.002_and_VER 101.003.003_and_VER 101.003.004",
				MENU:[
					{label:loc("navi_general_options"), data:NAVI.GENERAL_OPTIONS},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM},
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS},
					{label:loc("navi_panic_buttons"), data:NAVI.ALARM_KEY},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB},
					{label:loc("navi_sms"), data:NAVI.SMS},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_service"), data:NAVI.SERVICE}
				]
			},{	// 2 - Sensors
				CLIENT_BUILD_VERSION:"SNR."+BUILDVER,
				VERSION:"SNR",
				RELEASE:true,
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, group:1},
					{label:loc("navi_tuning"), data:NAVI.CONFIG, group:2},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
				]
			}];
		
/** LOAD SWITCHES */
		public static var NEED_SIZE_CMD:Boolean = true;
		public static var NEED_PARTITION:Boolean = false;
		public static var NEED_SYSTEM:Boolean = false;
		public static const NEED_VER_INFO1:Boolean = false;
		public static var USE_GPRS_COMPR:Boolean = false;
		public static var USE_GPRS_ROAMING:Boolean = true;
		public static var RELEASE:Object;
		public static var STRICT:Boolean = false;	// Если true - различие версий прибора не даст запуститься клиенту
/** GLOBAL SWITCHES */
		public static var MENU_GROUP:int = 0xFF;
		public static var FLASH_VARS:Object;
		public static var CLIENT_DEFAULT_STRING_HEIGHT:int = 25;
/** CONSTANTS */
		public static var LINK_CHANNELS_NUM:int = 8;
	// MENU	
		public static var MENU:Array;
		public static const MENU_UNDEFINED:Array = [{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}];
		public static function initHardwareConst():void
		{
		}
		public static const LOADER_SEQUENCE:Array = [
		];
	}
}
