package components.system
{
	import components.abstract.K14ABytePatcher;
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.NAVI;

	public class CONST
	{
		// 0 - Контакт 14 Ultimate
		public static const PRESET_NUM:int=0;
/** GLOBAL CONST	*/
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = "";
		private static const BUILDVER:String = "021.200";
		
		public static const DEBUG:Boolean = 1 == 1;
		
		public static const PRESET:Array = [
			{	// 1 - Контакт 14 U
				CLIENT_BUILD_VERSION:"K-14."+BUILDVER,
				VERSION:"K-14_and_K-14A_and_K-14W_and_K-14L_and_K-14AW_and_K-14K_and_K-14KW",
				LEVEL:"003",		
				RELEASE:"006-023",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_date"), data:NAVI.DATE, cmds:[CMD.TIME_ZONE, CMD.SERVER_NTP, CMD.TIME_SYNCH]},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, cmds:[CMD.AUTOTEST, CMD.SYS_NOTIF]},
					{label:loc("navi_partition"), data:NAVI.PARTITION, cmds:[CMD.PARTITION, CMD.PART_SET]},
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, group:1, cmds:[CMD.OUT_INDPART,CMD.OUT_ALARM1,CMD.OUT_ALARM2, CMD.LED14_IND] },
					{label:loc("navi_panic_button"), data:NAVI.ALARM_KEY, cmds:[CMD.ALARM_KEY] },
					{label:loc("navi_radiosystem"), data:NAVI.RF_SYSTEM},
					{label:loc("navi_rf_sensors"), data:NAVI.RF_SENSOR, needsystem:true, cmds:[  ]},
					{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL, submenu:true, needsystem:true},
					{label:loc("navi_rf_keyboard"), data:NAVI.RF_KEY, submenu:true, needsystem:true},
					{label:loc("navi_rf_modules_much"), data:NAVI.RF_MODULE, submenu:true, needsystem:true, group: 64 },
					{label:loc("navi_screen_keyboard"), data:NAVI.SCREEN_KEYBOARD },
					//{label:loc("navi_rf_rele"), data:NAVI.RF_RELE, submenu:true, needsystem:true},
					{label:loc("navi_rf_map"), data:NAVI.RF_MAP, submenu:true, needsystem:true},
					{label:loc("navi_user_code"), data:NAVI.USER_PASS, cmds:[CMD.MASTER_CODE,CMD.KEY_BLOCK,CMD.USER_PASS]},
					{label:loc("navi_indsound"), data:NAVI.IND_SOUND, cmds:[CMD.LED14_IND,CMD.BUZZER14,CMD.BUZ_PART], group:4 },
					{label:loc("navi_fourth_keyboard"), data:NAVI.FOURTH_KEYBOARD, cmds:[ CMD.RF_KEY, CMD.RF_KEY_BZI, CMD.RF_KEY_BZP ], group:16 },
					{label:loc("input_temp_sensor"), data:NAVI.TEMPERATURE,  submenu:true, needsystem:true },
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS, cmds:[ CMD.CH_COM_ADD, CMD.CH_COM_LINK, CMD.CH_SEND_IMEI], altLabel:loc("navi_link_channels_no_filter") },
					{label:loc("navi_sms"), data:NAVI.SMS, submenu:true, cmds:[CMD.SMS_PARAM, CMD.SMS_PART, CMD.SMS_ZONE, CMD.SMS_R_CTRL, CMD.SMS_USER, CMD.SMS_TEXT] },
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_param_wifi"), data:NAVI.PARAMS_WIFI, submenu:true, cmds:[CMD.ESP_POINT_SETTINGS], group:2},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_ALL, CMD.ENGIN_NUMB]},
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_device_power"), data:NAVI.DEVICE_POWER },
					{label:loc("navi_lock_from_writer"), data:NAVI.LOCK_FROM_WRITERS, group:8},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE },
					{label:loc("------ debug section"), debug:true},
					{label:loc("Certificate"), data:NAVI.CERTIFICATE, debug:true}
					
				],
				LOADER_SEQUENCE:[
					LoaderServant.NEED_PATCH14AN2,
					LoaderServant.NEED_PARTITION, 
					LoaderServant.NEED_SYSTEM,
					LoaderServant.NEED_VER_INFO1,
					LoaderServant.NEED_APN_INFO ]
			}];
			
