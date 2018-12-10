package components.abstract
{
	import components.abstract.functions.loc;
	import components.protocol.statics.SERVER;

	public class DEVICESB
	{
		public function DEVICESB()
		{
		}
		
		public static function get fullver():String
		{
			return SERVER.BOTTOM_VER_INFO[0][1];
		}
		public static function get commit():String
		{
			var a:Array = SERVER.BOTTOM_VER_INFO[1][0].split(".");
			if (a && a[1])
				return String(a[1]);
			return "#error.commit";
		}
		public static function get bootloader():String
		{
			var a:Array = SERVER.BOTTOM_VER_INFO[1][0].split(".");
			if (a && a[2])
				return String(a[2]);
			return "#error.bootloader";
		}
		public static function get release():int
		{
			
			var a:Array = SERVER.BOTTOM_VER_INFO[0][1].split(".");
			if (a && a[2])
				return int(a[2]);
			return 0;
		}
		public static function get name():String	// визуальное представление, читаемое для пользователя
		{
			if (LOC.exist(alias+"."+app))
				return loc(alias+"."+app);
			return loc(alias);
		}
		public static function get name_k16():String	// визуальное представление, читаемое для пользователя
		{
			
			if (LOC.exist(alias+"."+app.charAt( 0 )))
				return loc(alias+"."+ app.charAt( 0 ) );
			return loc(alias);
		}
		public static function get app():String	// визуальное представление, читаемое для пользователя
		{
			var a:Array = (SERVER.BOTTOM_VER_INFO[0][1] as String).split(".");
			return a[1];
		}
		public static function get alias():String	
		{
			var a:Array = SERVER.BOTTOM_VER_INFO[0][1].split(".");
			if (a && a[0])
				return a[0];
			return "#error.devicealias";
		}
	}
}