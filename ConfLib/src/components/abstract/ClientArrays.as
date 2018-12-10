package components.abstract
{
	import components.abstract.functions.loc;
	import components.static.DS;

	public class ClientArrays
	{
// LINK CHANNELS
		public static const CH_COMLINK_PARAM5:Array = [
			{label:loc("ui_linkch_not_in_use"),data:0},
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"SIM1 GPRS-offline ContactID",data:3},
			{label:"SIM2 GPRS-offline ContactID",data:4},
			{label:loc("ui_linkch_sim1_csd_gsm"),data:5},
			{label:loc("ui_linkch_sim2_csd_gsm"),data:6},
			{label:loc("ui_linkch_sim1_v32"),data:7},
			{label:loc("ui_linkch_sim2_v32"),data:8},
			{label:"SIM1 SMS ContactID",data:9},
			{label:"SIM2 SMS ContactID",data:10},
			{label:"LAN online ContactID",data:11},
			{label:"LAN offline ContactID",data:12},
			{label:"WIFI online ContactID",data:13},
			{label:"WIFI offline ContactID",data:14},
			{label:loc("ui_linkch_long_dtmf"),data:15},
			{label:loc("ui_linkch_dtmf"),data:16},
			{label:loc("ui_linkch_sim1_sms_owner"),data:17},
			{label:loc("ui_linkch_sim2_sms_owner"),data:18},
			{label:loc("ui_linkch_sim1_speech_owner"),data:19},
			{label:loc("ui_linkch_sim2_speech_owner"),data:20},
			{label:loc("ui_linkch_sim1_gsm_long_dtmf"),data:21},
			{label:loc("ui_linkch_sim2_gsm_long_dtmf"),data:22},
			{label:loc("ui_linkch_sim1_gsm_dtmf"),data:23},
			{label:loc("ui_linkch_sim2_gsm_dtmf"),data:24}
			
		];
		
		public static const CH_COMLINK_PARAM5_14AW:Array = [
			{label:loc("ui_linkch_not_in_use"),data:0},
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"SIM1 GPRS-offline ContactID",data:3},
			{label:"SIM2 GPRS-offline ContactID",data:4},
			{label:loc("ui_linkch_sim1_csd_gsm"),data:5},
			{label:loc("ui_linkch_sim2_csd_gsm"),data:6},
			{label:loc("ui_linkch_sim1_v32"),data:7},
			{label:loc("ui_linkch_sim2_v32"),data:8},
			{label:"SIM1 SMS ContactID",data:9},
			{label:"SIM2 SMS ContactID",data:10},
			{label:"WIFI online ContactID",data:13},
			{label:loc("ui_linkch_sim1_sms_owner"),data:17},
			{label:loc("ui_linkch_sim2_sms_owner"),data:18}
			];
		
		public static const CH_COMLINK_PARAM5_14_R6:Array = [ // для релиза 6 и ниже
			{label:loc("ui_linkch_not_in_use"),data:0},
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"SIM1 GPRS-offline ContactID",data:3},
			{label:"SIM2 GPRS-offline ContactID",data:4},
			{label:loc("ui_linkch_sim1_csd_gsm"),data:5},
			{label:loc("ui_linkch_sim2_csd_gsm"),data:6},
			{label:loc("ui_linkch_sim1_v32"),data:7},
			{label:loc("ui_linkch_sim2_v32"),data:8},
			{label:"SIM1 SMS ContactID",data:9},
			{label:"SIM2 SMS ContactID",data:10},
			{label:loc("ui_linkch_sim1_sms_owner"),data:17},
			{label:loc("ui_linkch_sim2_sms_owner"),data:18}
			
		];
		public static const CH_COMLINK_PARAM5_14_R7:Array = [	// для релиза 7 и выше
			{label:loc("ui_linkch_not_in_use"),data:0},
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"SIM1 GPRS-offline ContactID",data:3},
			{label:"SIM2 GPRS-offline ContactID",data:4},
			{label:loc("ui_linkch_sim1_csd_gsm"),data:5},
			{label:loc("ui_linkch_sim2_csd_gsm"),data:6},
			{label:loc("ui_linkch_sim1_v32"),data:7},
			{label:loc("ui_linkch_sim2_v32"),data:8},
			{label:"SIM1 SMS ContactID",data:9},
			{label:"SIM2 SMS ContactID",data:10},
			{label:"WIFI online ContactID",data:13},
			//{label:"WIFI offline ContactID",data:14},
			{label:loc("ui_linkch_sim1_sms_owner"),data:17},
			{label:loc("ui_linkch_sim2_sms_owner"),data:18}
		];
		public static const CH_COMLINK_PARAM5_14A:Array = [
			{label:loc("ui_linkch_not_in_use"),data:0},
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"SIM1 GPRS-offline ContactID",data:3},
			{label:"SIM2 GPRS-offline ContactID",data:4},
			{label:loc("ui_linkch_sim1_csd_gsm"),data:5},
			{label:loc("ui_linkch_sim2_csd_gsm"),data:6},
			{label:loc("ui_linkch_sim1_v32"),data:7},
			{label:loc("ui_linkch_sim2_v32"),data:8},
			{label:"SIM1 SMS ContactID",data:9},
			{label:"SIM2 SMS ContactID",data:10},
			{label:loc("ui_linkch_sim1_sms_owner"),data:17},
			{label:loc("ui_linkch_sim2_sms_owner"),data:18}
		];
		public static const CH_COMLINK_PARAM5_7:Array = [
			{label:loc("ui_linkch_not_in_use"),data:0},
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"SIM1 GPRS-offline ContactID",data:3},
			{label:"SIM2 GPRS-offline ContactID",data:4},
			{label:loc("ui_linkch_sim1_csd_gsm"),data:5},
			{label:loc("ui_linkch_sim2_csd_gsm"),data:6},
			{label:"SIM1 SMS ContactID",data:9},
			{label:"SIM2 SMS ContactID",data:10},
			{label:"LAN online ContactID",data:11},
			{label:"LAN offline ContactID",data:12},
			{label:loc("ui_linkch_sim1_sms_owner"),data:17},
			{label:loc("ui_linkch_sim2_sms_owner"),data:18},
			{label:loc("ui_linkch_long_dtmf"),data:15},
			{label:loc("ui_linkch_dtmf"),data:16},
			{label:loc("ui_linkch_sim1_gsm_dtmf"),data:23},
			{label:loc("ui_linkch_sim2_gsm_dtmf"),data:24},
			{label:loc("ui_linkch_sim1_call"),data:25},
			{label:loc("ui_linkch_sim2_call"),data:26}
		];
		public static const CH_COMLINK_PARAM5_16RT1:Array = [
			{label:loc("ui_linkch_not_in_use"),data:0},
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"SIM1 GPRS-offline ContactID",data:3},
			{label:"SIM2 GPRS-offline ContactID",data:4},
			{label:loc("ui_linkch_sim1_csd_gsm"),data:5},
			{label:loc("ui_linkch_sim2_csd_gsm"),data:6},
			{label:loc("ui_linkch_sim1_v32"),data:7},
			{label:loc("ui_linkch_sim2_v32"),data:8},
			{label:"SIM1 SMS ContactID",data:9},
			{label:"SIM2 SMS ContactID",data:10},
			{label:"LAN online ContactID",data:11},
			{label:"LAN offline ContactID",data:12},
			{label:loc("ui_linkch_long_dtmf"),data:15},
			{label:loc("ui_linkch_dtmf"),data:16},
			{label:loc("ui_linkch_sim1_sms_owner"),data:17},
			{label:loc("ui_linkch_sim2_sms_owner"),data:18},
			{label:loc("ui_linkch_sim1_gsm_dtmf"),data:23},
			{label:loc("ui_linkch_sim2_gsm_dtmf"),data:24}
		];
		public static function getComLinkAdapted():Array
		{
			
			var arr:Array;
			
			const arrChCall:Array = [ {label:loc("ui_linkch_sim1_call"),data:25},
				{label:loc("ui_linkch_sim2_call"),data:26} ];
			
			const nm_sim1:String =  loc( "sim" ) 
									+ "1 " 
									+ loc( "ui_linkch_gprs_sim1_offline_contactId" );
			const nm_sim2:String =  loc( "sim" ) 
				+ "2 " 
				+ loc( "ui_linkch_gprs_sim1_offline_contactId" );
			
			
			const gprsOfflineContactId:Array = [ {label:nm_sim1,data:27},
				{label: nm_sim2 ,data:28} ];
			
			switch(DS.deviceAlias) {
				case DS.K14W:
					arr =  CH_COMLINK_PARAM5_14_R7;
					break;
				case DS.K14:
					arr =  CH_COMLINK_PARAM5_14_R6;
					break;
				case DS.K14A:
				case DS.K14K:
					arr =  CH_COMLINK_PARAM5_14A;
					break;
				case DS.K14AW:
				case DS.K14KW:
					arr =  CH_COMLINK_PARAM5_14AW;
					break;
				case DS.K7:
					arr =  CH_COMLINK_PARAM5_7;
					
					break;
				default:
					arr = CH_COMLINK_PARAM5; 
			}
			
			
			if( DS.isfam( DS.K14 ) && DS.release > 12 ) arr = arr.concat( arrChCall.concat( gprsOfflineContactId ) );
			//else if( DEVICES.isFamily( DEVICES.K14 ) && DEVICES.release > 12 ) arr = arr.concat( arrChCall );
			
			return arr;
		}
