package components.abstract.servants
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.UTIL;

	public class VoyagerHistoryServant
	{
		public static const P_SIMPLE:int = 0;
		public static const P_LITLE_ENDIAN:int = 1;
		public static const P_BIG_ENDIAN:int = 2;
		public static const P_2:int = 3;
		public static const P_3:int = 4;
		public static const P_COORD:int = 5;
		public static const P_DATE:int = 6;
		public static const P_TIME:int = 7;
		public static const P_SPEED:int = 8;
		public static const P_U:int = 9;
		public static const P_CRC:int = 10;
		public static const P_SIGNED:int = 11;
		public static const P_INT_FIXED_1:int = 12;
		public static const P_INT_FIXED_2:int = 13;
		public static const P_INT_FIXED_4:int = 14;
		public static const P_SIGNED_INT2_FIXED_2:int = 15;
		public static const P_INTERVAL:int = 16;
		public static const P_ENGINE:int = 17;	//Остановлен/Заведен
		public static const P_THUMPER:int = 18;	//Закрыт/Открыт
		public static const P_AKB:int = 19;	//Норма/Разряжен
		public static const P_EXIST:int = 20;	//Нет/Есть
		//public static const P_MOVING:int = 210;
		public static const P_YESNO:int = 22;	//Нет/Да
		public static const P_DEBUG:int = 23;
		public static const P_BUTTON:int = 24;	//Не нажата/Нажата
//		public static const P_GERKON:int = 25;
		public static const P_ALARM:int = 26;	//Норма/Тревога
	//	public static const P_SWITCHONOFF:int = 27;
		public static const P_DIGIT_KEY:int = 27;
		public static const P_SWITCHOFF_ON:int = 28;	//Выключен/Включен
		public static const P_SWITCHOFF_ONSHE:int = 29;	//Выключена/Включена
		public static const P_SWITCHOFF_ONIT:int = 30;	//Выключено/Включено
		public static const P_GSM:int = 31;
		public static const P_WIFI:int = 32;
		public static const P_SIGNAL_NOTEXIST_EXIST:int = 33;	//Нет сигнала/Есть сигнал
		public static const P_ACC_ACCELERATION:int = 34;
		public static const P_SIGNED_INT_FIXED_2:int = 35;
		public static const P_FUEL_LEVEL_L:int = 36;
		public static const P_FUEL_LEVEL_P:int = 37;
		public static const P_FUEL:int = 38;
		public static const P_T_LIQUID_FREEZE:int = 39;
		public static const P_ENGINE_SPEED:int = 40;
		public static const P_INSTANT_FLOW:int = 41;
		public static const P_MOTOHOURS:int = 42;
		public static const P_TOTAL_MILAGE:int = 43;
		public static const P_TEMPERATURE:int = 44;
		public static const P_THUMPER_F:int = 45;	//Закрыта/Открыта
		public static const P_NORM_RESET:int = 46;	//Норма/Перезагрузка
		public static const P_GUARD:int = 47; // 0-Снят, 1-Взят
		public static const P_TMKEY:int = 48; // 0 - Нет, 1 - Считан
		public static const P_MAC:int = 49; // Mac addres
		public static const P_NAVI_RUN:int = 50;	// Навигационный пробег
		public static const P_MOTO_HOURS:int = 51;	// Моточасы
		public static const P_DOOR:int = 52;	// открыт / закрыт
		private static const P_FULL_NM:int = 53;
		private static const P_NOYES:int = 54;
		
		private static var HIS_PARAM:Vector.<Object>;
		public static var crcCalculation:Function;
		
		
		private static function initStaticParams():void
		{
			// header используется в составе истории, если нет хидера используется title
			//HIS_PARAM[15] = {byte:2, w:100, title:"U внешн.",header:"Напряжение питания (В)", print:P_U}; // Напряжение питания UUU.UU
			// title используется в названии таблички и на составе истории если нет header
			if (HIS_PARAM)
				return;
			
			HIS_PARAM = new Vector.<Object>(256);
			// область обязательных параметров
			HIS_PARAM[1] = {byte:1, w:0, title:"vhis_1", field:"ID_REC", print:P_SIMPLE};				
			HIS_PARAM[2] = {byte:1, w:100, title:"vhis_2", field:"TYPE", print:P_2};
			HIS_PARAM[3] = {byte:1, w:200, title:"vhis_3", field:"FLAG", print:P_3};
			HIS_PARAM[4] = {byte:4, w:100, fw:true,/** force width, при MISC.DEBUG_HISTORY_DIGITAL_VIEW == 1 все равн использовать стандартную w*/ title:"vhis_4", field:"Index", print:P_LITLE_ENDIAN}; // байта	Index	Уникальный 32-битный счетчик записи в историю, +1 для каждой новой.
			// облать байтовых параметров
			HIS_PARAM[5] = {byte:4, w:100, fw:true, title:"vhis_5", field:"Latitude", print:P_COORD, group:5};				
			HIS_PARAM[6] = {byte:4, w:100, fw:true, title:"vhis_6", field:"Longitude", print:P_COORD, group:5};				
			HIS_PARAM[7] = {byte:3, w:70, fw:true, title:"vhis_7", field:"Date", print:P_DATE, group:7};				
			HIS_PARAM[8] = {byte:3, w:70, fw:true, title:"vhis_8", field:"Time", print:P_TIME, group:7, func:adaptUTC};				
			HIS_PARAM[9] = {byte:4, w:90, title:"vhis_9", field:"Speed", print:P_SPEED};				
			HIS_PARAM[10] = {byte:1, w:55, title:"vhis_10", field:"Satellites", print:P_SIMPLE};				
			HIS_PARAM[11] = {byte:2, w:70, title:"vhis_11", field:"Altitude", print:P_SIGNED};				
			HIS_PARAM[12] = {byte:2, w:80, title:"vhis_12", field:"Angle", print:P_SIMPLE};				
			HIS_PARAM[13] = {byte:1, w:50, title:"vhis_13", field:"HDOP", print:P_INT_FIXED_1};				
			HIS_PARAM[14] = {byte:1, w:50, title:"vhis_14", field:"VDOP", print:P_INT_FIXED_1};
			
			HIS_PARAM[15] = {byte:2, w:140, title:"vhis_15", field:"U_power", print:P_U};
			HIS_PARAM[16] = {byte:2, w:130, title:"vhis_16", field:"U_bat", print:P_U};
			HIS_PARAM[17] = {byte:2, w:110, title:"vhis_17", field:"FUEL_S1", print:P_ENGINE_SPEED };
			HIS_PARAM[18] = {byte:1, w:130, title:"vhis_18", field:"FUEL_S1_T", print:P_TEMPERATURE};	
			HIS_PARAM[19] = {byte:2, w:110, title:"vhis_19", field:"FUEL_S2", print:P_ENGINE_SPEED};
			HIS_PARAM[20] = {byte:1, w:130, title:"vhis_20", field:"FUEL_S2_Т", print:P_TEMPERATURE};
			HIS_PARAM[21] = {byte:2, w:110, title:"vhis_21", field:"FUEL_S3", print:P_ENGINE_SPEED};
			HIS_PARAM[22] = {byte:1, w:130, title:"vhis_22", field:"FUEL_S3_T", print:P_TEMPERATURE};
			HIS_PARAM[23] = {byte:2, w:110, title:"vhis_23", field:"FUEL_S4", print:P_ENGINE_SPEED};
			HIS_PARAM[24] = {byte:1, w:130, title:"vhis_24", field:"FUEL_S4_T", print:P_TEMPERATURE};
			HIS_PARAM[25] = {byte:1, w:130, title:"vhis_25", field:"TEMP_CPU", print:P_TEMPERATURE};
			HIS_PARAM[26] = {byte:1, w:140, title:"vhis_26", field:"TEMP1_W", print:P_TEMPERATURE};
			HIS_PARAM[27] = {byte:2, w:130, title:"vhis_27", field:"FUEL_R1", print:P_SIMPLE};	
			HIS_PARAM[28] = {byte:2, w:130, title:"vhis_28", field:"FUEL_R2", print:P_SIMPLE};
			HIS_PARAM[29] = {byte:2, w:120, title:"vhis_29", header:"vhis_header_29", field:"FUEL_F1", print:P_SIMPLE};	
			HIS_PARAM[30] = {byte:2, w:120, title:"vhis_30", header:"vhis_header_30", field:"FUEL_F2", print:P_SIMPLE};
			HIS_PARAM[31] = {byte:2, w:120, title:"vhis_31", header:"vhis_header_31", field:"FUEL_A1", print:P_SIMPLE};	
			HIS_PARAM[32] = {byte:2, w:120, title:"vhis_32", header:"vhis_header_32", field:"FUEL_A2", print:P_SIMPLE};
			HIS_PARAM[33] = {byte:1, w:170, title:"vhis_33", field:"LEVEL_GSM", print:P_GSM};
			HIS_PARAM[34] = {byte:1, w:170, title:"vhis_34", field:"LEVEL_WIFI", print:P_WIFI};
			HIS_PARAM[35] = {byte:2, w:60, title:"vhis_35", header:"vhis_header_35", field:"ACC_X", print:P_SIGNED_INT_FIXED_2, group:35};
			HIS_PARAM[36] = {byte:2, w:60, title:"vhis_36", field:"ACC_Y", print:P_SIGNED_INT_FIXED_2, group:35};
			HIS_PARAM[37] = {byte:2, w:60, title:"vhis_37", field:"ACC_Z", print:P_SIGNED_INT_FIXED_2, group:35};
			HIS_PARAM[38] = {byte:2, w:60, title:"vhis_38", field:"ACC_V", print:P_SIGNED_INT_FIXED_2, group:35};
			HIS_PARAM[39] = {byte:2, w:60, title:"vhis_39", field:"ACC_VS", print:P_SIGNED_INT_FIXED_2, group:35};
			HIS_PARAM[40] = {byte:2, w:60, title:"vhis_40", field:"TANGAGE", print:P_SIGNED, group:35};
			HIS_PARAM[41] = {byte:2, w:60, title:"vhis_41", field:"ROLL", print:P_SIGNED, group:35};
			
			HIS_PARAM[42] = {byte:6, w:130, title:"vhis_42", field:"TM_KEY", print:P_DIGIT_KEY};// 	8 байт по 2, ACC_X, ACC_Y, ACC_Z, ACC_V
			HIS_PARAM[43] = {byte:1, w:60, title:"vhis_43", field:"Engine_block", print:P_LITLE_ENDIAN};
		/*		HIS_PARAM[44] = {byte:1, w:60, title:"Пересечение граней", field:"EDGE", print:P_BITFIELD_1TO8};*/
			HIS_PARAM[45] = {byte:6, w:135, title:"vhis_45", field:"MAC", print:P_MAC};
			HIS_PARAM[46] = {byte:2, w:60, title:"vhis_46", field:"BS_MCC", print:P_LITLE_ENDIAN, header:"vhis_header_46", group:46};
			HIS_PARAM[47] = {byte:2, w:60, title:"vhis_47", field:"BS_MNC", print:P_LITLE_ENDIAN, group:46};
			HIS_PARAM[48] = {byte:4, w:60, title:"vhis_48", field:"BS_CELLID", print:P_LITLE_ENDIAN, group:46};
			HIS_PARAM[49] = {byte:2, w:60, title:"vhis_49", field:"BS_LAC", print:P_LITLE_ENDIAN, group:46};
			HIS_PARAM[50] = {byte:2, w:60, title:"vhis_50", field:"BS_RXL", print:P_LITLE_ENDIAN, group:46};
			
			HIS_PARAM[51] = {byte:4, w:160, title:"vhis_51", field:"NAV_MILEAGE", print:P_NAVI_RUN};
			HIS_PARAM[52] = {byte:4, w:160, title:"vhis_52", field:"NAV_HOURS", print:P_MOTO_HOURS};
			HIS_PARAM[53] = {byte:2, w:90, title:"vhis_53", field:"FUEL_S5", print:P_LITLE_ENDIAN};
			HIS_PARAM[54] = {byte:1, w:110, title:"vhis_54", field:"FUEL_S5_T", print:P_TEMPERATURE};
			HIS_PARAM[55] = {byte:1, w:110, title:"vhis_55", field:"PDOP", print:P_INT_FIXED_1};
			/// invisible: false - открываем эти пункты для состава истории
			HIS_PARAM[60] = {byte:4, w:110, title:"vhis_60", field:"CN100", print:P_SIMPLE, invisible:false};
			HIS_PARAM[61] = {byte:4, w:110, title:"vhis_61", field:"CN101", print:P_SIMPLE, invisible:false};
			HIS_PARAM[62] = {byte:4, w:110, title:"vhis_62", field:"CN102", print:P_SIMPLE, invisible:false};
			HIS_PARAM[63] = {byte:1, w:110, title:"vhis_63", field:"SMS_COUNT", print: P_SIMPLE };
			
			/// ПАССАЖИРОПОТОК
			HIS_PARAM[64] = {byte:2, w:70, title:"can_doors", field:"DOORS_EN", print: P_SIMPLE, invisible:false };
			HIS_PARAM[65] = {byte:2, w:70, title:"state_doors", field:"DOORS_TS", print: P_SIMPLE, invisible:false };
			HIS_PARAM[66] = {byte:4, w:70, title:"reader_door1", field:"DOORS1_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[67] = {byte:4, w:70, title:"reader_door2", field:"DOORS2_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[68] = {byte:4, w:70, title:"reader_door3", field:"DOORS3_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[69] = {byte:4, w:70, title:"reader_door4", field:"DOORS4_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[70] = {byte:4, w:70, title:"reader_door5", field:"DOORS5_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[71] = {byte:4, w:70, title:"reader_door6", field:"DOORS6_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[72] = {byte:4, w:70, title:"reader_door7", field:"DOORS7_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[73] = {byte:4, w:70, title:"reader_door8", field:"DOORS8_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[74] = {byte:4, w:70, title:"reader_door9", field:"DOORS9_CNT", print: P_FULL_NM, invisible:false };
			HIS_PARAM[75] = {byte:4, w:70, title:"reader_door10", field:"DOORS10_CNT", print: P_FULL_NM, invisible:false };
			
			/// Датчики угла наклона
			HIS_PARAM[76] = {byte:2, w:70, title:"tilt_angle_sensor1", field:"SENS_ANG_1"};//, header: "tilt_angle_sensor1" };
			HIS_PARAM[77] = {byte:2, w:70, title:"tilt_angle_sensor2", field:"SENS_ANG_2"};//, header: "tilt_angle_sensor2" };
			HIS_PARAM[78] = {byte:2, w:70, title:"tilt_angle_sensor3", field:"SENS_ANG_3"};//, header: "tilt_angle_sensor3" };
			HIS_PARAM[79] = {byte:2, w:70, title:"tilt_angle_sensor4", field:"SENS_ANG_4"};//, header: "tilt_angle_sensor4" };
			
		
			// CAN ПАРАМЕТРЫ БИТОВЫЕ	
			HIS_PARAM[103] = {byte:2, w:110, title:"vhis_103", field:"CAN_FUEL_L", print:P_FUEL_LEVEL_L};		
			HIS_PARAM[104] = {byte:1, w:110, title:"vhis_104", field:"CAN_FUEL_P", print:P_FUEL_LEVEL_P};		
			HIS_PARAM[105] = {byte:4, w:140, title:"vhis_105", field:"CAN_FUEL", print:P_FUEL};		
			HIS_PARAM[106] = {byte:2, w:120, title:"vhis_106", field:"TEMP_AF", print:P_T_LIQUID_FREEZE};	
			HIS_PARAM[107] = {byte:2, w:155, title:"vhis_107", field:"RPM", print:P_ENGINE_SPEED};	
			HIS_PARAM[108] = {byte:2, w:140, title:"vhis_108", field:"IFC", print:P_INSTANT_FLOW};	
			HIS_PARAM[109] = {byte:4, w:70, title:"vhis_109", field:"HOURS", print:P_MOTOHOURS};	
			HIS_PARAM[110] = {byte:4, w:100, title:"vhis_110", field:"MILEAGE", print:P_TOTAL_MILAGE};				
			HIS_PARAM[111] = {byte:4, w:100, title:"vhis_111", field:"UP_SERVICE", print:P_TOTAL_MILAGE};
			
													
			HIS_PARAM[112] = {byte:1, bit:112, w:130, title:"vhis_112", field:"DOOR_FL", print:P_THUMPER_F};
			HIS_PARAM[113] = {byte:1, bit:112, w:130, title:"vhis_113", field:"DOOR_FR", print:P_THUMPER_F};	
			HIS_PARAM[114] = {byte:1, bit:112, w:130, title:"vhis_114", field:"DOOR_BR", print:P_THUMPER_F};
			HIS_PARAM[115] = {byte:1, bit:112, w:130, title:"vhis_115", field:"DOOR_BL", print:P_THUMPER_F};
			HIS_PARAM[116] = {byte:1, bit:112, w:60, title:"vhis_116", field:"HOOD", print:P_THUMPER};
			HIS_PARAM[117] = {byte:1, bit:112, w:60, title:"vhis_117", field:"TRUNK", print:P_THUMPER};	
			HIS_PARAM[118] = {byte:1, bit:112, w:140, title:"vhis_118", field:"GUARD", print:P_GUARD};
			HIS_PARAM[119] = {byte:1, bit:112, w:140, title:"vhis_119", field:"ALARM", print:P_ALARM};
			
			HIS_PARAM[120] = {byte:1, bit:120, w:120, title:"vhis_120", field:"AT_D", print:P_EXIST};	
			HIS_PARAM[121] = {byte:1, bit:120, w:120, title:"vhis_121", field:"AT_R", print:P_EXIST};
			HIS_PARAM[122] = {byte:1, bit:120, w:120, title:"vhis_122", field:"AT_N", print:P_EXIST};
			HIS_PARAM[123] = {byte:1, bit:120, w:120, title:"vhis_123", field:"AT_P", print:P_EXIST};	
			HIS_PARAM[124] = {byte:1, bit:120, w:100, title:"vhis_124", field:"BRAKE", print:P_EXIST};
			HIS_PARAM[125] = {byte:1, bit:120, w:110, title:"vhis_125", field:"BRAKE_P", print:P_EXIST};
			HIS_PARAM[126] = {byte:1, bit:120, w:130, title:"vhis_126", field:"CAR_MOVE", print:P_EXIST};
			HIS_PARAM[127] = {byte:1, bit:120, w:100, title:"vhis_127", field:"MODE_W", print:P_EXIST};
			
			HIS_PARAM[128] = {byte:1, bit:128, w:140, title:"vhis_128", field:"IGN_KEY", print:P_EXIST};	
			HIS_PARAM[129] = {byte:1, bit:128, w:70, title:"vhis_129", field:"ACCESSORY", print:P_EXIST};		
			HIS_PARAM[130] = {byte:1, bit:128, w:100, title:"vhis_130", field:"IGNITION", print:P_EXIST};	
			HIS_PARAM[131] = {byte:1, bit:128, w:140, title:"vhis_131", field:"ENGINE_ST", print:P_EXIST};		
			HIS_PARAM[132] = {byte:1, bit:128, w:110, title:"vhis_132", field:"LIGHTS_M", print:P_EXIST};		
			HIS_PARAM[133] = {byte:1, bit:128, w:90, title:"vhis_133", field:"DIPPED", print:P_EXIST};	
			HIS_PARAM[134] = {byte:1, bit:128, w:90, title:"vhis_134", field:"BEAM", print:P_EXIST};	
			HIS_PARAM[135] = {byte:1, bit:128, w:120, title:"vhis_135", field:"SEAT_BELT", print:P_EXIST};	

			HIS_PARAM[136] = {byte:1, bit:136, w:160, title:"vhis_136", field:"WIPER", print:P_SWITCHOFF_ON};	
			HIS_PARAM[137] = {byte:1, bit:136, w:160, title:"vhis_137", field:"TURN_LEFT", print:P_SWITCHOFF_ON};
			HIS_PARAM[138] = {byte:1, bit:136, w:160, title:"vhis_138", field:"TURN_RIGHT", print:P_SWITCHOFF_ON};
			HIS_PARAM[139] = {byte:1, bit:136, w:60, title:"vhis_139", field:"LOCK", print:P_DOOR};	// 
			HIS_PARAM[140] = {byte:1, bit:136, w:60, title:"", field:"", print:P_EXIST};	// 
			HIS_PARAM[141] = {byte:1, bit:136, w:60, title:"", field:"", print:P_EXIST};	// 
			HIS_PARAM[142] = {byte:1, bit:136, w:60, title:"", field:"", print:P_EXIST};	// 
			HIS_PARAM[143] = {byte:1, bit:136, w:60, title:"", field:"", print:P_EXIST};	// 
			
			HIS_PARAM[176] = {byte:1, bit:176, w:60, title:"vhis_176", field:"GSM_Jamming", print:P_EXIST};	// 0-Нет, 1-Да	
			HIS_PARAM[177] = {byte:1, bit:176, w:60, title:"vhis_177", field:"SMS_ERROR", print:P_EXIST};	// 
			HIS_PARAM[178] = {byte:1, bit:176, w:60, title:"vhis_178", field:"GPS_FIX", print:P_EXIST};	// 
			HIS_PARAM[179] = {byte:1, bit:176, w:60, title:"vhis_179", field:"TEMP1_HI", print:P_EXIST};	// 
			HIS_PARAM[180] = {byte:1, bit:176, w:60, title:"vhis_180", field:"TEMP1_LO", print:P_EXIST};	// 
			HIS_PARAM[181] = {byte:1, bit:176, w:60, title:"", field:"", print:P_EXIST};	// 
			HIS_PARAM[182] = {byte:1, bit:176, w:60, title:"", field:"", print:P_EXIST};	// 
			HIS_PARAM[183] = {byte:1, bit:176, w:60, title:"", field:"", print:P_EXIST};	//
			
			// область битовых параметров
			HIS_PARAM[184] = {byte:1, bit:184, w:60, title:"", field:"", print:P_EXIST};
			HIS_PARAM[185] = {byte:1, bit:184, w:60, title:"vhis_185", field:"SM", print:P_EXIST};
			HIS_PARAM[186] = {byte:1, bit:184, w:60, title:"vhis_186", field:"SA", print:P_ALARM, group:35};
			HIS_PARAM[187] = {byte:1, bit:184, w:60, title:"vhis_187", field:"SI", print:P_ALARM, group:35};
			HIS_PARAM[188] = {byte:1, bit:184, w:60, title:"vhis_188", field:"SS", print:P_ALARM};
			HIS_PARAM[189] = {byte:1, bit:184, w:60, title:"vhis_189", field:"SC", print:P_ALARM, group:35};
			HIS_PARAM[190] = {byte:1, bit:184, w:90, title:"vhis_190", field:"ST", print:P_ALARM, group:35};
			HIS_PARAM[191] = {byte:1, bit:184, w:60, title:"vhis_191", field:"SR", print:P_ALARM, group:35};
			
			HIS_PARAM[192] = {byte:1, bit:192, w:50, title:"vhis_192", field:"Test", print:P_YESNO};
			HIS_PARAM[193] = {byte:1, bit:192, w:60, title:"vhis_193", field:"Alarm", print:P_ALARM};
			HIS_PARAM[194] = {byte:1, bit:192, w:70, title:"vhis_194", field:"Traffic", print:P_EXIST};
			HIS_PARAM[195] = {byte:1, bit:192, w:60, title:"vhis_195", field:"Int_bat", print:P_AKB};
			HIS_PARAM[196] = {byte:1, bit:192, w:100, title:"vhis_196", header:"vhis_header_196", field:"Config", print:P_YESNO};
			HIS_PARAM[197] = {byte:1, bit:192, w:100, title:"vhis_197", field:"PROG", print:P_YESNO};
			HIS_PARAM[198] = {byte:1, bit:192, w:90, title:"vhis_198", field:"Tamper", print:P_THUMPER};
			HIS_PARAM[199] = {byte:1, bit:192, w:90, title:"vhis_199", field:"3DFix", print:P_YESNO};
			
			HIS_PARAM[200] = {byte:1, bit:200, w:60, title:"vhis_200", field:"Call1", print:P_BUTTON};
			HIS_PARAM[201] = {byte:1, bit:200, w:60, title:"vhis_201", field:"Call2", print:P_BUTTON};
			HIS_PARAM[202] = {byte:1, bit:200, w:60, title:"vhis_202", field:"Call3", print:P_BUTTON};
			HIS_PARAM[203] = {byte:1, bit:200, w:60, title:"", field:"", print:P_YESNO};
			HIS_PARAM[204] = {byte:1, bit:200, w:60, title:"", field:"", print:P_YESNO};
			HIS_PARAM[205] = {byte:1, bit:200, w:60, title:"", field:"", print:P_YESNO};
			HIS_PARAM[206] = {byte:1, bit:200, w:60, title:"vhis_206", header:"vhis_header_206", field:"RegGSM", print:P_EXIST};
			HIS_PARAM[207] = {byte:1, bit:200, w:60, title:"extender", field:"NoLinkExt", print:P_NOYES};
			
			HIS_PARAM[208] = {byte:1, bit:208, w:100, title:"vhis_208", header:"vhis_header_208", field:"Engine", print:P_ENGINE};
			HIS_PARAM[209] = {byte:1, bit:208, w:90, title:"vhis_209", header:"vhis_header_209", field:"Ext_bat", print:P_AKB};
			HIS_PARAM[210] = {byte:1, bit:208, w:100, title:"vhis_210",header:"vhis_header_210", field:"Power", print:P_EXIST};
			HIS_PARAM[211] = {byte:1, bit:208, w:90, title:"vhis_211", field:"Ignition", print:P_SWITCHOFF_ONIT};
			HIS_PARAM[212] = {byte:1, bit:208, w:60, title:"vhis_212", field:"Charge", print:P_SWITCHOFF_ON};
			HIS_PARAM[213] = {byte:1, bit:208, w:80, title:"vhis_213", field:"Reset", print:P_NORM_RESET};
			HIS_PARAM[214] = {byte:1, bit:208, w:70, title:"vhis_214", header:"vhis_header_214", field:"Nav_PWR", print:P_SWITCHOFF_ONSHE};
			HIS_PARAM[215] = {byte:1, bit:208, w:70, title:"vhis_215", header:"vhis_header_215", field:"Link_PWR", print:P_SWITCHOFF_ON};
			
			HIS_PARAM[216] = {byte:1, bit:216, w:120, title:"vhis_216", field:"ReedSwitch", print:P_ALARM};
			HIS_PARAM[217] = {byte:1, bit:216, w:120, title:"vhis_217", field:"ExtMagnetic", print:P_ALARM};
			HIS_PARAM[218] = {byte:1, bit:216, w:120, title:"vhis_218", field:"ReedSwitch Ext", print:P_ALARM}; 
			HIS_PARAM[219] = {byte:1, bit:216, w:100, title:"vhis_219", field:"MasterCode", print:P_YESNO};
			HIS_PARAM[220] = {byte:1, bit:216, w:60, title:"vhis_220", field:"NEW_BS", print:P_YESNO};
			HIS_PARAM[221] = {byte:1, bit:216, w:60, title:"vhis_221", field:"Hold_Connection", print:P_YESNO};
			HIS_PARAM[222] = {byte:1, bit:216, w:60, title:"vhis_222", field:"Tracking_mode", print:P_SWITCHOFF_ON};
			HIS_PARAM[223] = {byte:1, bit:216, w:80, title:"vhis_223", field:"Key_TM", print:P_TMKEY};
			
			HIS_PARAM[224] = {byte:1, bit:224, w:90, title:"vhis_224", header:"vhis_header_224", field:"DIN1", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[225] = {byte:1, bit:224, w:90, title:"vhis_225", header:"vhis_header_225", field:"DIN2", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[226] = {byte:1, bit:224, w:90, title:"vhis_226", header:"vhis_header_226", field:"DIN3", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[227] = {byte:1, bit:224, w:90, title:"vhis_227", header:"vhis_header_227", field:"DIN4", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[228] = {byte:1, bit:224, w:90, title:"vhis_228", header:"vhis_header_228", field:"DIN5", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[229] = {byte:1, bit:224, w:90, title:"vhis_229", header:"vhis_header_229", field:"DIN6", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[230] = {byte:1, bit:224, w:90, title:"vhis_230", header:"vhis_header_230", field:"DIN7", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[231] = {byte:1, bit:224, w:90, title:"vhis_231", header:"vhis_header_231", field:"DIN8", print:P_SIGNAL_NOTEXIST_EXIST};
			
			HIS_PARAM[232] = {byte:1, bit:232, w:90, title:"vhis_232", header:"vhis_header_232", field:"DIN9", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[233] = {byte:1, bit:232, w:90, title:"vhis_233", header:"vhis_header_233", field:"DIN10", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[234] = {byte:1, bit:232, w:90, title:"vhis_234", header:"vhis_header_234", field:"DIN11", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[235] = {byte:1, bit:232, w:90, title:"vhis_235", header:"vhis_header_235", field:"DIN12", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[236] = {byte:1, bit:232, w:90, title:"vhis_236", header:"vhis_header_236", field:"DIN13", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[237] = {byte:1, bit:232, w:90, title:"vhis_237", header:"vhis_header_237", field:"DIN14", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[238] = {byte:1, bit:232, w:90, title:"vhis_238", header:"vhis_header_238", field:"DIN15", print:P_SIGNAL_NOTEXIST_EXIST};
			HIS_PARAM[239] = {byte:1, bit:232, w:90, title:"vhis_239", header:"vhis_header_239", field:"DIN16", print:P_SIGNAL_NOTEXIST_EXIST};
			
			HIS_PARAM[240] = {byte:1, bit:240, w:90, title:"vhis_240", header:"vhis_header_240", field:"OUT1", print:P_SWITCHOFF_ON};	// 	Дискретный выход 1-8
			HIS_PARAM[241] = {byte:1, bit:240, w:90, title:"vhis_241", header:"vhis_header_241", field:"OUT2", print:P_SWITCHOFF_ON};
			HIS_PARAM[242] = {byte:1, bit:240, w:90, title:"vhis_242", header:"vhis_header_242", field:"OUT3", print:P_SWITCHOFF_ON};
			HIS_PARAM[243] = {byte:1, bit:240, w:90, title:"vhis_243", header:"vhis_header_243", field:"OUT4", print:P_SWITCHOFF_ON};
			HIS_PARAM[244] = {byte:1, bit:240, w:90, title:"vhis_244", header:"vhis_header_244", field:"OUT5", print:P_SWITCHOFF_ON};
			HIS_PARAM[245] = {byte:1, bit:240, w:90, title:"vhis_245", header:"vhis_header_245", field:"OUT6", print:P_SWITCHOFF_ON};
			HIS_PARAM[246] = {byte:1, bit:240, w:90, title:"vhis_246", header:"vhis_header_246", field:"OUT7", print:P_SWITCHOFF_ON};
			HIS_PARAM[247] = {byte:1, bit:240, w:90, title:"vhis_247", header:"vhis_header_247", field:"OUT8", print:P_SWITCHOFF_ON};
			
			// Область отладночных параметров
			HIS_PARAM[248] = {byte:4, w:90, title:"DEBUG 1", field:"DEBUG 1", print:P_DEBUG};
			HIS_PARAM[249] = {byte:4, w:90, title:"DEBUG 2", field:"DEBUG 2", print:P_DEBUG};
			HIS_PARAM[250] = {byte:4, w:90, title:"DEBUG 3", field:"DEBUG 3", print:P_DEBUG};
			HIS_PARAM[251] = {byte:4, w:90, title:"DEBUG 4", field:"DEBUG 4", print:P_DEBUG};
			HIS_PARAM[252] = {byte:4, w:90, title:"DEBUG 5", field:"DEBUG 5", print:P_DEBUG};
			HIS_PARAM[253] = {byte:4, w:90, title:"DEBUG 6", field:"DEBUG 6", print:P_DEBUG};
			HIS_PARAM[254] = {byte:4, w:90, title:"DEBUG 7", field:"DEBUG 7", print:P_DEBUG};
			// Контрольная сумма
			HIS_PARAM[255] = {byte:2, w:90, title:"vhis_255", header:"vhis_header_255", field:"CRC", print:P_CRC};//CRC16	КС	Контрольная сумма
		}
		public static function get PARAMS():Vector.<Object>
		{
			if (!HIS_PARAM)
				initStaticParams();
			return HIS_PARAM;
		}
		public static function isCanParam(s:String):Boolean
		{
			var len:int = PARAMS.length;
			for (var i:int=0; i<len; i++) {
				if( HIS_PARAM[i] is Object && HIS_PARAM[i].title == s && i > 63 && i < 144 )
					return true;
			}
			return false;
		}
		public static function dformat(value:Array, param:int, bitnum:int):String
		{
			var hash:Object;
			var txt:String;
			var target:int;
			
			target = toLitleEndian(value) & (1 << bitnum);
			if (target == 0)
				return "0";
			return "1";
		}
		public static function format(value:Array, param:int, bitnum:int):String
		{
			var hash:Object;
			var txt:String;
			var target:int;
			var cycles:int;
			try {
				switch(param) {
					case P_SIMPLE:	//ID записи	Используется для идентификации списка параметров ( номер структуры HISTORY_SELECT_PAR
						return toLitleEndian(value).toString();
					case P_LITLE_ENDIAN:
						return toLitleEndian(value).toString();
					case P_2:	//Тип записи	1 - по времени, 2 - по смещению, 3 - по событию
						if (value[0] < 5) {
							hash = [loc("g_no"),loc("his_by_time"),loc("his_by_shift"),loc("his_by_event"),loc("his_no_move")];
							//hash = ["Нет","По времени","По смещению","По событию","Нет движения"];
							
							return hash[value[0]].toString();
						}
						return value[0].toString();
					case P_3:	//Передача	Факт передачи записи, 0xFF-не передано, 0x33-передано
						// Флаг передачи записи, 0xFF-не передано, 0x33-передано, пересчет контрольной суммы при установке флага 0x33 не производится.
						// Для приборов с ЕГТС, при успешной передаче записи на сервер Ритм, биты 7 и 3 устанавливаются в 0, при успешной передаче на сервер ЕГТС, биты 6 и 2 устанавливаются в 0.
						if (OPERATOR.dataModel.getData(CMD.CONNECT_SERVER).length > 2)
							hash = {0xff:loc("his_not_transfered"), 0x33:loc("his_transfered_egts_ritm"), 0x77:loc("his_transfered_ritm"), 0xBB:loc("his_transfered_egts")};
						else
							hash = {0xff:loc("his_not_transfered"), 0x33:loc("his_transfered")};
						txt = "";
						if (MISC.COPY_DEBUG)
							txt = "0x"+int(value[0]).toString(16) + " ";
						return txt + hash[value[0]].toString();
					case P_COORD:	// Широта	Для южного полушария добавляется "-", формат ddmmmmmmm (координаты) | Долгота	Для западного полушария добавляется "-", формат dddmm.mmmmm (координаты)
						//Старший бит == 1 значит минус
						
						target = toLitleEndian(value);
						var minus:String = "";
						if( (value[3] & (0xf << 7)) > 0 ) {
							target = target & 0x7FFFFFFF;
							minus = "-";
						}
						var del:Number = 10000000;
						var coord:Number = target/del;
						var min:Number = (coord - Math.floor(coord))*100/60;
						txt = Math.floor(coord) + "." + zerosAfter( min.toString().slice( 2,8 ),6);
						return minus+txt;
					case P_DATE:	//Дата	Дата фиксации точки (BCD) ddmmyy ( сгруппировано в дата/время )
						txt = UTIL.formateZerosInFront( int(value[2]).toString(16),2) +"."+
						UTIL.formateZerosInFront( int(value[1]).toString(16),2) +"."+
						UTIL.formateZerosInFront( int(value[0]).toString(16),2);
						if( txt.search( RegExpCollection.COMPLETE_DDdotMMdotYY ) != 0 )
							txt = loc("g_not_valid");
						return txt;
					case P_TIME:	//Время	Время фиксации точки (BCD) hhmmss ( сгруппировано в дата/время )
						txt = UTIL.formateZerosInFront( int(value[2]).toString(16),2) +":"+
						UTIL.formateZerosInFront( int(value[1]).toString(16),2) +":"+
						UTIL.formateZerosInFront( int(value[0]).toString(16),2);
						if( txt.search( RegExpCollection.COMPLETE_HHcolonMMcolonSS ) != 0 )
							txt = loc("g_not_valid");
						return txt;
					case P_SPEED:	//Скорость	Скорость объекта, в узлах v.vvv ( верхний уровень переводит в км/ч )
						return (toLitleEndian( value )/1000*1.852).toFixed(3);
					case P_INT_FIXED_1:	//HDOP	Cнижение точности в горизонтальной плоскости hh.h (0.00-25.5) VDOP	Cнижение точности в вертикальной плоскости vv.v (0.00-25.5)
						return (toLitleEndian(value)/10).toFixed(1);
					case P_U:	//	Напряжение питания UU.U (код 0 - 5В и меньше, код 255 - 30,5В )
						target = toLitleEndian(value);
						txt = (target/100).toFixed(2);
						return txt;
					case P_ACC_ACCELERATION:
						txt = "";
						cycles = 10;
						for (target=0; target<cycles; target+=2) {
							txt += toSignedLitleEndian(value.slice(target,target+2));
							if (target < (cycles-2) )
								txt+="  ";
						}
						return txt;
					case P_DIGIT_KEY:
						//	48-бит цифровой ключ, (0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF) - нет приложенного ключа,
						//(0x00,0x00,0x00,0x00,0x00,0x00)- короткое замыкание шины, иначе, код ключа
						txt = "";
						var temp:String;
						cycles = value.length;
						for (target=0; target<cycles; target++) {
							temp = (value[target] as int).toString(16).toUpperCase();
							if (temp.length < 2)
								temp = "0"+temp;
							txt += temp;
							if (target < (cycles-1))
								txt+=" ";
						}
						return txt;
						break;
					case P_SIGNED_INT_FIXED_2:
						txt = String(int(toSignedLitleEndian(value))/100);
						return txt;
					case P_CRC:	//CRC16	КС	Контрольная сумма
						// Просчет CRC надо отдавать управляющему компоненту, для этого в нем надо передать функцию просчета
						if (crcCalculation != null)
							return crcCalculation( toLitleEndian( value ) );
						return loc("g_yes");
					case P_SIGNED:	//	Знаковое число
						return toSignedLitleEndian(value);//toSignedBigEndian(value);
					case P_INT_FIXED_2:
						return  (toLitleEndian(value)/100).toFixed(2);
					case P_INT_FIXED_4:
						return  (toLitleEndian(value)/10000).toFixed(4);
					case P_INTERVAL:
						return  (toLitleEndian(value)/10000).toFixed(1);
					case P_MAC:
						if (value.length == 6) {
							txt ="";
							var len:int = value.length;
							for (var i:int=0; i<len; i++) {
								txt += UTIL.fz(int(value[i]).toString(16),2).toUpperCase();
								if (i!=len-1)
									txt += "-";
							}
						} else
							txt = "#error.MAC"
						return txt;
					case P_MOTO_HOURS:
						return Number(toLitleEndian(value)/3600).toFixed(1);
					case P_NAVI_RUN:
						return Number(toLitleEndian(value)/1000).toFixed(1);
					case P_GSM:
						txt = toSignedLitleEndian(value);
						if (int(txt) == -128)
							txt = loc("g_no_net_registration");
						return txt;
					case P_WIFI:
						txt = toSignedLitleEndian(value);
						if (int(txt) == -128)
							txt = loc("g_no_connection");
						return txt;
					case P_ENGINE:	//0-двигатель не заведен, 1-Двигатель заведен
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_engine_stopped");
							default:
								return loc("his_engine_started");
						}
					case P_THUMPER:	// 0-в норме, прибор закрыт, 1-вскрытие
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_closed");
							default:
								return loc("his_opened");
						}
					case P_DOOR:	// 0-открыт, 1-закрыт
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_opened");
							default:
								return loc("his_closed");
						}
					case P_AKB:		// Настраивается, 0- в норме, 1-разряд
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_norm");
							default:
								return loc("his_depleted");
						}
					case P_YESNO:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("g_no");
							default:
								return loc("g_yes");
						}
					case P_NOYES:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("g_yes");
							default:
								return loc("g_no");
						}
					case P_EXIST:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("g_no");
							default:
								return loc("his_exist");
						}
					case P_BUTTON:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_not_pressed");
							default:
								return loc("his_pressed");
						}
					case P_ALARM:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_norm");
							default:
								return loc("his_alarm");
						}
					case P_SWITCHOFF_ON:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_disabled");
								
							default:
								return loc("his_enabled");
						}
					case P_SWITCHOFF_ONSHE:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_disabled_f");
								
							default:
								return loc("his_enabled_f");
						}
					case P_SWITCHOFF_ONIT:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_disabled_n");
								
							default:
								return loc("his_enabled_n");
						}
					case P_SIGNAL_NOTEXIST_EXIST:	//	0-нет, 1-да
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_no_signal");
								
							default:
								return loc("his_signal_exist");
						}
					case P_THUMPER_F:	//	0-закрыта, 1-открыта
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_closed_f");
							default:
								return loc("his_opened_f");
						}
					case P_NORM_RESET:
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_norm");
							default:
								return loc("his_reload");
						}
					case P_GUARD:
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("his_taken_off");
							default:
								return loc("his_taken_on");
						}
					case P_TMKEY:
						target = toLitleEndian(value) & (1 << bitnum);
						switch(target) {
							case 0:
								return loc("g_no");
							default:
								return loc("his_key_read");
						}
					case P_INSTANT_FLOW:
						target = toLitleEndian(value);	
						if (uint(target & 0xFFFF) == 0x8000)
							return loc("his_not_available");
						return (target/100).toString();
					case P_FUEL:
						target = toLitleEndian(value);	
						if (uint(target & 0xFFFFFFFF) == 0x80000000)
							return loc("his_not_available");
						return target.toString();
					case P_FUEL_LEVEL_L:
						target = toLitleEndian(value);	
						if (uint(target & 0xFFFF) == 0x8000)
							return loc("his_not_available");
						return target.toString();
					case P_FULL_NM:
						target = toLitleEndian(value);	
						if (uint(target & 0xFFFF) == 0xFFFF)
							return loc("his_not_available");
						return target.toString();
					case P_FUEL_LEVEL_P:
						target = toLitleEndian(value);	
						if (uint(target & 0xFF) == 0x80)
							return loc("his_not_available");
						return target.toString();	
					case P_T_LIQUID_FREEZE:
						target = int(toSignedLitleEndian(value));	
						if (int(target & 0xFFFF) == 0x8000)
							return loc("his_not_available");
						return target.toString();	
					case P_ENGINE_SPEED:
						target = toLitleEndian(value);	
						if (uint(target & 0xFFFF) == 0x8000)
							return loc("his_not_available");
						return target.toString();	
					case P_MOTOHOURS:
						target = toLitleEndian(value);	
						if (uint(target & 0xFFFFFFFF) == 0x80000000)
							return loc("his_not_available");
						return target.toString();
					case P_TOTAL_MILAGE:
						target = toLitleEndian(value);	
						if (uint(target & 0xFFFFFFFF) == 0x80000000)
							return loc("his_not_available");
						return target.toString();
					case P_TEMPERATURE:
						target = int(toSignedLitleEndian(value));
						if (uint(target & 0xFF) == 0x80)
							return loc("his_not_available");
						return target.toString();
					case P_SIGNED_INT2_FIXED_2:
						return "#compile.error";
					case P_DEBUG:
						return "0x"+toLitleEndian(value).toString(16);
				}
			} catch(error:Error) { 
				trace(error.message)
			}
			return "-*-";
		}
		private static function toLitleEndian(arr:Array ):uint
		{
			if (arr.length > 4) {
				dtrace( "VoyagerHistoryServant tryes to parse "+arr.length+" byte int" );
				return 0;
			}
			var value:uint=0;
			var len:int = arr.length;
			for(var k:int=0; k<len; ++k) {
				value |= arr[k] << k*8;
			}
			return value;
		}
		private static function zerosAfter(s:String, n:int):String
		{
			if (s.length < n ) {
				if (s.length < n) {
					for(var i:int=s.length; i<n; ++i  ) {
						s += "0";
					}
				}
			}
			return s;
		}
		private static function toSignedLitleEndian(arr:Array ):String
		{
			var need_invert:Boolean = false;
			if( (arr[ arr.length-1 ] & (0xf << 7)) > 0 )
				need_invert = true;
			
			var value:int=0;
			var len:int = arr.length;
			for(var k:int=0; k<len; ++k) {
				value |= arr[k] << k*8;
			}
			
			if (need_invert) {
				var mask:int;
				for(k=0; k<len; ++k) {
					mask |= 0xFF << 8*k
				}
				return "-"+((value ^ mask)+1);
			}
			return value.toString();
		}
		
		
		private static function adaptUTC(a:Array):void
		{	// нужен для отображения UTC времени со сдвигом GMT в истории
			var t:String = a[a.length-1];
			var d:String = a[a.length-2];	
			
			if (t && d) {
			
				var parts:Array = d.split(".");
				parts = parts.concat( t.split(":"));
				parts[2] = int(parts[2]) < 70 ? "20"+parts[2] : "19"+parts[2];
				var date:Date = new Date;
				date.setUTCFullYear( parts[2] );
				date.setUTCMonth( int(parts[1])-1, parts[0] );
				date.setUTCHours( parts[3], parts[4], parts[5] );
			/*	if (MISC.COPY_DEBUG) {
					a[a.length-1] = UTIL.formateZerosInFront( date.getUTCHours(), 2) + ":" + 
						UTIL.formateZerosInFront( date.getUTCMinutes(), 2 ) +  ":" + 
						UTIL.formateZerosInFront( date.getUTCSeconds(), 2);
					
					a[a.length-2] = UTIL.formateZerosInFront( date.getUTCDate(), 2) +"."+ 
						UTIL.formateZerosInFront( int(date.getUTCMonth()+1),2) +"."+ 
						UTIL.formateZerosInFront( String(date.getUTCFullYear()).slice(2,4), 2 );
				} else {*/
					a[a.length-1] = UTIL.formateZerosInFront( date.getHours(), 2) + ":" + 
						UTIL.formateZerosInFront( date.getMinutes(), 2 ) +  ":" + 
						UTIL.formateZerosInFront( date.getSeconds(), 2);
					
					a[a.length-2] = UTIL.formateZerosInFront( date.getDate(), 2) +"."+ 
						UTIL.formateZerosInFront( int(date.getMonth()+1),2) +"."+ 
						UTIL.formateZerosInFront( String(date.getFullYear()).slice(2,4), 2 );
			//	}
			}
		}
	}
}