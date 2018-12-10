package components.abstract
{
	import components.system.UTIL;
	
	import flash.utils.ByteArray;

	public class BitConvertor
	{
		public var bytes:ByteArray;
		
		private const HEADER_SIZE:int = 44;
		
		/**
		 	0..3 (4 байта) 	chunkId 	Содержит символы "RIFF" в ASCII кодировке (0x52494646 в big-endian представлении). Является началом RIFF-цепочки.
			4..7 (4 байта) 	chunkSize 	Это оставшийся размер цепочки, начиная с этой позиции. Иначе говоря, это размер файла - 8, то есть, исключены поля chunkId и chunkSize.
			8..11 (4 байта) 	format 	Содержит символы "WAVE" (0x57415645 в big-endian представлении)
			12..15 (4 байта) 	subchunk1Id 	Содержит символы "fmt " (0x666d7420 в big-endian представлении)
			16..19 (4 байта) 	subchunk1Size 	16 для формата PCM. Это оставшийся размер подцепочки, начиная с этой позиции.
			20..21 (2 байта) 	audioFormat 	Аудио формат, полный список можно получить здесь. Для PCM = 1 (то есть, Линейное квантование). Значения, отличающиеся от 1, обозначают некоторый формат сжатия.
			22..23 (2 байта) 	numChannels 	Количество каналов. Моно = 1, Стерео = 2 и т.д.
			24..27 (4 байта) 	sampleRate 	Частота дискретизации. 8000 Гц, 44100 Гц и т.д.
			28..31 (4 байта) 	byteRate 	Количество байт, переданных за секунду воспроизведения.
			32..33 (2 байта) 	blockAlign 	Количество байт для одного сэмпла, включая все каналы.
			34..35 (2 байта) 	bitsPerSample 	Количество бит в сэмпле. Так называемая "глубина" или точность звучания. 8 бит, 16 бит и т.д.
			36..39 (4 байта) 	subchunk2Id 	Содержит символы "data" (0x64617461 в big-endian представлении)
			40..43 (4 байта) 	subchunk2Size 	Количество байт в области данных.
			44.. 	data 	Непосредственно WAV-данные.	*/

		public function convert8bitWav(b:ByteArray):void
		{
			bytes = new ByteArray;
			b.readBytes( bytes,0,44);
			
			to12bit(b);
			
			return;
			
			// make mono
			//bytes[22] = 1;
			//bytes[23] = 0;
			// make sample rate
			
			var n:int = bytes[24] | (bytes[25] << 8) | (bytes[26] << 16) | (bytes[27] << 24 ); 
			n = n*2;
			
			/*bytes[28] = bytes[24];
			bytes[29] = bytes[25];
			bytes[30] = bytes[26];
			bytes[31] = bytes[27];*/
			
			bytes[28] = (n & 0x000000FF);
			bytes[29] = (n & 0x0000FF00) >> 8;
			bytes[30] = (n & 0x00FF0000) >> 16;
			bytes[31] = (n & 0xFF000000) >> 24;
			// 32..33 (2 байта) 	blockAlign 	Количество байт для одного сэмпла, включая все каналы.
			bytes[32] = 2;
			bytes[33] = 0;
			// 34..35 (2 байта) 	bitsPerSample 	Количество бит в сэмпле. Так называемая "глубина" или точность звучания. 8 бит, 16 бит и т.д.
			bytes[34] = 12;
			bytes[35] = 0;
			
			
			to8bit(b);
			
			var size:int = bytes.length-8;
			// 4..7 (4 байта) 	chunkSize 	Это оставшийся размер цепочки, начиная с этой позиции. Иначе говоря, это размер файла - 8, то есть, исключены поля chunkId и chunkSize.
			bytes[4] = (size & 0x000000FF);
			bytes[5] = (size & 0x0000FF00) >> 8;
			bytes[6] = (size & 0x00FF0000) >> 16;
			bytes[7] = (size & 0xFF000000) >> 24;
			size = bytes.length-44;
			// 40..43 (4 байта) 	subchunk2Size 	Количество байт в области данных.
			bytes[40] = (size & 0x000000FF);
			bytes[41] = (size & 0x0000FF00) >> 8;
			bytes[42] = (size & 0x00FF0000) >> 16;
			bytes[43] = (size & 0xFF000000) >> 24;
		}
		private function to12bit(b:ByteArray):void
		{
			var coef:Number = 0xFFF/0xFFFF;
			
			bytes.position = bytes.length;
			var num:int;
			var len:int = b.length;
			for (var i:int=HEADER_SIZE; i<len; i) {
				
				num = Math.ceil(((b[i+1] << 8) | b[i])*coef);
				
				bytes.writeByte( num & 0x00FF );
				bytes.writeByte( (num & 0xFF00) >> 8 );
				
				
				
				//var bg1:int = num & 0x00FF;
				//var bg2:int = (num & 0xFF00) >> 8;
				
				//bytes.writeByte( b[i+1] );
				i+=2;
			}
		}
		private function to8bit(b:ByteArray):void
		{
			bytes.position = bytes.length;
			var num:int;
			var len:int = b.length;
			for (var i:int=HEADER_SIZE; i<len; i) {
				
				num = (b[i] << 8) | b[i+1];

				bytes.writeByte( (num & 0x00FF) >> 4 );
				bytes.writeByte( (num & 0xFF00) >> 8 );
				
				//bytes.writeByte( b[i+1] );
				i+=2;
			}
		}
		
		/** На вход требуется 16 битный файл */ 
		public function get12Wav(b:ByteArray):void
		{
			/*
			var b1:ByteArray = new ByteArray;
			b1.writeByte( 0x40 );
			b1.writeByte( 0x60 );
			
			var num:int;
			var len:int = b.length;
			var b1int:int = b1[0]; 
			var b2int:int = b1[1]; 
			
			num = b1[1] << 8 | b1[0];
			num = num >> 4;
			
			var c2:int = (num & 0xFF00) >> 4;
			var c1:int = num & 0x00FF;
			
			return;
			*/
			processHeader(b);
			processData(b);
			
			bytes = b;
		}
		
		private function processHeader(b:ByteArray):void
		{
			// set mono
	//		b[22] = 1;
	//		b[23] = 0;
			// set bit per sample, 12 bit
		//	b[34] = 12;
		//	b[25] = 0;
		}
		private function processData(b:ByteArray):void
		{
			var num:int;
			var len:int = b.length;
			for (var i:int=HEADER_SIZE; i<len; i) {
				num = (b[i] << 8) | b[i+1];
				
				trace("до"+ (b[i] as int).toString(16) +" "+ (b[i+1] as int).toString(16) );
				
				b[i+1] = (num & 0xFF00) >> 8
				b[i] = (num & 0x00FF) >> 4
				
				trace("после"+ (b[i] as int).toString(16) +" "+ (b[i+1] as int).toString(16) );
					
				i+=2;
			}
		}
	}
}