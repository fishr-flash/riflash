package components.abstract.servants
{
	import components.abstract.functions.loc;
	import components.static.DS;

	public class CIDServant
	{
		public static const TYPE_UNDEFINED:uint = 0x00;
		public static const TYPE_IOGERKON:uint = 0x01;
		public static const TYPE_IPDYMOVOY:uint = 0x02;
		public static const TYPE_IPGLASSBREAK:uint = 0x03;
		public static const TYPE_IOOBEMNY:uint = 0x04;
		public static const TYPE_RADIOBRELOK:uint = 0x05;
		public static const TYPE_RADIORELE:uint = 0x06;
		public static const TYPE_RADIOKLAVIATURA:uint = 0x07;
		public static const TYPE_IPR:uint = 0x08;
		public static const TYPE_IPZATOPLENIYA:uint = 0x09;
		public static const TYPE_IOGERKON_CR2032:uint = 0x0A;
		public static const TYPE_LCD_KEYBOARD:uint = 0x0C;
		public static const TYPE_RDREPEATER:uint = 0x0D;
		public static const TYPE_NEW:uint = 0xFE;
		
		// Иднтификаторы шлейфов, не участвуют в RF_FUNCT, нужны только для внутриклиентского определения
		public static const WIRE_FIRE_BATTERY:uint = 0xB1;
		public static const WIRE_FIRE_NOBATTERY:uint = 0xB2;
		public static const WIRE_FIRE_GUARD_RESIST:uint = 0xB3;
		public static const WIRE_FIRE_DRY:uint = 0xB4;
		
		//Параметр 4 - Тип зоны - 0x00 - нет, 0x01 - проходная, 0x02 - входная, 0x03 - 24 часа, 0x04 - Мгновенная, 0x05 - Ключевая(в текущей версии реализации нет), 
		public static const ZONE_TYPE_NONE:int = 0x00;			// нет
		public static const ZONE_TYPE_PROHODNAYA:int = 0x01;	// проходная
		public static const ZONE_TYPE_VHODNAYA:int = 0x02;		// входная
		public static const ZONE_TYPE_24HOURS:int = 0x03;		// 24 часа
		public static const ZONE_TYPE_MGNOVENNAYA:int = 0x04;	// Мгновенная
		public static const ZONE_TYPE_KLUCHEVAYA:int = 0x05;	// Ключевая
		public static const ZONE_TYPE_S_PEREZAPROSOM:int = 0x06;// с перезапросом (сброс пожарного извещателя)
		public static const ZONE_TYPE_BEZ_PEREZAPROSA:int =0x07;// без перезапроса ( без сброса пожарного извещателя);
		
		private function getInt():int
		{
			return 23;
		}
		public static function getCIDName(id:int):String
		{
			var len:int = CID.length;
			for (var i:int=0; i<len; i++) {
				if( CID[i].data == id )
					return CID[i].label;
			}
			return "";
		}
		public static function getZoneTypeBySensor(value:int=-1):Array
		{
			if (!ZONE_COLLECTION) {
				ZONE_COLLECTION = new Array;
				
				ZONE_COLLECTION[TYPE_IPDYMOVOY] = [ {label:loc("g_no").toLocaleLowerCase(), data:0},{label:loc("zone_24"), data:3} ];
				ZONE_COLLECTION[TYPE_IPR] = [ {label:loc("g_no").toLocaleLowerCase(), data:0},{label:loc("zone_24"), data:3} ]; 
				ZONE_COLLECTION[WIRE_FIRE_BATTERY] = [ {label:loc("zone_with_request"), data:0x06},
						{label:loc("zone_no_request"), data:0x07} ];
				ZONE_COLLECTION[TYPE_IPGLASSBREAK] = [ {label:loc("g_no").toLocaleLowerCase(), data:0}, {label:loc("zone_instant"), data:4},
						{label:loc("zone_24"), data:3},  ];
				ZONE_COLLECTION[TYPE_IPZATOPLENIYA] = [ {label:loc("g_no").toLocaleLowerCase(), data:0}, {label:loc("zone_instant"), data:4},
					{label:loc("zone_24"), data:3},  ];
				ZONE_COLLECTION[TYPE_UNDEFINED] = [ {label:loc("g_no").toLocaleLowerCase(), data:0}, {label:loc("zone_instant"), data:4},
						{label:loc("zone_entrance"), data:2},	{label:loc("zone_passing_by"), data:1},{label:loc("zone_24"), data:3},  ];
				if( !DS.isfam( DS.K16 ) || ( DS.isfam( DS.K14 ) && DS.release > 22 ) )
				{
					ZONE_COLLECTION[TYPE_IOGERKON] = [ {label:loc("g_no").toLocaleLowerCase(), data:0}, {label:loc("zone_instant"), data:4},
						{label:loc("zone_entrance"), data:2},	{label:loc("zone_passing_by"), data:1}, {label:loc("key_zone"), data:5},
						{label:loc("zone_24"), data:3},  ];	
				}
				else
				{
					ZONE_COLLECTION[TYPE_IOGERKON] = [ {label:loc("g_no").toLocaleLowerCase(), data:0}, {label:loc("zone_instant"), data:4},
						{label:loc("zone_entrance"), data:2},	{label:loc("zone_passing_by"), data:1},
						{label:loc("zone_24"), data:3},  ];
				}
				
				ZONE_COLLECTION[ TYPE_RDREPEATER ] = [ {label:loc("g_no").toLocaleLowerCase(), data:0}, {label:loc("zone_instant"), data:4},
						{label:loc("zone_entrance"), data:2},	{label:loc("zone_passing_by"), data:1},{label:loc("zone_24"), data:3},  ];
				
			}
			if( ZONE_COLLECTION[value] )
				return ZONE_COLLECTION[value];
			return ZONE_COLLECTION[TYPE_UNDEFINED];
		}
		private static var ZONE_COLLECTION:Array;

		/*********************/
		
		public static const RF_RCTRL:int=1;
		public static const RF_KEY:int=2;
		
		public static const CID_RF_RCTRL_PANIC:int = 31;
		public static const CID_RF_RCTRL_UNGUARD:int = 32;
		public static const CID_RF_RCTRL_GUARD:int = 33;
		public static const CID_RF_KEY_MED:int = 34;
		public static const CID_RF_KEY_FIRE:int = 35;
		public static const CID_RF_KEY_PANIC:int = 36;

		public static const CID_RF_GERKON:int = 1;
		public static const CID_RF_GLASSBREAK:int = 3;
		public static const CID_RF_VOLUME:int = 4;
		public static const CID_RF_SMOKE:int = 2;
		public static const CID_RF_IPR:int = 8;
		public static const CID_RF_IPZATOPLENIYA:int = 9;
		public static const CID_RF_GERKON_CR2032:int = 10;
		public static const CID_RFRETRANS:int = 0x0D;
		public static const CID_WIRE_GUARD:int = 21;
		public static const CID_WIRE_FIRE:int = 22;
		
		
		public static const CID_ALARM_KEY:int = 23;

		public static const CID_DEBUG:int = 24;
		
		public static const CID_RFSENSORS:int = 25;
		
		public static const CID_WIRE_ALL:int = 26;
		public static const CID_K5WIRE:int = 27;
		
		
		public static const RAWCID_SYSTEM_EVENTS_LINKCHANNELS:int = 0;
		
		private static var CID_COLLECTION:Array;
		private static var RAWCID_COLLECTION:Array;
		
		
		public static function getRawEvent(value:int=-1):Array
		{
			if(!RAWCID_COLLECTION) {
				RAWCID_COLLECTION = [];
				RAWCID_COLLECTION[RAWCID_SYSTEM_EVENTS_LINKCHANNELS] = RAWCID_SYSTEM_LINKCHANNELS;
			}
			if (value >= 0) {
				if( RAWCID_COLLECTION[value] )
					return RAWCID_COLLECTION[value]
			}
			return [];
		}
		
		private static const CID_Debug:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1321"), data:1321, group:1},            
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1381"), data:1381, group:1},
			{label:loc("1391"), data:1391, group:1},
			{label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1321"), data:1321, group:1},            
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1381"), data:1381, group:1},
			{label:loc("1391"), data:1391, group:1}
		];
		
		
		public static function getEvent(value:int=-1):Array
		{
			
			if (!CID_COLLECTION) {
				CID_COLLECTION = new Array;
				CID_COLLECTION[CID_RF_RCTRL_PANIC] = CID_RCTRL_Panic;
				CID_COLLECTION[CID_RF_RCTRL_UNGUARD] = CID_RCTRL_OffGuard;
				CID_COLLECTION[CID_RF_RCTRL_GUARD] = CID_RCTRL_OnGuard;
				CID_COLLECTION[CID_RF_KEY_MED] = CID_Key_Medic;
				CID_COLLECTION[CID_RF_KEY_FIRE] = CID_Key_Fire;
				CID_COLLECTION[CID_RF_KEY_PANIC] = CID_Key_Panic;
				CID_COLLECTION[CID_RF_GERKON] = CID_Gerkon;
				CID_COLLECTION[CID_RF_GERKON_CR2032] = CID_Gerkon;
				CID_COLLECTION[CID_RF_GLASSBREAK] = CID_Gerkon;
				CID_COLLECTION[CID_RF_VOLUME] = CID_Volume;
				CID_COLLECTION[CID_RF_SMOKE] = CID_Smoke;
				CID_COLLECTION[CID_RF_IPR] = CID_Ipr;
				CID_COLLECTION[CID_WIRE_GUARD] = CID_Wire_Guard;
				CID_COLLECTION[CID_WIRE_FIRE] = CID_Wire_Fire;
				CID_COLLECTION[CID_RFRETRANS] = CID_RfRetrans;
				CID_COLLECTION[CID_ALARM_KEY] = CID_Alarm_Key;
				CID_COLLECTION[CID_DEBUG] = CID_Debug;
				CID_COLLECTION[CID_WIRE_ALL] = CID_K16_WIRE;
				CID_COLLECTION[CID_RF_IPZATOPLENIYA] =[ {label:loc("g_no"), data:0} ];
			}
			if (value >= 0 && CID_COLLECTION[value]) {
				if( CID_COLLECTION[value] )
					return CID_COLLECTION[value]
			} else {
				if( value >= 0 ) {
					switch(value) {
						case CID_RFSENSORS:
							switch(DS.deviceAlias) {
								case DS.K14:
								case DS.K14A:
								case DS.K14W:
								case DS.K14K:
								case DS.K14AW:
								case DS.K7:
									return CID_RFSENSOR_K14_K7;
								case DS.K16:
									return CID_RFSENSOR_K16;
							}
							break;
						case CID_K5WIRE:
							return CID_K5_WIRE;
					}
				} else {
					switch(DS.deviceAlias) {
						case DS.K5RT1:
						case DS.K5RT13G:
						case DS.K5RT1L:
						case DS.K5RT3:
						case DS.K5RT3L:
						case DS.K5RT33G:
							if(!CID_K5RT1) {
								CID_K5RT1 = CID.concat( CID_K5RT1_source );
								CID_K5RT1.sortOn("data", Array.NUMERIC );
							}
							return CID_K5RT1;
							break;
						case DS.K14:
						case DS.K14A:
						case DS.K14W:
						case DS.K14AW:
						case DS.K14K:
						case DS.K14KW:
						case DS.K16:
							return CID_K14;
						case DS.K7:
							return CID;
						case DS.isfam( DS.K5 ):
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
							if (!CID_K5) {
								
								CID_K5 = CID_K5_BASE.concat( CID );
								/*
								var a:Array = [];
								CID_K5 = CID.slice();
								var cide:int;
								var len:int = CID_K5_WIRE.length;
								var found:Boolean;
								for (var i:int=0; i<len; i++) {
									cide = int(CID_K5_WIRE[i].data);
									var lenj:int = CID_K5.length;
									found = false;
									 
									for (var j:int=0; j<lenj; j++) {
										if(cide == int((CID_K5[j].label as String).slice(0,3)) ) {
											found = true;
											break;
										}
									}
									if (!found)
										a.push( CID_K5_WIRE[i] );
								}*/
								
							}
							return CID_K5;
					}
				}
			}
			return CID;
		}
		
		// Список для экрана треожная копка
		private static const CID_Alarm_Key:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1201"), data:1201, group:1}
		];
		
		// Основная зона герконов или датчика разбития и для геркона RDD-3
		private static const CID_Gerkon:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1}
		];
		
		// Основная зона объёмника
		private static const CID_Volume:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1321"), data:1321, group:1},
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1}
		];
		
		// Основная зона дымового датчика
		private static const CID_Smoke:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1111"), data:1111, group:3}
		];
		
		// Основная зона ИПР
		private static const CID_Ipr:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1101"), data:1101, group:3}
		];
		
		// Доп.шлейф датчиков или проводной охранный шлейф
		private static const CID_Wire_Guard:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1321"), data:1321, group:1},            
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1391"), data:1391, group:1}
		];
		
		// Проводной пожарный шлейф (для обоих событий)
		private static const CID_Wire_Fire:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1111"), data:1111, group:3},
			{label:loc("1121"), data:1121, group:3},
			{label:loc("1131"), data:1131, group:3},
			{label:loc("1141"), data:1141, group:3},
			{label:loc("1151"), data:1151, group:3},
			{label:loc("1161"), data:1161, group:3},
			{label:loc("1171"), data:1171, group:3},
			{label:loc("1181"), data:1181, group:3},
		];
		
		// Радиобрелок, кнопка "Взять"
		private static const CID_RCTRL_OnGuard:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("4003"), data:4003, group:6 },
			{label:loc("4013"), data:4013, group:6 },
			{label:loc("4023"), data:4023, group:6 }
		];
		
		// Радиобрелок, кнопка "Снять"
		private static const CID_RCTRL_OffGuard:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("4001"), data:4001, group:5 },
			{label:loc("4011"), data:4011, group:5 },
			{label:loc("4021"), data:4021, group:5 }
		];
		
		// Радиобрелок, кнопка "*"
		private static const CID_RCTRL_Panic:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1011"), data:1011, group:9 },
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1201"), data:1201, group:1},
			/// отключено в соответствии с задачей https://megaplan.ritm.ru/event/1010961/card/
			//{label:loc("1231"), data:1231, group:1},
			{label:loc("1401"), data:1401, group:1}
		];
		
		// (Радио)клавиатура, кнопка "Пожар"
		private static const CID_Key_Fire:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1101"), data:1101, group:3}
		];        
		
		// (Радио)клавиатура, кнопка "Медики"
		private static const CID_Key_Medic:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 }
		];    
		
		
		private static const CID_RfRetrans:Array =    [    
			{label:loc("3011"), data:3011, group:9 }
		];    
		
		// (Радио)клавиатура, кнопка "Охрана"
		private static const CID_Key_Panic:Array =    [    {label:loc("g_no"), data:0},
			{label:loc("1201"), data:1201, group:1}
		];
		private static const CID:Array =	[	{label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1003"), data:1003, group:9 },
			{label:loc("1011"), data:1011, group:9 },
			{label:loc("1013"), data:1013, group:9 },
			{label:loc("1021"), data:1021, group:9 },
			{label:loc("1023"), data:1023, group:9 },
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1103"), data:1103, group:4},
			{label:loc("1111"), data:1111, group:3},
			{label:loc("1113"), data:1113, group:4},
			{label:loc("1121"), data:1121, group:3},
			{label:loc("1123"), data:1123, group:4},
			{label:loc("1131"), data:1131, group:3},
			{label:loc("1133"), data:1133, group:4},
			{label:loc("1141"), data:1141, group:3},
			{label:loc("1143"), data:1143, group:4},
			{label:loc("1151"), data:1151, group:3},
			{label:loc("1153"), data:1153, group:4},
			{label:loc("1161"), data:1161, group:3},
			{label:loc("1163"), data:1163, group:4},
			{label:loc("1171"), data:1171, group:3},
			{label:loc("1173"), data:1173, group:4},
			{label:loc("1181"), data:1181, group:3},
			{label:loc("1183"), data:1183, group:4},
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1203"), data:1203, group:2},
			{label:loc("1211"), data:1211, group:1},
			{label:loc("1213"), data:1213, group:2},
			{label:loc("1221"), data:1221, group:1},
			{label:loc("1223"), data:1223, group:2},
			{label:loc("1231"), data:1231, group:1},
			{label:loc("1231"), data:1233, group:2},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1303"), data:1303, group:2},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1313"), data:1313, group:2},
			{label:loc("1321"), data:1321, group:1},
			{label:loc("1323"), data:1323, group:2},
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1333"), data:1333, group:2},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1343"), data:1343, group:2},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1353"), data:1353, group:2},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1363"), data:1363, group:2},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1373"), data:1373, group:2},
			{label:loc("1381"), data:1381, group:1},
			{label:loc("1383"), data:1383, group:2},
			{label:loc("1391"), data:1391, group:1},
			{label:loc("1393"), data:1393, group:2},
			{label:loc("1401"), data:1401, group:1},
			{label:loc("1403"), data:1403, group:2},
			{label:loc("1411"), data:1411, group:1},
			{label:loc("1413"), data:1413, group:2},
			{label:loc("1421"), data:1421, group:1},
			{label:loc("1423"), data:1423, group:2},
			{label:loc("1431"), data:1431, group:1},
			{label:loc("1433"), data:1433, group:2},
			{label:loc("1441"), data:1441, group:1},
			{label:loc("1443"), data:1443, group:2},
			{label:loc("1451"), data:1451, group:1},
			{label:loc("1453"), data:1453, group:2},
			{label:loc("1471"), data:1471, group:1},
			{label:loc("1473"), data:1473, group:2},
			{label:loc("1501"), data:1501, group:1},
			{label:loc("1503"), data:1503, group:2},
			{label:loc("1511"), data:1511, group:1},
			{label:loc("1513"), data:1513, group:2},
			{label:loc("1521"), data:1521, group:1},
			{label:loc("1523"), data:1523, group:2},
			{label:loc("1531"), data:1531, group:1},
			{label:loc("1533"), data:1533, group:2},
			{label:loc("1541"), data:1541, group:1},
			{label:loc("1543"), data:1543, group:2},
			{label:loc("1551"), data:1551, group:1},
			{label:loc("1553"), data:1553, group:2},
			{label:loc("1561"), data:1561, group:1},
			{label:loc("1563"), data:1563, group:2},
			{label:loc("1571"), data:1571, group:1},
			{label:loc("1573"), data:1573, group:2},
			{label:loc("1581"), data:1581, group:1},
			{label:loc("1583"), data:1583, group:2},
			{label:loc("1591"), data:1591, group:1},
			{label:loc("1593"), data:1593, group:2},
			{label:loc("1611"), data:1611, group:1},
			{label:loc("1613"), data:1613, group:2},
			{label:loc("2001"), data:2001, group:3},
			{label:loc("2003"), data:2003, group:4},
			{label:loc("2011"), data:2011, group:3},
			{label:loc("2013"), data:2013, group:4},
			{label:loc("2021"), data:2021, group:3},
			{label:loc("2023"), data:2023, group:4},
			{label:loc("2031"), data:2031, group:3},
			{label:loc("2033"), data:2033, group:4},
			{label:loc("2041"), data:2041, group:3},
			{label:loc("2043"), data:2043, group:4},
			{label:loc("2051"), data:2051, group:3},
			{label:loc("2053"), data:2053, group:4},
			{label:loc("2061"), data:2061, group:3},
			{label:loc("2063"), data:2063, group:4},
			{label:loc("3001"), data:3001, group:8 },
			{label:loc("3003"), data:3003, group:8 },
			{label:loc("3011"), data:3011, group:8 },
			{label:loc("3013"), data:3013, group:8 },
			{label:loc("3021"), data:3021, group:8 },
			{label:loc("3023"), data:3023, group:8 },
			{label:loc("3031"), data:3031, group:8 },
			{label:loc("3033"), data:3033, group:8 },
			{label:loc("3041"), data:3041, group:8 },
			{label:loc("3043"), data:3043, group:8 },
			{label:loc("3051"), data:3051, group:8 },
			{label:loc("3061"), data:3061, group:8 },
			{label:loc("3071"), data:3071, group:8 },
			{label:loc("3073"), data:3073, group:8 },
			{label:loc("3081"), data:3081, group:8 },
			{label:loc("3091"), data:3091, group:8 },
			{label:loc("3093"), data:3093, group:8 },
			{label:loc("3101"), data:3101, group:8 },
			{label:loc("3103"), data:3103, group:8 },
			{label:loc("3121"), data:3121, group:8 },
			{label:loc("3123"), data:3123, group:8 },
			{label:loc("3191"), data:3191, group:8 },
			{label:loc("3193"), data:3193, group:8 },
			{label:loc("3201"), data:3201, group:8 },
			{label:loc("3203"), data:3203, group:8 },
			{label:loc("3211"), data:3211, group:8 },
			{label:loc("3213"), data:3213, group:8 },
			{label:loc("3221"), data:3221, group:8 },
			{label:loc("3223"), data:3223, group:8 },
			{label:loc("3231"), data:3231, group:8 },
			{label:loc("3233"), data:3233, group:8 },
			{label:loc("3241"), data:3241, group:8 },
			{label:loc("3243"), data:3243, group:8 },
			{label:loc("3251"), data:3251, group:8 },
			{label:loc("3253"), data:3253, group:8 },
			{label:loc("3301"), data:3301, group:8 },
			{label:loc("3303"), data:3303, group:8 },
			{label:loc("3311"), data:3311, group:8 },                               
			{label:loc("3321"), data:3321, group:8 },
			{label:loc("3323"), data:3323, group:8 },
			{label:loc("3331"), data:3331, group:8 },
			{label:loc("3333"), data:3333, group:8 },
			{label:loc("3341"), data:3341, group:8 },
			{label:loc("3343"), data:3343, group:8 },
			{label:loc("3351"), data:3351, group:8 },
			{label:loc("3353"), data:3353, group:8 },
			{label:loc("3361"), data:3361, group:8 },
			{label:loc("3363"), data:3363, group:8 },
			{label:loc("3441"), data:3441, group:8 },
			{label:loc("3443"), data:3443, group:8 },
			{label:loc("3501"), data:3501, group:8 },
			{label:loc("3503"), data:3503, group:8 },
			{label:loc("3511"), data:3511, group:8 },
			{label:loc("3513"), data:3513, group:8 },
			{label:loc("3521"), data:3521, group:8 },
			{label:loc("3523"), data:3523, group:8 },
			{label:loc("3531"), data:3531, group:8 },
			{label:loc("3533"), data:3533, group:8 },
			{label:loc("3541"), data:3541, group:8 },
			{label:loc("3551"), data:3551, group:8 },
			{label:loc("3553"), data:3553, group:8 },
			{label:loc("3561"), data:3561, group:8 },
			{label:loc("3563"), data:3563, group:8 },
			{label:loc("3701"), data:3701, group:8 },
			{label:loc("3703"), data:3703, group:8 },
			{label:loc("3711"), data:3711, group:8 },
			{label:loc("3713"), data:3713, group:8 },
			{label:loc("3721"), data:3721, group:8 },
			{label:loc("3723"), data:3723, group:8 },
			{label:loc("3731"), data:3731, group:8 },
			{label:loc("3733"), data:3733, group:8 },
			{label:loc("3801"), data:3801, group:8 },
			{label:loc("3803"), data:3803, group:8 },
			{label:loc("3811"), data:3811, group:8 },
			{label:loc("3813"), data:3813, group:8 },
			{label:loc("3821"), data:3821, group:8 },
			{label:loc("3823"), data:3823, group:8 },
			{label:loc("3831"), data:3831, group:8 },
			{label:loc("3833"), data:3833, group:8 },
			{label:loc("3841"), data:3841, group:8 },
			{label:loc("3843"), data:3843, group:8 },
			{label:loc("4001"), data:4001, group:5 },
			{label:loc("4003"), data:4003, group:6 },
			{label:loc("4011"), data:4011, group:5 },
			{label:loc("4013"), data:4013, group:6 },
			{label:loc("4021"), data:4021, group:5 },
			{label:loc("4023"), data:4023, group:6 },
			{label:loc("4031"), data:4031, group:5 },
			{label:loc("4033"), data:4033, group:6 },
			{label:loc("4041"), data:4041, group:5 },
			{label:loc("4043"), data:4043, group:6 },
			{label:loc("4051"), data:4051, group:5 },
			{label:loc("4053"), data:4053, group:6 },
			{label:loc("4061"), data:4061, group:5 },
			{label:loc("4063"), data:4063, group:6 },
			{label:loc("4071"), data:4071, group:5 },
			{label:loc("4073"), data:4073, group:6 },
			{label:loc("4083"), data:4083, group:6 },
			{label:loc("4091"), data:4091, group:5 },
			{label:loc("4093"), data:4093, group:6 },
			{label:loc("4111"), data:4111, group:8 },
			{label:loc("4121"), data:4121, group:8 },
			{label:loc("4131"), data:4131, group:8 },
			{label:loc("4141"), data:4141, group:8 },
			{label:loc("4151"), data:4151, group:8 },
			//{label:loc("4211"), data:4211, group:8 },
			{label:loc("4221"), data:4221, group:8 },
			{label:loc("4413"), data:4413, group:6 },
			{label:loc("4501"), data:4501, group:6 },
			{label:loc("4503"), data:4503, group:1 },
			{label:loc("4591"), data:4591, group:1 },
			{label:loc("4593"), data:4593, group:2 },
			{label:loc("4611"), data:4611, group:8 },
			{label:loc("5001"), data:5001, group:8 },
			{label:loc("5003"), data:5003, group:8 },
			{label:loc("5201"), data:5201, group:8 },
			{label:loc("5203"), data:5203, group:8 },
			{label:loc("5211"), data:5211, group:8 },
			{label:loc("5213"), data:5213, group:8 },
			{label:loc("5221"), data:5221, group:8 },
			{label:loc("5223"), data:5223, group:8 },
			{label:loc("5231"), data:5231, group:8 },
			{label:loc("5233"), data:5233, group:8 },
			{label:loc("5241"), data:5241, group:8 },
			{label:loc("5243"), data:5243, group:8 },
			{label:loc("5251"), data:5251, group:8 },
			{label:loc("5253"), data:5253, group:8 },
			{label:loc("5301"), data:5301, group:8 },
			{label:loc("5303"), data:5303, group:8 },
			{label:loc("5511"), data:5511, group:8 },
			{label:loc("5513"), data:5513, group:8 },
			{label:loc("5521"), data:5521, group:8 },
			{label:loc("5523"), data:5523, group:8 },
			{label:loc("5701"), data:5701, group:8 },
			{label:loc("5703"), data:5703, group:8 },
			{label:loc("5711"), data:5711, group:8 },
			{label:loc("5713"), data:5713, group:8 },
			{label:loc("5721"), data:5721, group:8 },
			{label:loc("5723"), data:5723, group:8 },
			{label:loc("5731"), data:5731, group:8 },
			{label:loc("5733"), data:5733, group:8 },
			{label:loc("5741"), data:5741, group:8 },
			{label:loc("5743"), data:5743, group:8 },
			{label:loc("6011"), data:6011, group:7 },
			{label:loc("6021"), data:6021, group:7 },
			{label:loc("6031"), data:6031, group:7 },
			{label:loc("6041"), data:6041, group:7 },
			{label:loc("6051"), data:6051, group:7 },
			{label:loc("6061"), data:6061, group:7 },
			{label:loc("6063"), data:6063, group:7 },
			{label:loc("6071"), data:6071, group:7 },
			{label:loc("6211"), data:6211, group:8 },
			{label:loc("6221"), data:6221, group:8 },
			{label:loc("6231"), data:6231, group:8 },
			{label:loc("6241"), data:6241, group:8 },
			{label:loc("6251"), data:6251, group:8 },
			{label:loc("6261"), data:6261, group:8 },
			{label:loc("6263"), data:6263, group:8 },
			{label:loc("6271"), data:6271, group:8 },
			{label:loc("6281"), data:6281, group:8 },
			{label:loc("6311"), data:6311, group:8 }
		];
		private static const CID_K5RT1_source:Array =	[
				{label:loc("1191"), data:1191 },
				{label:loc("1193"), data:1193 },
				{label:loc("1241"), data:1241 },
				{label:loc("1243"), data:1243 },
				{label:loc("1251"), data:1251 },
				{label:loc("1253"), data:1253 },
				{label:loc("1461"), data:1461 },
				{label:loc("1463"), data:1463 },
				{label:loc("1621"), data:1621 },
				{label:loc("1623"), data:1623 },
				{label:loc("1631"), data:1631 },
				{label:loc("1633"), data:1633 },
				{label:loc("3053"), data:3053 },
				{label:loc("3083"), data:3083 },
				{label:loc("3111"), data:3111 },
				{label:loc("3113"), data:3113 },
				{label:loc("3131"), data:3131 },
				{label:loc("3133"), data:3133 },
				{label:loc("3261"), data:3261 },
				{label:loc("3263"), data:3263 },
				{label:loc("3271"), data:3271 },
				{label:loc("3273"), data:3273 },
				{label:loc("3313"), data:3313 },
				{label:loc("3371"), data:3371 },
				{label:loc("3373"), data:3373 },
				{label:loc("3381"), data:3381 },
				{label:loc("3383"), data:3383 },
				{label:loc("3391"), data:3391 },
				{label:loc("3393"), data:3393 },
				{label:loc("3411"), data:3411 },
				{label:loc("3413"), data:3413 },
				{label:loc("3421"), data:3421 },
				{label:loc("3423"), data:3423 },
				{label:loc("3431"), data:3431 },
				{label:loc("3433"), data:3433 },
				{label:loc("3543"), data:3543 },
				{label:loc("3571"), data:3571 },
				{label:loc("3573"), data:3573 },
				{label:loc("3741"), data:3741 },
				{label:loc("3743"), data:3743 },
				{label:loc("3751"), data:3751 },
				{label:loc("3753"), data:3753 },
				{label:loc("3761"), data:3761 },
				{label:loc("3763"), data:3763 },
				{label:loc("3771"), data:3771 },
				{label:loc("3773"), data:3773 },
				{label:loc("3781"), data:3781 },
				{label:loc("3783"), data:3783 },
				{label:loc("3851"), data:3851 },
				{label:loc("3853"), data:3853 },
				{label:loc("3861"), data:3861 },
				{label:loc("3863"), data:3863 },
				{label:loc("3871"), data:3871 },
				{label:loc("3873"), data:3873 },
				{label:loc("3881"), data:3881 },
				{label:loc("3883"), data:3883 },
				{label:loc("3891"), data:3891 },
				{label:loc("3893"), data:3893 },
				{label:loc("3911"), data:3911 },
				{label:loc("3913"), data:3913 },
				{label:loc("3921"), data:3921 },
				{label:loc("3923"), data:3923 },
				{label:loc("3931"), data:3931 },
				{label:loc("3933"), data:3933 },
				{label:loc("4161"), data:4161 },
				{label:loc("4163"), data:4163 },
				{label:loc("4211"), data:4211 },
				{label:loc("4213"), data:4213 },
				{label:loc("4231"), data:4231 },
				{label:loc("4233"), data:4233 },
				{label:loc("4241"), data:4241 },
				{label:loc("4243"), data:4243 },
				{label:loc("4251"), data:4251 },
				{label:loc("4253"), data:4253 },
				{label:loc("4261"), data:4261 },
				{label:loc("4263"), data:4263 },
				{label:loc("4271"), data:4271 },
				{label:loc("4273"), data:4273 },
				{label:loc("4281"), data:4281 },
				{label:loc("4283"), data:4283 },
				{label:loc("4291"), data:4291 },
				{label:loc("4293"), data:4293 },
				{label:loc("4301"), data:4301 },
				{label:loc("4303"), data:4303 },
				{label:loc("4311"), data:4311 },
				{label:loc("4313"), data:4313 },
				{label:loc("4321"), data:4321 },
				{label:loc("4323"), data:4323 },
				{label:loc("4331"), data:4331 },
				{label:loc("4333"), data:4333 },
				{label:loc("4341"), data:4341 },
				{label:loc("4343"), data:4343 },
				{label:loc("4411"), data:4411 },
				{label:loc("4421"), data:4421 },
				{label:loc("4423"), data:4423 },
				{label:loc("4503"), data:4503 },
				{label:loc("4511"), data:4511 },
				{label:loc("4513"), data:4513 },
				{label:loc("4521"), data:4521 },
				{label:loc("4523"), data:4523 },
				{label:loc("4531"), data:4531 },
				{label:loc("4533"), data:4533 },
				{label:loc("4541"), data:4541 },
				{label:loc("4543"), data:4543 },
				{label:loc("4551"), data:4551 },
				{label:loc("4553"), data:4553 },
				{label:loc("4561"), data:4561 },
				{label:loc("4563"), data:4563 },
				{label:loc("4571"), data:4571 },
				{label:loc("4573"), data:4573 },
				{label:loc("4581"), data:4581 },
				{label:loc("4583"), data:4583 },
				{label:loc("4593"), data:4593 },
				{label:loc("4613"), data:4613 },
				{label:loc("4621"), data:4621 },
				{label:loc("4623"), data:4623 },
				{label:loc("4631"), data:4631 },
				{label:loc("4633"), data:4633 },
				{label:loc("4641"), data:4641 },
				{label:loc("4643"), data:4643 },
				{label:loc("4651"), data:4651 },
				{label:loc("4653"), data:4653 },
				{label:loc("4661"), data:4661 },
				{label:loc("4663"), data:4663 },
				{label:loc("5011"), data:5011 },
				{label:loc("5013"), data:5013 },
				{label:loc("5261"), data:5261 },
				{label:loc("5263"), data:5263 },
				{label:loc("5271"), data:5271 },
				{label:loc("5273"), data:5273 },
				{label:loc("5501"), data:5501 },
				{label:loc("5503"), data:5503 },
				{label:loc("5531"), data:5531 },
				{label:loc("5533"), data:5533 },
				{label:loc("5601"), data:5601 },
				{label:loc("5603"), data:5603 },
				{label:loc("5611"), data:5611 },
				{label:loc("5613"), data:5613 },
				{label:loc("5751"), data:5751 },
				{label:loc("5753"), data:5753 },
				{label:loc("5761"), data:5761 },
				{label:loc("5763"), data:5763 },
				{label:loc("5771"), data:5771 },
				{label:loc("5773"), data:5773 },
				{label:loc("6053"), data:6053 },
				{label:loc("6073"), data:6073 },
				{label:loc("6081"), data:6081 },
				{label:loc("6083"), data:6083 },
				{label:loc("6091"), data:6091 },
				{label:loc("6093"), data:6093 },
				{label:loc("6111"), data:6111 },
				{label:loc("6113"), data:6113 },
				{label:loc("6121"), data:6121 },
				{label:loc("6123"), data:6123 },
				{label:loc("6131"), data:6131 },
				{label:loc("6133"), data:6133 },
				{label:loc("6141"), data:6141 },
				{label:loc("6143"), data:6143 },
				{label:loc("6151"), data:6151 },
				{label:loc("6153"), data:6153 },
				{label:loc("6161"), data:6161 },
				{label:loc("6163"), data:6163 },
				{label:loc("6253"), data:6253 },
				{label:loc("6291"), data:6291 },
				{label:loc("6293"), data:6293 },
				{label:loc("6301"), data:6301 },
				{label:loc("6303"), data:6303 },
				{label:loc("6321"), data:6321 },
				{label:loc("6323"), data:6323 },
				{label:loc("6411"), data:6411 },
				{label:loc("6413"), data:6413 },
				{label:loc("6421"), data:6421 },
				{label:loc("6423"), data:6423 },
				{label:loc("6511"), data:6511 },
				{label:loc("6513"), data:6513 },
				{label:loc("6521"), data:6521 },
				{label:loc("6523"), data:6523 },
				{label:loc("6531"), data:6531 },
				{label:loc("6533"), data:6533 },
				{label:loc("6541"), data:6541 },
				{label:loc("6543"), data:6543 }
		];
		private static var CID_K5RT1:Array;
		
		private static const CID_K16_WIRE:Array =	[	{label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1011"), data:1011, group:9 },
			{label:loc("1011"), data:1021, group:9 },
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1111"), data:1111, group:3},
			{label:loc("1121"), data:1121, group:3},
			{label:loc("1131"), data:1131, group:3},
			{label:loc("1141"), data:1141, group:3},
			{label:loc("1151"), data:1151, group:3},
			{label:loc("1151"), data:1161, group:3},
			{label:loc("1171"), data:1171, group:3},
			{label:loc("1181"), data:1181, group:3},
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1211"), data:1211, group:1},
			{label:loc("1221"), data:1221, group:1},
			{label:loc("1231"), data:1231, group:1},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1321"), data:1321, group:1},
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1381"), data:1381, group:1},
			{label:loc("1391"), data:1391, group:1},
			{label:loc("1401"), data:1401, group:1},
			{label:loc("1411"), data:1411, group:1},
			{label:loc("1421"), data:1421, group:1},
			{label:loc("1431"), data:1431, group:1},
			{label:loc("1441"), data:1441, group:1},
			{label:loc("1451"), data:1451, group:1},
			{label:loc("1471"), data:1471, group:1},
			{label:loc("1501"), data:1501, group:1},
			{label:loc("1511"), data:1511, group:1},
			{label:loc("1521"), data:1521, group:1},
			{label:loc("1531"), data:1531, group:1},
			{label:loc("1541"), data:1541, group:1},
			{label:loc("1551"), data:1551, group:1},
			{label:loc("1561"), data:1561, group:1},
			{label:loc("1571"), data:1571, group:1},
			{label:loc("1581"), data:1581, group:1},
			{label:loc("1591"), data:1591, group:1},
			{label:loc("1611"), data:1611, group:1},
			{label:loc("2001"), data:2001, group:3},
			{label:loc("2011"), data:2011, group:3},
			{label:loc("2021"), data:2021, group:3},
			{label:loc("2031"), data:2031, group:3},
			{label:loc("2041"), data:2041, group:3},
			{label:loc("2051"), data:2051, group:3},
			{label:loc("2061"), data:2061, group:3},
			{label:loc("3001"), data:3001, group:8 },
			{label:loc("3011"), data:3011, group:8 },
			{label:loc("3021"), data:3021, group:8 },
			{label:loc("3031"), data:3031, group:8 },
			{label:loc("3041"), data:3041, group:8 },
			{label:loc("3051"), data:3051, group:8 },
			{label:loc("3061"), data:3061, group:8 },
			{label:loc("3071"), data:3071, group:8 },
			{label:loc("3081"), data:3081, group:8 },
			{label:loc("3091"), data:3091, group:8 },
			{label:loc("3101"), data:3101, group:8 },
			{label:loc("3121"), data:3121, group:8 },
			{label:loc("3191"), data:3191, group:8 },
			{label:loc("3201"), data:3201, group:8 },
			{label:loc("3211"), data:3211, group:8 },
			{label:loc("3221"), data:3221, group:8 },
			{label:loc("3231"), data:3231, group:8 },
			{label:loc("3241"), data:3241, group:8 },
			{label:loc("3251"), data:3251, group:8 },
			{label:loc("3301"), data:3301, group:8 },
			{label:loc("3311"), data:3311, group:8 },                               
			{label:loc("3321"), data:3321, group:8 },
			{label:loc("3331"), data:3331, group:8 },
			{label:loc("3341"), data:3341, group:8 },
			{label:loc("3351"), data:3351, group:8 },
			{label:loc("3361"), data:3361, group:8 },
			{label:loc("3441"), data:3441, group:8 },
			{label:loc("3501"), data:3501, group:8 },
			{label:loc("3511"), data:3511, group:8 },
			{label:loc("3521"), data:3521, group:8 },
			{label:loc("3531"), data:3531, group:8 },
			{label:loc("3541"), data:3541, group:8 },
			{label:loc("3551"), data:3551, group:8 },
			{label:loc("3561"), data:3561, group:8 },
			{label:loc("3701"), data:3701, group:8 },
			{label:loc("3711"), data:3711, group:8 },
			{label:loc("3721"), data:3721, group:8 },
			{label:loc("3731"), data:3731, group:8 },
			{label:loc("3801"), data:3801, group:8 },
			{label:loc("3811"), data:3811, group:8 },
			{label:loc("3821"), data:3821, group:8 },
			{label:loc("3831"), data:3831, group:8 },
			{label:loc("3841"), data:3841, group:8 },
			{label:loc("4001"), data:4001, group:5 },
			{label:loc("4011"), data:4011, group:5 },
			{label:loc("4021"), data:4021, group:5 },
			{label:loc("4031"), data:4031, group:5 },
			{label:loc("4041"), data:4041, group:5 },
			{label:loc("4051"), data:4051, group:5 },
			{label:loc("4061"), data:4061, group:5 },
			{label:loc("4071"), data:4071, group:5 },
			{label:loc("4091"), data:4091, group:5 },
			{label:loc("4111"), data:4111, group:8 },
			{label:loc("4121"), data:4121, group:8 },
			{label:loc("4131"), data:4131, group:8 },
			{label:loc("4141"), data:4141, group:8 },
			{label:loc("4151"), data:4151, group:8 },
			//{label:loc("4211"), data:4211, group:8 },
			{label:loc("4221"), data:4221, group:8 },
			{label:loc("4611"), data:4611, group:8 },
			{label:loc("5001"), data:5001, group:8 },
			{label:loc("5201"), data:5201, group:8 },
			{label:loc("5211"), data:5211, group:8 },
			{label:loc("5221"), data:5221, group:8 },
			{label:loc("5231"), data:5231, group:8 },
			{label:loc("5241"), data:5241, group:8 },
			{label:loc("5251"), data:5251, group:8 },
			{label:loc("5301"), data:5301, group:8 },
			{label:loc("5511"), data:5511, group:8 },
			{label:loc("5521"), data:5521, group:8 },
			{label:loc("5701"), data:5701, group:8 },
			{label:loc("5711"), data:5711, group:8 },
			{label:loc("5721"), data:5721, group:8 },
			{label:loc("5731"), data:5731, group:8 },
			{label:loc("5741"), data:5741, group:8 },
			{label:loc("6011"), data:6011, group:7 },
			{label:loc("6021"), data:6021, group:7 },
			{label:loc("6031"), data:6031, group:7 },
			{label:loc("6041"), data:6041, group:7 },
			{label:loc("6051"), data:6051, group:7 },
			{label:loc("6061"), data:6061, group:7 },
			{label:loc("6071"), data:6071, group:7 },
			{label:loc("6211"), data:6211, group:8 },
			{label:loc("6221"), data:6221, group:8 },
			{label:loc("6231"), data:6231, group:8 },
			{label:loc("6241"), data:6241, group:8 },
			{label:loc("6251"), data:6251, group:8 },
			{label:loc("6261"), data:6261, group:8 },
			{label:loc("6271"), data:6271, group:8 },
			{label:loc("6281"), data:6281, group:8 },
			{label:loc("6311"), data:6311, group:8 }
		];
		private static const CID_K14:Array =	[	{label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1003"), data:1003, group:9 },
			{label:loc("1011"), data:1011, group:9 },
			{label:loc("1013"), data:1013, group:9 },
			{label:loc("1021"), data:1021, group:9 },
			{label:loc("1023"), data:1023, group:9 },
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1103"), data:1103, group:4},
			{label:loc("1111"), data:1111, group:3},
			{label:loc("1113"), data:1113, group:4},
			{label:loc("1121"), data:1121, group:3},
			{label:loc("1123"), data:1123, group:4},
			{label:loc("1131"), data:1131, group:3},
			{label:loc("1133"), data:1133, group:4},
			{label:loc("1141"), data:1141, group:3},
			{label:loc("1143"), data:1143, group:4},
			{label:loc("1151"), data:1151, group:3},
			{label:loc("1153"), data:1153, group:4},
			{label:loc("1161"), data:1161, group:3},
			{label:loc("1163"), data:1163, group:4},
			{label:loc("1171"), data:1171, group:3},
			{label:loc("1173"), data:1173, group:4},
			{label:loc("1181"), data:1181, group:3},
			{label:loc("1183"), data:1183, group:4},
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1203"), data:1203, group:2},
			{label:loc("1211"), data:1211, group:1},
			{label:loc("1213"), data:1213, group:2},
			{label:loc("1221"), data:1221, group:1},
			{label:loc("1223"), data:1223, group:2},
			{label:loc("1231"), data:1231, group:1},
			{label:loc("1233"), data:1233, group:2},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1303"), data:1303, group:2},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1313"), data:1313, group:2},
			{label:loc("1321"), data:1321, group:1},
			{label:loc("1323"), data:1323, group:2},
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1333"), data:1333, group:2},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1343"), data:1343, group:2},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1353"), data:1353, group:2},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1363"), data:1363, group:2},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1373"), data:1373, group:2},
			{label:loc("1381"), data:1381, group:1},
			{label:loc("1383"), data:1383, group:2},
			{label:loc("1391"), data:1391, group:1},
			{label:loc("1393"), data:1393, group:2},
			{label:loc("1401"), data:1401, group:1},
			{label:loc("1403"), data:1403, group:2},
			{label:loc("1411"), data:1411, group:1},
			{label:loc("1413"), data:1413, group:2},
			{label:loc("1421"), data:1421, group:1},
			{label:loc("1423"), data:1423, group:2},
			{label:loc("1431"), data:1431, group:1},
			{label:loc("1433"), data:1433, group:2},
			{label:loc("1441"), data:1441, group:1},
			{label:loc("1443"), data:1443, group:2},
			{label:loc("1451"), data:1451, group:1},
			{label:loc("1453"), data:1453, group:2},
			{label:loc("1471"), data:1471, group:1},
			{label:loc("1473"), data:1473, group:2},
			{label:loc("1501"), data:1501, group:1},
			{label:loc("1503"), data:1503, group:2},
			{label:loc("1511"), data:1511, group:1},
			{label:loc("1513"), data:1513, group:2},
			{label:loc("1521"), data:1521, group:1},
			{label:loc("1523"), data:1523, group:2},
			{label:loc("1531"), data:1531, group:1},
			{label:loc("1533"), data:1533, group:2},
			{label:loc("1541"), data:1541, group:1},
			{label:loc("1543"), data:1543, group:2},
			{label:loc("1551"), data:1551, group:1},
			{label:loc("1553"), data:1553, group:2},
			{label:loc("1561"), data:1561, group:1},
			{label:loc("1563"), data:1563, group:2},
			{label:loc("1571"), data:1571, group:1},
			{label:loc("1573"), data:1573, group:2},
			{label:loc("1581"), data:1581, group:1},
			{label:loc("1583"), data:1583, group:2},
			{label:loc("1591"), data:1591, group:1},
			{label:loc("1593"), data:1593, group:2},
			{label:loc("1611"), data:1611, group:1},
			{label:loc("1613"), data:1613, group:2},
			{label:loc("2001"), data:2001, group:3},
			{label:loc("2003"), data:2003, group:4},
			{label:loc("2011"), data:2011, group:3},
			{label:loc("2013"), data:2013, group:4},
			{label:loc("2021"), data:2021, group:3},
			{label:loc("2023"), data:2023, group:4},
			{label:loc("2031"), data:2031, group:3},
			{label:loc("2033"), data:2033, group:4},
			{label:loc("2041"), data:2041, group:3},
			{label:loc("2043"), data:2043, group:4},
			{label:loc("2051"), data:2051, group:3},
			{label:loc("2053"), data:2053, group:4},
			{label:loc("2061"), data:2061, group:3},
			{label:loc("2063"), data:2063, group:4},
			{label:loc("3001"), data:3001, group:8 },
			{label:loc("3003"), data:3003, group:8 },
			{label:loc("3011"), data:3011, group:8 },
			{label:loc("3013"), data:3013, group:8 },
			{label:loc("3021"), data:3021, group:8 },
			{label:loc("3023"), data:3023, group:8 },
			{label:loc("3031"), data:3031, group:8 },
			{label:loc("3033"), data:3033, group:8 },
			{label:loc("3041"), data:3041, group:8 },
			{label:loc("3043"), data:3043, group:8 },
			{label:loc("3051"), data:3051, group:8 },
			{label:loc("3061"), data:3061, group:8 },
			{label:loc("3071"), data:3071, group:8 },
			{label:loc("3073"), data:3073, group:8 },
			{label:loc("3081"), data:3081, group:8 },
			{label:loc("3091"), data:3091, group:8 },
			{label:loc("3093"), data:3093, group:8 },
			{label:loc("3101"), data:3101, group:8 },
			{label:loc("3103"), data:3103, group:8 },
			{label:loc("3121"), data:3121, group:8 },
			{label:loc("3123"), data:3123, group:8 },
			{label:loc("3191"), data:3191, group:8 },
			{label:loc("3193"), data:3193, group:8 },
			{label:loc("3201"), data:3201, group:8 },
			{label:loc("3203"), data:3203, group:8 },
			{label:loc("3211"), data:3211, group:8 },
			{label:loc("3213"), data:3213, group:8 },
			{label:loc("3221"), data:3221, group:8 },
			{label:loc("3223"), data:3223, group:8 },
			{label:loc("3231"), data:3231, group:8 },
			{label:loc("3233"), data:3233, group:8 },
			{label:loc("3241"), data:3241, group:8 },
			{label:loc("3243"), data:3243, group:8 },
			{label:loc("3251"), data:3251, group:8 },
			{label:loc("3253"), data:3253, group:8 },
			{label:loc("3301"), data:3301, group:8 },
			{label:loc("3303"), data:3303, group:8 },
			{label:loc("3311"), data:3311, group:8 },                               
			{label:loc("3321"), data:3321, group:8 },
			{label:loc("3323"), data:3323, group:8 },
			{label:loc("3331"), data:3331, group:8 },
			{label:loc("3333"), data:3333, group:8 },
			{label:loc("3341"), data:3341, group:8 },
			{label:loc("3343"), data:3343, group:8 },
			{label:loc("3441"), data:3441, group:8 },
			{label:loc("3443"), data:3443, group:8 },
			{label:loc("3501"), data:3501, group:8 },
			{label:loc("3503"), data:3503, group:8 },
			{label:loc("3511"), data:3511, group:8 },
			{label:loc("3513"), data:3513, group:8 },
			{label:loc("3521"), data:3521, group:8 },
			{label:loc("3523"), data:3523, group:8 },
			{label:loc("3531"), data:3531, group:8 },
			{label:loc("3533"), data:3533, group:8 },
			{label:loc("3541"), data:3541, group:8 },
			{label:loc("3551"), data:3551, group:8 },
			{label:loc("3553"), data:3553, group:8 },
			{label:loc("3561"), data:3561, group:8 },
			{label:loc("3563"), data:3563, group:8 },
			{label:loc("3701"), data:3701, group:8 },
			{label:loc("3703"), data:3703, group:8 },
			{label:loc("3711"), data:3711, group:8 },
			{label:loc("3713"), data:3713, group:8 },
			{label:loc("3721"), data:3721, group:8 },
			{label:loc("3723"), data:3723, group:8 },
			{label:loc("3731"), data:3731, group:8 },
			{label:loc("3733"), data:3733, group:8 },
			{label:loc("3801"), data:3801, group:8 },
			{label:loc("3803"), data:3803, group:8 },
			{label:loc("3811"), data:3811, group:8 },
			{label:loc("3813"), data:3813, group:8 },
			{label:loc("3821"), data:3821, group:8 },
			{label:loc("3823"), data:3823, group:8 },
			{label:loc("3831"), data:3831, group:8 },
			{label:loc("3833"), data:3833, group:8 },
			{label:loc("3841"), data:3841, group:8 },
			{label:loc("3843"), data:3843, group:8 },
			{label:loc("4001"), data:4001, group:5 },
			{label:loc("4003"), data:4003, group:6 },
			{label:loc("4011"), data:4011, group:5 },
			{label:loc("4013"), data:4013, group:6 },
			{label:loc("4021"), data:4021, group:5 },
			{label:loc("4023"), data:4023, group:6 },
			{label:loc("4031"), data:4031, group:5 },
			{label:loc("4033"), data:4033, group:6 },
			{label:loc("4041"), data:4041, group:5 },
			{label:loc("4043"), data:4043, group:6 },
			{label:loc("4051"), data:4051, group:5 },
			{label:loc("4053"), data:4053, group:6 },
			{label:loc("4061"), data:4061, group:5 },
			{label:loc("4063"), data:4063, group:6 },
			{label:loc("4071"), data:4071, group:5 },
			{label:loc("4073"), data:4073, group:6 },
			{label:loc("4083"), data:4083, group:6 },
			{label:loc("4091"), data:4091, group:5 },
			{label:loc("4093"), data:4093, group:6 },
			{label:loc("4111"), data:4111, group:8 },
			{label:loc("4413"), data:4413, group:6 },
			{label:loc("4501"), data:4501, group:6 },
			{label:loc("4503"), data:4503, group:6 },
			{label:loc("4611"), data:4611, group:8 },
			{label:loc("4591"), data:4591, group:1 },
			{label:loc("4593"), data:4593, group:2 },
			{label:loc("5001"), data:5001, group:8 },
			{label:loc("5003"), data:5003, group:8 },
			{label:loc("5201"), data:5201, group:8 },
			{label:loc("5203"), data:5203, group:8 },
			{label:loc("5211"), data:5211, group:8 },
			{label:loc("5213"), data:5213, group:8 },
			{label:loc("5221"), data:5221, group:8 },
			{label:loc("5223"), data:5223, group:8 },
			{label:loc("5231"), data:5231, group:8 },
			{label:loc("5233"), data:5233, group:8 },
			{label:loc("5241"), data:5241, group:8 },
			{label:loc("5243"), data:5243, group:8 },
			{label:loc("5251"), data:5251, group:8 },
			{label:loc("5253"), data:5253, group:8 },
			{label:loc("5301"), data:5301, group:8 },
			{label:loc("5303"), data:5303, group:8 },
			{label:loc("5511"), data:5511, group:8 },
			{label:loc("5513"), data:5513, group:8 },
			{label:loc("5521"), data:5521, group:8 },
			{label:loc("5523"), data:5523, group:8 },
			{label:loc("5701"), data:5701, group:8 },
			{label:loc("5703"), data:5703, group:8 },
			{label:loc("5711"), data:5711, group:8 },
			{label:loc("5713"), data:5713, group:8 },
			{label:loc("5721"), data:5721, group:8 },
			{label:loc("5723"), data:5723, group:8 },
			{label:loc("5731"), data:5731, group:8 },
			{label:loc("5733"), data:5733, group:8 },
			{label:loc("5741"), data:5741, group:8 },
			{label:loc("5743"), data:5743, group:8 },
			{label:loc("6011"), data:6011, group:7 },
			{label:loc("6021"), data:6021, group:7 },
			{label:loc("6031"), data:6031, group:7 },
			{label:loc("6041"), data:6041, group:7 },
			{label:loc("6051"), data:6051, group:7 },
			{label:loc("6061"), data:6061, group:7 },
			{label:loc("6063"), data:6063, group:7 },
			{label:loc("6071"), data:6071, group:7 },
			{label:loc("6211"), data:6211, group:8 },
			{label:loc("6221"), data:6221, group:8 },
			{label:loc("6241"), data:6241, group:8 },
			{label:loc("6251"), data:6251, group:8 },
			{label:loc("6261"), data:6261, group:8 },
			{label:loc("6263"), data:6263, group:8 },
			{label:loc("6271"), data:6271, group:8 },
			{label:loc("6281"), data:6281, group:8 },
			{label:loc("6311"), data:6311, group:8 },
			{label:loc("9981"), data:9981, group:8 },
			//"9981":"998.1 Температура изменилась",
		];
		private static const CID_RFSENSOR_K16:Array =	[	{label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1011"), data:1011, group:9 },
			{label:loc("1021"), data:1021, group:9 },
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1111"), data:1111, group:3},
			{label:loc("1121"), data:1121, group:3},
			{label:loc("1131"), data:1131, group:3},
			{label:loc("1141"), data:1141, group:3},
			{label:loc("1151"), data:1151, group:3},
			{label:loc("1161"), data:1161, group:3},
			{label:loc("1171"), data:1171, group:3},
			{label:loc("1181"), data:1181, group:3},
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1211"), data:1211, group:1},
			{label:loc("1221"), data:1221, group:1},
			{label:loc("1231"), data:1231, group:1},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1321"), data:1321, group:1},
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1381"), data:1381, group:1},
			{label:loc("1391"), data:1391, group:1},
			{label:loc("1401"), data:1401, group:1},
			{label:loc("1411"), data:1411, group:1},
			{label:loc("1421"), data:1421, group:1},
			{label:loc("1431"), data:1431, group:1},
			{label:loc("1441"), data:1441, group:1},
			{label:loc("1451"), data:1451, group:1},
			{label:loc("1471"), data:1471, group:1},
			{label:loc("1501"), data:1501, group:1},
			{label:loc("1511"), data:1511, group:1},
			{label:loc("1521"), data:1521, group:1},
			{label:loc("1531"), data:1531, group:1},
			{label:loc("1541"), data:1541, group:1},
			{label:loc("1551"), data:1551, group:1},
			{label:loc("1561"), data:1561, group:1},
			{label:loc("1571"), data:1571, group:1},
			{label:loc("1581"), data:1581, group:1},
			{label:loc("1591"), data:1591, group:1},
			{label:loc("1611"), data:1611, group:1},
			{label:loc("2001"), data:2001, group:3},
			{label:loc("2011"), data:2011, group:3},
			{label:loc("2021"), data:2021, group:3},
			{label:loc("2031"), data:2031, group:3},
			{label:loc("2041"), data:2041, group:3},
			{label:loc("2051"), data:2051, group:3},
			{label:loc("2061"), data:2061, group:3},
			{label:loc("3001"), data:3001, group:8 },
			{label:loc("3011"), data:3011, group:8 },
			{label:loc("3021"), data:3021, group:8 },
			{label:loc("3031"), data:3031, group:8 },
			{label:loc("3041"), data:3041, group:8 },
			{label:loc("3051"), data:3051, group:8 },
			{label:loc("3061"), data:3061, group:8 },
			{label:loc("3071"), data:3071, group:8 },
			{label:loc("3081"), data:3081, group:8 },
			{label:loc("3091"), data:3091, group:8 },
			{label:loc("3101"), data:3101, group:8 },
			{label:loc("3121"), data:3121, group:8 },
			{label:loc("3191"), data:3191, group:8 },
			{label:loc("3201"), data:3201, group:8 },
			{label:loc("3211"), data:3211, group:8 },
			{label:loc("3221"), data:3221, group:8 },
			{label:loc("3231"), data:3231, group:8 },
			{label:loc("3241"), data:3241, group:8 },
			{label:loc("3251"), data:3251, group:8 },
			{label:loc("3301"), data:3301, group:8 },
			{label:loc("3311"), data:3311, group:8 },                               
			{label:loc("3321"), data:3321, group:8 },
			{label:loc("3331"), data:3331, group:8 },
			{label:loc("3341"), data:3341, group:8 },
			{label:loc("3351"), data:3351, group:8 },
			{label:loc("3361"), data:3361, group:8 },
			{label:loc("3441"), data:3441, group:8 },
			{label:loc("3501"), data:3501, group:8 },
			{label:loc("3511"), data:3511, group:8 },
			{label:loc("3521"), data:3521, group:8 },
			{label:loc("3531"), data:3531, group:8 },
			{label:loc("3541"), data:3541, group:8 },
			{label:loc("3551"), data:3551, group:8 },
			{label:loc("3561"), data:3561, group:8 },
			{label:loc("3701"), data:3701, group:8 },
			{label:loc("3711"), data:3711, group:8 },
			{label:loc("3721"), data:3721, group:8 },
			{label:loc("3731"), data:3731, group:8 },
			{label:loc("3801"), data:3801, group:8 },
			{label:loc("3811"), data:3811, group:8 },
			{label:loc("3821"), data:3821, group:8 },
			{label:loc("3831"), data:3831, group:8 },
			{label:loc("3841"), data:3841, group:8 },
			{label:loc("4001"), data:4001, group:5 },
			{label:loc("4011"), data:4011, group:5 },
			{label:loc("4021"), data:4021, group:5 },
			{label:loc("4031"), data:4031, group:5 },
			{label:loc("4041"), data:4041, group:5 },
			{label:loc("4051"), data:4051, group:5 },
			{label:loc("4061"), data:4061, group:5 },
			{label:loc("4071"), data:4071, group:5 },
			{label:loc("4091"), data:4091, group:5 },
			{label:loc("4111"), data:4111, group:8 },
			{label:loc("4121"), data:4121, group:8 },
			{label:loc("4131"), data:4131, group:8 },
			{label:loc("4141"), data:4141, group:8 },
			{label:loc("4151"), data:4151, group:8 },
			{label:loc("4221"), data:4221, group:8 },
			{label:loc("4611"), data:4611, group:8 },
			{label:loc("5001"), data:5001, group:8 },
			{label:loc("5201"), data:5201, group:8 },
			{label:loc("5211"), data:5211, group:8 },
			{label:loc("5221"), data:5221, group:8 },
			{label:loc("5231"), data:5231, group:8 },
			{label:loc("5241"), data:5241, group:8 },
			{label:loc("5251"), data:5251, group:8 },
			{label:loc("5301"), data:5301, group:8 },
			{label:loc("5511"), data:5511, group:8 },
			{label:loc("5521"), data:5521, group:8 },
			{label:loc("5701"), data:5701, group:8 },
			{label:loc("5711"), data:5711, group:8 },
			{label:loc("5721"), data:5721, group:8 },
			{label:loc("5731"), data:5731, group:8 },
			{label:loc("5741"), data:5741, group:8 },
			{label:loc("6011"), data:6011, group:7 },
			{label:loc("6021"), data:6021, group:7 },
			{label:loc("6031"), data:6031, group:7 },
			{label:loc("6041"), data:6041, group:7 },
			{label:loc("6051"), data:6051, group:7 },
			{label:loc("6061"), data:6061, group:7 },
			{label:loc("6071"), data:6071, group:7 },
			{label:loc("6211"), data:6211, group:8 },
			{label:loc("6221"), data:6221, group:8 },
			{label:loc("6231"), data:6231, group:8 },
			{label:loc("6241"), data:6241, group:8 },
			{label:loc("6251"), data:6251, group:8 },
			{label:loc("6261"), data:6261, group:8 },
			{label:loc("6271"), data:6271, group:8 },
			{label:loc("6281"), data:6281, group:8 },
			{label:loc("6311"), data:6311, group:8 },
			{label:loc("9981"), data:9981, group:8 }
		];
		private static const CID_RFSENSOR_K14_K7:Array =	[	{label:loc("g_no"), data:0},
			{label:loc("1001"), data:1001, group:9 },
			{label:loc("1011"), data:1011, group:9 },
			{label:loc("1021"), data:1021, group:9 },
			{label:loc("1101"), data:1101, group:3},
			{label:loc("1111"), data:1111, group:3},
			{label:loc("1121"), data:1121, group:3},
			{label:loc("1131"), data:1131, group:3},
			{label:loc("1141"), data:1141, group:3},
			{label:loc("1151"), data:1151, group:3},
			{label:loc("1161"), data:1161, group:3},
			{label:loc("1171"), data:1171, group:3},
			{label:loc("1181"), data:1181, group:3},
			{label:loc("1201"), data:1201, group:1},
			{label:loc("1211"), data:1211, group:1},
			{label:loc("1221"), data:1221, group:1},
			{label:loc("1231"), data:1231, group:1},
			{label:loc("1301"), data:1301, group:1},
			{label:loc("1311"), data:1311, group:1},
			{label:loc("1321"), data:1321, group:1},
			{label:loc("1331"), data:1331, group:1},
			{label:loc("1341"), data:1341, group:1},
			{label:loc("1351"), data:1351, group:1},
			{label:loc("1361"), data:1361, group:1},
			{label:loc("1371"), data:1371, group:1},
			{label:loc("1391"), data:1391, group:1},
			{label:loc("1401"), data:1401, group:1},
			{label:loc("1411"), data:1411, group:1},
			{label:loc("1421"), data:1421, group:1},
			{label:loc("1431"), data:1431, group:1},
			{label:loc("1441"), data:1441, group:1},
			{label:loc("1451"), data:1451, group:1},
			{label:loc("1471"), data:1471, group:1},
			{label:loc("1501"), data:1501, group:1},
			{label:loc("1511"), data:1511, group:1},
			{label:loc("1521"), data:1521, group:1},
			{label:loc("1531"), data:1531, group:1},
			{label:loc("1541"), data:1541, group:1},
			{label:loc("1551"), data:1551, group:1},
			{label:loc("1561"), data:1561, group:1},
			{label:loc("1571"), data:1571, group:1},
			{label:loc("1581"), data:1581, group:1},
			{label:loc("1591"), data:1591, group:1},
			{label:loc("1611"), data:1611, group:1},
			{label:loc("2001"), data:2001, group:3},
			{label:loc("2011"), data:2011, group:3},
			{label:loc("2021"), data:2021, group:3},
			{label:loc("2031"), data:2031, group:3},
			{label:loc("2041"), data:2041, group:3},
			{label:loc("2051"), data:2051, group:3},
			{label:loc("2061"), data:2061, group:3},
			{label:loc("3001"), data:3001, group:8 },
			{label:loc("3011"), data:3011, group:8 },
			{label:loc("3031"), data:3031, group:8 },
			{label:loc("3041"), data:3041, group:8 },
			{label:loc("3071"), data:3071, group:8 },
			{label:loc("3081"), data:3081, group:8 },
			{label:loc("3091"), data:3091, group:8 },
			{label:loc("3101"), data:3101, group:8 },
			{label:loc("3121"), data:3121, group:8 },
			{label:loc("3191"), data:3191, group:8 },
			{label:loc("3201"), data:3201, group:8 },
			{label:loc("3211"), data:3211, group:8 },
			{label:loc("3221"), data:3221, group:8 },
			{label:loc("3231"), data:3231, group:8 },
			{label:loc("3241"), data:3241, group:8 },
			{label:loc("3251"), data:3251, group:8 },
			{label:loc("3301"), data:3301, group:8 },
			{label:loc("3311"), data:3311, group:8 },                               
			{label:loc("3321"), data:3321, group:8 },
			{label:loc("3331"), data:3331, group:8 },
			{label:loc("3701"), data:3701, group:8 },
			{label:loc("3711"), data:3711, group:8 },
			{label:loc("3721"), data:3721, group:8 },
			{label:loc("3731"), data:3731, group:8 },
			{label:loc("3801"), data:3801, group:8 },
			{label:loc("3811"), data:3811, group:8 },
			{label:loc("3831"), data:3831, group:8 },
			{label:loc("3841"), data:3841, group:8 },
			{label:loc("4001"), data:4001, group:5 },
			{label:loc("4011"), data:4011, group:5 },
			{label:loc("4021"), data:4021, group:5 },
			{label:loc("4031"), data:4031, group:5 },
			{label:loc("4041"), data:4041, group:5 },
			{label:loc("4051"), data:4051, group:5 },
			{label:loc("4061"), data:4061, group:5 },
			{label:loc("4071"), data:4071, group:5 },
			{label:loc("4091"), data:4091, group:5 },
			{label:loc("5001"), data:5001, group:8 },
			{label:loc("5201"), data:5201, group:8 },
			{label:loc("5211"), data:5211, group:8 },
			{label:loc("5231"), data:5231, group:8 },
			{label:loc("5301"), data:5301, group:8 },
			{label:loc("5511"), data:5511, group:8 },
			{label:loc("5521"), data:5521, group:8 },
			{label:loc("5701"), data:5701, group:8 },
			{label:loc("5711"), data:5711, group:8 },
			{label:loc("5721"), data:5721, group:8 },
			{label:loc("5731"), data:5731, group:8 },
			{label:loc("5741"), data:5741, group:8 },
			{label:loc("6061"), data:6061, group:7 },
		];
		private static var CID_K5:Array;
		private static const CID_K5_BASE:Array = [
			{label:loc("6311"), data:6311},
			{label:loc("9981"), data:9981},
			{label:loc("7501"), data:7501}
		];
		/// 
		/**
		 * 3. Так же выявили такую особенность что на шлейфы можно назначить событие "нет". 
		 * Видимо досталось от К-14\16. Там зоны можно отключить выставив событие  "нет". 
		 * В К-1М и всех К-9, а также К-5 зоны не отключаются.  
		 * В результате видим формирование пустого события по зонам. 
		 * Опять же решим средствами программы конфигурации-просто уберем значение "нет" из списка.
		 *   https://megaplan.ritm.ru/task/1064992/card/
		 * 
		 */
		private static const CID_K5_WIRE:Array =    [    /*{label:loc("g_no"), data:0},*/
			{label:loc("1001"), data:100},
			{label:loc("1011"), data:101},
			{label:loc("1021"), data:102},
			{label:loc("1101"), data:110},
			{label:loc("1111"), data:111},
			{label:loc("1121"), data:112},
			{label:loc("1131"), data:113},
			{label:loc("1141"), data:114},
			{label:loc("1151"), data:115},
			{label:loc("1161"), data:116},
			{label:loc("1171"), data:117},
			{label:loc("1181"), data:118},
			{label:loc("1201"), data:120},
			{label:loc("1211"), data:121},
			{label:loc("1221"), data:122},
			{label:loc("1231"), data:123},
			{label:loc("1301"), data:130},
			{label:loc("1311"), data:131},
			{label:loc("1321"), data:132},
			{label:loc("1331"), data:133},
			{label:loc("1341"), data:134},
			{label:loc("1351"), data:135},
			{label:loc("1361"), data:136},
			{label:loc("1371"), data:137},
			{label:loc("1381"), data:138},
			{label:loc("1391"), data:139},
			{label:loc("1401"), data:140},
			{label:loc("1411"), data:141},
			{label:loc("1421"), data:142},
			{label:loc("1431"), data:143},
			{label:loc("1441"), data:144},
			{label:loc("1451"), data:145},
			{label:loc("1501"), data:150},
			{label:loc("1511"), data:151},
			{label:loc("1521"), data:152},
			{label:loc("1531"), data:153},
			{label:loc("1541"), data:154},
			{label:loc("1551"), data:155},
			{label:loc("1561"), data:156},
			{label:loc("1571"), data:157},
			{label:loc("1581"), data:158},
			{label:loc("1591"), data:159},
			{label:loc("1611"), data:161},
			{label:loc("2001"), data:200},
			{label:loc("2011"), data:201},
			{label:loc("2021"), data:202},
			{label:loc("2031"), data:203},
			{label:loc("2041"), data:204},
			{label:loc("2051"), data:205},
			{label:loc("2061"), data:206},
			{label:loc("3001"), data:300},
			{label:loc("3011"), data:301},
			{label:loc("3021"), data:302},
			{label:loc("3031"), data:303},
			{label:loc("3041"), data:304},
			{label:loc("3051"), data:305},
			{label:loc("3061"), data:306},
			{label:loc("3071"), data:307},
			{label:loc("3081"), data:308, group:8 },
			{label:loc("3091"), data:309},
			{label:loc("3101"), data:310},
			{label:loc("3121"), data:312},
			{label:loc("3191"), data:319},
			{label:loc("3201"), data:320},
			{label:loc("3211"), data:321},
			{label:loc("3221"), data:322},
			{label:loc("3231"), data:323},
			{label:loc("3241"), data:324},
			{label:loc("3251"), data:325},
			{label:loc("3301"), data:330},
			{label:loc("3311"), data:331},
			{label:loc("3321"), data:332},
			{label:loc("3331"), data:333},
			{label:loc("3341"), data:334},
			{label:loc("3351"), data:335},
			{label:loc("3361"), data:336},
			{label:loc("3441"), data:344},
			{label:loc("3501"), data:350},
			{label:loc("3511"), data:351},
			{label:loc("3521"), data:352},
			{label:loc("3531"), data:353},
			{label:loc("3541"), data:354},
			{label:loc("3551"), data:355},
			{label:loc("3561"), data:356},
			{label:loc("3701"), data:370},
			{label:loc("3711"), data:371},
			{label:loc("3721"), data:372},
			{label:loc("3731"), data:373},
			{label:loc("3801"), data:380},
			{label:loc("3811"), data:381},
			{label:loc("3821"), data:382},
			{label:loc("3831"), data:383},
			{label:loc("3841"), data:384},
			{label:loc("4001"), data:400},
			{label:loc("4011"), data:401},
			{label:loc("4021"), data:402},
			{label:loc("4031"), data:403},
			{label:loc("4041"), data:404},
			{label:loc("4051"), data:405},
			{label:loc("4061"), data:406},
			{label:loc("4071"), data:407},
			{label:loc("4091"), data:409},
			{label:loc("4111"), data:411},
			{label:loc("4121"), data:412},
			{label:loc("4131"), data:413},
			{label:loc("4141"), data:414},
			{label:loc("4151"), data:415},
			{label:loc("4211"), data:421},
			{label:loc("4221"), data:422},
			{label:loc("5001"), data:500},
			{label:loc("5201"), data:520},
			{label:loc("5211"), data:521},
			{label:loc("5221"), data:522},
			{label:loc("5231"), data:523},
			{label:loc("5241"), data:524},
			{label:loc("5251"), data:525},
			{label:loc("5251"), data:530},
			{label:loc("5511"), data:551},
			{label:loc("5521"), data:552},
			{label:loc("5701"), data:570},
			{label:loc("5711"), data:571},
			{label:loc("5721"), data:572},
			{label:loc("5731"), data:573},
			{label:loc("5741"), data:574},
			{label:loc("6011"), data:601},
			{label:loc("6021"), data:602},
			{label:loc("6031"), data:603},
			{label:loc("6041"), data:604},
			{label:loc("6051"), data:605},
			{label:loc("6051"), data:606},
			{label:loc("6071"), data:607},
			{label:loc("6211"), data:621},
			{label:loc("6221"), data:622},
			{label:loc("6231"), data:623},
			{label:loc("6241"), data:624},
			{label:loc("6251"), data:625},
			{label:loc("6261"), data:626},
			{label:loc("6271"), data:627},
			{label:loc("6281"), data:628},
			{label:loc("6311"), data:631},
			{label:loc("7501"), data:750}
		];
		private static const RAWCID_SYSTEM_LINKCHANNELS:Array =	[ 	
			0x1211,	0x1391,	0x1393,	0x1441,	0x1443,0x1581, 
			0x1583, 0x1591, 0x1593,
			0x3011, 0x3013,	0x3021,	0x3023, 0x3051,	0x3091,
			0x3801, 0x3831,	0x3833,	0x3841,	0x3843,
			0x4001, 0x4003,	0x4011,	0x4013, 0x4021,
			0x4023, 0x4061,	0x4063,	0x4071,	0x4073,
			0x4083, 0x4413,	0x4503,	0x4591,	0x4593,
			0x6021, 0x6211,	0x6271,	0x6281,	0x1471,
			0x1473, 0x1001,	0x4611,	0x1201,	0x1101,
			0x4501,	0x3801, 0x1381, 0x9981
		];
	}
}