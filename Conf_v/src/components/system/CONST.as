package components.system
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.NAVI;

	public class CONST
	{
		
		// 1 - Вояджер L1/L2
		// 2 - Вояджер 2/L3
		// 3 - Вояджер 3
		// 4 - Вояджер 4
		// 5 - Вояджер 5
		// 6 - Вояджер 6
		// 7 - Вояджер L0
		// 8 - V-BRPM
		// 9
		public static const PRESET_NUM:int= 2;
/** GLOBAL CONST	*/
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = "";
		private static const BUILDVER:String = "034.293";	// 029.002 no 843 port
		///  1 - on debug
		public static const DEBUG:Boolean = 1 == 1; 

		public static const VOYAGER_PAR_STRUCTURES:int=1;
		
		public static const PRESET:Array = [ {},
			{	// 1 - Вояджер 2 Лайт
				CLIENT_BUILD_VERSION:"VL."+BUILDVER,
				VERSION:"V-L1_and_V-L2_and_V-L1-3G_and_V-L2-3G", 
				RELEASE:"026-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, cmds:[ CMD.VR_SMS_GUARD ]},
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT
																		, CMD.VR_WORKMODE_SET
																		, CMD.VR_WORKMODE_ENGINE_START
																		, CMD.VR_WORKMODE_ENGINE_RUNS
																		, CMD.VR_WORKMODE_ENGINE_STOP
																		, CMD.VR_WORKMODE_START
																		, CMD.VR_WORKMODE_MOVE
																		, CMD.VR_WORKMODE_STOP
																		, CMD.VR_WORKMODE_PARK
																		, CMD.VR_WORKMODE_REGULAR
																		, CMD.VR_WORKMODE_SCHEDULE] },
					{label:loc("navi_events"), data:NAVI.VOYAGER_EVENTS, cmds:[ CMD.VR_NEW_FLAG_ENABLE, CMD.VR_MSG_SETTINGS ], group: 16 },
					{label:loc("navi_sms"), data:NAVI.SMS, cmds:[ CMD.VR_SMS_LOCATION_ENABLE
																, CMD.VR_SMS_SETTINGS
																, CMD.VR_SMS_SCHEDULE
																, CMD.VR_SMS_NOTIF
																, CMD.VR_SMS_NOTIF_LIST
																, CMD.TIME_ZONE ], group:1024 },
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_3DFIX, CMD.VR_PACK_SIZE, CMD.VR_FILTER_TRACK]}, //, debug:true
					{label:loc("navi_agps"), data:NAVI.AGPS, cmds:[CMD.VR_AGPS_ENABLE], group:1 },
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR] },
					{label:loc("navi_conters"), data:NAVI.COUNTERS, cmds:[CMD.VR_COUNTER_NAV_MILEAGE, CMD.VR_COUNTER_NAV_HOURS] },
					{label:loc("navi_input"), data:NAVI.INPUT, submenu:true, cmds:[CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL] },
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, cmds:[ CMD.VR_OUT  ], group:4 },//, CMD.VR_SPEED_ALARM, CMD.VR_ACC_ALARM, CMD.VR_OUT, CMD.VR_OUT_STATE ], group:128 },
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER
																					, CMD.PROTOCOL_TYPE
																					, CMD.EGTS_LOGIN_ENABLE
																					, CMD.EGTS_USER_NAME_PASSWORD]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_param_egts"), data:NAVI.PARAMS_EGTS, cmds:[CMD.EGTS_UNIT_HOME_DISPATCHER_ID
																					, CMD.EGTS_SUBRECORD_TELEDATA_EN
																					, CMD.EGTS_CNT_STAT_SEND_ENABLE
																					, CMD.EGTS_CRYPTO_ENABLE
																					, CMD.EGTS_CRYPTO_GOST_S_BOX
																					, CMD.EGTS_CRYPTO_GOST_KEY
																					, CMD.EGTS_FLAG_ENABLE ], group:1 },
					{label:loc("navi_egts_stats"), data:NAVI.STATS_EGTS, group:2 },
					{label:loc("navi_net_mode"), data:NAVI.NETWORK_MODE, cmds:[ CMD.MODEM_NETWORK_CTRL ], group: 8 },
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY },
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					//	{label:"Навигационный приемник", data:NAVI.NAVI_RECEIVER, cmds:[CMD.VR2_NMEA_SEND_PORT]},
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true },
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				]
			},{	// 2 - Вояджер 2
				CLIENT_BUILD_VERSION:"V2/L3."+BUILDVER,
				VERSION:"V-2_and_V-L3_and_V-2N_and_V-2-3G_and_V-L3-3G_and_V-ASN",
				RELEASE:"025-999",//"020.015",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, cmds:[ CMD.VR_SMS_GUARD ]},
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_authorize"), data:NAVI.AUTHORIZATION, cmds:[ CMD.VR_IDENT_ENABLE
																				, CMD.VR_IDENT_TIMEOUT
																				, CMD.VR_SMS_GUARD
																				, CMD.VR_TM_ACTION ], group:128 },
					{label:loc( "keys_of_users" ), data:NAVI.IMB_KEYS, cmds:[ CMD.VR_TM_KEY ], group:128  },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT, CMD.VR_WORKMODE_SET, CMD.VR_WORKMODE_ENGINE_START, 
						CMD.VR_WORKMODE_ENGINE_RUNS, CMD.VR_WORKMODE_ENGINE_STOP, CMD.VR_WORKMODE_START, CMD.VR_WORKMODE_MOVE, 
						CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR, CMD.VR_WORKMODE_SCHEDULE] },
					{label:loc("navi_events"), data:NAVI.VOYAGER_EVENTS, cmds:[ CMD.VR_NEW_FLAG_ENABLE, CMD.VR_MSG_SETTINGS ] },
					{label:loc("navi_sms"), data:NAVI.SMS, cmds:[ CMD.TIME_ZONE,  CMD.VR_SMS_SETTINGS, CMD.VR_SMS_SCHEDULE, CMD.VR_SMS_NOTIF_LIST ]},
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_3DFIX, CMD.VR_PACK_SIZE, CMD.VR_FILTER_TRACK ]}, //, debug:true
					{label:"A-GPS", data:NAVI.AGPS, cmds:[CMD.VR_AGPS_ENABLE] },
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR ]},	//	16 128
					{label:loc("navi_conters"), data:NAVI.COUNTERS, cmds:[CMD.VR_COUNTER_NAV_MILEAGE, CMD.VR_COUNTER_NAV_HOURS] },
					{label:loc("navi_input"), data:NAVI.INPUT, submenu:true, cmds:[CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL ]},// 16 128
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, cmds:[   ], group:1 },//, CMD.VR_SPEED_ALARM, CMD.VR_ACC_ALARM, CMD.VR_OUT, CMD.VR_OUT_STATE ], group:128 },
					{label:loc("navi_indication"), data:NAVI.INDICATION, cmds:[CMD.VR2_IND_MODE]},
					{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS, cmds:[], group:4},
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER, CMD.EGTS_USER_NAME_PASSWORD, CMD.PROTOCOL_TYPE]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_param_wifi"), data:NAVI.PARAMS_WIFI, submenu:true, cmds:[ ], group:4},
					{label:loc("navi_param_egts"), data:NAVI.PARAMS_EGTS, cmds:[
																				CMD.PROTOCOL_TYPE
																				, CMD.EGTS_FLAG_ENABLE
																				, CMD.EGTS_UNIT_HOME_DISPATCHER_ID]  },// , CMD.EGTS_SUBRECORD_TELEDATA_EN] },
				//	{label:loc("navi_param_egts"), data:NAVI.PARAMS_EGTS, cmds:[CMD.EGTS_UNIT_HOME_DISPATCHER_ID,CMD.EGTS_CNT_STAT_SEND_ENABLE] },
					/*{label:loc("navi_param_egts"), data:NAVI.PARAMS_EGTS, cmds:[CMD.EGTS_UNIT_HOME_DISPATCHER_ID,CMD.EGTS_CNT_STAT_SEND_ENABLE, 
						CMD.EGTS_CRYPTO_ENABLE, CMD.EGTS_CRYPTO_GOST_KEY, CMD.EGTS_CRYPTO_GOST_S_BOX], group:1024 },*/
					{label:loc("navi_egts_stats"), data:NAVI.STATS_EGTS, cmds:[CMD.EGTS_CNT_STAT_SEND_ENABLE],  group:64 },
					{label:loc("navi_net_mode"), data:NAVI.NETWORK_MODE, cmds:[ CMD.MODEM_NETWORK_CTRL ], group:2 },
					{label:loc("navi_dispatcher"), data:NAVI.TANGENTA, cmds:[ CMD.VR_TANGENTA ], group:256},
					{label:loc("navi_msg_terminal"), data:NAVI.MESSAGE_TERMINAL, group:256},
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY },
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_car_informer"), data:NAVI.CARINFORMER, group:4},
					{label:loc("navi_can"), data:NAVI.CAN, cmds:[CMD.CAN_CAR_ID,  CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL, CMD.VR_SERIAL_USE]},
					///
					{label:loc("navi_ports_io"), data:NAVI.SERIAL_PORT, submenu:true, cmds:[CMD.VR_SERIAL_USE] },
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
				//	{label:"Навигационный приемник", data:NAVI.NAVI_RECEIVER, cmds:[CMD.VR2_NMEA_SEND_PORT]},
					{label:"Обновление Light", data:NAVI.DEBUG_UPDATE, debug:true  },
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true },
					{label:"История таблица", data:NAVI.HISTORY_EXT, debug:true },
					{label:"История таблица FS", data:NAVI.DEBUG_HISTORY, debug:true },
					{label:"Настройки", data:NAVI.DEBUG_OPTIONS, debug:true },
					{label:loc( "navi_track" ), data:NAVI.TEST, cmds:[ CMD.VR_FILTER_TRACK, CMD.VR_PACK_SIZE,  CMD.VR_FILTER_3DFIX ],  debug:true },
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				]
			},{	// 3 - Вояджер 3		нет внешнего питания
				CLIENT_BUILD_VERSION:"V3."+BUILDVER,
				VERSION:"V-3_and_V-3L_and_V-3L-3G",
				RELEASE:"008-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, cmds:[ CMD.VR_SMS_GUARD ]},
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT, CMD.VR_WORKMODE_SET, CMD.VR_WORKMODE_START,
						CMD.VR_WORKMODE_MOVE, CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR, CMD.VR_WORKMODE_SCHEDULE] },
					{label:loc("navi_events"), data:NAVI.VOYAGER_EVENTS, cmds:[ CMD.VR_NEW_FLAG_ENABLE, CMD.VR_MSG_SETTINGS ] },
					{label:loc("navi_sms"), data:NAVI.SMS, cmds:[ CMD.VR_SMS_LOCATION_ENABLE
																, CMD.VR_SMS_SETTINGS
																, CMD.VR_SMS_SCHEDULE
																, CMD.VR_SMS_NOTIF
																, CMD.VR_SMS_NOTIF_LIST
																, CMD.TIME_ZONE ], group:1024 },
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_TRACK, CMD.VR_PACK_SIZE, CMD.VR_FILTER_3DFIX]},
					{label:"A-GPS", data:NAVI.AGPS, cmds:[CMD.VR_AGPS_ENABLE], group:512 },
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR] },
					{label:loc("navi_conters"), data:NAVI.COUNTERS, cmds:[CMD.VR_COUNTER_NAV_MILEAGE] },
					{label:loc("navi_buttons"), data:NAVI.BUTTONS, cmds:[CMD.VR_KEY_SIDE_SWITCH], group:1 },
					{label:loc("navi_notify"), data:NAVI.NOTIF, cmds:[CMD.VR_NOTIFICATION ], group:1 },
					{label:loc("navi_indication"), data:NAVI.INDICATION, cmds:[CMD.VR_IND_MODE] },
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER, CMD.PROTOCOL_TYPE]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_net_mode"), data:NAVI.NETWORK_MODE, cmds:[ CMD.MODEM_NETWORK_CTRL ], group:2 },
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE },
					{label:"------ debug section", debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true},
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true }
				]
			},{	// 4 - Вояджер 4		
				CLIENT_BUILD_VERSION:"V4."+BUILDVER,
				VERSION:"V-4",
				RELEASE:"008-999",//["003","004"],
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, cmds:[CMD.VR_SMS_GUARD]},
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT, CMD.VR_WORKMODE_SET, CMD.VR_WORKMODE_ENGINE_START, 
											CMD.VR_WORKMODE_ENGINE_RUNS, CMD.VR_WORKMODE_ENGINE_STOP, CMD.VR_WORKMODE_START, CMD.VR_WORKMODE_MOVE, 
											CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR, CMD.VR_WORKMODE_SCHEDULE, CMD.TIME_ZONE] },
					{label:loc("navi_events"), data:NAVI.VOYAGER_EVENTS, cmds:[ CMD.VR_NEW_FLAG_ENABLE, CMD.VR_MSG_SETTINGS ] },
					{label:loc("navi_sms"), data:NAVI.SMS, cmds:[ CMD.VR_SMS_LOCATION_ENABLE, CMD.VR_SMS_SETTINGS, CMD.VR_SMS_SCHEDULE, CMD.VR_SMS_NOTIF,   CMD.TIME_ZONE ], group:1024 },
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_TRACK, CMD.VR_PACK_SIZE, CMD.VR_FILTER_3DFIX]},
					{label:"A-GPS", data:NAVI.AGPS, cmds:[CMD.VR_AGPS_ENABLE], group:512 },
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR] },
					{label:loc("navi_conters"), data:NAVI.COUNTERS, cmds:[CMD.VR_COUNTER_NAV_MILEAGE, CMD.VR_COUNTER_NAV_HOURS], group:2 },
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER, CMD.PROTOCOL_TYPE]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM_OLD, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING], group:16},
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_map"), data:NAVI.MAP, group:1},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE, binary:true},
					{label:"------ debug section", debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true},
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true }
				]
			},{	// 5 - Вояджер 5			нет внешнего питания
				CLIENT_BUILD_VERSION:"V5."+BUILDVER,
				VERSION:"V-5",
				RELEASE:"025-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, cmds:[ CMD.VR_SMS_GUARD ]},
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT, CMD.VR_WORKMODE_SET, CMD.VR_WORKMODE_START, 
						CMD.VR_WORKMODE_MOVE, CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR, CMD.VR_WORKMODE_SCHEDULE] },
					{label:loc("navi_sms"), data:NAVI.SMS, cmds:[ CMD.VR_SMS_LOCATION_ENABLE, CMD.VR_SMS_SETTINGS, CMD.VR_SMS_SCHEDULE, CMD.VR_SMS_NOTIF,   CMD.TIME_ZONE ], group:1024 },
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_TRACK, CMD.VR_PACK_SIZE, CMD.VR_FILTER_3DFIX]},
					{label:"A-GPS", data:NAVI.AGPS, cmds:[CMD.VR_AGPS_ENABLE], group:512 },
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR] },
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER, CMD.PROTOCOL_TYPE]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true},
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true }
				]
			},{	// 6 - Вояджер 6		нет внешнего питания
				CLIENT_BUILD_VERSION:"V6."+BUILDVER,
				VERSION:"V-6",
				RELEASE:"028-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, cmds:[ CMD.VR_SMS_GUARD ]},
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT, CMD.VR_WORKMODE_SET, CMD.VR_WORKMODE_START, 
						CMD.VR_WORKMODE_MOVE, CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR, CMD.VR_WORKMODE_SCHEDULE] },
					{label:loc("navi_events"), data:NAVI.VOYAGER_EVENTS, cmds:[ CMD.VR_NEW_FLAG_ENABLE, CMD.VR_MSG_SETTINGS ]},
					{label:loc("navi_sms"), data:NAVI.SMS, cmds:[ CMD.VR_SMS_LOCATION_ENABLE, CMD.VR_SMS_SETTINGS, CMD.VR_SMS_SCHEDULE, CMD.VR_SMS_NOTIF,   CMD.TIME_ZONE ], group:1024 },
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_TRACK, CMD.VR_FILTER_3DFIX, CMD.VR_PACK_SIZE]},
					{label:"A-GPS", data:NAVI.AGPS, cmds:[CMD.VR_AGPS_ENABLE], group:512 },
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR] },
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER, CMD.PROTOCOL_TYPE]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true},
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true },
					//{label:loc( "navi_track" ), data:NAVI.TEST, cmds:[ CMD.VR_FILTER_TRACK, CMD.VR_PACK_SIZE,  CMD.VR_FILTER_3DFIX ],  debug:true }
				]
			},{ // 7 - Вояджер L0
				CLIENT_BUILD_VERSION:"L0."+BUILDVER,
				VERSION:"V-L0",
				RELEASE:"041-999",//"020.015",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO },
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT, CMD.VR_WORKMODE_SET, CMD.VR_WORKMODE_ENGINE_START, 
						CMD.VR_WORKMODE_ENGINE_RUNS, CMD.VR_WORKMODE_ENGINE_STOP, CMD.VR_WORKMODE_START, CMD.VR_WORKMODE_MOVE, 
						CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR, CMD.VR_WORKMODE_SCHEDULE] },
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_3DFIX, CMD.VR_PACK_SIZE, CMD.VR_FILTER_TRACK]}, //, debug:true
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR]},
					{label:loc("navi_conters"), data:NAVI.COUNTERS, cmds:[CMD.VR_COUNTER_NAV_MILEAGE, CMD.VR_COUNTER_NAV_HOURS] },
					{label:loc("navi_input"), data:NAVI.INPUT, submenu:true, cmds:[CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL]},
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, cmds:[] },
					{label:loc("navi_indication"), data:NAVI.INDICATION, cmds:[CMD.VR2_IND_MODE]},
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER, CMD.PROTOCOL_TYPE]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_param_egts"), data:NAVI.PARAMS_EGTS, cmds:[CMD.EGTS_UNIT_HOME_DISPATCHER_ID,CMD.EGTS_CNT_STAT_SEND_ENABLE, 
						CMD.EGTS_CRYPTO_ENABLE, CMD.EGTS_CRYPTO_GOST_KEY, CMD.EGTS_CRYPTO_GOST_S_BOX] },
					{label:loc("navi_egts_stats"), data:NAVI.STATS_EGTS },
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY },
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true },
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				]
			},
			{	// 8 - V-BRPM
				CLIENT_BUILD_VERSION:"V-BRPM."+BUILDVER,
				VERSION:"V-BRPM", 
				RELEASE:"026-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO, cmds:[ CMD.VR_SMS_GUARD ]},
					{label:loc("navi_date"), data:NAVI.DATE },
					{label:loc("navi_em"), data:NAVI.ENERGY_MODE, cmds:[CMD.VR_WORKMODE_CURRENT
						, CMD.VR_WORKMODE_SET
						, CMD.VR_WORKMODE_ENGINE_START
						, CMD.VR_WORKMODE_ENGINE_RUNS
						, CMD.VR_WORKMODE_ENGINE_STOP
						, CMD.VR_WORKMODE_START
						, CMD.VR_WORKMODE_MOVE
						, CMD.VR_WORKMODE_STOP
						, CMD.VR_WORKMODE_PARK
						, CMD.VR_WORKMODE_REGULAR
						, CMD.VR_WORKMODE_SCHEDULE] },
					{label:loc("navi_events"), data:NAVI.VOYAGER_EVENTS, cmds:[ CMD.VR_NEW_FLAG_ENABLE, CMD.VR_MSG_SETTINGS ]},
					{label:loc("navi_sms"), data:NAVI.SMS, cmds:[ CMD.VR_SMS_LOCATION_ENABLE
						, CMD.VR_SMS_SETTINGS
						, CMD.VR_SMS_SCHEDULE
						, CMD.VR_SMS_NOTIF
						, CMD.VR_SMS_NOTIF_LIST
						, CMD.TIME_ZONE ] },
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[CMD.VR_FILTER_3DFIX, CMD.VR_PACK_SIZE, CMD.VR_FILTER_TRACK]}, //, debug:true
					{label:loc("navi_agps"), data:NAVI.AGPS, cmds:[CMD.VR_AGPS_ENABLE] },
					{label:loc("navi_indication"), data:NAVI.INDICATION, cmds:[CMD.VR2_IND_MODE]},
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, submenu:true, cmds:[CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR] },
					{label:loc("navi_conters"), data:NAVI.COUNTERS, cmds:[CMD.VR_COUNTER_NAV_MILEAGE, CMD.VR_COUNTER_NAV_HOURS] },
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER
						, CMD.PROTOCOL_TYPE]},
					//{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM_OLD, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY },
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					{label:"em debug", data:NAVI.DEBUG_ENERGYMODES, debug:true }
					
				]
			}
			,{	// 8 
			},{	// 9 - Вояджер 2TN
			},];
		
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
		public static const MENU_UNDEFINED:Array = [
			{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } }
			/**{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}*/];
		public static function initHardwareConst():void
		{
			var color:int = 0xFFFFFFFF;
			
			MENU_GROUP = 0;
			var r:int = DS.release;
			var bl:int = int(DS.getBootloader());
			var a:int = int( DS.app );
			
			
			
			switch(PRESET_NUM) {
				
				case 1:
					
					OPERATOR.getSchema( CMD.CONNECT_SERVER).StructCount = 4;
					OPERATOR.getSchema( CMD.VR_OUT ).StructCount = 1;
					
					if (r > 47) {
						MENU_GROUP |= 1;
						MENU_GROUP |= 1024;
						
					}
					if( r >= 41 )
					{
						MENU_GROUP |= 2;	// статистика ЕГТС
						if( DS.isDevice( DS.V2 ) )addCmd(NAVI.PARAMS_WIFI,  CMD.MODEM_NETWORK_CTRL);
					}
						
					if( a > 3 )
					{
						MENU_GROUP |=4;
						
					}
					
					/**
					 * Залезли в такую *опу потому, что ранее 52го релиза команда имела 
					 * размер параметра равный одному байту, после 2ум...
					 * 
					 */
					if( r < 52 ){
						OPERATOR.getSchema( CMD.VR_FILTER_TRACK).getParamByStructure( 2 ).Length = 1;
						
					}
					
					
					
					if( DS.isDevice( DS.VL1_3G ) || DS.isDevice( DS.VL2_3G ) )
																						MENU_GROUP |=8;
					
					if( r >= 52 )
						MENU_GROUP |= 16;
					
					if( r > 58 && DS.isfam( DS.F_V, DS.VL0, DS.V4, DS.V6, DS.V_BRPM  ) )
					{
						addCmd( NAVI.PARAMS_EGTS, CMD.VR_EGTS_VEHICLE_DATA );
					}
						
					if( DS.isfam( DS.F_VL ) || DS.isfam( DS.F_VL_3G ) )
					{
						addMultyCMD( NAVI.OUT, [ CMD.VR_SPEED_ALARM,   CMD.VR_OUT_STATE ] )		
					}
				
					
					
						
					
					break;
					
				case 2:
					
					OPERATOR.getSchema( CMD.CONNECT_SERVER).StructCount = 4;
					
					switch( DS.alias ) {
						case DS.isfam( DS.V2 ):
							
							addMultyCMD( NAVI.VSENSORS,
										[ CMD.VR_SENSOR_SI
										, CMD.VR_SENSOR_SA
										, CMD.VR_SENSOR_SC
										, CMD.LIMITS_TEMP ]);
							addMultyCMD( NAVI.INPUT,
										[ CMD.VR_INPUT_ANALOG
										, CMD.VR_INPUT_ANALOG_VALUE
										] );
							
							
							
							if( DS.isDevice( DS.V_ASN ) )
							{
									
								addCmd( NAVI.TANGENTA, CMD.VR_EGTS_DISPATCH_CENTER_NUM );
								
								addCmd( NAVI.TRACK, CMD.VR_NAV_SYSTEM );
								addCmd( NAVI.PARAMS_EGTS, CMD.VR_EGTS_WORKMODE );
								
								
								
								
								
							}
							else
							{
								addMultyCMD( NAVI.INPUT,
									[  CMD.VR_INPUT_FREQ
										, CMD.VR_INPUT_PULSE
									] );
								
								
							}
							
							if( DS.isDevice( DS.V2 ) && a === 8 )
							{
								/// Screens LINK_CHANNELS, PARAMS_WIFI, CAR_INFORMER
								MENU_GROUP |= 4;
								addCmd(NAVI.PARAMS_WIFI,  CMD.ESP_POINT_SETTINGS );
								addCmd(NAVI.PARAMS_WIFI,  CMD.ESP_SET_NET);
								addCmd(NAVI.LINK_CHANNELS, CMD.CH_VR_COM_LINK);
								
							}
							
							MENU_GROUP |= 128;	// включение выходов,  navi_input, navi_sensors
							MENU_GROUP |= 256;	// navi_dispatcher, navi_msg_terminal
							
							
							if( r > 38 )
							{
								addCmd(NAVI.PARAMS_EGTS, CMD.EGTS_CNT_STAT_SEND_ENABLE);
								addCmd(NAVI.PARAMS_EGTS, CMD.EGTS_CRYPTO_ENABLE);
								addCmd(NAVI.PARAMS_EGTS, CMD.EGTS_CRYPTO_GOST_KEY);
								addCmd(NAVI.PARAMS_EGTS, CMD.EGTS_CRYPTO_GOST_S_BOX);
								addCmd(NAVI.PARAMS_EGTS, CMD.EGTS_LOGIN_ENABLE);
								
								if( r < 58 && DS.isDevice( DS.V2 ))addCmd(NAVI.PARAMS_EGTS, CMD.VR_EGTS_PRIORITY);
								
								MENU_GROUP |= 64;
							}
							
							
							if( r > 45 )
							{
								addCmd(NAVI.PARAMS_EGTS, CMD.EGTS_SUBRECORD_TELEDATA_EN);
								addCmd(NAVI.SMS, CMD.VR_SMS_NOTIF);
								addCmd(NAVI.SMS, CMD.VR_SMS_LOCATION_ENABLE);
								
								addCmd(NAVI.OUT, CMD.VR_OUT);
								addCmd(NAVI.OUT, CMD.VR_SPEED_ALARM);
								addCmd(NAVI.OUT, CMD.VR_ACC_ALARM);
							}
							
							if( DS.isDevice( DS.V2_3G )|| a === 107 )
							{
								MENU_GROUP |= 2;
							}
								
							if( r > 48 )
							{
								addMultyCMD(NAVI.CAN, [ CMD.CAN_FUNCT_SELECT
																, CMD.VR_IRMA_DOOR_NUM
																, CMD.VR_IRMA_DOOR_INPUT
																, CMD.VR_IRMA_DOOR_DELAY ] );
							}
							
							if( r > 58 )
							{
								
								if(  DS.isfam( DS.F_V, DS.VL0, DS.V4, DS.V6, DS.V_BRPM ) )
								{
									addCmd( NAVI.PARAMS_EGTS, CMD.VR_EGTS_VEHICLE_DATA );
								}
							}
							
							
					
							MENU_GROUP |= 1;
							
							break;
							
						
							
						case DS.isfam( DS.VL3 ):
							
							if( a > 3 )
							{
								OPERATOR.getSchema(CMD.VR_OUT).StructCount = 1;
								addCmd(NAVI.OUT, CMD.VR_OUT);
								MENU_GROUP |= 1; // Экран Выходы
							}
							
							if( r > 38 )
							{
								addCmd(NAVI.PARAMS_EGTS, CMD.EGTS_CNT_STAT_SEND_ENABLE);
								
								MENU_GROUP |= 64;
							}
							
							if( DS.isDevice( DS.VL3_3G ) )
							{
								MENU_GROUP |= 2;
							}
							
							break;
						
						default:
							break;
					}
					
					
						
					
					
						
					
						
					break;
				case 3:
					if( r >= 46  )
					{
						MENU_GROUP |= 512;
						MENU_GROUP |= 1024;
					}
					
					if( DS.isDevice( DS.V3 ) )
												MENU_GROUP |= 1;
					
					if( DS.isDevice( DS.V3L_3G ) )
												MENU_GROUP |= 2;
					
					break;
				case 4:
					if (r >= 20) {		// A-GPS
						MENU_GROUP |= 4;
					}
					if (r >= 25) {	// Карта
						MENU_GROUP |= 1;
						MENU_GROUP |= 8;
					} else {	// Old GRPS SIM, no APN
						MENU_GROUP |= 16;
						LOADER_SEQUENCE = [LoaderServant.NEED_SIZE_CMD];
					}
					if (r >= 26 && bl >= 2 && bl <= 5) // Счетчики
						MENU_GROUP |= 2;
					
					if( r >= 46  )
					{
						MENU_GROUP |= 512;
						MENU_GROUP |= 1024;
					}
					break;
				
				case 5:
					if( r >= 46  )
					{
						MENU_GROUP |= 512;
						MENU_GROUP |= 1024;
					}
					
					break;
				
				case 6:
					MENU_GROUP |= 512;
					if( r >= 46  )MENU_GROUP |= 1024;
					
				
			}
		}
		public static var LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD,
			LoaderServant.NEED_APN_INFO,
			
			
		];
		
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
		
		private static function addMultyCMD(navi:int, cmds:Array):void
		{
			var len:int = cmds.length;
			for (var i:int=0; i<len; i++) 
				addCmd( navi, cmds[ i ] );
			
		}
	}
}
