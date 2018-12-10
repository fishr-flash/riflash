package components.system
{
	import components.abstract.DEVICESB;
	import components.abstract.functions.loc;
	import components.abstract.sysservants.LoaderServant;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.NAVI;

	public class CONST
	{
/** GLOBAL CONST	*/
		public static const CLIENT_BUILD_VERSION:String = "K-16.017.117";

		public static var VERSION:String = "K-16_and_K-16-3G";
		public static const DEBUG:Boolean = 1 == 0;
/** LOAD SWITCHES */
		public static var MENU_GROUP:int = 0;
		public static const USE_GPRS_COMPR:Boolean = true;
		public static const USE_GPRS_ROAMING:Boolean = false;
		public static const SAVE_PATH:String = "";

		public static var RELEASE:Object=true;
		public static var STRICT:Boolean = false;	// Если true - различие версий прибора не даст запуститься клиенту
		public static const RELEASE_TOP:Object = "005-019";
		public static const RELEASE_BOTTOM:Object = "013-019";
		  
/** GLOBAL SWITCHES */
		public static var FLASH_VARS:Object;
		public static var CLIENT_DEFAULT_STRING_HEIGHT:int = 25;
		public static const USE_OUTDATED_PROTOCOL:Boolean= false;
/** CONSTANTS */
		public static const LINK_CHANNELS_NUM:int = 8;
		public static const RFKEY_NUM:int = 5;
		public static const DATAKEY_NUM:int = 5;
		public static var RFMODULE_NUM:int = 16;
	// MENU	
		// bottom - показывает что экран считывается с нижней платы, надо изменить адрес
		public static var MENU:Array = null;
		
		public static const MENU_TOP:Array = [
			{label:loc("navi_device_info"), data:NAVI.VER_INFO_HYBRID},
			{label:loc("navi_date"), data:NAVI.DATE, cmds:[CMD.TIME_SYNCH]},
			{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, bottom:true, cmds:[CMD.AUTOTEST, CMD.SYS_NOTIF]},
			{label:loc("navi_device_power"), data:NAVI.DEVICE_POWER, bottom:true, group:1, cmds:[CMD.VOLTAGE_LIMITS, CMD.CPW_LIMITS]},
			{label:loc("navi_partition"), data:NAVI.PARTITION, bottom:true, cmds:[CMD.PARTITION, CMD.PART_SET]},
			{label:loc("navi_object"), data:NAVI.OBJECT, cmds:[CMD.OBJECT]},
			{label:loc("navi_temperature"), data:NAVI.TEMPERATURE, cmds:[CMD.SAVE_CID_TEMPERATURE, CMD.LIMITS_TEMP ], bottom:true },
			//{label:loc("input_temp_sensor"), data:NAVI.TEMPERATURE, cmds:[CMD.SAVE_CID_TEMPERATURE, CMD.LIMITS_TEMP ], bottom:true, submenu: true },
			{label:loc("navi_wire"), data:NAVI.ALARM_WIRE, submenu:true, bottom:true, cmds:[CMD.ALARM_WIRE_SET, CMD.ALARM_WIRE_LEVEL, CMD.ALARM_WIRE_RES]},
			{label:loc("navi_out"), data:NAVI.OUT, submenu:true, bottom:true, cmds:[CMD.OUT_CTRL_INIT, CMD.OUT_PERMANENTLY_ON, CMD.OUT_OFF_LEVEL, CMD.OUT_INDPART,
				CMD.OUT_ALARM1, CMD.OUT_ALARM2, CMD.OUT_ON_LEVEL, CMD.OUT_INDMES]},
			{label:loc("navi_screen_keyboard"), data:NAVI.SCREEN_KEYBOARD },
			{label:loc("navi_relay"), data:NAVI.DATA_RELE, submenu:true, bottom:true, cmds:[CMD.RELAY_INDPART, CMD.RELAY_PERMANENTLY_ON, 
				CMD.RELAY_INDMES, CMD.RELAY_ALARM1, CMD.RELAY_ALARM2]},
			{label:loc("navi_radiosystem"), data:NAVI.RF_SYSTEM, bottom:true},
			{label:loc("navi_rf_sensors"), data:NAVI.RF_SENSOR, needsystem:true, bottom:true},
			{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL, submenu:true, needsystem:true, bottom:true},
			{label:loc("navi_rf_modules_much"), data:NAVI.RF_MODULE, submenu:true, needsystem:true, bottom:true, group: 2   },
			{label:loc("navi_rf_keyboard"), data:NAVI.RF_KEY, submenu:true, needsystem:true, bottom:true},
			///FIXME: Debug value! Remove it now!
			//{label:"Радиореле", data:NAVI.RF_RELE, submenu:true, needsystem:true, bottom:true},
			{label:loc("navi_rf_map"), data:NAVI.RF_MAP, submenu:true, needsystem:true, bottom:true},
			{label:loc("navi_user_code"), data:NAVI.USER_PASS, bottom:true, cmds:[CMD.MASTER_CODE,CMD.KEY_BLOCK,CMD.USER_PASS]},
			{label:loc("navi_tmreader"), data:NAVI.TM_READER, bottom:true, cmds:[CMD.READER_TM]},
			{label:loc("navi_tmkeys"), data:NAVI.TM_KEYS, submenu:true, bottom:true},
			{label:loc("navi_keyboards"), data:NAVI.DATA_KEY, submenu:true, bottom:true},
			{label:loc("navi_link_channels"), data:NAVI.LINK_CHANNELS, cmds:[CMD.CH_COM_ADD, CMD.CH_COM_LINK, CMD.CH_SEND_IMEI, CMD.PING_SET_TIME], altLabel:loc("navi_link_channels_no_filter") },
			{label:loc("navi_sms"), data:NAVI.SMS, submenu:true, cmds:[CMD.SMS_PARAM, CMD.SMS_TM, CMD.SMS_PART, CMD.SMS_ZONE, CMD.SMS_R_CTRL, CMD.SMS_USER, CMD.SMS_TEXT] },
			{label:loc("navi_param_gprs"), data:NAVI.GPRS_SIM, cmds:[CMD.GPRS_SIM, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_BASE]},
			{label:loc("navi_lan_params"), data:NAVI.PARAMS_LAN, cmds:[CMD.SET_NET, CMD.SET_OPENED_PORT]},
			{label:loc("navi_phone_line"), data:NAVI.PHONE_LINE, cmds:[CMD.TELCO_CONTROL_LINE]},
			{label:loc("navi_history"), data:NAVI.HISTORY},
			{label:loc("navi_engin_numbers"), data:NAVI.ENGIN_NUMB, cmds:[CMD.ENGIN_ALL, CMD.ENGIN_NUMB] },
			{label:loc("navi_map"), data:NAVI.MAP},
			{label:loc("navi_lock_from_writer"), data:NAVI.LOCK_FROM_WRITERS},
//			{label:"Certificate", data:NAVI.CERTIFICATE},
			{label:loc("navi_update")+" K16RT1", data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate")+" K16RT1", color:COLOR.RED} } },
			{label:loc("navi_update")+" K-16C", data:NAVI.UPDATE_SECOND, status:{ 1:{title:loc("navi_isupdate")+" K-16C", color:COLOR.RED} } },
			{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}
		];
		public static const MENU_DOWN:Array = [
			{label:loc("navi_device_info"), data:NAVI.VER_INFO},
			{label:loc("navi_date"), data:NAVI.DATE},
			{label:loc("navi_sys_events"), data:NAVI.SYS_EVENTS, cmds:[CMD.AUTOTEST, CMD.SYS_NOTIF]},
			{label:loc("navi_device_power"), data:NAVI.DEVICE_POWER, group:1, cmds:[CMD.VOLTAGE_LIMITS, CMD.CPW_LIMITS]},
			{label:loc("navi_partition"), data:NAVI.PARTITION, cmds:[CMD.PARTITION, CMD.PART_SET]},
			{label:loc("navi_temperature"), data:NAVI.TEMPERATURE },
			{label:loc("navi_wire"), data:NAVI.ALARM_WIRE, submenu:true, cmds:[CMD.ALARM_WIRE_SET, CMD.ALARM_WIRE_LEVEL, CMD.ALARM_WIRE_RES]},
			{label:loc("navi_out"), data:NAVI.OUT, submenu:true, cmds:[CMD.OUT_CTRL_INIT, CMD.OUT_PERMANENTLY_ON, CMD.OUT_OFF_LEVEL, CMD.OUT_INDPART,
				CMD.OUT_ALARM1, CMD.OUT_ALARM2, CMD.OUT_ON_LEVEL, CMD.OUT_INDMES]},
			{label:loc("navi_relay"), data:NAVI.DATA_RELE, submenu:true, cmds:[CMD.RELAY_INDPART, CMD.RELAY_PERMANENTLY_ON, 
				CMD.RELAY_INDMES, CMD.RELAY_ALARM1, CMD.RELAY_ALARM2]},
			{label:loc("navi_radiosystem"), data:NAVI.RF_SYSTEM},
			{label:loc("navi_rf_sensors"), data:NAVI.RF_SENSOR, needsystem:true},
			{label:loc("navi_rf_charm"), data:NAVI.RF_RCTRL, submenu:true, needsystem:true},
			{label:loc("navi_rf_modules_much"), data:NAVI.RF_MODULE, submenu:true, needsystem:true  },
			{label:loc("navi_rf_keyboard"), data:NAVI.RF_KEY, submenu:true, needsystem:true},
			{label:loc("navi_rf_map"), data:NAVI.RF_MAP, submenu:true, needsystem:true},
			{label:loc("navi_user_code"), data:NAVI.USER_PASS, cmds:[CMD.MASTER_CODE,CMD.KEY_BLOCK,CMD.USER_PASS]},
			{label:loc("navi_tmreader"), data:NAVI.TM_READER, cmds:[CMD.READER_TM]},
			{label:loc("navi_tmkeys"), data:NAVI.TM_KEYS, submenu:true},
			{label:loc("navi_keyboards"), data:NAVI.DATA_KEY, submenu:true},
			{label:loc("navi_history"), data:NAVI.HISTORY},
			{label:loc("navi_update"), data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate"), color:COLOR.RED} } },
			{label:loc("navi_service"), data:NAVI.SERVICE, binary:true},
		];
		
		public static function get MENU_UNDEFINED():Array 
		{
			if (SERVER.DUAL_DEVICE) 
				return [
					{label:loc("navi_update")+" K16.2", data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate")+" K16.2", color:COLOR.RED} } },
					{label:loc("navi_update")+" K16.1", data:NAVI.UPDATE_SECOND, status:{ 1:{title:loc("navi_isupdate")+" K16.1", color:COLOR.RED} } }
				];
			return [
				{label:loc("navi_update")+" K16.2", data:NAVI.UPDATE, status:{ 1:{title:loc("navi_isupdate")+" K16.2", color:COLOR.RED} } }];
		}
		public static const _MENU_UNDEFINED:Array = [{label:loc("navi_service"), data:NAVI.SERVICE, binary:true}];
		public static const LOADER_SEQUENCE:Array = [
			LoaderServant.NEED_SET_ADR485,
			//LoaderServant.NEED_VER_INFO_BOTTOM,
			LoaderServant.NEED_SIZE_CMD,
			LoaderServant.NEED_PARTITION, 
			LoaderServant.NEED_SYSTEM
		];	
		
		public static function initHardwareConst():void
		{
			
			MENU_GROUP = 0;
			
			if( DS.release > 19 )OPERATOR.getSchema( CMD.TM_KEY ).StructCount = 128;
			if( SERVER.BOTTOM_VER_INFO )
			{
				SERVER.BOTTOM_RELEASE = String( SERVER.BOTTOM_VER_INFO[ 0 ][ 1 ] ).split(".")[2];
			}
			else
			{
				SERVER.BOTTOM_RELEASE = String( SERVER.VER_FULL ).split(".")[2];
			}
			
			
			
			if( SERVER.BOTTOM_RELEASE < 17 )
							createOld906();
				
			if( DS.isDevice( DS.K16_3G ) )
			{
				addCmd( NAVI.GPRS_SIM, CMD.MODEM_NETWORK_CTRL );
			}
			if( SERVER.HARDWARE_VER == null ) 	// запуск с эмулятора
				SERVER.HARDWARE_VER = "";
			
			
			
			if (SERVER.DUAL_DEVICE) {
				if (DEVICESB.release >= 7)	// NAVI.DEVICE_POWER
					MENU_GROUP |= 1;
			} else {
				if (DS.release >= 7)	// NAVI.DEVICE_POWER
					MENU_GROUP |= 1;
				/*if (DEVICES.release >= 7)	// NAVI.DEVICE_POWER
					MENU_GROUP |= 1;*/
			}
			
			if( SERVER.BOTTOM_RELEASE > 17 )
				MENU_GROUP |= 2;
			
		}
		
		private static function addCmd(navi:int, cmd:int):void
		{
			var menu:Array = MENU_TOP.concat( MENU_DOWN );
			var len:int = menu.length;
			for (var i:int=0; i<len; i++) {
				if( menu[i].data == navi ) {
					(menu[i].cmds as Array).push(cmd);
				}
			}
		}
		
		private static function createOld906():void
		{
			const p0:ParameterSchemaModel = new ParameterSchemaModel( "Decimal", 2, 1, true );
			const p1:ParameterSchemaModel = new ParameterSchemaModel( "Decimal", 2, 2, true );
			const p2:ParameterSchemaModel = new ParameterSchemaModel( "Decimal", 2, 3, true );
			const p3:ParameterSchemaModel = new ParameterSchemaModel( "Decimal", 2, 4, false );
			
			OPERATOR.getSchema( CMD.VOLTAGE_LIMITS ).Parameters.removeAll();
			
			OPERATOR.getSchema( CMD.VOLTAGE_LIMITS ).Parameters.addItemAt( p0, 0 );//( [ p0, p1, p2, p3 ] ); 
			OPERATOR.getSchema( CMD.VOLTAGE_LIMITS ).Parameters.addItemAt( p1, 1 );//( [ p0, p1, p2, p3 ] ); 
			OPERATOR.getSchema( CMD.VOLTAGE_LIMITS ).Parameters.addItemAt( p2, 2 );//( [ p0, p1, p2, p3 ] ); 
			OPERATOR.getSchema( CMD.VOLTAGE_LIMITS ).Parameters.addItemAt( p3, 3 );//( [ p0, p1, p2, p3 ] ); 
			
			
		}
	}
}
