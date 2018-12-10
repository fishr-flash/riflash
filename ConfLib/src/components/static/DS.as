package components.static
{
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.protocol.statics.SERVER;

	public class DS
	{
		public static const K16:String = "K-16";
		public static const K16_3G:String = "K-16-3G";
		public static const LCD1:String = "LCD-1";
		public static const LCD2:String = "LCD-2";
		public static const LCD3:String = "LCD-3";
		public static const LCD4:String = "LCD-4";
		public static const K14:String = "K-14";
		public static const K14A:String = "K-14A";
		public static const K14W:String = "K-14W";
		public static const K14L:String = "K-14L";
		public static const K14AW:String = "K-14AW";
		public static const K14K:String = "K-14K";
		public static const K14KW:String = "K-14KW";
		public static const K7:String = "K-7"; /// неизвестный прибор
		public static const K2:String = "K-2";
		public static const K2M:String = "K-2M";
		public static const KLAN:String = "K-LAN";
		public static const A_ETH:String = "A-ETH";
		public static const V2:String = "V-2";
		public static const V_ASN:String = "V-ASN";
		public static const V2_3G:String = "V-2-3G";
		public static const V3:String = "V-3";
		public static const V3L:String = "V-3L";
		public static const V3L_3G:String = "V-3L-3G";
		public static const V4:String = "V-4";
		public static const V5:String = "V-5";
		public static const V6:String = "V-6";
		public static const V15:String = "V-15";	// проект Вояджер 15
		public static const V15IP:String = "V-15IP";	// проект Вояджер 15IP
		public static const ACC1:String = "ACC-1";
		public static const ACC2:String = "ACC-2";
		public static const F_VL:String = "F-VL";
		public static const VL0:String = "V-L0";
		public static const VL1:String = "V-L1";
		public static const VL1_3G:String = "V-L1-3G";
		public static const VL2:String = "V-L2";
		public static const VL2_3G:String = "V-L2-3G";
		public static const VL3:String = "V-L3";
		public static const VL3_3G:String = "V-L3-3G";
		public static const V_BRPM:String = "V-BRPM";
		public static const F_V:String = "F_V";
		public static const K15:String = "K-15";	// проект Вояджер 15
		public static const K15IP:String = "K-15IP";	// проект Вояджер 15
		public static const K1:String = "K-1";
		public static const K1M:String = "K-1M";
		public static const K5:String = "K-5";
		public static const K5A:String = "K-5A";
		public static const K5AA:String = "K-5AA";
		public static const A_BRD:String = "A-BRD";
		public static const K5GL:String = "K-5GL";
		public static const K53G:String = "K-5-3G";
		public static const K5RT1:String = "K-RT1";	// K5 RT1
		public static const K5RT13G:String = "K-RT1-3G";	// K5 RT1
		public static const K5RT1L:String = "K-RT1L";	// K5 RT1L
		public static const K5RT3:String = "K-RT3";	// K5 RT3
		public static const K5RT3L:String = "K-RT3L";	// K5 RT3L
		public static const K5RT33G:String = "K-RT3-3G";	// K5 RT3L
		public static const K9:String = "K-9";
		public static const K9A:String = "K-9A";
		public static const K9M:String = "K-9M";
		public static const K9K:String = "K-9K";
		public static const V2T:String = "V-2T";
		public static const C15:String = "C-15";	// проект Вояджер 15
		public static const MR1:String = "M-R1";
		public static const MS1:String = "M-S1";
		public static const MT1:String = "M-T1";
		public static const M_RR1:String = "M-RR1";
		public static const R15:String = "R-15";	// проект Вояджер 15
		public static const R15IP:String = "R-15IP";	// проект Вояджер 15
		public static const R10:String = "R-10";	// Интеллектуальное реле
		public static const A_REL:String = "A-REL";	// Интеллектуальное реле красная плата
		public static const VM:String = "V-M";	// Android Trakker
		public static const RDK:String = "RDK";	// RDK
		public static const RDK_LR:String = "RDK-LR";	// RDK-LR ( RDK LoRa )
		public static const WTS_1:String = "WTS-1";	// датчик 
		public static const F_VL_3G:String = "F_VL_3G";	// группа вояджеров с расширением 3G
		public static const asAKAW:String = "asAKAW";	// k-14 A,K,AW
		
		
		public static var fgetStatus:Function;
		
		static private var FAMILY:Object = null;
		
		
		/**
		 * 	Сюда передается идентификатор "главы" симейства
		 * того или иного прибора, напр. K-1 является главой
		 * семейства K-1, K-1M. Чтобы узнать ялвяется ли подключенный
		 * прибор представителем того или иного семейства. Это
		 * обычно нужно для того чтобы текущий прибор отождествить
		 * с основным если те или иные операции для основного прибора
		 * поддходят без изменений для текущего.
		 * 
		 * Все семейства указываются тут же и объект FAMILY формируется
		 * при первом же вызове метода...
		 * 
		 *  
		 * @param father условное наименование семейства приборов отношение к которому проверяется текущего прибора
		 * @param ...excludes если надо исключить приборы из заданного семейства перечисляем их после первого пар-ра
		 * @return если совпадение найдено возвращает строковое значение текущего прибора, если нет вернет null
		 * 
		 */		
		public static function isfam( father:String, ...excludes ):String
		{
			var isMe:Boolean = false;
			if(!FAMILY )
			{
				
				FAMILY = {};
				FAMILY[ DS.K1 ] = [ K1, K1M ];
				FAMILY[ DS.LCD3 ] = [ LCD3, LCD4 ];
				FAMILY[ DS.K15 ] = [ K15, K15IP ];
				FAMILY[ DS.K16 ] = [ K16, K16_3G ];
				FAMILY[ DS.K9 ] = [ K9, K9A, K9M, K9K ];
				FAMILY[ DS.K2 ] = [ K2, K2M ];
				FAMILY[ DS.K5 ] = [ K5, K5A, K5GL, K53G, K5AA, A_BRD  ];
				FAMILY[ DS.K5A ] = [ K5, K5A, K5GL, K53G  ];
				FAMILY[ DS.K5AA ] = [ K5A, K5AA, A_BRD  ];
				FAMILY[ DS.K5RT3 ] = [  K5RT3, K5RT3L, K5RT33G ];
				FAMILY[ DS.K5RT1 ] = [  K5RT1, K5RT1L, K5RT13G ];
				FAMILY[ DS.K14 ] = [ K14, K14A, K14AW, K14L, K14W, K14K, K14KW ];
				FAMILY[ DS.K14W ] = [ K14AW, K14W, K14KW ];
				FAMILY[ DS.VL0 ] = [ VL2, V2, V2_3G, VL3, V3, V3L, V4, V6, V_ASN ];
				FAMILY[ DS.V2 ] = [ V2, V2_3G, V2T, V_ASN, V_BRPM ];
				FAMILY[ DS.F_VL_3G ] = [ VL1_3G, VL2_3G, V3L_3G, VL3_3G  ];
				FAMILY[ DS.F_VL ] = [ VL0, VL1, VL1_3G, VL2, VL2_3G, VL3, VL3_3G ];
				FAMILY[ DS.VL3 ] = [ VL3, VL3_3G ];
				FAMILY[ DS.F_V ] = [ VL0, VL1, VL1_3G, VL2, VL2_3G, VL3, VL3_3G, V2, V2_3G, V2T, V4, V6, V_BRPM, V_ASN    ];
				FAMILY[ DS.asAKAW ] = [ K14A, K14K, K14AW ];
				FAMILY[ DS.V15 ] = [ V15, V15IP ];
				FAMILY[ DS.R10 ] = [ R10, A_REL ];
				FAMILY[ DS.KLAN ] = [ KLAN, A_ETH ];
				
				
				
				
			}
			
			
			
			isMe = FAMILY[ father ].indexOf( DS.alias ) > -1 && !( excludes != null && excludes.indexOf( DS.alias ) > -1 );
			
			 return isMe?DS.alias:null;
		}
		
		public static function isVoyager():Boolean
		{
			switch(deviceAlias) {
				case VL0:
				case VL1:
				case VL2:
				case VL3:
				case V2:
				case V2_3G:
				case V3:
				case V3L:
				case V4:
				case V5:
				case V6:
				case V15:
				case V15IP:
				case V2T:
				case ACC2:
				case DS.isfam( DS.F_V ):
				
					return true;
			}
			return false;
		}
		public static function get isRFM():Boolean
		{
			switch(deviceAlias) {
				case MR1:
				case MS1:
				case MT1:
					return true;
			}
			return false;
		}
		public static function get isK14s():Boolean
		{
			switch(deviceAlias) {
				case K14:
				case K14A:
				case K14W:
				case K14AW:
				case K14K:
				case K14KW:
				case K14L:
					return true;
			}
			return false;
		}
		public static function get isVgr():Boolean
		{
			switch(deviceAlias) {
				case VL0:
				case VL1:
				case VL2:
				case VL3:
				case V2:
				case V3:
				case V3L:
				case V4:
				case V5:
				case V6:
				case V2T:
				case V_BRPM:
					return true;
			}
			return false;
		}
		
		public static function get asK9():String
		{
			var result:String = deviceAlias;
			
			switch( result ) {
				case K9:
				case K9A:
				case K9M:
				case K9K:
					result = K9;
					
					break;
				default:
					break;
			}
			
			return result;
		}
		public static function isV15():Boolean
		{
			switch(deviceAlias) {
				case V15:
				case V15IP:
					return true;
			}
			return false;
		}
		public static function isNoEGTSVojagers( deviceId:String ):Boolean
		{
			
			const noEgtsDevices:Array = [ DS.V3
										, DS.V3L
										, DS.V3L_3G
										, DS.V4
										, DS.V5
										, DS.V6
										, DS.V_BRPM
										, DS.VL0 ];
			
			if( DS.release < 42 ) return false;
			
			return noEgtsDevices.indexOf( deviceId ) == -1;
		}
		public static function get fullver():String
		{
			return SERVER.VER_FULL;
		}
		public static function get app():String
		{
			return SERVER.HARDWARE_VER;
		}
		public static function get commit():String
		{
			var a:Array = SERVER.VER_SOFTWARE.split(".");
			if (a && a[1])
				return String(a[1]);
			return "#error.commit";
		}
		public static function get bootloader():String
		{
			var a:Array = SERVER.VER_SOFTWARE.split(".");
			if (a && a[2])
				return String(a[2]);
			return "#error.bootloader";
		}
		public static function getCommit():String
		{
			var a:Array = SERVER.VER_SOFTWARE.split(".");
			if (a && a[1] && a[2])
				return String(a[1]+"."+a[2]);
			return "#error.commit";
		}
		public static function getBootloader():String
		{
			var a:Array = SERVER.VER_SOFTWARE.split(".");
			if (a && a[2])
				return String(a[2]);
			return "#error.bootloader";
		}
		public static function getStatusVersion():String
		{
			if( fgetStatus is Function )
				return fgetStatus()
			return SERVER.VER_FULL;
		}
		public static function getName():String
		{
			return deviceAlias;
		}
		public static function get release():int
		{
			var a:Array = SERVER.VER_FULL.split(".");
			if (a && a[2])
				return int(a[2]);
			return 0;
		}
		public static function getRelease():String
		{
			var a:Array = SERVER.VER_FULL.split(".");
			if (a && a[2])
				return String(a[2]);
			return "#error.release";
		}
	/*	public static function getCurrentDevice():String
		{
			return MISC.COPY_VER;
		}*/
		public static function isDevice(d:String):Boolean
		{
			var v:String = deviceAlias;
			switch(d) {
				case V2T:
				case V2:
					return deviceAlias == V2;
					
				
				
				
					
			}
			
			
			return deviceAlias == d;
		}
		public static function getFullVersion():String
		{
			return SERVER.VER_FULL;
		}
		
		
		public static function get name_k16():String	// визуальное представление, читаемое для пользователя
		{
			
			if (LOC.exist(alias+"."+app.charAt( 0 )))
				return loc(alias+"."+ app.charAt( 0 ) );
			return loc(alias);
		}
		public static function get name():String	// визуальное представление, читаемое для пользователя
		{
			
			if (LOC.exist(alias+"."+app))
				return loc(alias+"."+app);
			return loc(alias);
		}
		public static function get alias():String	
		{
			return deviceAlias;
		}
		
		public static function get deviceAlias():String	
		{
			var a:Array = SERVER.VER_FULL.split(".");
			if (a && a[0]) {
				if (String(a[0]).toLowerCase() == loc("sys_unidentified").toLowerCase())
					return (MISC.COPY_VER as String).split("_and_")[0];
				return String(a[0]);
			}
			return "#error.alias";
		}
		public static function getDeviceFirmwareTime():String
		{
			switch(deviceAlias) {
				case K16:
					return "15 "+loc("time_sec_full");
				case K14:
					return "2 "+loc("time_mins_full");
				case LCD1:
				case K5:
				case K53G:
					return "3 "+loc("time_mins_full");
				case ACC1:
					return "5 "+loc("time_sec_full");
			}
			return "30 "+loc("time_sec_full");
		}
	}
}