package components.abstract
{
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import components.abstract.functions.dtrace;
	import components.static.MISC;
	
	import su.fishr.utils.Dumper;

	public class LOC
	{
		[Embed(source="assets/rus.txt",mimeType="application/octet-stream")]
		private static var rus:Class;
		[Embed(source="assets/eng.txt",mimeType="application/octet-stream")]
		private static var eng:Class;
		[Embed(source="assets/itl.txt",mimeType="application/octet-stream")]
		private static var itl:Class;
		
		private static var inst:LOC;
		public static function access():LOC
		{
			if(!inst)
				inst = new LOC;
			return inst;
		}
		public static const RU:String = "ru_RU";
		public static const EN:String = "en_US";
		public static const IT:String = "it_IT";
		
		private var callback:Function;
		private var timer:Timer;
		private var loaded:Boolean=false;
		
		public function setLang(f:Function, l:String):void
		{
			
			callback = f;
			lang = l;
			createLocale();
		}
		private function createLocale():void
		{
			if( !loaded ) {
				var b:ByteArray;

				if (MISC.DEBUG_LANG > 0) {
					switch(MISC.DEBUG_LANG) {
						case 1:
							lang = "ru_RU"; 
							break;
						case 2:
							lang = "en_US";
							break;
						case 3:
							lang = "it_IT";
							break;
					}
				}
				
				switch(language) {
					case "ru_RU":
					case "ru-RU":
						lang = "ru_RU"; 
						b = new rus() as ByteArray;
						break;
					case "en_US":
					case "en-US":
						lang = "en_US";
						b = new eng() as ByteArray;
						break;
					case "it_IT":
					case "it-IT":
						lang = "it_IT";
						b = new itl() as ByteArray;
						break;
					default:
						dtrace("Unknown locale \""+lang+"\", loaded default locale en_US"); 
						lang = "en_US";
						b = new eng() as ByteArray;
						break;
				}
				
				storage = {};
				var s:String = b.readUTFBytes(b.bytesAvailable);
				try {
					var obj:Object = JSON.parse(s);
				} catch(error:Error) {
					trace("Locale JSON parse error");
				}
				if (obj)
					storage[language] = obj;
				else
					storage[language] = {};

				if (timer)
					timer.stop();
				loaded = true;
				callback();
			}
		}
		
		private static var storage:Object;
		private static var lang:String;
		public static function get language():String
		{
			return lang;
		}
		
		public static function exist(s:String):Boolean
		{
			if ( storage && storage[lang] && storage[lang][s] )
				return true;
			return false;
		}
		public static function loc(s:String):String
		{
			
			if ( storage && storage[lang] && storage[lang][s] )
				return storage[lang][s];
			return s;
		}
	}
}