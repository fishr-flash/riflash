package components.protocol
{
	import flash.utils.ByteArray;
	
	import components.abstract.functions.dtrace;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.CRC16;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.protocol.workers.BinaryCompressor;

	public class ProtocolBinary2
	{
		private var lastPacketNum:int;
		private var PACKET_ADRESS:int;
		public function disassemble(a:Array):Package
		{
			PACKET_ADRESS = 0;
			var funct:uint;
			if (a) {
				
				var adrTo:int = a[7];
				
				
				if (adrTo != CLIENT.ADDRESS)	// если адрес получателя не клиент - ничего не делать
					return null;
				
				var responseCrc16:int = ( (a[ a.length-1 ] << 8) | a[ a.length-2 ] );
				
				// [PR 3] [VER 1] [LP length 2] [ADR 2] [NP packet num 2] [F funct 1]
				funct = a[10];//
				var pVer:int = a[3];
				var error:uint = uint(a[10] & 0xF0);//
				var cmdIndex:int = (a[12] << 8) | a[11];//
				var structAmount:int = (a[14] << 8) | a[13];//
				lastPacketNum = (a[9] << 8) | a[8];//
				PACKET_ADRESS = a[6];
				var dataLength:int = (a[5] << 8) | a[4];
				
				if ( pVer != 0x02 ) {
					errorStop( "Неправильная версия протокола", ErrorHandler.WRONG_PROTOCOL );
					return null;
				}
				if ( !checkCRC16( a.slice(0, a.length-2 ), responseCrc16 ) ) {
					errorStop( "Ошибка контрольной суммы", ErrorHandler.WRONG_CRC );
					return null;
				}
				if ( error == 0x80 ) {
					errorStop("error", funct );
					return null;
				}
			} else
				funct = SERVER.BROKEN;
			var k:int;
			var p:Package;
			switch( funct ) {
				case SERVER.ONE_WAY_COMPRESSED_WRITE:
					return disassembleCompressedStream(a.slice(15, a.length-2), cmdIndex );
				case SERVER.ONE_WAY_WRITE:	// на функцию 7 не надо отвечать подтверждением получения
					return disassembleStream(a.slice(15, a.length-2), cmdIndex, false );;
				case SERVER.REQUEST_WRITE:
					return disassembleStream(a.slice(15, a.length-2), cmdIndex );
				case SERVER.ANSWER_READ:
					return disassembleStream(a.slice(15, a.length-2), cmdIndex, false );
				case SERVER.ANSWER_WRITE:
					p = new Package;
					p.success = true;
					p.bin2response = false;
					return p;
				case SERVER.BROKEN:	// когда искуственно посылается сломаный или нелошедший пакет, чтобы увеличить его номер при пересылке
					p = new Package;
					p.broken = true;
					return p;
				default:
					accidentStop( "Ошибка: с сервера пришла неверная функция записи/чтения: "+funct.toString(16), lastPacketNum );
					break;
			}
			return null;
		}
		private function disassembleCompressedStream(_bytes:Array, _cmdid:int):Package
		{
			var a:Array = BinaryCompressor.access().unpack(_bytes);
			
			var p:Package = new Package;
			p.cmd = _cmdid;
			p.data = a;
			p.structure = 0;
			p.bin2response = false;
			p.compressed = true;
			
			return p;
		}
		private function disassembleStream( _bytes:Array, _cmdid:int, bin2response:Boolean=true ):Package
		{
			var cmd:CommandSchemaModel = OPERATOR.getSchema( _cmdid );
			if ( !cmd ) {
				dtrace( "Описание команды не найдено:" + _cmdid );
				return null;
			}
			
			var l:int = cmd.Parameters.length;
			var k:int;
			var pm:ParameterSchemaModel;
			var structs:Array = new Array;
			var data:Array = [];
			
			while( _bytes.length > 0 ) {
				
				for ( var i:int=0; i < l; ++i ) {
					pm = cmd.Parameters[i];
					switch( pm.Type ) {
						case "String":
							var rlen:int = _bytes.length
							k=0;
							while( k < rlen ) {
								if ( _bytes[k] == 0x00 ) {
									if ( k > pm.Length ) {
										errorStop( "Длина текстовой строки больше, чем в описании команды", ErrorHandler.STRING_TOO_LONG );
										return null;
									}
									data.push( hex2str( _bytes.splice( 0, k ) ) );
									_bytes.shift();
									break;
								} else {
									k++;
								}
							}
							if ( data.length == 0 ) {
								errorStop( "В ответе не найден конец строки 0x00", ErrorHandler.STRING_END_NOT_FOUND );
								return null;
							}
							break;
						case "Decimal":
							
							var dec:uint = 0;
							for( k=pm.Length-1; k >= 0; --k ) {
								dec += _bytes[k] << k*8;
							}
							_bytes = _bytes.splice( pm.Length, _bytes.length );
							data.push( dec );
							
							break;
					}
				}
				if (data.length == cmd.Parameters.length) {
					structs.push( data );
					data = new Array;
				}
			}
			var p:Package = new Package;
			p.cmd = _cmdid;
			p.data = structs;
			p.structure = 0;
			p.bin2response = bin2response;
			return p;
		}
		public function generateAnswer():ByteArray
		{
			var ba:ByteArray = new ByteArray;
			var packetLength:int = 13;
			var a:Array = [0x80, 0x80, 0x80,
				0x02, 
				packetLength, 0x00,
				CLIENT.ADDRESS, PACKET_ADRESS,
				lastPacketNum & 0x00FF, (lastPacketNum & 0xFF00) >> 8, 
				SERVER.ANSWER_WRITE];
			var crc16:int = CRC16.calculate( a, a.length );
			a.push( crc16 & 0x00FF );
			a.push( (crc16 & 0xFF00) >> 8 );
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				ba.writeByte( a[i] );
			}
			return ba;
			/*
			Преамбула 3 Предназначена для поиска начала пакета
			Версия 1 Версия протокола
			Длина 2 Длина всего пакета
			Адрес 2, 1байт адрес получателя, 1байт адрес отправителя
			Номер пакета 2 Номер пакета, позволяет идентифицировать связку запрос-ответ
			Функция 	1	Функция, подтверждающая, что запись прошла удачно или неудачно.
			CRC16 2 Контрольная сумма CRC16  ( x16+x15+x2+1)
			*/
		}
		private function hex2str( _arr:Array ):String 
		{
			var len:int = _arr.length;
			var byteArr:ByteArray = new ByteArray;
			for( var i:int; i < len; ++i) {
				byteArr.writeByte( _arr[i] );
			}
			byteArr.position = 0;
			return byteArr.readMultiByte( byteArr.bytesAvailable, "windows-1251" );
		}
		private function checkCRC16( _arr:Array, _crc16:int ):Boolean
		{
			if ( CRC16.calculate( _arr, _arr.length ) != _crc16 )
				return false;
			return true;
		}
		private function accidentStop( _msg:String, lastPacketNum:uint ):void 
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
		}
		private function errorStop( _msg:String, err:int ):void 
		{
			//	fRequeue();
			//ErrorHandler.onError(err);
			trace("PROTOCOL BINARY 2 ERROR")
		}
	}
}