// OUT 16
		public static const OUT_PATTERNS:Array = [{label:loc("ui_out_disabled"), data:0},
			{label:loc("ui_out_always_on"), data:3},
			{label:loc("ui_out_ind_part_state"), data:1},
			{label:loc("ui_out_trigger_on_part_alarm"), data:2},
			{label:loc("ui_out_ind_unsent_events"), data:4}
		];
// OUT 17
		public static const OUT_PATTERNS_K7:Array = [{label:loc("ui_out_disabled"), data:0},
			{label:loc("ui_out_ind_part_state"), data:1},
			{label:loc("ui_out_trigger_on_part_alarm"), data:2} ];
		
		public static const OUT_PATTERNS_SHORT:Array = [{label:loc("ui_out_disabled"), data:0} ];		
// RELE
		public static const RELE_PATTERNS:Array = [{label:loc("ui_out_disabled"), data:0},
			{label:loc("ui_rele_always_on"), data:4},
			{label:loc("ui_out_ind_part_state"), data:1},
			{label:loc("ui_out_trigger_on_part_alarm"), data:2},
			{label:loc("ui_out_ind_unsent_events"), data:3}];
		//	{label:"Прямое управление выходом с брелока и клавиатуры", data:4},
		//	{label:"Включение выхода по расписанию", data:5},
		//	{label:"Настройка срабатывания по событиям ContactID", data:6}];
