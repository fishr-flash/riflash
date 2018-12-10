package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.static.DS;

	public class FirmwareChecker
	{
		public static function check(b:ByteArray, ver:String):ByteArray
		{
			// больше не проверяем соответствие прошивки обновляемой плате
			//if (DS.isfam(DS.K16)) {
			if ( false ) {
				var fw:ByteArray = new ByteArray;
				b.readBytes( fw, 0, b.bytesAvailable-6 );
				
				var len:int = b.length;
				var add:ByteArray = new ByteArray;
				var value:int;
				for (var i:int=len-6; i<len; i++) {
					value = b[i] << 3;
					if(( value & 0xff00) > 0 ) {
						value |= (value >> 8);
						value = value & 0xff;
					}
					add.writeByte( value );
				}
				add.position = 0;
				var str:String = add.readMultiByte(add.bytesAvailable, "windows-1251");
				var re:RegExp = /K-16\.[1-2]/g;
				
				if (re.test(str) ) {
					var k16ver:int = int(str.charAt(5));
					var currentver:int = int(ver.charAt(5));
					if ( currentver == k16ver )
						return fw;
				}
				return null;
			}
			return b; 
		}
	}
}