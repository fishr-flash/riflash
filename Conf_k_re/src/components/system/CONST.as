package components.system
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.NAVI;

	public class CONST
	{
		// 1 - K5 K-5_and_K-5A_and_K-5AA_and_K-5-3G_and_K-5GL_and_A-BRD
		// 2 - K9 K-9_and_K-9A_and_K-9M_and_K-9K
		// 3 - K LAN K-LAN_and_A-ETH
		// 4 - K1  K-1_and_K-1M
		// 5 - K5-RT1 K-RT1_and_K-RT1L_and_K-RT1-3G
		// 6 - K5-RT3 K-RT3_and_K-RT3L_and_K-RT3-3G

		
		public static const PRESET_NUM:int= 2;
/** GLOBAL CONST	*/
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = ""; 
		private static const BUILDVER:String = "005.414";	// c 008 нет запроса на 843 порт
		public static const DEBUG:Boolean = 1 == 0;	// При экспорте поправить FSShadow

		public static const PRESET:Array = [ { /*zerro config, not use*/ },
			{	// 1 - K5
				CLIENT_BUILD_VERSION:"K-5."+BUILDVER,
				VERSION:"K-5_and_K-5A_and_K-5AA_and_K-5-3G_and_K-5GL_and_A-BRD",
				RELEASE:"003-999",
				MENU:[ 
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_general_options"), data:NAVI.GENERAL_OPTIONS, cmds:[CMD.OBJECT ]},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM},
					{label:loc("navi_device_power"), data:NAVI.DEVICE_POWER, group:64 },
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS},
					//{label:loc("navi_phone_line"), data:NAVI.PHONE_LINE, group:32 },
					{label:loc("navi_wire_params"), data:NAVI.WIRE_OPTIONS},
					{label:loc("navi_part_params"), data:NAVI.PARTITION},
					{label:loc("navi_wire_config"), data:NAVI.ALARM_WIRE},
					{label:loc("navi_temperature"), data:NAVI.TEMPERATURE, group:16},
					{label:loc("navi_tmreader"), data:NAVI.TM_READER, group:2},
					{label:loc("navi_keyboards"), data:NAVI.KEYBOARD},
					{label:loc("navi_keyboard_code"), data:NAVI.USER_PASS},
					{label:loc("navi_tmkeys"), data:NAVI.TM_KEYS},
					{label:loc("navi_out"), data:NAVI.OUT},
					{label:loc("navi_screen_keyboard"), data:NAVI.SCREEN_KEYBOARD, group:4 },
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB},
					{label:loc("navi_sms"), data:NAVI.SMS},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_map"), data:NAVI.MAP, group:1},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_lock_from_writer"), data:NAVI.LOCK_FROM_WRITERS, group:8 },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				],
				LOADER_SEQUENCE:[LoaderServant.NEED_APN_INFO
									, LoaderServant.NEED_PARTITION_K5A
									///FIXME: Debug value! Remove it now! Возможно не понадобится затирать
									/// задизабленные разделы, т.к. вроде прошивка должна контролировать
									/// почистить здесь и в LoaderServant
									//, LoaderServant.ERASE_DISABLED_PARTITION_OF_K5A
									, LoaderServant.NEED_K5_ADC_TRESH
									, LoaderServant.NEED_KBD ]
				
			},{	// 2 - K9
				CLIENT_BUILD_VERSION:"K9."+BUILDVER,
				VERSION:"K-9_and_K-9A_and_K-9M_and_K-9K",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_general_options"), data:NAVI.GENERAL_OPTIONS},
					//{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS },
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM},
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS},
					{label:loc("navi_wire_config"), data:NAVI.ALARM_WIRE},
					{label:loc("navi_wire_params"), data:NAVI.WIRE_OPTIONS },
					{label:loc("navi_part_params"), data:NAVI.PARTITION},
					{label:loc("navi_temperature"), data:NAVI.TEMPERATURE},
					{label:loc("navi_screen_keyboard"), data:NAVI.SCREEN_KEYBOARD },
					{label:loc("ui_key_title"), data:NAVI.KEYBOARD, group: 4},
					{label:loc("navi_keyboard_code"), data:NAVI.USER_PASS},
					{label:loc("navi_tmkeys"), data:NAVI.TM_KEYS, group:2},
					{label:loc("navi_out"), data:NAVI.OUT},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB},
					{label:loc("navi_sms"), data:NAVI.SMS},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_map"), data:NAVI.MAP, group:1},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_lock_from_writer"), data:NAVI.LOCK_FROM_WRITERS, group:8 },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				],
				LOADER_SEQUENCE:[LoaderServant.NEED_APN_INFO, LoaderServant.NEED_CH_COM_TIME_PARAM_COUNT ]
				//LOADER_SEQUENCE:[LoaderServant.NEED_APN_INFO ]
			},{	// 3 - K LAN
				CLIENT_BUILD_VERSION:"K-LAN."+BUILDVER,
				VERSION:"K-LAN_and_A-ETH",
				RELEASE:"003-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_guard"), data:NAVI.GUARD, cmds:[CMD.LAN_PART, CMD.OBJECT, CMD.LAN_ZONE]},
					{label:loc("navi_network"), data:NAVI.NETWORK, cmds:[CMD.LAN_MAC, CMD.LAN_DHCP_SETTINGS]},
					{label:loc("navi_server"), data:NAVI.SERVER, cmds:[CMD.LAN_SERVER_CONNECT]},
					{label:loc("navi_net_service"), data:NAVI.NETWORK_MODE, cmds:[CMD.LAN_SNMP_SETTINGS, CMD.LAN_WEB_ENABLE, CMD.LAN_ICMP_ENABLE]},
					{label:loc("navi_service"), data:NAVI.SERVICE},
				]
			},{// 4 - K1
				CLIENT_BUILD_VERSION:"K-1."+BUILDVER,
				VERSION:"K-1_and_K-1M",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_general_options"), data:NAVI.GENERAL_OPTIONS},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM},
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS},
					{label:loc("navi_panic_buttons"), data:NAVI.WIRE_OPTIONS},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB},
					{label:loc("navi_sms"), data:NAVI.SMS},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_lock_from_writer"), data:NAVI.LOCK_FROM_WRITERS, group: 1 },
					{label:loc("navi_service"), data:NAVI.SERVICE},
				],
				LOADER_SEQUENCE:[LoaderServant.NEED_APN_INFO, LoaderServant.NEED_K1_DEFAULTS, LoaderServant.NEED_CH_COM_TIME_PARAM_COUNT ]
			},{// 5 - K5-RT1
				CLIENT_BUILD_VERSION:"K-5 RT1."+BUILDVER,
				VERSION:"K-RT1_and_K-RT1L_and_K-RT1-3G",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_general_options"), data:NAVI.GENERAL_OPTIONS, cmds:[CMD.OBJECT, CMD.SYS_NOTIF, CMD.K5RT_ATEST_CODE, CMD.K5_ADV_ATEST, CMD.K5_MAIN_ATEST, CMD.K5RT_EMULATOR_HS]},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, cmds:[CMD.SYS_NOTIF, CMD.K5RT_ATEST_CODE, CMD.K5_ADV_ATEST, CMD.K5_MAIN_ATEST]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.K5_G_TRY_TIME, CMD.K5RT_GPRS_ADD, CMD.CH_COM_LINK_GPRS, CMD.GPRS_SIM]},
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS, cmds:[CMD.K5RT_CH_ONLINE, CMD.K9_IMEI_IDENT, CMD.K5RT_DIR_CHANGE,
						CMD.PING_SET_TIME, CMD.K5RT_DIRECTIONS]},
					{label:loc("navi_wire_params"), data:NAVI.WIRE_OPTIONS, cmds:[CMD.K5RT_AWIRE_TYPE]},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.K5_EPHONE,CMD.ENGIN_ALL]},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_lock_from_writer"), data:NAVI.LOCK_FROM_WRITERS, group:8 },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					//{label:"------ debug section", debug:true},
					//{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				]
			},{// 6 - K5-RT3
				CLIENT_BUILD_VERSION:"K-5 RT3."+BUILDVER,
				VERSION:"K-RT3_and_K-RT3L_and_K-RT3-3G",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, group:2},
					{label:loc("navi_general_options"), data:NAVI.GENERAL_OPTIONS, cmds:[CMD.OBJECT, CMD.SYS_NOTIF, CMD.K5_ADV_ATEST, CMD.K5_MAIN_ATEST, CMD.K5RT_SLOW_DTMF]},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, cmds:[CMD.SYS_NOTIF, CMD.K5_ADV_ATEST, CMD.K5_MAIN_ATEST]},
					{label:loc("navi_c2000_events"), data:NAVI.C2000_EVENTS, cmds:[ CMD.K5RT_BOLID_FLTR_TYPE
																					, CMD.K5RT_BOLID_EVENT_MASK
																					, CMD.K5RT_BOLID_OBJECT
																					, CMD.K5RT_BOLID_PROTOCOL_TYPE ]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.K5_G_TRY_TIME, CMD.K5RT_GPRS_ADD, CMD.CH_COM_LINK_GPRS, CMD.GPRS_SIM]},
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS, cmds:[CMD.K5RT_CH_ONLINE, CMD.K9_IMEI_IDENT, CMD.K5RT_DIR_CHANGE,
						CMD.PING_SET_TIME, CMD.K5RT_DIRECTIONS]},
					{label:loc("navi_wire_params"), data:NAVI.WIRE_OPTIONS, cmds:[CMD.K5RT_AWIRE_TYPE, CMD.K5RT_BOLID_LINK, CMD.K5RT_TAMPER]},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.K5_EPHONE,CMD.ENGIN_ALL]},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_lock_from_writer"), data:NAVI.LOCK_FROM_WRITERS },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:loc("navi_bolid_online"), data:NAVI.BOLID_ONLINE },// cmds:[ CMD.K5RT_BOLID_ONLINE ]},
					
					{label:"------ debug section", debug:true}
					//{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				]
			}];
		