// DATE	
		public static const aTimeZones:Array = [{label:loc("ui_date_gmt12"),data:12},
			{label:loc("ui_date_gmt11"),data:11},
			{label:loc("ui_date_gmt10"),data:10},
			{label:loc("ui_date_gmt9"),data:9},
			{label:loc("ui_date_gmt8"),data:8},
			{label:loc("ui_date_gmt7"),data:7},
			{label:loc("ui_date_gmt6"),data:6},
			{label:loc("ui_date_gmt5"),data:5},
			{label:loc("ui_date_gmt4"),data:4},
			{label:loc("ui_date_gmt3"),data:3},
			{label:loc("ui_date_gmt2"),data:2},
			{label:loc("ui_date_gmt1"),data:1},
			{label:loc("ui_date_gmt0"),data:0},
		];
		
	//	public static const days:Array = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
	//	public static const months:Array = ["Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"]
// GPRS_SIM  K2
	/*	public static const aOperatorK2:Array = [{label:"Вручную", data:0},{label:"Автовыбор", data:1}, {label:"Мегафон", data:2}, {label:"МТС", data:3}, {label:"Билайн", data:4}, {label:"Теле2", data:5} ];
		public static const aOperatorConfigInfoK2:Array = [	[ "", "", "", "" ],
			[ "", "", "", "" ],
			[ "*99#", "internet.megafon.ru", "megafon", "megafon" ],
			[ "*99#", "internet.mts.ru", "mts", "mts" ],
			[ "*99#", "internet.beeline.ru", "beeline", "beeline" ],
			[ "*99#", "internet.tele2.ru", "tele2", "tele2" ]	];*/
// GPRS_SIM 		
		public static const aOperator:Array = [{label:loc("misc_by_hand"), data:0},
			{label:loc("misc_megafon"), data:1}, {label:loc("misc_mts"), data:2}, 
			{label:loc("misc_beeline"), data:3}, {label:loc("misc_tele2"), data:4} ];
		public static const aOperatorConfigInfo:Array = [	[ "", "", "", "" ],
			[ "*99#", "internet", "", "" ],
			[ "*99#", "internet.mts.ru", "mts", "mts" ],
			[ "*99#", "internet.beeline.ru", "beeline", "beeline" ],
			[ "*99#", "internet.tele2.ru", "tele2", "tele2" ]	];
