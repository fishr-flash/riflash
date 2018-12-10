package components.protocol.workers
{
	import flash.utils.ByteArray;
	
	import components.abstract.functions.dtrace;
	import components.gui.DevConsole;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.system.UTIL;

	public class PacketInspector
	{
		public static const BINARY1:int = 0x01;
		public static const TEXT:int = 0x02;
		public static const INCOMPLETE:int = 0x03;
		public static const BROKEN:int = 0x04;
		public static const GARBAGE:int = 0x05;
		public static const BINARY2:int = 0x06;
		public static const DISCREPANCY:int = 0x07;
		public static const IGNORE:int = 0x08;	// пришедший ответ стирается, но клиент продолжает ждать ответ
		public static const INCOMPLETE_B2:int = 0x09; 
		
		private const BINARY_PATTERN:Array = [0x80, 0x80, 0x80];
		
		public var MANUAL:Boolean = false; // true когда запрос отсылается вручную
		public var LAST_INSPECTED_SIZE:int;
		
		private var expectedPacketNumber:int=-1;
		private var gotpnum:int;
		
		private var uid:Number;
		
		public function PacketInspector()
		{
			uid = UTIL.generateSimpleUId();
		}
		public function rememberPacketNumber(b:ByteArray):void
		{
			expectedPacketNumber = (b[9] << 8) | b[8];
			var cmd:CommandSchemaModel  = OPERATOR.getSchema( int((b[13] << 8) | b[12]) );
		}
		public function inspect(b:ByteArray):int
		{
			if (CLIENT.PROTOCOL_BINARY) {
				var len:int;
				var i:int;
				
				if (b[0]== 0x80 && b[1] == 0x80 && b[2] == 0x80 )
					return parseBinaryPacket(b);
				else
					return parseBinaryPreamble(b);
			} else {
				var txt:String = b.readMultiByte( b.bytesAvailable, "windows-1251" );
				b.position = 0;
				
				var bas:String = UTIL.showByteArray( b );
				
				//var av:int = txt.search( /ОК\r?\n?/g ); // ОК написан на русском 
				var byytr:int = b[b.bytesAvailable-1];
				
				if( txt.search( /(OK\r?)/g ) > -1 || txt.search( /(ERR\r?)/g ) > -1 || txt.search( /(IGN\r?)/g ) > -1 || b[b.bytesAvailable-1] == 0x0D )
					return TEXT;
				else
					return INCOMPLETE;
			}
			return GARBAGE;
		}
		public function clearUntilPreamble(b:ByteArray):ByteArray
		{
			var len:int = b.length;
			var clone:ByteArray = new ByteArray; 
			if (len > 3) {
				var garbage:Boolean = true;
				var garbage_collector:String;
				for (var i:int=1; i<len; ++i) {
					if( b[i]== 0x80 && b[i+1] == 0x80 && b[i+2] == 0x80 ) {
						
						b.position = 0;
						garbage_collector = b.readMultiByte( i, "windows-1251" );
						garbage_collector += " ("+ UTIL.showByteArray( b ) + ")";
						DevConsole.write( garbage_collector, DevConsole.IGNORE );
						
						b.position = i;
						b.readBytes( clone, 0, b.length-i );
						b.length = 0;
						clone.readBytes( b, 0, clone.length );
						break;
					}
				}
			}
			clone.position = clone.length;
			return clone;
		}
		
		private function parseBinaryPacket(b:ByteArray):int
		{
			if( b.length > 9 ) {
				var ver:int = b[3];
				LAST_INSPECTED_SIZE = (b[5] << 8) | b[4];
				
				var protocolver:int;
				
				var s:String = UTIL.showByteArray(b);
				
				if (b.length >= LAST_INSPECTED_SIZE) {
					
					protocolver = getBinary();
					if (protocolver == 1) {
						gotpnum = (b[9] << 8) | b[8];
						if (gotpnum != expectedPacketNumber ) {
							dtrace("ERROR: DISCREPANCY, got: "+gotpnum+" expect: "+ expectedPacketNumber + " uid :"+uid);
							return DISCREPANCY;
						}
						
						var a1:Object = b[10];
						var a2:Object = (b[10] & 0xF0 )
						
						if ( b[10] != 2 && b[10] != 4 && (b[10] & 0xF0 ) != 0x80 ) // если функция протокола не ответ на чтение и не ответ на запись
							return IGNORE;
					}
					return protocolver;
				}
			}
			if( b.length > 3 && b[3] == 2 )
				return INCOMPLETE_B2;
			return INCOMPLETE;
			function getBinary():int
			{
				switch(ver) {
					case 1:
						return BINARY1;
					case 2:
						return BINARY2;
				}
				return BROKEN;
			}
		}
		private function parseBinaryPreamble(b:ByteArray):int
		{
			var len:int = b.length-2;
			if (len < 1)
				return INCOMPLETE;
			var i:int;
			var garbage:Boolean = true;
			var garbage_collector:String;
			for (i=0; i<len; ++i) {
				if( b[i]== 0x80 && b[i+1] == 0x80 && b[i+2] == 0x80 ) {
					
					b.position = 0;
					garbage_collector = b.readMultiByte( i, "windows-1251" );
					garbage_collector += " ("+ UTIL.showByteArray( b ) + ")";
					DevConsole.write( garbage_collector, DevConsole.GARBAGE );
					
					b.position = i;
					var clone:ByteArray = new ByteArray; 
					b.readBytes( clone, 0, b.length-i );
					b.length = 0;
					clone.readBytes( b, 0, clone.length );
					garbage = false;
					break;
				}
			}
			if (garbage) {
				b.position = 0;
				garbage_collector = b.readMultiByte( i, "windows-1251" );
				if (MANUAL)
					DevConsole.write( garbage_collector, DevConsole.MANUAL );
				else
					DevConsole.write( garbage_collector, DevConsole.GARBAGE );
				return GARBAGE;
			}
			return parseBinaryPacket(b);
			
		}
		private function binaryIsComplete(_response:Array):Boolean
		{
			var len:int = (_response[5] << 8) | _response[4];
			if (_response.length == len)
				return true;
			return false;
		}
		public function textIsComplete():Boolean
		{
			return false;
		}
	}
}