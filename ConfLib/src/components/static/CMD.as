package components.static
{
	public class CMD
	{
		// SERVER EVENTS
		public static const SIM_SLOT_COUNT:int = 5;
		public static const GPRS_APN_COUNT:int = 6;
		public static const GPRS_APN_BASE:int = 7;
		public static const GPRS_APN_AUTO:int = 8;
		public static const GPRS_APN_SELECT:int = 9;
		
		public static const GPRS_SIM:int = 10;
		public static const GPRS_COMPR:int = 11;
		public static const NO_GPRS_ROAMING:int = 12;
		
		public static const GET_PHONE_OVER_SMS:int = 14;
		
		public static const GET_LBS:int = 17;
		public static const SEND_LBS:int = 18;
		public static const RF_FUNCT:int = 20;
		public static const RF_STATE:int = 21;
		public static const RF_SYSTEM:int = 22;
		public static const RF_CODES:int = 23;
		public static const RF_MESSAGE_TAMPER:int = 24;
		public static const RF_SENSOR_KEY_ZONE:int = 28;
		
		public static const RF_SENSOR:int = 30;
		public static const RF_SENSOR_TIME:int = 31;
		
		public static const RF_RCTRL:int = 40;
		public static const RF_TYPE_KEYB:int = 49;
		public static const RF_KEY:int = 50;
		public static const RF_KEY_BZI:int = 51;
		public static const RF_KEY_BZP:int = 52;
		
		public static const SMS_R_CTRL:int = 60;
		public static const SMS_ZONE:int = 61;
		public static const SMS_PARAM:int = 62;
		public static const SMS_USER:int = 63;
		public static const SMS_PART:int = 64;
		public static const SMS_TEXT:int = 65;
		public static const SMS_TM:int = 66;
		
		public static const DATE_TIME:int = 70;
		public static const TIME_ZONE:int = 71;
		public static const TIME_SYNCH:int = 72;
		public static const SERVER_NTP:int = 73;
		public static const DATE_TIME_FUNCT:int = 74;
		public static const DATE_TIME_STATE:int = 75;
		
		public static const LED_IND:int = 79;
		
		public static const LED14_IND:int = 80;
		public static const BUZZER14:int = 81;
		public static const BUZ_PART:int = 82;
		public static const ALARM_KEY:int = 83;
		
		public static const ENGIN_NUMB:int = 90;
		public static const ENGIN_ALL:int = 91;
		
		public static const PARTITION:int = 100;
		public static const PART_STATE:int = 101;
		public static const PART_SET:int = 102;
		public static const PART_FUNCT:int = 103;
		//public static const PART_SLAVE:int = 104;
		public static const PART_STATE_ALL:int = 105;
		public static const PART_STATE_ALL2:int = 106;
		public static const SEND_KEYBOARD:int = 107;
		public static const PART_SET_TEST_LINK:int = 108;
		
		public static const MASTER_CODE:int = 110;
		public static const KEY_BLOCK:int = 111;
		public static const USER_PASS:int = 112;
		
		public static const MODEM_NETWORK_CTRL:int = 116;
		public static const NAV_INFO:int = 117;
	//	public static const VER_COMMENT:int = 118;		больше не используется
		public static const MODEM_INFO:int = 119;
		public static const VER_INFO:int = 120;
		public static const VER_INFO1:int = 121;
		public static const GSM_SIG_LEV:int = 122;
		
		public static const USSD_FUNCT:int = 123;
		public static const USSD_STRING:int = 124;
		public static const USSD_BALANS:int = 125;
		public static const EXT_MODEM_INFO:int = 126;
		public static const EXT_MODEM_NETWORK_CTRL:int = 127;
	//	public static const EXT_MODEM_INFO_ADD:int = 128;
		
		public static const AUTOTEST:int = 130;
		public static const SYS_NOTIF:int = 131;
		
		public static const MAPRF_SEN:int = 140;
		public static const MAPRF_KEY:int = 141;
		public static const MAPRF_MOD:int = 142;
		public static const MAPRF_REL:int = 143;
		public static const MAPRF_SELECT:int = 144;
		public static const MAPRF_GET:int = 145;
		public static const MAPRF_CLEAR:int = 146;
		
		public static const RFRELAY_INIT:int = 150;
		public static const RFRELAY_FUNCT:int = 152;
		public static const RFRELAY_STATE:int = 153;
		public static const RFRELAY_AWSET:int = 154;
		public static const RFRELAY_INDPART:int = 156;
		public static const RFRELAY_INDMES:int = 157;
		public static const RFRELAY_ALARM1:int = 158;
		public static const RFRELAY_ALARM2:int = 159;
		public static const RFRELAY_ALARM3:int = 160;
		public static const RFRELAY_SCHED1:int = 162;
		public static const RFRELAY_SCHED2:int = 163;
		
		public static const HISTORY_VER:int = 170;
		public static const HISTORY_INFO:int = 171;
		public static const HISTORY_REC:int = 172;
		public static const HISTORY_DELETE:int = 173;
		public static const HISTORY_BLOCK:int = 174;
		public static const HISTORY_SELECT_PAR:int = 175;
		public static const HISTORY_INDEX:int = 176;
		public static const HISTORY_SIZE:int = 177;
		public static const HISTORY_AVAILABLE_PAR:int = 178;
		
		public static const HISTORY_RETRANSMISSION:int = 183;
		
		public static const SET_HISTORY_INDEX:int = 185;
		public static const SELECT_HISTORY_BY:int = 186;
		public static const SEND_SELECT_HISTORY_INDEX:int = 187;
		public static const SEND_SELECT_HISTORY:int = 188;
		public static const SEND_SELECT_HISTORY_BREAK:int = 189;
		public static const EVENT_LOG_REC:int = 190;
		public static const EVENT_LOG_INDEX:int = 191;
		public static const EVENT_LOG_INFO:int = 192;
		public static const EVENT_LOG_DELETE:int = 193;
		
		public static const ALARM_WIRE_SET:int = 200;
		public static const ALARM_WIRE_LEVEL:int = 210;
		public static const ALARM_WIRE_RES:int = 211;
		public static const ALARM_WIRE_FUNCT:int = 212;
		public static const ALARM_WIRE_STATE:int = 213;
		public static const K7_ALARM_WIRE_SET:int = 215;
		public static const K7_ALARM_WIRE_GET:int = 216;
		
		public static const SET_DEV_HARD_VER:int = 300;
		public static const ENCRYPTION_KEY_128:int = 301;
		
		public static const CTRL_MASTER_CODE:int = 319;
		public static const CTRL_FILTER_CMD:int = 320;
		public static const CTRL_COUNT_OUT:int = 321;
		public static const CTRL_TYPE_OUT:int = 322;
		public static const CTRL_TEST_OUT:int = 323;
	//	public static const CTRL_STATE_OUT:int = 324;
		public static const CTRL_INIT_OUT:int = 325;
		public static const CTRL_TEMPLATE_OUT:int = 326;
		public static const CTRL_TEMPLATE_ST_PART:int = 327;
		public static const CTRL_TEMPLATE_AL_LST_PART:int = 328;
		public static const CTRL_TEMPLATE_AL_PART:int = 329;
		public static const CTRL_TEMPLATE_UNSENT_MESS:int = 330;
		public static const CTRL_TEMPLATE_MANUAL:int = 331;
		public static const CTRL_TEMPLATE_MANUAL_TIME:int = 332;
		public static const CTRL_TEMPLATE_MANUAL_CNT:int = 333;
		public static const CTRL_TEMPLATE_FAULT:int = 334;
		public static const CTRL_SERVER_SETTINGS:int = 335;
		
		public static const CTRL_GET_STT_ID_VISIBLE:int = 336;
		public static const CTRL_STT_ID_VISIBLE:int = 337;
		
		public static const CTRL_SENSOR_CNT_STRUCT:int = 349;
		public static const CTRL_SENSOR_AVAILABLE:int = 350;
		public static const CTRL_GET_SENSOR:int = 351;
		public static const CTRL_VOLTAGE_SENSOR:int = 352;
		public static const CTRL_TAMPER_SENSOR:int = 353;
		public static const CTRL_TEMPERATURE_SENSOR:int = 354;
		public static const CTRL_KEY_SENSOR:int = 355;
		public static const CTRL_DOUT_SENSOR:int = 356;
		
		public static const CTRL_NAME_OUT:int = 369;
		public static const CTRL_TEMPLATE_RCTRL:int = 370;
		public static const CTRL_TEMPLATE_RFSENSALARM:int = 371;
		public static const CTRL_TEMPLATE_RFSENSSTATE:int = 372;
		public static const CTRL_TEMPLATE_REACT_ST_PART:int = 373;
		public static const CTRL_TEMPLATE_REACT_ST_ZONE:int = 374;
		public static const CTRL_TEMPLATE_ALL_FIRE:int = 375;
		public static const CTRL_TEMPLATE_REACT_ST_EXT:int = 376;
		public static const CTRL_TEMPLATE_RF_ALARM_BUTTON:int = 377;
		
		public static const CTRL_GET_MAPRF_LOG:int = 390;
		public static const CTRL_MAPRF_LOG:int = 391;
		
		
		public static const RF_CTRL:int = 401;
		public static const RF_CTRL_OUT_STATE:int = 402;
		public static const RF_CTRL_TEMPLATE_ST_PART:int = 403;
		public static const RF_CTRL_TEMPLATE_AL_LST_PART:int = 404;
		public static const RF_CTRL_TEMPLATE_AL_PART:int = 405;
		public static const RF_CTRL_TEMPLATE_UNSENT_MESS:int = 406;
		public static const RF_CTRL_TEMPLATE_FAULT:int = 407;
		public static const RF_CTRL_TEMPLATE_MANUAL:int = 408;
		public static const RF_CTRL_TEMPLATE_MANUAL_TIME:int = 409;
		public static const RF_CTRL_TEMPLATE_MANUAL_CNT:int = 410;
		
		public static const READER_TM:int = 500;
		public static const READER_TM2:int = 501;
		public static const TM_KEY:int = 502;
		public static const TM_KEY2:int = 503;
		public static const TM_KEY_FUNCT:int = 504;
		public static const TM_KEY_STATE:int = 505;
		public static const RF_RCTRL2:int = 506;
		
		public static const BUZZER_SIREN:int = 508;
		
		public static const POWER_SAVE:int = 510;
		
		public static const AUTOTEST_CYCLE:int = 514;
		public static const AUTOTEST_ADD_CYCLE:int = 515;
		
		public static const SYS_NOTIF2:int = 516;
		public static const NOTIF_K2:int = 517;
		public static const NOTIF_K2_LIMIT:int = 518;
		public static const NOTIF_K2_STATE:int = 519;
		public static const SENSOR_K2:int = 520; 
		
		public static const SMS_DATE_TIME_NOTIF_K2:int = 521;
		public static const SMS_SETTING_K2:int = 522;
		public static const SMS_TEXT_K2:int = 523;
		public static const TEST_K2:int = 524;
		
		public static const PING_SET_TIME:int = 529;
		public static const PING:int = 530;
		
	//	public static const OUT_INIT:int = 540;			// удалена
		public static const OUT_CTRL_INIT:int = 541;
		public static const OUT_FUNCT:int = 542;
		public static const OUT_STATE:int = 543;
		public static const OUT_CTRL_STATE:int = 544;
		public static const OUT_ON_LEVEL:int = 545;
		public static const OUT_OFF_LEVEL:int = 546;
		public static const OUT_EXP_LEVEL:int = 547;
		public static const OUT_ALARM1:int = 548;
		public static const OUT_ALARM2:int = 549;
		public static const OUT_ALARM3:int = 550;
		public static const OUT_INDPART:int = 551;
		public static const OUT_PERMANENTLY_ON:int = 552;
		public static const OUT_INDMES:int = 553;
		
	//	public static const RELAY_INIT:int = 570;		// удалена
		public static const RELAY_FUNCT:int = 571;
		public static const RELAY_STATE:int = 572;
		public static const RELAY_ALARM1:int = 573;
		public static const RELAY_ALARM2:int = 574;
		public static const RELAY_INDPART:int = 575;
		public static const RELAY_INDMES:int = 576;
		public static const RELAY_PERMANENTLY_ON:int = 577;
		
		public static const DATA_KEY:int = 580;
		public static const DATA_KEY_BZI:int = 581;
		public static const DATA_KEY_BZP:int = 582;
		public static const DATA_KEY_FUNCT:int = 583;
		public static const DATA_KEY_STATE:int = 584;
		
		public static const CH_COM_GET_INFO:int = 600;
		public static const CH_COM_MAX_INFO:int = 601;
		public static const CH_COM_ADD:int = 602;
		public static const CH_COM_LINK_LOCK:int = 603;
		public static const CH_COM_LINK:int = 604;
		public static const CH_COM_LINK_GPRS:int = 605;
		public static const CH_COM_LINK_CSD:int = 606;
		
		public static const CH_COM_OBJ:int = 611;
		public static const CH_COM_EVENT:int = 612;
		public static const CH_COM_PART:int = 613;
		public static const CH_COM_ZONE:int = 614;
		public static const CH_COM_UPDATE:int = 615;
		public static const CH_SEND_IMEI:int = 616;
		public static const CH_VR_COM_LINK:int = 617;
		public static const CH_COM_GPRS_TIMEOUT_SERVER:int = 618;
		
		public static const CH_COM_TIME_PARAM_COUNT:int = 620;
		public static const CH_COM_TIME_PARAM:int = 621;
		public static const CH_COM_GOTO_GPRS_OFFLINE_WHILE:int = 622;
		public static const CH_COM_DUBLE_ONLINE:int = 623;
		
		public static const OBJECT:int = 700;
		
		public static const VR_INPUT_TYPE:int = 702;
		public static const VR_INPUT_DIGITAL:int = 703;
		public static const VR_INPUT_ANALOG:int = 704;
		public static const VR_INPUT_FREQ:int = 705;
		public static const VR_INPUT_PULSE:int = 706;
		
		public static const VR_VIBRO_SENSOR:int = 710;
		
		public static const VR_TANGENTA:int = 715;
		
		public static const VR_OUT_COUNT:int = 719; 
		public static const VR_OUT:int = 720;
		public static const VR_OUT_MANUAL_CONTROL:int = 721;
		public static const VR_OUT_STATE:int = 722;
		public static const VR_SPEED_ALARM:int = 723;
		
		public static const VR_ACC_ALARM:int = 725;
		
		public static const VR_SENSOR_SI:int = 731;
		public static const VR_SENSOR_SI_REMEMBER:int = 732;
		public static const VR_SENSOR_SI_XY:int = 733;
		public static const VR_SENSOR_SA:int = 734;
		public static const VR_SENSOR_SC:int = 735;
		
		public static const VR_INPUT_ANALOG_VALUE:int = 739;
		
		public static const VR_SMS_SETTINGS:int = 744;
		public static const VR_SMS_SCHEDULE:int = 745;
		
		public static const VR_SMS_NOTIF_LIST:int = 746;
		public static const VR_SMS_NOTIF:int = 747;
		public static const VR_SMS_GUARD:int = 748;
		public static const VR_SMS_LOCATION_ENABLE:int = 750;
		
		
		public static const VR_KEY_SIDE_SWITCH:int = 751;
		
		public static const VR_SERIAL_USE:int = 753;
		
		public static const VR_MASTER_KEY:int = 755;
		public static const VR_NOTIFICATION:int = 756;
		public static const VR_SEND_SMS_LINK_MAP:int = 757;
		
		public static const VR_PACK_SIZE:int = 759;
		public static const VR_FILTER_TRACK:int = 760;
		public static const VR_FILTER_3DFIX:int = 761;
		public static const VR2_IND_MODE:int = 762;
		public static const VR_NMEA_ROUTING:int = 763;
		public static const VR_IND_MODE:int = 764;
		public static const VR_NAV_SYSTEM:int = 765;
		
		public static const VR2_WORKMODE_CURRENT:int = 773;
		public static const VR_WORKMODE_CURRENT:int = 774;
		public static const VR_WORKMODE_SET:int = 776;
		public static const VR_WORKMODE_EVENT:int = 778;
		public static const VR_WORKMODE_ENGINE_START:int = 780;
		public static const VR_WORKMODE_ENGINE_RUNS:int = 782;
		public static const VR_WORKMODE_ENGINE_STOP:int = 784;
		public static const VR_WORKMODE_START:int = 786;
		public static const VR_WORKMODE_STOP:int = 788;
		public static const VR_WORKMODE_MOVE:int = 790;
		public static const VR_WORKMODE_PARK:int = 792;
		public static const VR_WORKMODE_REGULAR:int = 794;
		public static const VR_WORKMODE_SCHEDULE:int = 796;
		
		public static const VIDEO_SETTINGS:int = 800;
		public static const VIDEO_ARC_SETTINGS:int = 802;
		public static const VIDEO_CAMS:int = 804;
		public static const VIDEO_CAM_SOURCE:int = 805;
		public static const K15_VIDEO_SETTINGS:int = 806;
		public static const VIDEO_TVIN_POWER:int = 807;
		public static const VIDEO_RECORD:int = 808;
		public static const VIDEO_IV_SETTINGS:int = 809;
		public static const VIDEO_IV_STATUS:int = 810;
		public static const VIDEO_IV_COMMAND:int = 811;
		public static const VIDEO_FILE_RECORDING_TIME:int = 812;
		public static const VIDEO_SIDE_NUMDER_VEHICLE:int = 813;
		public static const VIDEO_IP_CAM_SETTINGS:int = 815;
		public static const VIDEO_IP_CAM_FPS:int = 816;
		public static const GET_PHOTO_SHOT:int = 819;
		public static const SEND_PHOTO_SHOT:int = 820;
		public static const VIDEO_IP_CAM_RESET:int = 821;
		public static const GET_RECORD_CAM_STATE:int = 822;
		
		public static const LCD_LOGO_IMG:int = 850;
		public static const LCD_LOGO_CRC32:int = 851;
		public static const LCD_LOGO_WRITE:int = 852;
		public static const LCD_BACKLIGHT:int = 853;
		public static const KBD_ICO_VECT_TABLE_STORAGE:int = 860;
		public static const KBD_ICO_STORAGE:int = 861;
		public static const KBD_PARTITION_NAME:int = 862;
		public static const KBD_ZONES_NAME:int = 863;
		public static const KBD_LOGO:int = 864;
		
		public static const BATTERY_LEVEL:int = 900;
		public static const SAVE_CID_TEMPERATURE:int = 901;
		public static const GET_TEMPERATURE:int = 902; 
		public static const LIMITS_TEMP:int = 903;
		public static const VOLTAGE_SENSOR:int = 904;
		public static const CPW_SENSOR:int = 905;
		public static const VOLTAGE_LIMITS:int = 906;
		public static const CPW_LIMITS:int = 907;
		public static const RF_CTRL_TEMP:int = 908;
		
		public static const ATTITUDE_SENSOR:int = 910;
		public static const POSITION_SENSOR:int = 912;											
		public static const RANGE_ACC:int = 914;													
		public static const LIMITS_ACC:int = 916;								
		public static const TEST_ACC:int = 918;
		public static const VECTOR_ACC:int = 920;
		public static const OUT_ACC:int = 921;
		public static const DST_ALARM:int = 923;
		
		public static const VR_VOLTAGE_VALUE:int = 930;
		public static const VR_VOLTAGE_SENSOR:int = 932;
		
		public static const VR_COUNTER_NAV_MILEAGE:int = 998;
		public static const VR_COUNTER_NAV_HOURS:int = 999;
		
		public static const VR_AGPS_ENABLE:int = 1001;
		public static const VR_TM_KEY:int = 1015;
		public static const VR_TM_SEARCH:int = 1016;
		public static const VR_TM_ACTION:int = 1017;
		public static const VR_IDENT_ENABLE:int = 1018;
		public static const VR_IDENT_TIMEOUT:int = 1019;
		
		public static const VR_IRMA_DOOR_NUM:int = 1100;
		public static const VR_IRMA_DOOR_INPUT:int = 1101;
		public static const VR_IRMA_DOOR_DELAY:int = 1102;
		
		public static const VR_MSG_LIST:int = 1440;
		public static const VR_MSG_SETTINGS:int = 1441;
		public static const VR_NEW_FLAG_ENABLE:int = 1442;
		
		public static const HOLD_CONNECTION:int = 1453;
		public static const SEND_RUBBER_HISTORY_SERVER:int = 1454;
		public static const SEND_SECURITY_TOKEN:int = 1455;
		
		public static const TRAKING_MODE:int = 1458;
		public static const GET_NMEA_RMC:int = 1459;
		public static const RITM_LINK_ID:int = 1460;
		
		public static const CERTIFICATE_SAVE:int = 1496;
		public static const SET_CERTIFICATE:int = 1497;
		public static const CERTIFICATE_VERIFICATION:int = 1498;
		public static const GET_CERTIFICATE:int = 1499;
		
		public static const SOUND_LOAD:int = 1500;
		public static const SOUND_SIZE:int = 1501;
		public static const SOUND_DELETE_SUBSECTOR:int = 1502;
		public static const SOUND_DELETE_SECTOR:int = 1503;
		public static const SOUND_DELETE_STATUS:int = 1504;
		
		public static const SOUND_PLAY_FILE:int = 1520;
		public static const SOUND_PLAY_FILE_NAME:int = 1521;
		
		public static const V2D_NBR_GROUP_DISP:int = 1600;
		public static const V2D_LIST_GROUP_DISP:int = 1601;
		public static const V2D_NBR_GROUP_DRIVER:int = 1602;
		public static const V2D_LIST_GROUP_DRIVER:int = 1603;
		public static const V2D_NBR_MESSAGE_DISP:int = 1604;
		public static const V2D_LIST_MESSAGE_DISP:int = 1605;
		public static const V2D_NBR_MESSAGE_DRIVER:int = 1606;
		public static const V2D_LIST_MESSAGE_DRIVER:int = 1607;
		public static const V2D_MESSAGE_BASE:int = 1610;
		public static const V2D_MESSAGE_DISP:int = 1611;
		public static const V2D_MESSAGE_DRIVER:int = 1612;
		
		public static const CAN_CAR_ID:int = 3000;
		public static const CAN_INPUTS:int = 3001;
		public static const CAN_PARAMS_FUEL:int = 3002;
		public static const CAN_PARAMS_ENGINE:int = 3003;
		public static const CAN_PARAMS_EXPL:int = 3004;
		public static const CAN_GET_PARAMS:int = 3005;
		
		public static const CAN_ENGINE:int = 3008;
		public static const CAN_FUNCT_SELECT:int = 3009;
		
		public static const EGTS_UNIT_HOME_DISPATCHER_ID:int = 3100;
		
		public static const EGTS_LOGIN_ENABLE:int = 3108;
		public static const EGTS_USER_NAME_PASSWORD:int = 3109;
		public static const EGTS_CNT_STAT_SEND_ENABLE:int = 3110;
		public static const EGTS_CNT_STAT_COUNT:int = 3111;
		public static const EGTS_CNT_STAT_VALUE:int = 3112;
		public static const EGTS_CNT_GET_VALUES:int = 3113;
		
		public static const EGTS_CRYPTO_ENABLE:int = 3120;
		public static const EGTS_CRYPTO_GOST_KEY:int = 3122;
		public static const EGTS_CRYPTO_GOST_S_BOX:int = 3123;
		public static const EGTS_FLAG_ENABLE:int = 3124;
		public static const EGTS_SUBRECORD_TELEDATA_EN:int = 3126;
		public static const VR_EGTS_PRIORITY:int = 3127;
		public static const VR_EGTS_WORKMODE:int = 3128;
		public static const VR_EGTS_IMEI:int = 3129;
		public static const VR_EGTS_DISPATCH_CENTER_NUM:int = 3130;
		public static const VR_EGTS_VEHICLE_DATA:int = 3131;
		
		public static const K5_G_PHONE:int = 3500;
		public static const K5_G_APN:int = 3501;
		public static const K5_G_APN_LOG:int = 3502;
		public static const K5_G_APN_PASS:int = 3503;
		public static const K5_G_SRV_IP:int = 3504;
		public static const K5_G_SRV_PORT:int = 3505;
		public static const K5_G_SRV_PASS:int = 3506;
		public static const K5_ADC_TRESH:int = 3507;
		public static const K5_ADC_GET:int = 3508;
		public static const K5_AWIRE_STATE:int = 3509;
		public static const K5_AWIRE_PART_CODE:int = 3510;
		public static const K5_DIRECTIONS:int = 3511;
		public static const K5_PART_PARAMS:int = 3512;
		public static const K5_AWIRE_DELAY:int = 3513;
		public static const K5_PART_DELAY:int = 3514;
		public static const K5_AWIRE_TYPE:int = 3515;
		public static const K5_APHONE:int = 3516;
		public static const K5_EPHONE:int = 3517;
		public static const K5_FAULT_CODE:int = 3518;
		public static const K5_BIT_SWITCHES:int = 3519;
		public static const BIT_SWITCHES:int = 3520;
		
		public static const K5_DIG_TIME:int = 3521;
		public static const K5_G_TRY_TIME:int = 3522;
		public static const K5_AND_OR:int = 3523;
		public static const K5_PART_EVCOUNT:int = 3524;
		public static const K5_SYR_LEN:int = 3525;
		public static const K5_SYR_PAR:int = 3526;
		public static const K5_PART_OUT:int = 3527;
		public static const K5_OUT_DRIVE:int = 3528;
		public static const K5_SMS_TEXT:int = 3529;
		public static const K5_MAIN_ATEST:int = 3530;
		public static const K5_ADV_ATEST:int = 3531;
		public static const K5_KEY_BLOCK:int = 3532;
		public static const K5_TIME_CPW:int = 3533;
		public static const K5_KBD_COUNT:int = 3534;
		public static const K5_KBD_INDEX:int = 3535;
		public static const K5_KBD_NUMOBJ:int = 3536;
		public static const K5_KBD_KEY_CNT:int = 3537;
		public static const K5_KBD_KEY:int = 3538;
		public static const K5_KBD_MKEY:int = 3539;
		public static const K5_HISTORY_REC:int = 3540;
		public static const K5_TM_KEY_CNT:int = 3541;
		public static const K5_TM_DELAY:int = 3542;
		public static const K5_TM_KEY:int = 3543;
		public static const K5_TM_CUR_KEY:int = 3544;
		public static const SEND_TM_KEY_TO_SERVER:int = 3545;
		public static const TM_KBD_ALARM_BEEP_ENABLE:int = 3546;
		public static const SYR_PAR:int = 3547;

		public static const K9_AWIRE_TYPE:int = 3600;
		public static const K9_PART_PARAMS:int = 3601;
		public static const K9_HISTORY_REC:int = 3602;
		public static const K9_BIT_SWITCHES:int = 3603;
		public static const K9_BAT_EVENTS:int = 3604;
		public static const K9_DIRECTIONS:int = 3605;
		public static const K9_TM_LED_PART:int = 3606;
		public static const K9_EXIT_PART:int = 3607;
		public static const K9_PERIM_PART:int = 3608;
		public static const K9_SIM_SWITCH:int = 3610;
		public static const K9_LED_TEST:int = 3611;
		public static const K9_IMEI_IDENT:int = 3612;
		public static const K9_ADV_ATEST:int = 3613;
		public static const K9_MAIN_ATEST:int = 3616;
		public static const AWIRE_CHANGE_DELAY:int = 3617;
		
		public static const K5RT_DIRECTIONS:int = 3700;
		public static const K5RT_EMULATOR_HS:int = 3701;
		public static const K5RT_ATEST_CODE:int = 3702;
		public static const K5RT_AWIRE_TYPE:int = 3703;
		public static const K5RT_SLOW_DTMF:int = 3704;
		public static const K5RT_DIR_CHANGE:int = 3705;
		public static const K5RT_GPRS_ADD:int = 3706;
		public static const K5RT_CH_ONLINE:int = 3707;
		public static const K5RT_TAMPER:int = 3708;
		public static const K5RT_BOLID_ONLINE:int = 3720;
		public static const K5RT_BOLID_FLTR_TYPE:int = 3721;
		public static const K5RT_BOLID_EVENT_MASK:int = 3722;
		public static const K5RT_BOLID_LINK:int = 3723;
		public static const K5RT_BOLID_OBJECT:int = 3724;
		public static const K5RT_BOLID_PROTOCOL_TYPE:int = 3725;
		
		
		public static const LAN_SERVER_CONNECT:int = 3750;
		public static const LAN_DHCP_SETTINGS:int = 3751;
		public static const LAN_SNMP_SETTINGS:int = 3752;
		public static const LAN_ICMP_ENABLE:int = 3753;
		public static const LAN_WEB_ENABLE:int = 3754;
		public static const LAN_PART:int = 3755;
		public static const LAN_ZONE:int = 3756;
		public static const LAN_SET_UP:int = 3757;
		public static const LAN_MAC:int = 3758;
		public static const LAN_SERVDIS_TIME:int = 3759;
		
		public static const K5_STOP_PANEL:int = 3799;
		
		public static const LR_RF_SYSTEM:int = 4000;
		public static const LR_DEVICE_ADD_TO_RF_SYSTEM:int = 4010;
		public static const LR_RF_STATE:int = 4011;
		public static const LR_DEVICE_DEL_FROM_RF_SYSTEM:int = 4012;
		public static const LR_DEVICE_RES_FROM_RF_SYSTEM:int = 4013;
		public static const LR_DEVICE_BREAK:int = 4014;
		public static const LR_DEVICE_LIST_RF_SYSTEM:int = 4020;
		public static const LR_GET_LOG:int = 4030;
		public static const LR_SEND_LOG:int = 4031;
		
		
		public static const SEKOP_ROUTE_GPPT:int = 62000;
		
		public static const DRW_M_USBH2:int = 63014;
		
		public static const ESP_POINT_RESET:int = 65420;
		public static const ESP_POINT_SETTINGS:int = 65421;
		public static const ESP_POINT_MANUFACTURE:int = 65422;
		public static const ESP_GET_POINT_CLIENTS:int = 65423;
		public static const ESP_POINT_CLIENT_LIST:int = 65424;
		public static const ESP_INFO:int = 65425;
		public static const ESP_GET_NET_LIST:int = 65426;
		public static const ESP_NET_LIST:int = 65427;
		public static const ESP_SET_NET:int = 65428;
		public static const ESP_GET_NET:int = 65429;
		public static const ESP_CONNECT_NET:int = 65430;
		
		public static const TELCO_CONTROL_LINE:int = 65475;
		
		public static const RF_CALIBR433_FREQ:int = 65480;
		
		public static const VPN_SERVER:int = 65440;
		public static const VPN_GET_TYPE_AUTH:int = 65441;
		public static const VPN_SET_TYPE_AUTH:int = 65442;
		public static const VPN_GROUP_ID:int = 65443;
		public static const VPN_USER_ID:int = 65444;
		public static const VPN_GET_INFO:int = 65445;
		
		public static const SET_ADDR_RS485:int = 65490;
		public static const SET_ADDR_DATA:int = 65491;
		
		public static const PROTOCOL_TYPE:int = 65495;
		public static const SET_VPN:int = 65496;
		public static const WIFI_GET_NET:int = 65497;
		public static const LTE_CONNECT_SELECT:int = 65498;
		public static const CONNECT_SERVER:int = 65499;
		public static const SET_NET:int = 65500;
		public static const GET_NET:int = 65501;
		
		public static const SET_OPENED_PORT:int = 65502;
		public static const SET_MAC_ADDR:int = 65503;
		public static const WIFI_POINT_SETTINGS:int = 65504; 
		public static const WIFI_POINT_CLIENT_LIST:int = 65505; 
		public static const WIFI_NETS_STORED:int = 65506;  
		public static const WIFI_NETS_CHANGE:int = 65507;
		public static const SET_SERVER:int = 65508;
		public static const GET_COUNT_WIFI_NETS:int = 65509;
		public static const WIFI_NETS_VISIBLE:int = 65510;
		public static const SETTINGS_WIFI_NETS:int = 65511;
		
		public static const GET_BUF_SIZE:int = 65513;
		public static const GET_MAX_IND_CMDS:int = 65514;
		
		public static const V15_LIST_DISK:int = 65518;
		public static const V15_FORMAT_DISK:int = 65519;
		
		public static const REBOOT:int = 65521;
		
		public static const START_UPDATE_FIRMWARE:int = 65524;
		public static const UPDATE_FIRMWARE_STATUS:int = 65525;
		public static const GET_UPDATE_FW_CHANEL:int = 65526;
		public static const BOOT_CRC32:int = 65527;
		public static const BOOT_WRITE:int = 65528;
		public static const BOOT_SER:int = 65530;
		public static const GPRS_ENCRYPTION:int = 3790;
		
		
		public static const OP_j_ENGIN_NUMB:int = 80001;
		public static const OP_E_USE_ENGIN_NUMB:int = 80002;
		public static const OP_o_OBJECT:int = 80003;
		public static const OP_FMR_MASTERKEY:int = 80004;
		public static const OP_AQ_GSM_SIGNAL:int = 80005;
		public static const OP_AN_AUTOTEST_COUNT:int = 80006;
		public static const OP_AH_AUTOTEST_HOURS:int = 80007;
		public static const OP_AM_AUTOTEST_MINUTES:int = 80008;
		public static const OP_AA_ADDITIONAL_AUTOTEST:int = 80009;
		public static const OP_PO_POWER:int = 80010;
		public static const OP_v_VER_INFO:int = 80011;
		public static const OP_r_HISTORY_EVENT_RESTART:int = 80012;
		public static const OP_GC_GPRS_NUM:int = 80013;
		public static const OP_GN_GPRS_APN:int = 80014;
		public static const OP_GU_GPRS_APN_USER:int = 80015;
		public static const OP_GP_GPRS_APN_PASS:int = 80016;
		public static const OP_GS_SERVER_ADR:int = 80017;
		public static const OP_GG_SERVER_PORT:int = 80018;
		public static const OP_GI_SERVER_PASS:int = 80019;
		public static const OP_GT_GRPS_TRY:int = 80020;
		public static const OP_P_GPRS_COMPR:int = 80021;
		public static const OP_z_ZONES:int = 80022;
		public static const OP_C_AKARM_KEY:int = 80023;
		public static const OP_GA_LINK_CHANNEL_ONLINE:int = 80024;
		public static const OP_D_LINK_CHANNEL:int = 80025;
		public static const OP_FP_HISTORY_INDEX:int = 80026;
		public static const OP_fer_HISTORY_RECORD:int = 80027;
		public static const OP_FH_HISTORY_RECORD:int = 80028;
		public static const OP_h_CH_TEL:int = 80029;
		public static const OP_AND_CH_COM_LINK:int = 80030;
		public static const OP_digt_TIME_DIGIT_CALL:int = 80031;
		public static const OP_DO_CH_DIRECTION_TYPE:int = 80032;
		public static const OP_sp_STOP_PANEL:int = 80033;
		
		public static const OP_T_WIRE_TYPE:int = 80034;
		public static const OP_CA_PARTITION_ALARM_COUNT:int = 80035;
		public static const OP_p_PARTITION:int = 80036;
		public static const OP_id_ID:int = 80037;
		public static const OP_SM_SMS:int = 80038;
		public static const OP_P2_IMEI:int = 80039;
		// Sensor
		public static const OP_ms_RDD1_ADDWIRE:int = 80040;
		public static const OP_BL_BOOTLOADER:int = 80041;
		public static const OP_BE_BOOTLOADER_ENGAGE:int = 80042;
		public static const OP_W_WRITE:int = 80043;
		public static const OP_pAVCP_LIMITS:int = 80044;
		public static const OP_pA_LIMIT:int = 80045;
		public static const OP_pV_LIMIT:int = 80046;
		public static const OP_pC_LIMIT:int = 80047;
		public static const OP_pP_LIMIT:int = 80048;
		public static const OP_un_BOOTLOADER_VER:int = 80049;
		
		// K1
		public static const OP_EE_FW_WRITE:int = 80050;
		
		public static const RUN_CMD_HASH:Object = {20:true,22:true, 74:true, 173:true, 65528:true};
		
		private static const RUN_SEPARATE:Object = {};//{710:true, 932:true};
		
		public static function isSeparate(v:int):Boolean
		{
			return RUN_SEPARATE[v];
		}
		public function getByProperty(p:String):int
		{
			return (this as Object)[p];
		}
	}
}