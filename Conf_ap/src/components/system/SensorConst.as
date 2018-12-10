package components.system
{
	import components.protocol.Package;
	import components.protocol.statics.SERVER;
	import components.static.DS;

	public class SensorConst
	{
		/**
		RSD1.005.001
		RIPR1.002.001
		RDD1.001.001
		RGD1.002.001
		RMD1.001.001
		RDD3.003.001
		*//**
		14.002 - RDD1
		14.003 - RMD1
		14.005 - RSD1
		14.008 - RIPR1
		14.009 - RGD1
		14.012 - RDD3
		*/
		public static const TYPE_RDD1:String = "RDD1";
		public static const TYPE_RMD:String = "RMD1";
		
		public static const HASH_NUMBERS:Array = ["RDD1","RMD1","RSD1","RIPR1","RGD1","RDD3"];
		public static const HASH_NAMES:Object = {"RDD1":0,"RMD1":1,"RSD1":2,"RIPR1":3,"RGD1":4,"RDD3":5};
		
		public static function isSameVersion(p:Package):Boolean
		{
			var v:String = extract(p);
			if (SERVER.VER != v)
				return false;
			return true;
		}
		public static function getAlias(p:Package):String
		{
			var s:String = extract(p);
			var result:String;
			var a:Array = s.split(".");
			s = a[0] +"." + a[1];
			switch(s) {
				case "VER 14.002":
					return "RDD1";
				case "VER 14.003":
					return "RMD1";
				case "VER 14.005":
					return "RSD1";
				case "VER 14.008":
					return "RIPR1";
				case "VER 14.009":
					return "RGD1";
				case "VER 14.012":
					return "RDD3";
			}
			return "UNKNOWN";
		}
		public static function getBootLoaderVersion(p:Package):String
		{
			var alias:String;
			
			var rmd1:RegExp = /MD/g;
			var rdd1:RegExp = /DD/g;
			var rdd3:RegExp = /RDD3/g;
			var rsd1:RegExp = /RSD/g;
			var rgd1:RegExp = /RGD/g;
			var ripr1:RegExp = /RIPR/g;
			
			var s:String = extract(p);
			
			if (rmd1.test(s) )
				alias = "RMD1";
			else if (rdd1.test(s))
				alias = "RDD1";
			else if (rdd3.test(s))
				alias = "RDD3";
			else if (rsd1.test(s))
				alias = "RSD1";
			else if (rgd1.test(s))
				alias = "RGD1";
			else if (ripr1.test(s))
				alias = "RDD1";
			return alias;
		}
		public static function extract(p:Package):String
		{
			return String(p.getValidStructure()[0]).replace(/\n?\r?/g,"")
		}
	}
}