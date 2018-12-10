package components.system
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.NAVI;

	public class CONST
	{
		// 0 - Контакт 2
		// 1 - Контакт 2 Online
		public static const PRESET_NUM:int=0;
/** GLOBAL CONST	*/
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = "";
		private static const BUILDVER:String = "009.023";
		
		public static const DEBUG:Boolean = Boolean(1 == 1);
		
		public static const PRESET:Array = [
			{	// 1 - Контакт 2
				CLIENT_BUILD_VERSION:"K-2."+BUILDVER,
				VERSION:"K-2",
				LEVEL:"001",		
				RELEASE:"003-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_date"), data:NAVI.DATE, cmds:[CMD.TIME_ZONE,CMD.SERVER_NTP,CMD.TIME_SYNCH]},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, cmds:[CMD.AUTOTEST, CMD.SYS_NOTIF2, CMD.USSD_BALANS, CMD.AUTOTEST_CYCLE ]},
					{label:loc("navi_energy_save"), data:NAVI.POWER_SAVE, cmds:[CMD.POWER_SAVE]},
					{label:loc("navi_sensor"), data:NAVI.SENSOR, cmds:[CMD.SENSOR_K2]},
					{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL },
					{label:loc("navi_tmreader"), data:NAVI.TM_READER, cmds:[CMD.READER_TM2]},
					{label:loc("navi_tmkeys"), data:NAVI.TM_KEYS, cmds:[CMD.TM_KEY2] },
					{label:loc("navi_zummer_alarm"), data:NAVI.BUZZER_SIREN, cmds:[CMD.BUZZER_SIREN]},
					{label:loc("navi_notify"), data:NAVI.NOTIF, cmds:[CMD.NOTIF_K2, CMD.NOTIF_K2_LIMIT]},
					{label:loc("navi_sms"), data:NAVI.SMS_SETTING, cmds:[CMD.SMS_SETTING_K2, CMD.SMS_TEXT_K2]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM]},
					{label:loc("navi_event_log"), data:NAVI.HISTORY},
					{label:loc("navi_test"), data:NAVI.TEST},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE }
				],
				LOADER_SEQUENCE:[ LoaderServant.NEED_USSD_BALANCE, LoaderServant.NEED_VER_INFO1 ]
			},{
				// 2 - Контакт 2 Online
				CLIENT_BUILD_VERSION:"K-2M."+BUILDVER,
				VERSION:"K-2M",
				LEVEL:"001",		
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_date"), data:NAVI.DATE, cmds:[CMD.TIME_ZONE, CMD.SERVER_NTP, CMD.TIME_SYNCH]},
					/*{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, cmds:[CMD.AUTOTEST, CMD.SYS_NOTIF2, CMD.USSD_BALANS, CMD.AUTOTEST_CYCLE ]},
					{label:loc("navi_energy_save"), data:NAVI.POWER_SAVE, cmds:[CMD.POWER_SAVE]},
					{label:loc("navi_sensor"), data:NAVI.SENSOR, cmds:[CMD.SENSOR_K2]},
					{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL },
					{label:loc("navi_tmreader"), data:NAVI.TM_READER, cmds:[CMD.READER_TM2]},
					{label:loc("navi_tmkeys"), data:NAVI.TM_KEYS, cmds:[CMD.TM_KEY2] },
					{label:loc("navi_zummer_alarm"), data:NAVI.BUZZER_SIREN, cmds:[CMD.BUZZER_SIREN]},
					{label:loc("navi_notify"), data:NAVI.NOTIF, cmds:[CMD.NOTIF_K2, CMD.NOTIF_K2_LIMIT]},
					{label:loc("navi_sms"), data:NAVI.SMS_SETTING, cmds:[CMD.SMS_SETTING_K2, CMD.SMS_TEXT_K2]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM]},
					{label:loc("navi_event_log"), data:NAVI.HISTORY},*/
					{label:loc("navi_test"), data:NAVI.TEST},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:"------ debug section", debug:true},
					{label:loc("navi_service"), data:NAVI.SERVICE }
					
				]/*,
				LOADER_SEQUENCE:[ LoaderServant.NEED_USSD_BALANCE ]*/
			}];
			
/** LOAD SWITCHES */
		public static var MENU_GROUP:int = 0xFF;
		public static var NEED_SIZE_CMD:Boolean = true;
		public static var NEED_PARTITION:Boolean = false;
		public static var NEED_SYSTEM:Boolean = false;
		public static var NEED_VER_INFO1:Boolean = false;
		public static var USE_GPRS_COMPR:Boolean = false;
		public static var USE_GPRS_ROAMING:Boolean = false;
		public static var LEVEL:Object;
		public static var RELEASE:Object;
		public static var STRICT:Boolean = false;	// Если true - различие версий прибора не даст запуститься клиенту
		
/** GLOBAL SWITCHES */
		public static var FLASH_VARS:Object;
		public static var CLIENT_DEFAULT_STRING_HEIGHT:int = 25;
		public static const SAVE_PATH:String = "";
		public static const USE_OUTDATED_PROTOCOL:Boolean= false;
		
/** CONSTANTS */
		public static var LINK_CHANNELS_NUM:int = 8;
		public static var RFKEY_NUM:int = 3;

		public static var MENU:Array;
		public static const MENU_UNDEFINED:Array = [
			{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
			{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}];
		public static function initHardwareConst():void		{	}
		public static var LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD
		];
	}
}
