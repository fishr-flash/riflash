package components.protocol.statics
{
	public class CRC16
	{
		/** crc 16 modbus RTU 
		/** Original code by Lammert Bies, converted for AS3 by Ochnev Michael */
		
		public static function calculate( bytes:Array, length:int):int {
			var result:int = 0xffff;
			for (var i:int; i < length; ++i) {
				result = crc16_update(result, bytes[i] & 0xFF);
			}
			return result;
		}
		
		private static function crc16_update(crc:uint, a:uint):uint
		{
			crc ^= a;
			for (var i:int; i < 8; ++i)	{
				if (crc & 1) {
					crc = (crc >> 1) ^ 0xA001;
				} else {
					crc = (crc >> 1);
				}
			}
			
			return crc;
		}
	}
}