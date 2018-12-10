package components.resources
{
	import flash.utils.ByteArray;
	
	import components.abstract.LOC;
	import components.abstract.functions.dtrace;
	import components.static.DS;
	
	import su.fishr.utils.searcPropValueInArr;

	public class Resources
	{
		[Embed(source="assets/k5_sms_ru.txt",mimeType="application/octet-stream")]
		private static var k5_sms_ru:Class;
		[Embed(source="assets/k5_sms_en.txt",mimeType="application/octet-stream")]
		private static var k5_sms_en:Class;
		[Embed(source="assets/k5_sms_it.txt",mimeType="application/octet-stream")]
		private static var k5_sms_it:Class;
		
		[Embed(source="assets/k9_sms_ru.txt",mimeType="application/octet-stream")]
		private static var k9_sms_ru:Class;
		[Embed(source="assets/k9_sms_en.txt",mimeType="application/octet-stream")]
		private static var k9_sms_en:Class;
		[Embed(source="assets/k9_sms_it.txt",mimeType="application/octet-stream")]
		private static var k9_sms_it:Class;
		
		[Embed(source="assets/k1_sms_ru.txt",mimeType="application/octet-stream")]
		private static var k1_sms_ru:Class;
		[Embed(source="assets/k1_sms_en.txt",mimeType="application/octet-stream")]
		private static var k1_sms_en:Class;
		[Embed(source="assets/k1_sms_it.txt",mimeType="application/octet-stream")]
		private static var k1_sms_it:Class;
		
		public static function SmsArray():Array
		{           
			var b:ByteArray;
			
			dtrace( DS.alias );
			dtrace( LOC.language );
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					switch(LOC.language) {
						case LOC.RU:
							b = new k5_sms_ru() as ByteArray;
							break;
						case LOC.EN:
							b = new k5_sms_en() as ByteArray;
							break;
						case LOC.IT:
							b = new k5_sms_it() as ByteArray;
							break;
					}
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
					switch(LOC.language) {
						case LOC.RU:
							b = new k9_sms_ru() as ByteArray;
							break;
						case LOC.EN:
							b = new k9_sms_en() as ByteArray;
							break;
						case LOC.IT:
							b = new k9_sms_it() as ByteArray;
							break;
					}
					break;
				case DS.K1:
				case DS.K1M:
					switch(LOC.language) {
						case LOC.RU:
							b = new k1_sms_ru() as ByteArray;
							break;
						case LOC.EN:
							b = new k1_sms_en() as ByteArray;
							break;
						case LOC.IT:
							b = new k1_sms_it() as ByteArray;
							break;
					}
					break; 
			}
			var txt:String = b.readMultiByte(b.bytesAvailable, "windows-1251");
			
			var a:Array = String(txt).split("\r");
			var part:Array;
			var names:Array = new Array;
			var notes:Array = new Array;
			
			var len:int = a.length, i:int;
			
			if (DS.isfam(DS.K1)) {
				
				var key:int = 0;
				if( int( DS.app ) < 7 )
				{
					key = findNbrElem( 58, a );
					if( key > -1 )
						a.splice( key, 1 );
				}
				
				if( int( DS.app ) === 3 )
				{
					key = findNbrElem( 23, a );
					if( key > -1 )
						a.splice( key, 1 );
					
					key = findNbrElem( 24, a );
					if( key > -1 )
						a.splice( key, 1 );
				}
					
			//if( DEVICES.isFamily( DEVICES.K1 ) ) {
				for (i=0; i<len; i++) {
					part = String(a[i]).split("|");
					if (part.length > 1) {
						names[int(part[0])+1] = part[1];
						//notes[int(part[0])] = part[2];
						notes.push( part[2] );
					}
				}
				
				
			}
			else
			{
				if( !DS.isDevice( DS.A_BRD ) )
				{
					a.splice( 67, 2 ); // удавление пунктов Неиспр. телефонной линии и Восст.Неисправность тел линии	
				}
				
				
				
				for (i=0; i<len; i++) {
					part = String(a[i]).split("|");
					if (part.length > 1) {
						names.push( part[1] );
						notes.push( part[2] );
					}
				}
				
				
				
			}
			
			
			
			return [names, notes];
		}
		
		private static function findNbrElem( index:int, a:Array ):int
		{
			var len:int = a.length;
			for (var i:int=0; i<len; i++) 
				if( String( a[ i ] ).indexOf( index + "|" ) > -1 ) 
					return i;
			
			return -1;
		}
		
		
	}
}