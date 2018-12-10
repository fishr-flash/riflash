package components.system
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.static.NAVI;
	
	public class CONST
	{
		
		// 0 - V15
		// 1 - K15
		// 2 - cam
		// 3 - reader	/	recorder ( R-15 & R-15IP )
		// 4 - V-M Android Trakker

		/** GLOBAL CONST	*/
		public static const PRESET_NUM:int= 0;
		public static var CLIENT_BUILD_VERSION:String = "";
		public static var VERSION:String = ""
		private static const BUILDVER:String = "014.083";	// с 003 843 порт упразднен
		public static const DEBUG:Boolean = 1 == 1;
		
		public static const QUICK_HISTORY_DELETE:Boolean = false;
		
		public static const PRESET:Array = [
			{	// 0 - Вояджер 15-A10
				CLIENT_BUILD_VERSION:"V15."+BUILDVER,
				VERSION:"V-15_and_V-15IP",
				RELEASE:"001-999",
				LOADER_SEQUENCE:[LoaderServant.NEED_APN_INFO],
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					//{label:loc("navi_date"), data:NAVI.DATE},
					{label:loc("navi_ext_modem"), data:NAVI.MODEM_XG, cmds:[CMD.EXT_MODEM_NETWORK_CTRL]},
					{label:loc("navi_date"), data:NAVI.DATE, debug:false},
					{label:loc("navi_config_ip_cameras"), data:NAVI.CONFIG_IP_CAMS, 
																					cmds:
																					[ CMD.VIDEO_IP_CAM_SETTINGS, 
																						CMD.VIDEO_IP_CAM_FPS, 
																						CMD.VIDEO_FILE_RECORDING_TIME],
																					group: 4},
					{label:loc("sw_check")+ " " + loc( "sw_ipcams" ), data:NAVI.CHECK_IP_CAMS, cmds:[ ], group: 4},
					{label:loc("navi_track"), data:NAVI.TRACK, cmds:[ CMD.VR_FILTER_TRACK]},
					{label:loc("navi_sensors"), data:NAVI.VSENSORS, cmds:[ CMD.VR_VIBRO_SENSOR, CMD.VR_VOLTAGE_SENSOR] },
					{label:loc("navi_coord_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER]},
					{label:loc("navi_input"), data:NAVI.INPUT, submenu:true, cmds:[CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL ]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_param_wifi"), submenu:true, data:NAVI.PARAMS_WIFI, cmds:[CMD.WIFI_NETS_STORED, CMD.SETTINGS_WIFI_NETS]},
					{label:loc("navi_wifi_ap"), data:NAVI.PARAMS_WIFIAP, cmds:[CMD.WIFI_POINT_SETTINGS] },
					{label:loc("navi_lan_params"), data:NAVI.PARAMS_LAN, cmds:[CMD.SET_NET]},
					{label:loc("navi_config_cam"), data:NAVI.VIDEO_CAMS_CONFIG, cmds:[CMD.VIDEO_CAMS, CMD.VIDEO_CAM_SOURCE, CMD.K15_VIDEO_SETTINGS ], group: 2},
					{label:loc("navi_vpn_params"), data:NAVI.PARAMS_VPN, cmds:[CMD.VPN_SERVER, CMD.VPN_SET_TYPE_AUTH
						, CMD.VPN_GROUP_ID, CMD.VPN_USER_ID]},
					{label:loc("navi_param_egts"), data:NAVI.PARAMS_EGTS, cmds:[CMD.PROTOCOL_TYPE, CMD.EGTS_UNIT_HOME_DISPATCHER_ID]  },
					//{label:loc("navi_egts_stats"), data:NAVI.STATS_EGTS, cmds:[CMD.EGTS_CNT_STAT_SEND_ENABLE],  group:64 },
					{label:loc("navi_ivideon_params"), data:NAVI.IVIDEO, group: 2},
					{label:loc("navi_history_struct"), data:NAVI.HISTORY_STRUCTURE, cmds:[CMD.HISTORY_SELECT_PAR]},
					{label:loc("navi_history"), data:NAVI.HISTORY_EXT},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					//{label:loc("navi_can"), data:NAVI.CAN, cmds:[CMD.CAN_CAR_ID]},
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_cert"), data:NAVI.CERTIFICATE},
					{label:loc("navi_update"), data:NAVI.UPDATE},
					{label:loc("navi_service"), data:NAVI.SERVICE},
					
					{label:"------ debug section", debug:true},
					
					{label:loc("navi_can"), data:NAVI.CAN, cmds:[CMD.CAN_CAR_ID], debug:true},
					{label:loc("navi_videorecording_config"), data:NAVI.VIDEO_RECORD_CONFIG, cmds:[CMD.K15_VIDEO_SETTINGS, CMD.VIDEO_FILE_RECORDING_TIME, CMD.VIDEO_SIDE_NUMDER_VEHICLE, CMD.VIDEO_CAM_SOURCE], group:1, debug:true }
					
					
				],
				USE_GPRS_ROAMING:true
			},{	// 1 - Контакт 15-A10
				CLIENT_BUILD_VERSION:"K15."+BUILDVER,
				VERSION:"K-15_and_K-15IP",
				RELEASE:"002-999",
				LOADER_SEQUENCE:[LoaderServant.NEED_SYSTEM, LoaderServant.NEED_PARTITION, LoaderServant.NEED_APN_INFO],
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_date"), data:NAVI.DATE},
					{label:loc("navi_config_ip_cameras"), data:NAVI.CONFIG_IP_CAMS, 
																					cmds:
																					[ CMD.VIDEO_IP_CAM_SETTINGS, 
																						CMD.VIDEO_IP_CAM_FPS, 
																						CMD.VIDEO_FILE_RECORDING_TIME],
																					group: 4},
					{label:loc("sw_check")+ " " + loc( "sw_ipcams" ), data:NAVI.CHECK_IP_CAMS, cmds:[ ], group: 4},
					{label:loc("navi_ext_modem"), data:NAVI.MODEM_XG, cmds:[CMD.EXT_MODEM_NETWORK_CTRL]},
					{label:loc("navi_config_cam"), data:NAVI.VIDEO_CAMS_CONFIG, cmds:[CMD.VIDEO_CAMS, CMD.K15_VIDEO_SETTINGS], group: 2},
					{label:loc("navi_servers"), data:NAVI.SERVER, cmds:[CMD.SET_SERVER]},
					{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM,CMD.NO_GPRS_ROAMING, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
					{label:loc("navi_param_wifi"), submenu:true, data:NAVI.PARAMS_WIFI, cmds:[CMD.WIFI_NETS_STORED, CMD.SETTINGS_WIFI_NETS]},
					{label:loc("navi_wifi_ap"), data:NAVI.PARAMS_WIFIAP, cmds:[CMD.WIFI_POINT_SETTINGS] },
					{label:loc("navi_lan_params"), data:NAVI.PARAMS_LAN, cmds:[CMD.SET_NET]},
					{label:loc("navi_vpn_params"), data:NAVI.PARAMS_VPN, cmds:[CMD.VPN_SERVER, CMD.VPN_SET_TYPE_AUTH
						, CMD.VPN_GROUP_ID, CMD.VPN_USER_ID]},
					{label:loc("navi_ivideon_params"), data:NAVI.IVIDEO},
					{label:loc("navi_history"), data:NAVI.HISTORY_EXT},
					{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_NUMB,CMD.ENGIN_ALL] },
					{label:"", debug:true},
					{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, cmds:[CMD.AUTOTEST, CMD.SYS_NOTIF]},
					{label:loc("navi_partition"), data:NAVI.PARTITION, cmds:[CMD.PARTITION, CMD.PART_SET]},
					{label:loc("navi_wire"), data:NAVI.ALARM_WIRE, cmds:[CMD.K7_ALARM_WIRE_SET], submenu:true},
					{label:loc("navi_out"), data:NAVI.OUT, submenu:true, group:1},
					{label:loc("navi_radiosystem"), data:NAVI.RF_SYSTEM},
					{label:loc("navi_rf_sensors"), data:NAVI.RF_SENSOR, needsystem:true},
					{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL, submenu:true, needsystem:true},
					{label:loc("navi_rf_keyboard"), data:NAVI.RF_KEY, submenu:true, needsystem:true},
					{label:loc("navi_rf_map"), data:NAVI.RF_MAP, submenu:true, needsystem:true},
					{label:loc("navi_user_code"), data:NAVI.USER_PASS, cmds:[CMD.MASTER_CODE,CMD.KEY_BLOCK,CMD.USER_PASS]},
					{label:loc("navi_tmreader"), data:NAVI.TM_READER, bottom:true, cmds:[CMD.READER_TM]},
					{label:loc("navi_tmkeys"), data:NAVI.TM_KEYS, submenu:true, bottom:true},
					{label:loc("navi_keyboards"), data:NAVI.DATA_KEY, submenu:true, bottom:true},
					{label:"", debug:true},
					{label:loc("navi_map"), data:NAVI.MAP},
					{label:loc("navi_cert"), data:NAVI.CERTIFICATE},
					{label:loc("navi_update"), data:NAVI.UPDATE},
					{label:loc("navi_service"), data:NAVI.SERVICE}
				//	{label:"------ debug section", debug:true},
				//	{label:loc("navi_map"), data:NAVI.MAP,debug:true}
				],
				USE_GPRS_ROAMING:true
			},{	// 2 - IP Камера
				CLIENT_BUILD_VERSION:"C-15."+BUILDVER,
				VERSION:"C-15",
				RELEASE:"002-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_date"), data:NAVI.DATE},
					{label:loc("navi_ext_modem"), data:NAVI.MODEM_XG, cmds:[CMD.EXT_MODEM_NETWORK_CTRL]},
					{label:loc("navi_config_cam"), data:NAVI.VIDEO_CAMS_CONFIG, cmds:[CMD.VIDEO_CAMS, CMD.K15_VIDEO_SETTINGS]},
					{label:loc("navi_config_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER]},
					{label:loc("navi_param_wifi"), submenu:true, data:NAVI.PARAMS_WIFI, cmds:[CMD.WIFI_NETS_STORED, CMD.SETTINGS_WIFI_NETS]},
					{label:loc("navi_param_wifi"), data:NAVI.PARAMS_WIFIAP, cmds:[CMD.WIFI_POINT_SETTINGS] },
					//{label:loc("navi_lan_params"), data:NAVI.PARAMS_LAN, cmds:[CMD.SET_NET]},
					{label:loc("navi_vpn_params"), data:NAVI.PARAMS_VPN, cmds:[CMD.VPN_SERVER, CMD.VPN_SET_TYPE_AUTH
						, CMD.VPN_GROUP_ID, CMD.VPN_USER_ID]},
					{label:loc("navi_ivideon_params"), data:NAVI.IVIDEO},
					{label:loc("navi_update"), data:NAVI.UPDATE},
					{label:loc("navi_service"), data:NAVI.SERVICE},
					{label:"------ debug section", debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true},
				],
				USE_GPRS_ROAMING:true
			},{	// 3 - Reader / Recorder
				CLIENT_BUILD_VERSION:"R15."+BUILDVER,
				VERSION:"R-15_and_R-15IP",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:loc("navi_date"), data:NAVI.DATE},
					{label:loc("navi_config_ip_cameras"), data:NAVI.CONFIG_IP_CAMS, cmds:[ CMD.VIDEO_IP_CAM_SETTINGS, CMD.VIDEO_IP_CAM_FPS, CMD.VIDEO_FILE_RECORDING_TIME], group:4},
					{label:loc("navi_ext_modem"), data:NAVI.MODEM_XG, cmds:[CMD.EXT_MODEM_NETWORK_CTRL]},
					{label:loc("navi_config_cam"), data:NAVI.VIDEO_CAMS_CONFIG, cmds:[CMD.VIDEO_CAMS, CMD.K15_VIDEO_SETTINGS], group:2 },
					{label:loc("navi_config_server"), data:NAVI.CONNECT_SERVER, cmds:[CMD.CONNECT_SERVER]},
					{label:loc("navi_lan_params"), data:NAVI.PARAMS_LAN, cmds:[CMD.SET_NET]},
					{label:loc("navi_vpn_params"), data:NAVI.PARAMS_VPN, cmds:[CMD.VPN_SERVER, CMD.VPN_SET_TYPE_AUTH
						, CMD.VPN_GROUP_ID, CMD.VPN_USER_ID]},
					{label:loc("navi_ivideon_params"), data:NAVI.IVIDEO, group:2  },
					{label:loc("navi_cert"), data:NAVI.CERTIFICATE},
					{label:loc("navi_update"), data:NAVI.UPDATE},
					{label:loc("navi_service"), data:NAVI.SERVICE},
				],
				USE_GPRS_ROAMING:true
			},{	// 4 - Android Trakker
				CLIENT_BUILD_VERSION:"V-M."+BUILDVER,
				VERSION:"V-M",
				RELEASE:"001-999",
				MENU:[
					{label:loc("navi_device_info"), data:NAVI.VER_INFO},
					{label:"------ debug section", debug:true},
					{label:loc("navi_history"), data:NAVI.HISTORY_EXT, debug:true},
					{label:"Certificate", data:NAVI.CERTIFICATE, debug:true}
				]
			}
		];
		
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
		/** CONSTANTS */
		public static var RFKEY_NUM:int = 5;
		public static var DATAKEY_NUM:int = 3;
		// HISTORY
		public static const HIS_DELETE:int = 0x01;
		public static const HIS_DELETE_SUCCESS:int = 0x02;
		// MENU	
		public static var MENU:Array;
		public static const MENU_UNDEFINED:Array = [{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}];
		public static function initHardwareConst():void	
		{
			MENU_GROUP = 0;
			var r:int = DS.release;
			/*if ( DEVICES.isDevice(DEVICES.V15) && r >= 6 ) {
				addCmd(NAVI.VIDEO_CAMS_CONFIG, CMD.VIDEO_FILE_RECORDING_TIME);
				addCmd(NAVI.VIDEO_CAMS_CONFIG, CMD.VIDEO_SIDE_NUMDER_VEHICLE);
				MENU_GROUP |= 1; 
			}*/
			
			switch( DS.alias ) {
				case DS.V15:
					if( r >= 6 )
					{
						addCmd(NAVI.VIDEO_CAMS_CONFIG, CMD.VIDEO_FILE_RECORDING_TIME);
						addCmd(NAVI.VIDEO_CAMS_CONFIG, CMD.VIDEO_SIDE_NUMDER_VEHICLE);
						MENU_GROUP |= 1; 
					}
					
						MENU_GROUP |= 2;
						
						OPERATOR.getSchema( CMD.VR_INPUT_TYPE ).StructCount = 1;
						OPERATOR.getSchema( CMD.VR_INPUT_DIGITAL ).StructCount = 1;
					break;
				
				case DS.R15:
				case DS.K15:
				
						MENU_GROUP |= 2;
					break;
				
				case DS.V15IP:
					OPERATOR.getSchema( CMD.VR_INPUT_TYPE ).StructCount = 1;
					OPERATOR.getSchema( CMD.VR_INPUT_DIGITAL ).StructCount = 1;
				case DS.R15IP:
				case DS.K15IP:
						MENU_GROUP |= 4;
					break;
				
				default:
					break;
			}
			
			OPERATOR.getSchema( CMD.VR_INPUT_TYPE ).StructCount = 1;
			OPERATOR.getSchema( CMD.VR_INPUT_DIGITAL ).StructCount = 1;
			
		}
		
		public static var LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SIZE_CMD
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
	}
}