/** LOAD SWITCHES */
		public static var MENU_GROUP:int = 0xFF;
		public static var NEED_SIZE_CMD:Boolean = true;
		public static var NEED_PARTITION:Boolean = true;
		public static var NEED_SYSTEM:Boolean = true;
		public static var NEED_VER_INFO1:Boolean = true;
		public static var USE_GPRS_COMPR:Boolean = true;
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
		public static var RFMODULE_NUM:int = 16;

		public static var MENU:Array;
		public static const MENU_UNDEFINED:Array = [
			{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
			/**{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}*/];
		public static function initHardwareConst():void	
		{
			MENU_GROUP = 0;
			
			OPERATOR.getSchema( CMD.BATTERY_LEVEL ).StructCount = 1;
			
			var app:int = int(DS.app);
			var alias:String = DS.alias;
			const release:int = DS.release;
			
			if ( app != 4)
				MENU_GROUP |= 1;	// Выходы
			
			if ( DS.isfam(DS.K14W ))
				MENU_GROUP |= 2;	// Wifi
			
			if ( alias != DS.K14A && alias != DS.K14AW && alias != DS.K14K && alias != DS.K14KW )
				MENU_GROUP |= 4;	// Индикация и звук*/
			if( release > 16 )
				MENU_GROUP |= 64;
			
			switch( alias ) {

				case DS.isfam(DS.K14W ):
					addCmd( NAVI.LINK_CHANNELS, CMD.CH_COM_DUBLE_ONLINE );
				case DS.K14:
					if( release  > 9 )
					{
						MENU_GROUP |= 8;
					}
					
					
					break;
				case DS.K14K:
				case DS.K14KW:
					if( release  >= 11 )
					{
						MENU_GROUP |= 16;
						MENU_GROUP |= 8;
					}
					
					addCmd( NAVI.FOURTH_KEYBOARD, CMD.LED_IND );
					
					break;
					
				case DS.K14A:
				case DS.K14AW:
				
					if( release  >= 11 )
					{
						MENU_GROUP |= 8;
						MENU_GROUP |= 16;
					}
					
					addCmd( NAVI.FOURTH_KEYBOARD, CMD.LED_IND );
					
					break;
				
				
				default:
					
					break;
			}
			/*if ( alias == DEVICES.K14 ) 
				MENU_GROUP |= 8;*/
		/*	if ( alias.search("A")>=0 )
				MENU_GROUP |= 4;	// Звук
			else
				MENU_GROUP |= 8;	// Индикация и звук*/
			
		//	if ( alias.search("A") >= 0 )
		//		MENU_GROUP |= 4;	// Индикация и звук
		//	else
			//MENU_GROUP |= 2;	// Звук
			
			//if ( DEVICES.isDevice(DEVICES.K14A) || DEVICES.isDevice(DEVICES.K14L))	
			//MENU_GROUP |= 16;	// Тревожная кнопка есть везде, кроме L
			
			if( release >= 11 )
			{
				addCmd( NAVI.PARTITION,  CMD.PART_SET_TEST_LINK );
			}
			
			if (app == 4 && DS.isDevice(DS.K14A)) {
				new K14ABytePatcher();
			}
			
			if( release > 22 )
				addCmd( NAVI.SENSOR, CMD.RF_SENSOR_KEY_ZONE );
		}
		
		private static function addCmd(navi:int, cmd:int):void
		{
			var menu:Array = PRESET[PRESET_NUM].MENU;
			var len:int = menu.length;
			for (var i:int=0; i<len; i++) {
				if( menu[i].data == navi ) {
					(menu[i].cmds as Array).push(cmd);
				}
			}
		}
		
		public static var LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD
		];
	}
}
