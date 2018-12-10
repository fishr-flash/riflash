package components.protocol.statics
{
	public class CRC32
	{
		public static function calculate( str:Array, len:int):int 
		{
			var _crc:int = 0xFFFFFFFF;// начальное значение
			for ( var i:int = 0; i < len; ++i) {
				_crc = crc32_update(_crc, str[i]);
			}
			_crc = ~_crc; ////Внимание!!!
			return (int) (_crc & 0xFFFFFFFF);
		}
		
		private static function crc32_update(crc:int, a:int):int 
		{
			crc &= 0xFFFFFFFF;
			a &= 0xFF;
			crc ^= a;
			for (var i:int = 0; i < 8; ++i) {
				crc &= 0xFFFFFFFF;
				if ((crc & 1) != 0)
					crc = (crc >>> 1) ^ 0xEDB88320;
				else
					crc = (crc >>> 1);
			}
			return (crc & 0xFFFFFFFF);
		}
	}
}