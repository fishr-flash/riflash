package components.protocol.statics
{
	import flash.utils.ByteArray;

	/**
	 * 
	 * Алгоритмы формирования ключей для шифрования файлов конфигураций.

		1. Строковая переменная MISC.COPY_VER, может принимать следующие значения для Вояджер. V-L1,L2,2,L3,3,4,5,6,L0,15:
		  1.1. Для L1/L2 - "V-L1_and_V-L2".
		  1.2. для 2/L3 - "V-2_and_V-L3".
		  1.3. Для 3 - "V-3".
		  1.4. Для 4 - "V-4".
		  1.5. Для 5 - "V-5".
		  1.6. Для 6 - "V-6".
		  1.7. Для L0 - "V-L0".
		  
		  MISC.COPY_VER дублируется в одну строку и записывается в бинарный массив командой Actionscript ByteArray.writeUTFBytes() 
		  ( кодирование декодирование https://habrahabr.ru/post/138173/ ) откуда затем считывается
		  32 битное беззнаковое целое. Этот результат записывается как 1 ключ.
		
		2. Выолняется исключающее ИЛИ ( XOR ) над двумя целочисленными переменными: CLIENT.TIMER_IDLE ( 20000 ), CLIENT.OLD_ADDRESS ( 0xFE ). Переменные
		   эти имеют устоявшееся постоянное значение, однако они не являются константами и теоретически могут меняться из кода. Результат является 2ым ключом.
		   
		3. Третьим ключом служит значение константы COLOR.WIRE_LIGHT_BROWN - 0xc49a6c.
		
		4. Четвертый ключ формируется перед записью, по фомуле (0x23 + SERVER.REQUEST_READ)*2643, где SERVER.REQUEST_READ = 0x01   
		
	 */
	public final class SHA256
	{
		
		private static const num_rounds:int = 64;
		
		//public static var _k:Array = [0x1023B1a4,0x42c90a10,0xdee616b0,0x154a2365];
		public static var _k:Array = [1261252916,20190,12884588,95148];
		public static function set k(value:Array):void
		{
			
			_k = value;
		}
		public static function get k():Array 
		{
			return _k;
		}
		 
		private static function rol(base:int, shift:int):int
		{
			var res:int;
			shift &= 0x1F;
			res = (base << shift) | (base >> (32 - shift));
			
			
			return res;
		}
		public static function encrypt(s:String):ByteArray
		{
			//s = "<x>1</x>";
			
			
			var b:ByteArray = new ByteArray;
			b.writeUTFBytes(s);
			
			while( Math.floor(b.length/8) != b.length/8 ) {
				b.writeUTFBytes(" ");
			}
			
			var len:int = b.length;
			for (var i:int=0; i<len; i) {
				doEncryption( b, i);
				i+=8;
			}
			return b;
		}
		private static function doEncryption(b:ByteArray, index:int):void
		{
			var i:int;
			var y:uint;
			var z:uint;
			var sum:int;
			var delta:int = 0x9E3779B9;
			/* load and pre-white the registers */
			b.position = index;
			y = b.readUnsignedInt() + k[0];
			z = b.readUnsignedInt() + k[1];
			/* Round functions */
			for (i = 0; i < num_rounds; i++) 
			{
				y += ((z << 4) ^ (z >> 5)) + (z ^ sum) + rol(k[sum & 3], z);
				sum += delta;
				z += ((y << 4) ^ (y >> 5)) + (y ^ sum) + rol(k[(sum >> 11) & 3], y);
			}
			b.position -= 8;
			/* post-white and store registers */
			b.writeUnsignedInt(y ^ k[2]);
			b.writeUnsignedInt(z ^ k[3]);
			
			
		}
		public static function decrypt(b:ByteArray):ByteArray
		{
			var len:int = b.length;
			for (var i:int=0; i<len; i) {
				doDecryption( b, i);
				i+=8;
			}
			b.position = 0;
			
			
			
			return b;
		}
		private static function doDecryption(b:ByteArray, index:int):void
		{
			var i:int;
			var y:int;
			var z:int;
			var delta:int=0x9E3779B9;
			var sum:int=delta*num_rounds;
			b.position = index;
			y = b.readUnsignedInt() ^ k[2];
			z = b.readUnsignedInt() ^ k[3];
			
			for (i = 0; i < num_rounds; i++) 
			{
				z -= ((y << 4) ^ (y >> 5)) + (y ^ sum) + rol(k[(sum >> 11) & 3], y);
				sum -= delta;
				y -= ((z << 4) ^ (z >> 5)) + (z ^ sum) + rol(k[sum & 3], z);
				
			}
			b.position -= 8;
			b.writeUnsignedInt(y - k[0]);
			b.writeUnsignedInt(z - k[1]);
		}
	}
}