// RF_SENSOR	
		public static const aSensorStatus:Array = [ loc("g_no").toLowerCase(), loc("rfd_adding"), loc("rfd_not_found"), loc("rfd_already_exist"),
			loc("rfd_add_success"), loc("rfd_add_cancel"), loc("rfd_num_busy"),
			loc("rfd_cant_add"), loc("rfd_error_add_or_delete") ];
		public static const aSensorTypeNames:Array = [ 
					loc("rfd_not_recognized")
					, loc("rfd_gerkon")
					, loc("rfd_smoke")
					, loc("rfd_glass_break")
					, loc("rfd_volume")
					, loc("rfd_rftrinket")
					, loc("rfd_rfrelay")
					, loc("rfd_rfkey")
					, loc("rfd_ipr")
					, loc("rfd_flood")
					, loc("rfd_gerkon_rdd3")
					, loc("rfd_lcd_keyboard") 
					, loc("rfd_lcd_keyboard")
					, loc("rfd_rd_repeater") ];
		
		public static const sms_text:Array = [
			loc("sms_alarm_motion"),
			loc("sms_alarm_add_wire"),
			loc("sms_alarm_attack1"),
			loc("sms_alarm_attack2"),
			loc("sms_alarm_attack3"),
			loc("sms_alarm_attack4"),
			loc("sms_alarm_attack5"),
			loc("sms_alarm_attack6"),
			loc("sms_alarm_attack7"),
			loc("sms_alarm_attack8"),
			loc("sms_alarm_tamper"),
			loc("sms_autotest"),
			loc("sms_system_restart"),  
			loc("sms_battery_power"),
			loc("sms_constant_power"),
			loc("sms_battery_low"),
			loc("sms_onguard_key1"), 
			loc("sms_onguard_key2"), 
			loc("sms_onguard_key3"), 
			loc("sms_onguard_key4"), 
			loc("sms_onguard_key5"), 
			loc("sms_onguard_key6"), 
			loc("sms_onguard_key7"), 
			loc("sms_onguard_key8"), 
			loc("sms_offguard_key1"),   
			loc("sms_offguard_key2"),   
			loc("sms_offguard_key3"),   
			loc("sms_offguard_key4"),   
			loc("sms_offguard_key5"),   
			loc("sms_offguard_key6"),   
			loc("sms_offguard_key7"),   
			loc("sms_offguard_key8"),   
			loc("sms_onguard_trinket1"), 
			loc("sms_onguard_trinket2"),
			loc("sms_onguard_trinket3"),
			loc("sms_onguard_trinket4"),
			loc("sms_onguard_trinket5"),
			loc("sms_onguard_trinket6"),
			loc("sms_onguard_trinket7"),
			loc("sms_onguard_trinket8"),
			loc("sms_offguard_trinket1"),
			loc("sms_offguard_trinket2"),
			loc("sms_offguard_trinket3"),
			loc("sms_offguard_trinket4"),
			loc("sms_offguard_trinket5"),
			loc("sms_offguard_trinket6"),
			loc("sms_offguard_trinket7"),
			loc("sms_offguard_trinket8"),
			loc("sms_onguard_control"),
			loc("sms_offguard_control"),
			loc("sms_onguard_tm"),
			loc("sms_clear_history"),
			loc("sms_battery_malfunction")
		];
		// использует Контакт 2
		public static const sms_contsctID:Array = [
			"113201001",
			"113001002",
			"112001101",
			"112001102",
			"112001103",
			"112001104",
			"112001105",
			"112001106",
			"112001107",
			"112001108",
			"113901003",
			"160200000",
			"130500000",  
			"130100000",
			"330100000",
			"130200000",
			"340201001", 
			"340201002", 
			"340201003", 
			"340201004", 
			"340201005", 
			"340201006", 
			"340201007", 
			"340201008", 
			"140201001",   
			"140201002",   
			"140201003",   
			"140201004",   
			"140201005",   
			"140201006",   
			"140201007",   
			"140201008",   
			"340201101", 
			"340201102",
			"340201103",
			"340201104",
			"340201105",
			"340201106",
			"340201107",
			"340201108",
			"140201101",
			"140201102",
			"140201103",
			"140201104",
			"140201105",
			"140201106",
			"140201107",
			"140201108",
			"340201000",
			"140201000",
			"340201000",
			"162100000",
			"130900000"
		];
		
		public static const EXCLUDE_OPTIONS:Array = [
			{label:"SIM1 GPRS-online ContactID",data:1},
			{label:"SIM2 GPRS-online ContactID",data:2},
			{label:"LAN online ContactID",data:11},
			{label:"WIFI online ContactID",data:13},
			{label:"SIM1 GPRS-offline ContactID + config",data:27},
			{label:"SIM2 GPRS-offline ContactID + config",data:28},
		];
	}
}