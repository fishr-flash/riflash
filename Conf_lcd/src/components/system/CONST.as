package components.system
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.NAVI;

	public class CONST
	{
		// 1 - ACC2
		// 2 - versionless updater
		// 3 - LCD key
		
		public static const PRESET_NUM:int=3;
/** GLOBAL CONST	*/
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = "";
		private static const BUILDVER:String = "003.007";	// 001.004 no 843 port
		public static const DEBUG:Boolean = 1 == 1;

		public static const PRESET:Array = [ {},
			{	// 1 - ACC reborn
				CLIENT_BUILD_VERSION:"ACC2."+BUILDVER,
				VERSION:"ACC-2",
				RELEASE:"001-003",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO_ACC},
					{label:loc("navi_calibration"), data:NAVI.CONFIG},
					{label:loc("navi_output"), data:NAVI.OUT, cmds:[CMD.OUT_ACC] },
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_SENSOR_SI, CMD.VR_SENSOR_SA, CMD.VR_SENSOR_SC]},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
				]
			},{	// 2 - versionless updater
				CLIENT_BUILD_VERSION:"UPD."+BUILDVER,
				VERSION:"ANYVERSION",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
				]
			},{	// 3 - lcd key
				CLIENT_BUILD_VERSION:"LCD."+BUILDVER,
				VERSION:"LCD-1_and_LCD-2",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_display"), data:NAVI.DISPLAY},
					{label:loc("navi_logo"), data:NAVI.LOGO, binary:true },
					{label:loc("navi_adress"), data:NAVI.ADDRESS },
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
					//{label:loc("navi_service"), data:NAVI.SERVICE, binary:true},
				]
			}];
		
/** LOAD SWITCHES */
		public static var MENU_GROUP:int = 0xFF;
		public static var NEED_SIZE_CMD:Boolean = true;
		public static var NEED_PARTITION:Boolean = false;
		public static var NEED_SYSTEM:Boolean = false;
		public static const NEED_VER_INFO1:Boolean = false;
		public static var USE_GPRS_COMPR:Boolean = false;
		public static var USE_GPRS_ROAMING:Boolean = true;
		public static var RELEASE:Object;
		public static var STRICT:Boolean = false;	// Если true - различие версий прибора не даст запуститься клиенту
/** GLOBAL SWITCHES */
		public static var FLASH_VARS:Object;
		public static var CLIENT_DEFAULT_STRING_HEIGHT:int = 25;
/** CONSTANTS */
	// MENU	
		public static var MENU:Array;
		public static const MENU_UNDEFINED:Array = [{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
			/*{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}*/];
		public static function initHardwareConst():void
		{
		}
		public static var LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD
		];
	}
}
