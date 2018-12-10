package components.abstract
{
	import components.abstract.functions.loc;

	public class RegExpCollection
	{
		// Завершенные выражения
		public static const REF_0to255:String = "^(([01]?\\d{1,2})|(2[0-4]\\d)|(25[0-5]))$";
		public static const REF_15to600:String = "^((600)|([1-5]\\d\\d)|(1[5-9])|([2-9][0-9]))$";
		public static const REF_001to125:String = "^((0{0,2}[0-9])|[1-9]\\d|(1[0-1]\\d)|(12[0-5])|(255))$";
		public static const REF_000to127:String = "^-*((0{0,2}[0-9])|[1-9]\\d|(1[0-1]\\d)|(12[0-7])|(255))$";
		public static const REF_30to125:String = "^((0?[3-9]\\d)|(1[0-1]\\d)|(12[0-5])|(255))$";
		public static const REF_0and5to255_f:String = "^(([5-9]|[1-9]\\d|1\\d\\d)|(2[0-4]\\d)|(25[0-5])|0)$"; //1-255
		public static const REF_0to600:String = "^(600|([0-5]\\d\\d)|(\\d\\d)|(\\d))$"; //1-255
		public static const REF_1to255:String = "^(([1-9]|[1-9]\\d|1\\d\\d)|(2[0-4]\\d)|(25[0-5]))$"; //1-255
		public static const REF_1to255_OR_NOTHING:String = "^(^$|([1-9]|[1-9]\\d|1\\d\\d)|(2[0-4]\\d)|(25[0-5]))$"; //1-255
		public static const REF_2to255:String = "^((0*[2-9]|0?[1-9]\\d|1\\d\\d)|(2[0-4]\\d)|(25[0-5]))$"; //2-255
//		public static const REF_5to255:String = "^((0*[5-9]|0?[1-9]\\d|1\\d\\d)|(2[0-4]\\d)|(25[0-5]))$"; //5-255
		public static const REF_1to30_none:String = "^((0?\\d)|([1-2]\\d)|30|"+loc("g_no")+")$";
		public static const REF_0or10to99:String = "^(0|[1-9]\\d)$";
		public static const REF_0_10to254:String = "^(0|(0?[1-9]\\d)|(1\\d\\d)|(2[0-4]\\d)|(25[0-4]))$"; //1-254
		public static const REF_300to10k:String = "^(0{0,2}[3-9]\\d\\d|0?[1-9]\\d\\d\\d|10000)$";
		public static const REF_0to24_none:String = "^((0?\\d)|(1\\d)|(2[0-4])|"+loc("g_no")+")$";
		public static const REF_0to32_none:String = "^((0?\\d)|([1-2]\\d)|(3[0-2])|"+loc("g_no")+")$";
		public static const REF_minus_63to63:String = "^((-?0?\\d)|(-?[1-5]\\d)|(-?6[0-3]))$";
		public static const REF_minus_127to127:String = "^((-?0?0?\\d)|(-?0?\\d\\d)|(-?1[0-1]\\d)|(-?12[0-7]))$";
		public static const REF_0to25_none_and_dot:String = "^[1-2]?[0-5](\\.[0-9])?$";
		
		public static const REF_0to65536_FLOAT2:String = "^(655(\\.3[0-5]?)?|655(\\.[0-2]\\d?)?|65[0-4](\\.\\d{1,2})?|" +
			"6[0-4]\\d(\\.\\d{1,2})?|[1-5]\\d{2}(\\.\\d{1,2})?|\\d{1,2}(\\.\\d{1,2})?)$";
		public static const REF_0to65535_FLOAT1:String = "^(6553(\\.[0-5])?|655[0-2](\\.\\d)?|65[0-4]\\d(\\.\\d)?|6[0-4](\\d){2}(\\.\\d)?|[1-5](\\d){3}(\\.\\d)?|[0-9](\\d){0,2}(\\.\\d)?)$"	// "^(6553(\\.[0-5])?|655[0-2](\\.\\d)?|65[0-4]\\d(\\.\\d)?|6[0-4](\\d){2}(\\.\\d)?|[1-5](\\d){3}(\\.\\d)?|[0-9](\\d){0,2}(\\.\\d)?)$";
		public static const REF_0to255_FLOAT1:String = "^(([01]?\\d(\\.\\d)?)|(2[0-4](\\.\\d)?)|(25(\\.[0-5])?))$";
			
		public static const REF_TIME_0000to9959:String = "^((\\d?\\d):(0?\\d|[0-5]\\d))$";
		public static const REF_TIME_0000to5999:String = "^((0?\\d|[0-5]\\d):(\\d?\\d))$";
		public static const REF_TIME_0001to9959:String = "^(([1-9]\\d):(0\\d)|(\\d[1-9]):(0\\d)|(00):(0[1-9])|(\\d\\d):(0[1-9]|[1-5][0-9]))$";
		public static const REF_TIME_0500to9959:String = "^((0?[5-9]|[1-9]\\d):(0?\\d|[0-5]\\d))$";
		public static const REF_TIME_0010to1000:String = "^((0?0:[1-5]?\\d)|(0?[1-9]:[0-5]?\\d|10:00))$";
		public static const REF_TIME_0000and0010to1000:String = "^((0?0:[1-5]?\\d)|(0?[1-9]:[0-5]?\\d|10:00|00:00))$";
		public static const REF_TIME_0000and0010to3600:String = "^((0?0:[0-5]?\\d)|(0?[1-9]:[0-5]?\\d|10:00|60:00|00:00))$";
		public static const REF_TIME_0and0010to300:String = "^((0?0:[1-5]?\\d)|(0?[1-9]:[0-5]?\\d|10:00|00:00))$";
		public static const REF_TIME_0and0010to1000:String = "^((0?0:[1-5]?\\d)|(0?[1-9]:[0-5]?\\d|10:00|00:00))$";
		public static const REF_TIME_00to2359_FF:String = "^((0?\\d|[0-1]\\d|2[0-3]):([0-5]\\d|0?\\d)|(255:255))$";
		public static const REF_TIME_0005to3000:String = "^((00:([1-5]\\d))|(00:(0[5-9]))|(0[1-9]:[0-5]\\d)|(([1-2]\\d):([0-5]\\d))|30:00|00:00)$"
		public static const REF_TIME_0005to3000_NO00:String = "^((00:([1-5]\\d))|(00:(0[5-9]))|(0[1-9]:[0-5]\\d)|(([1-2]\\d):([0-5]\\d))|30:00)$"
		public static const REF_TIME_0015to6000_NO00:String = "^((00:([2-5]\\d))|(00:(1[5-9]))|(0[1-9]:[0-5]\\d)|(([1-5]\\d):([0-5]\\d))|60:00)$"
		public static const REF_TIME_0030to6000_NO00:String = "^((00:[3-5]\\d)|([1-5]\\d:[0-5]\\d)|(0[1-9]:[0-5]\\d)|60:00)$";
		public static const REF_TIME_00to59:String = "^(0?\\d|[0-5]\\d)$"
		public static const REF_TIME_0000to1600:String = "^((1[0-5]|0[0-9]):[0-5][0-9])|16:00$" /// для установок времени ММ:СС с макс. значением 16 мин.
		public static const REF_TIME_0005to9959:String = "^(00:0[5-9])|(\\d[1-9]:\\d\\d)|([1-9]\\d:\\d\\d)|(\\d\\d:[1-9]\\d)$" /// для установок времени ММ:СС с макс. значением от 00:05 до 99:59
			
		public static const REF_1to10:String = "^((0?[1-9])|10)$";
		public static const REF_1to99:String = "^((0?[1-9])|([1-9]\\d))$";
		//public static const REF_1to99:String = "^.*$";
		public static const REF_1to999:String = "^(0*[1-9]\\d*)$";
		public static const REF_10to20:String = "^(1\\d|20)$";
		public static const REF_10to10000:String = "^([1-9](\\d){1,4}|10000)$"; 
		public static const REF_10to65535:String = "^(6553[0-5]|655[0-2][0-9]\\d|65[0-4](\\d){2}|6[0-4](\\d){3}|[1-5](\\d){4}|[1-9](\\d){1,3})$";
		//public static const REF_0to65535:String = "^(6553[0-5]|655[0-2][0-9]\\d|65[0-4](\\d){2}|6[0-4](\\d){3}|[1-5](\\d){4}|[0-9](\\d){0,3})$";
		public static const REF_0to65535:String = "^(6553[0-5]|655[0-2]\\d|65[0-4](\\d){2}|6[0-4](\\d){3}|[1-5](\\d){4}|[0-9](\\d){0,3})$";
		public static const REF_0to32767:String = "^(3276[0-7]|327[0-5]\\d|32[0-6](\\d){2}|3[0-1](\\d){3}|[1-2](\\d){4}|[0-9](\\d){0,3})$";
		public static const REF_0to254:String = "^((0*\\d)|(0?[1-9]\\d)|(1\\d\\d)|(2[0-4]\\d)|(25[0-4]))$"; //0-254
		public static const REF_REMOVE_HTML_TAGS:String = "<[^<]+?>";
		public static const REF_NOT_EMPTY:String = "^(?!\s*$).+";
		
		/*
		
		
		public static const REF_0to65535float:String = "^((6553(\\.[0-5])?)|655(\\.[0-2]\\d|" +
			"65[0-4](\\d){2}(\\.\\d)?|" +
			"6[0-4](\\d){3}(\\.\\d)?|" +
			"[1-5](\\d){4}(\\.\\d)?|" +
			"[0-9](\\d){0,3}(\\.\\d)?|" +
			"0\\.\\d)$";
		public static const REF_0to255:String = "^(([01]?\\d{1,2})|(2[0-4]\\d)|(25[0-5]))$";
		*/
		public static const REF_1to600:String = "^(([1-9])|([1-9]\\d)|([1-5]\\d\\d)|600)$";
		//public static const REF_0to600:String = "^((\\d?\\d)|([1-5]\\d\\d)|600)$";
		public static const REF_1to8:String = "^([1-8])$";
		public static const REF_3to10:String = "^(0?[3-9]|10)$";
		public static const REF_1to60:String = "^(60|[0-5][0-9]|[1-9])$";
		public static const REF_1to120:String = "^(120|[0-1][0-1][0-9]|[1-9][0-9]|[1-9])$";
		public static const REF_10to120:String = "^(([1-9]\\d)|(1[0-1]\\d)|120)$";
		public static const REF_5to120:String = "^(([5-9])|([1-9]\\d)|(1[0-1]\\d)|120)$";
		public static const REF_10to240:String = "^((0?[1-9]\\d)|(1\\d\\d)|2[0-3]\\d|240)$";
		public static const REF_20to250:String = "^((0?[2-9]\\d)|(1\\d\\d)|2[0-4]\\d|250)$";
		public static const REF_20to240:String = "^((0?[2-9]\\d)|(1\\d\\d)|2[0-3]\\d|240)$";
		public static const REF_50to250:String = "^((0?[5-9]\\d)|(1\\d\\d)|2[0-4]\\d|250)$";
		public static const REF_20to120:String = "^((0?[2-9]\\d)|1[0-1]\\d|120)$";
		public static const REF_0000to6000:String = "^((([0]?\\d|[0-5]\\d):([0]?\\d|[0-5]\\d))|(60:00))$"
		public static const REF_0000to5959:String = "^(([0]?\\d|[0-5]\\d):([0]?\\d|[0-5]\\d))$";
		public static const REF_0000to9959alltime:String = "^(((\\d?\\d):(0?\\d|[0-5]\\d))|"+loc("input_constant")+")$";
		public static const REF_0000to9959:String = "^((\\d?\\d):(0?\\d|[0-5]\\d))$";
		public static const REF_0002to9959:String = "^(((\\d\\d):(0[2-9]|[1-5]\\d))|((\\d[1-9]|[1-9]\\d):([0-5]\\d)))$";
		public static const REF_CODE_OBJECT:String = "^(([0-9B-Eb-e]*[1-9B-Eb-e][0-9B-Eb-e]*)|([0-9B-Eb-e]*[Ff]?[0-9B-Eb-e]*[Ff]?[0-9B-Eb-e]*[Ff][0-9B-Eb-e]*))$";
		public static const REF_PORT:String = "^(6553[0-5]|655[0-2]\\d|65[0-4]\\d{2}|6[0-4]\\d{3}|[1-5]\\d{4}|[1-9]\\d{0,3})$";
		public static const REF_DELIM:String = " +, +|, *| *,| +";
		public static const REF_1toFFFE:String = "^(([0-9B-Eb-e]*[1-9B-Eb-e][0-9B-Eb-e]*)|([0-9B-Eb-e]*[Ff]?[0-9B-Eb-e]*[Ff]?[0-9B-Eb-e]*[Ff][0-9B-Eb-e]*))$";
		public static const REF_PLT_STRING:String = "( *\\-*\\w*\\.*\\d*,){23}\\r\\n";
		public static const REF_1to254:String = "^((0*[1-9])|(0?[1-9]\\d)|(1\\d\\d)|(2[0-4]\\d)|(25[0-4]))$"; //1-254
		public static const REF_8SYMBOL:String = "^(.{8,8})$" //"^(\\d{8,})$";
			
		// Незавершенные выражения
		public static const RE_1to65535:String = "(6553[0-5]|655[0-2][0-9]\\d|65[0-4](\\d){2}|6[0-4](\\d){3}|[1-5](\\d){4}|[1-9](\\d){0,3})";
		public static const RE_1to255:String = "(([1-9]|[1-9]\\d|1\\d\\d)|(2[0-4]\\d)|(25[0-5]))"; //1-255
		public static const RE_0to255:String = "^((25[0-5])|(2[0-4]\\d)|(1\\d\\d)|(\\d\\d)|(\\d))$"; //0-255
		public static const RE_TIME_0000to9959:String = "((\\d?\\d):(0?\\d|[0-5]\\d))";
		public static const RE_00to2359:String = "((0?\\d)|([0-1]\\d)|(2[0-3])):(0?\\d|[0-5]\\d)"; 
		//public static const RE_0005to2359:String = "((0?\\d)|([0-1]\\d)|(2[0-3])):(0?[5-9]|[1-5]\\d)";	// K7
		public static const RE_0005to2359:String = "(0?0:([1-5][0-9]))|" +
			"(0?0:(0[5-9]))|" +
			"(0?[1-9]:[0-5]?\\d)|" +
			"((1\\d):([0-5]?\\d))|" +
			"((2[0-3]):([0-5]?\\d))";
		public static const RE_TEL:String = "((\\+)?[0-9]+)";
		public static const RE_TEL_NOREQUIRED:String = "((\\+)?[0-9]*)";
		public static const RE_0500to2359:String = "(0?[5-9]|1\\d|2[0-3]):([0-5]\\d|\\d)";	// K7
		
		/**
		 * 	Каналы CSD, CSD v32, SMS, GSM DTMF: цифры '0'..'9', допустим один '+' в начале; p,w,t - не используются.
			Каналы проводной линии DTMF и длинный DTMF: цифры '0'..'9' и символы 'p','P','t','T','w','W' в любом порядке и количестве; символ '+' не использовать.
 		**/ 
		
		
		// Link Channels
		/*public static const RE_IP_ADDRESS:String = "((([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.){3}" +
			"([01]?\\d\\d?|2[0-4]\\d|25[0-5]))";*/
		//public static const RE_IP_ADDRESS:String = "((([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.){3}([01]?\\d\\d?))";
		public static const REF_MAC_ADDRESS:String = "^(([A-z0-9][A-z0-9]:){5}([A-z0-9][A-z0-9]))$";
		public static const REF_IP_ADDRESS:String = "^((([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.){3}([01]?\\d\\d?|2[0-4]\\d|25[0-5]))$";
		public static const REF_DOMEN:String = "^((([a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.){1,}([A-Za-z0-9\\-]*[A-Za-z0-9]))$";
		public static const RE_IP_ADDRESS:String = "((([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.){3}([01]?\\d\\d?|2[0-4]\\d|25[0-5]))";
		//public static const RE_IP_ADDRESS_1st_bite_1to223:String = "((([1-9]|[1-9]\\d\\d?|2[0-4]\\d|25[0-3])\\.)([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.){2}" +
		public static const RE_IP_ADDRESS_1st_bite_1to223:String  = "(" +
			"(([1-9]\\d?|1\\d\\d?|2[0-1]\\d|22[0-3])\\.)" +
			"((([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.){2})" +
			"([01]?\\d\\d?|2[0-4]\\d|25[0-5]))";
		public static const RE_IP_ADDRESS_BY_REGEXR_OR_DOMAIN:String = "/^(([a-zA-Z|\.]{3,})|((\d{1,3}\.){3}(\d{1,3})))$/";
		//public static const RE_IP_ADDRESS_BY_REGEXR_OR_DOMAIN:String = "/(( \S{3,} ) | (\d{1,3}\.){3}(\d{1,3}) )/gx";
		//public static const RE_TEL_LC:String = "((p|P|t|T|w|W|\\+)?[0-9wW]+)";
		public static const RE_TEL_MIN3DIGIT:String = "((\\+)?[0-9]{3,})";
		public static const RE_TEL_LC:String = "((\\+)?[0-9]+)";
		public static const RE_TEL_PROVOD:String = "((p|P|t|T|w|W)?[0-9wWpPtT]+)";
		public static const RE_TEL_PROVOD_K1:String = "((p|P|t|T|w|W|\\*|#)?[0-9wWpPtT\\*#]+)";
		//public static const RE_DOMEN:String = "((([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.){1,}([A-Za-z]|[A-Za-z][A-Za-z0-9\\-]*[A-Za-z0-9]))";
		public static const RE_DOMEN:String = "((([a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.){1,}([A-Za-z0-9\\-]*[A-Za-z0-9]))";
		public static const RE_PORT:String = "(6553[0-5]|655[0-2]\\d|65[0-4]\\d{2}|6[0-4]\\d{3}|[1-5]\\d{4}|[1-9]\\d{0,3})";
		
		//public static const REF_TIME_00to2359_FF:String = "^(255:255|FF:FF|(0?\\d|[0-1]\\d|2[0-3]):([0-5]\\d|0?\\d))$";		// K2
		public static const COMPLETE_DDdotMMdotYY:RegExp = /(((0[1-9])|(1\d)|(2\d)|(3[0-1]))\.((0[1-9])|(1[0-2]))\.(\d\d))/g;
		public static const COMPLETE_HHcolonMMcolonSS:RegExp = /((0\d)|(1\d)|(2[0-3])):([0-5]\d):([0-5]\d)/g
		public static const COMPLETE_TM_KEY:RegExp = /(?!0{16}|1{16}|f{16}|F{16})([0-9A-Fa-f]){16}/g;
		public static const COMPLETE_100to300:String = "^(([1-2]\\d\\d)|300)$";
		public static const COMPLETE_50to100:String = "^((0?[5-9]\\d)|100)$";
		public static const COMPLETE_2to10:String = "^([2-9]|10)$";
		public static const COMPLETE_1to16:String = "^([1-9]|(1[0-6]))$";
		public static const COMPLETE_1to13:String = "^([1-9]|(1[0-3]))$";
		public static const COMPLETE_1to30:String = "^([1-9]|([1-2]\\d)|30)$";
		public static const COMPLETE_1to120:String = "^([1-)$";
		public static const COMPLETE_HOURS:String = "^(0?\\d|(1\\d)|(2[0-3]))$";
		public static const COMPLETE_MINUTES:String = "^(0?\\d|([0-5]\\d))$";
		//public static const RE_00to2459:String = "(0?\\d|[0-1]\\d|2[0-4]):(0?\\d|[0-5]\\d)";
		public static const COMPLETE_ATLEST1SYMBOL:RegExp = /^(?!\s*$).+/;
		public static const COMPLETE_ATLEST3SYMBOL:String = "^(.{3,})$" //"^(\\d{8,})$";
		public static const COMPLETE_ATLEST4SYMBOL:String = "^(.{4,})$" //"^(\\d{8,})$";
		public static const COMPLETE_ATLEST8SYMBOL:String = "^(.{8,})$" //"^(\\d{8,})$";
		public static const COMPLETE_0to10dot0:RegExp = /^((\d(\.\d)?)|(\d(\.\d)?)|10(.0)?)$/;//^(\d\d?(\.\d)?)$/;
		public static const COMPLETE_0dot1to10dot0:RegExp = /^((0\.[1-9])|([1-9](\.\d)?)|(10(.0)?))$/;//^(\d\d?(\.\d)?)$/;
		public static const COMPLETE_0dot1to24dot0:RegExp = /^((0\.[1-9])|([1-9](\.\d)?)|(1\d(.\d)?)|(2[0-3](.\d)?)|24?(.0)?)$/;//^(\d\d?(\.\d)?)$/;
		public static const COMPLETE_0to10and_dot:String = "^((\\d)|(\\d\\.\\d)|10)$";
		public static const COMPLETE_TIMESTRING:String = "\\d{6,6}"; // "HHMMSS"
	}
}