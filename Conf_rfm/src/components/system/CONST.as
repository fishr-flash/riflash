package components.system
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.NAVI; 

	public class CONST
	{
		// 1 - Реле - Сирена - Табло - это Wifimodul
		// 2 - Новая редакция RDK с процессором STM
		// 3 - RDK-LR RDK LoRa
		// 4 - M-RR1  Радиосистема Ритм. Ретранслятор 433МГц.
		// 5 - R-10.Интеллектуальное реле
		public static const PRESET_NUM:int = 4;
/** GLOBAL CONST	*/
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = "";
		private static const BUILDVER:String = "002.117";
		public static const DEBUG:Boolean = 1== 1;

		public static const PRESET:Array = [ {},
			{	// 1 - Реле - Сирена - Табло
				CLIENT_BUILD_VERSION:"Wifi Modul."+BUILDVER,
				VERSION:"M-R1_and_M-S1_and_M-T1",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_sensors"), data:NAVI.SENSOR },
					{label:loc("navi_indication"), data:NAVI.OUT, submenu:true, group:2, cmds:[CMD.CTRL_INIT_OUT,
						CMD.CTRL_TEMPLATE_AL_PART, CMD.CTRL_TEMPLATE_ST_PART, CMD.CTRL_TEMPLATE_AL_LST_PART, CMD.CTRL_TEMPLATE_UNSENT_MESS,
						CMD.CTRL_TEMPLATE_MANUAL_TIME, CMD.CTRL_TEMPLATE_FAULT,	CMD.CTRL_TEMPLATE_OUT, CMD.CTRL_NAME_OUT]},
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, group:1, cmds:[CMD.CTRL_INIT_OUT,
						CMD.CTRL_TEMPLATE_AL_PART, CMD.CTRL_TEMPLATE_ST_PART, CMD.CTRL_TEMPLATE_AL_LST_PART, CMD.CTRL_TEMPLATE_UNSENT_MESS,
						CMD.CTRL_TEMPLATE_MANUAL_TIME, CMD.CTRL_TEMPLATE_FAULT,	CMD.CTRL_TEMPLATE_OUT, CMD.CTRL_NAME_OUT]},
					{label:loc("navi_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CTRL_SERVER_SETTINGS] },  
					{label:loc("navi_control_device"), data:NAVI.CONTROL_DEVICE, cmds:[CMD.CTRL_FILTER_CMD] },
					{label:loc("navi_param_wifi"), data:NAVI.PARAMS_WIFI, submenu:true, cmds:[CMD.ESP_POINT_SETTINGS, CMD.ESP_SET_NET]},
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE},
				],
				LOADER_SEQUENCE:[ LoaderServant.NEED_RFM_OUTCOUNT,
					LoaderServant.NEED_RFM_AVAILABLE_SENSOR]
			},{
				// 2 - Новая редакция RDK с процессором STM
				CLIENT_BUILD_VERSION:"RDK."+BUILDVER,
				VERSION:"RDK",
				RELEASE:"001-006",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_sensors"), data:NAVI.SENSOR },
					{label:loc("navi_radiosystem"), data:NAVI.RF_SYSTEM},
					{label:loc("navi_rf_sensors"), data:NAVI.RF_SENSOR, needsystem:true},
					{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL, needsystem:true},
					{label:loc("navi_rf_map"), data:NAVI.RF_MAP, needsystem:true},
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, cmds:[CMD.CTRL_NAME_OUT, CMD.CTRL_TEMPLATE_RFSENSALARM,
						CMD.CTRL_INIT_OUT, CMD.CTRL_TEMPLATE_RCTRL, CMD.CTRL_TEMPLATE_OUT, CMD.CTRL_TEMPLATE_RFSENSSTATE]},
					{label:loc("navi_event_log"), data:NAVI.HISTORY},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE}
				],
				LOADER_SEQUENCE:[ LoaderServant.NEED_SYSTEM,
					LoaderServant.NEED_RFM_OUTCOUNT,
					LoaderServant.NEED_RFM_AVAILABLE_SENSOR]
			},{
				// 3 - RDK LoRa 
				CLIENT_BUILD_VERSION:"RDK-LR."+BUILDVER,
				VERSION:"RDK-LR",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_radiosystem"), data:NAVI.RF_SYSTEM, cmds:[ CMD.LR_RF_SYSTEM ]},
					{label:loc("navi_panic_buttons"), data:NAVI.ALARM_KEY },
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, cmds:[CMD.CTRL_NAME_OUT, CMD.CTRL_TEMPLATE_RFSENSALARM,
						CMD.CTRL_INIT_OUT, CMD.CTRL_TEMPLATE_RCTRL, CMD.CTRL_TEMPLATE_OUT, CMD.CTRL_TEMPLATE_RFSENSSTATE]},
					{label:loc("navi_event_log"), data:NAVI.HISTORY},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE}
				],
				LOADER_SEQUENCE:[ //LoaderServant.NEED_SYSTEM,
					LoaderServant.NEED_RFM_OUTCOUNT,
					LoaderServant.NEED_RFM_CNT_SENSOR,
					LoaderServant.NEED_RFM_AVAILABLE_SENSOR]
			},{
				// 4 - M-RR1  Радиосистема Ритм. Ретранслятор 433МГц.
				CLIENT_BUILD_VERSION:"M-RR1."+BUILDVER,
				VERSION:"M-RR1",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					/*{label:loc("navi_sensors"), data:NAVI.SENSOR },*/
					{label:loc("navi_radiosystem"), data:NAVI.RF_SYSTEM},
					{label:loc("navi_rf_sensors"), data:NAVI.RF_SENSOR, needsystem:true},
					//{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL, needsystem:true},
					{label:loc("navi_rf_map"), data:NAVI.RF_MAP, needsystem:true},
					/*{label:loc("navi_out"), data:NAVI.OUT, submenu:true, cmds:[CMD.CTRL_NAME_OUT, CMD.CTRL_TEMPLATE_RFSENSALARM,
						CMD.CTRL_INIT_OUT, CMD.CTRL_TEMPLATE_RCTRL, CMD.CTRL_TEMPLATE_OUT, CMD.CTRL_TEMPLATE_RFSENSSTATE]},
					{label:loc("navi_event_log"), data:NAVI.HISTORY},*/
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
					//{label:loc("navi_service"), data:NAVI.SERVICE}
				],
				LOADER_SEQUENCE:[ LoaderServant.NEED_SYSTEM ]//,
					//LoaderServant.NEED_RFM_OUTCOUNT,
					//LoaderServant.NEED_RFM_AVAILABLE_SENSOR]
			},{
				// 5 - Интеллектуальное реле R-10
				CLIENT_BUILD_VERSION:"R-10."+BUILDVER,
				VERSION:"R-10_and_A-REL",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_sensors"), data:NAVI.SENSOR },
					{label:loc("navi_relay"), data:NAVI.DATA_RELE, submenu:true, cmds:[CMD.CTRL_INIT_OUT
																						, CMD.CTRL_TEMPLATE_OUT
																						, CMD.CTRL_TEMPLATE_REACT_ST_PART
																						, CMD.CTRL_TEMPLATE_REACT_ST_ZONE
																						, CMD.CTRL_TEMPLATE_ALL_FIRE
																						, CMD.CTRL_TEMPLATE_MANUAL_TIME
																						, CMD.CTRL_TEMPLATE_REACT_ST_EXT] },
				//	{label:loc("navi_adress"), data:NAVI.ADDRESS, cmds:[CMD.SET_ADDR_DATA]},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_control_device"), data:NAVI.ENCRYPTION},
					{label:loc("navi_service"), data:NAVI.SERVICE}
				],
				LOADER_SEQUENCE:[ 
					LoaderServant.NEED_RFM_OUTCOUNT,
					LoaderServant.NEED_RFM_AVAILABLE_SENSOR
				]
			}];
		
/** LOAD SWITCHES */
		public static var MENU_GROUP:int = 0xFF;
		public static var NEED_SIZE_CMD:Boolean = true;
		public static var NEED_PARTITION:Boolean = false;
		public static var NEED_SYSTEM:Boolean = false;
		public static var NEED_VER_INFO1:Boolean = false;
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
		public static const MENU_UNDEFINED:Array = [
			{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }];
		public static function initHardwareConst():void
		{
			// Если табло или сирена, надо переименовать Выходы в Индикацию
			MENU_GROUP = 0;
			
			if (DS.isDevice(DS.MS1) || DS.isDevice(DS.MT1))
				MENU_GROUP |= 2;
			else
				MENU_GROUP |= 1;
		}
		public static var LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD
		];
	}
}