/** LOAD SWITCHES */
		public static var MENU_GROUP:int = 0xFF;
		public static var NEED_SIZE_CMD:Boolean = true;
		public static var NEED_PARTITION:Boolean = false;
		public static var NEED_SYSTEM:Boolean = false;
		public static const NEED_VER_INFO1:Boolean = false;
		public static var USE_GPRS_COMPR:Boolean = false;
		public static var USE_GPRS_ROAMING:Boolean = false;
		
		public static var RELEASE:Object;
		public static var STRICT:Boolean = false;	// Если true - различие версий прибора не даст запуститься клиенту
/** GLOBAL SWITCHES */
		public static var FLASH_VARS:Object;
/** CONSTANTS */
		public static var SYSTEM_PERIOD_OF_TRANSMISSION_ALARM:int = 0;
	// MENU	
		public static var MENU:Array;
		public static const MENU_UNDEFINED:Array = [{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
			/**{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}*/];
		
		/**
		 * Здесь ставим фильтр на выведение пунктов 
		 * меню для различных приборов, релизов и пр.
		 * признаков.
		 * 
		 * В массиве PRESET мы должны добавить в состав
		 * элемента который должен быть скрыт при опр. 
		 * обстоятельствах поле group:int. Теперь
		 * когда в свиче мы выяснили, что совпал тот или иной
		 * признак оборудования мы должны указать битовую маску пунктов
		 * которые будут скрыты. Например если группа меню которую
		 * мы намерены исключить содержит идентификатор 4 ( 0000 0100 ), то
		 * мы должны в маске указать MENU_GROUP |= 4 ( 0000 0100 ), тогда
		 * все пункты меню которые мы отнесли к 4ой группе выведены 
		 * не будут.
		 * 
		 */		
		public static function initHardwareConst():void
		{
			MENU_GROUP = 0;
			var app:int = int(DS.app);
			var r:int = DS.release;
			
			
			
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					if( DS.isDevice( DS.A_BRD ) )
					{
						OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 69;
					}
					else if(  r < 12 )
						OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 55;
					else if(  r == 12 )
						OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 66;
					else
						OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 67;
					
					if (SERVER.isGeoritm())
						MENU_GROUP |= 1;
					if (r >= 6)
						MENU_GROUP |= 2;	// READER
					if(  r > 9 )
					{
						MENU_GROUP |= 8;	// Экран снятия блокировки
						
						
						if( DS.isfam( DS.K5, DS.K5AA, DS.A_BRD, DS.K5A, DS.K5GL  ) ) OPERATOR.getSchema( CMD.K5_AWIRE_STATE).StructCount = 16;
						
					}
					
					/*if( DS.isDevice( DS.A_BRD ) )
					{
						MENU_GROUP |= 32;	// Контроль телефонной линии
					}*/
					
					if(  r > 11 )
						MENU_GROUP |= 16;	// Экран температур
					
					OPERATOR.getSchema( CMD.SMS_PART).StructCount = 16;
					
					if( ( DS.isfam( DS.K5, DS.A_BRD ) && app != 6 && app != 8 )  )
													MENU_GROUP |= 64;
					
					break;
				case DS.K5RT1:
				case DS.K5RT13G:
				case DS.K5RT1L:
					MENU_GROUP |= 8;	// Экран снятия блокировки
					break;
				case DS.K5RT3:
				case DS.K5RT33G:
					if(  r > 6 )
								MENU_GROUP |= 2;	// Экран Сведения о приборе
					break;
				case DS.K1M:
					if( r > 8 ) MENU_GROUP |= 1;	// Экран снятия блокировки
					if( r < 10 ) OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 68;
					 OPERATOR.getSchema( CMD.VER_INFO1).StructCount = 1;
					break;
				case DS.K9:
				case DS.K9K:
					if(  app != 2 || r != 7 ){
						MENU_GROUP |= 4;
						
					}
								
					
					MENU_GROUP |= 2;
					
				case DS.K9A:
				case DS.K9M:
					
					if (SERVER.isGeoritm())
						MENU_GROUP |= 1;
					if (app == 5 || app == 2  )	// TM-KEYS
						MENU_GROUP |= 2;
					MENU_GROUP |= 8;
					
					
				OPERATOR.getSchema( CMD.K5_ADC_TRESH).StructCount = 3;
				OPERATOR.getSchema( CMD.K5_AWIRE_STATE).StructCount = 6;
				///FIXME: Debug value! Remove it now! Проработать вопрос, затем включать.
				//OPERATOR.getSchema( CMD.K5_KBD_KEY_CNT).StructCount = 10;
					break;
				
				
			}
			
			
			
		}
		public static var LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD
			
		];
	}
}
