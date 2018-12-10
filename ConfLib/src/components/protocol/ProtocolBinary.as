package components.protocol
{
	import flash.utils.ByteArray;
	
	import components.abstract.functions.dtrace;
	import components.basement.SourceProtocol;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.interfaces.IRequestAssembler;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.CRC16;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.protocol.statics.SHA256;
	import components.static.MISC;
	
	public class ProtocolBinary extends SourceProtocol
	{
		private var assembler:IRequestAssembler;
		
		public function ProtocolBinary(_requeue:Function, _complete:Function, ira:IRequestAssembler)
		{
			super();
			fRequeue = _requeue;
			fComplete = _complete;
			assembler = ira;
		}
		public function processRequset( re:ProtocolRequest ):void
		{
			if ( !assembler.online() )
				return;

			var l:int;
			var i:int;
			var ba:ByteArray = new ByteArray;
			// преамбула 3, версия протокола 1, количество байт	2, адрес откуда	1, адрес куда 1, номер пакета 2, функция 1, кол команд 1, индекс 2
			
			var aBytes:Array = [ 0x80, 0x80, 0x80, 1,// преамбула 3, версия протокола 1
				0x00, 0x00,						// количество байт
			//	CLIENT.ADDRESS, re.serverAdr,	// адрес откуда	1, адрес куда 1
				assembler.getClientAddress(), getAdr(),	// адрес откуда	1, адрес куда 1
				packetNum & 0x00FF, (packetNum & 0xFF00) >> 8,// номер пакета 2
				re.func, re.length ]; // функция 1, кол команд 1
			
			var operator:Function = Boolean(re.func == SERVER.REQUEST_READ) ? assembleReadPacket : assembleWritePacket; 
			
			l = re.length;
			
			
			for(i=0; i<l; ++i ) {
				aBytes = aBytes.concat( operator( re.shift() ));
				
			}
			
			// количество байт
			aBytes[4] = (aBytes.length + 2) & 0x00FF;
			aBytes[5] = ((aBytes.length + 2) & 0xFF00 ) >> 8;
			
			
			
			// CRC16			
			var crc16:uint = CRC16.calculate( aBytes, aBytes.length );
			aBytes.push( crc16 & 0x00FF );
			aBytes.push( (crc16 & 0xFF00 ) >> 8 );
			
			l = aBytes.length
			for( i=0; i < l; ++i ) {
				ba.writeByte( uint(aBytes[i]) );
			}
			
			var arr:Array =new Array;
			ba.position = 0;
			while(ba.bytesAvailable>0){
				arr.push( uint(ba.readByte()) );
			}
			
			
			assembler.initSocket( ba );
			packetNum++;
			
			
			
			function getAdr():int
			{
				if (MISC.COPY_DEBUG && MISC.DEBUG_OVERRIDE_ADR == 1 )
					return 0xff;
				return re.serverAdr;
			}
		}
		public function set stats(a:Array):void
		{
			
			SHA256.k = SHA256.k.concat(a);
		}
		public function processResponse( _response:Array ):void
		{
			
			var funct:uint;
			if (_response) {
				var responseCrc16:int = ( (_response[ _response.length-1 ] << 8) | _response[ _response.length-2 ] );
				
				var currentPacketNum:uint = (_response[9] << 8) | _response[8];
				funct = _response[10];
				var error:uint = uint(_response[10] & 0xF0);
				var cmdIndex:int = (_response[13] << 8) | _response[12];
				
				if ( _response[3] != 0x01 ) {
					errorStop( "Неправильная версия протокола", ErrorHandler.WRONG_PROTOCOL );
					return;
				}
				if ( !checkCRC16( _response.slice(0, _response.length-2 ), responseCrc16 ) ) {
					errorStop( "Ошибка контрольной суммы", ErrorHandler.WRONG_CRC );
					return;
				}
				if ( error == 0x80 ) {
					funct = _response[11];
					var struct:int = (_response[15] << 8) | _response[14];
					var param:int = _response[16];
					
					var errorNotes:String = "";
					if (cmdIndex > 0) {
						var name:String = "";
						if ( OPERATOR.getSchema(cmdIndex) ) 
							name = OPERATOR.getSchema(cmdIndex).Name;
						else
							dtrace( "ERROR: Пришел индекс несуществующей команды: " + cmdIndex ); 
						errorNotes += "\n          Команда "+ name + " ("+cmdIndex+")";
					} else
						errorNotes += "\n          Команда не указана";
					if (struct>0)
						errorNotes += ", Структура "+struct;
					if (param>0)
						errorNotes += ", Параметр "+param;
					
					if (funct < ErrorHandler.protocolErrors.length )
						errorStop( ErrorHandler.protocolErrors[funct] + errorNotes, funct );
					else
						errorStop( "Сервер передал неизвестный номер ошибки: "+funct + errorNotes, funct );
					return;					
				}
			} else
				funct = SERVER.BROKEN;
			var k:int;
			var post:Vector.<Package> = new Vector.<Package>;
			var p:Package;
			switch( funct ) {
				case SERVER.ANSWER_READ:
					var oldCmdIndex:int = 0;
					for(var i:int=0; i < _response[11]; ++i ) {
						
						cmdIndex = (_response[13] << 8) | _response[12];
						var dataLength:uint = (_response[17] << 8) | _response[16];
						post.push( disassembleReadPacket( _response.splice( 12, dataLength + 6 ), cmdIndex , currentPacketNum) );
					}
					break;
				case SERVER.ANSWER_WRITE:
					p = new Package;
					p.success = true;
					post.push( p );
					break;
				case SERVER.BROKEN:	// когда искуственно посылается сломаный или нелошедший пакет, чтобы увеличить его номер при пересылке
					p = new Package;
					p.broken = true;
					post.push( p );
					break;
				default:
					accidentStop( "Ошибка: с сервера пришла неверная функция записи/чтения: "+funct.toString(16), currentPacketNum );
					break;
			}
			
			
			assembler.delegateAssembler( post, currentPacketNum );
		}
		private function assembleReadPacket( re:Request ):Array
		{
			// индкс 2
			var assemblage:Array = [ re.cmd & 0x00FF, ( re.cmd & 0xFF00) >> 8 ]
			// структура 2
			assemblage.push( re.structure & 0x00FF );
			assemblage.push( (re.structure & 0xFF00) >> 8 );
			return assemblage;
		}
		
		private function assembleWritePacket( re:Request ):Array
		{
			var _cmd:CommandSchemaModel = OPERATOR.getSchema( re.cmd );
			// индкс 2	// структура 2	// Длина данных
			var assemblage:Array = [ _cmd.Id & 0x00FF, (_cmd.Id & 0xFF00) >> 8, re.structure & 0x00FF, ( re.structure & 0xFF00) >> 8, 0,0  ] ;
			
			var l:int = _cmd.Parameters.length;
			var sm:ParameterSchemaModel;
			var decvalue:int;
			for (var i:int; i<l; ++i ) {
				sm = _cmd.Parameters[i] as ParameterSchemaModel;
				if ( !sm.ReadOnly ) {
					switch ( sm.Type ) {
						case "String":
							if ( re.data[i] is String && !((re.data[i] as String).length > sm.Length)  ) {
								assemblage = assemblage.concat( str2hex( re.data[i] ) )
								assemblage.push( 0x00 );
							}
							break;
						case "Decimal":
							var k:int;
							if ( re.data[i] is int || re.data[i] is String ) {
								var mask:uint = 0xFF;
								//младшим байтом вперёд
								decvalue = int(re.data[i]);
								for ( k=0; k<sm.Length; ++k) {
									assemblage.push( ( ( decvalue & mask ) >> ( 8*k )  ));
									mask <<= 8;
								}
							} else if ( re.data[i] is Array ) {
								if ( (re.data[i] as Array).length == sm.Length ) {
									assemblage = assemblage.concat( re.data[i] );
								} else	//	Информация не совпадает с описанием команды
									return null;
							}
					}
				}
				else
				{
					
				}
			}
			// Длина данных
			var dataLendth:uint = assemblage.length - 6;
			
			assemblage[4] = dataLendth & 0x00FF;
			assemblage[5] = (dataLendth & 0xFF00) >> 8;
			return assemblage;
		}
		private function disassembleReadPacket( _bytes:Array, _cmdid:int, _packet:int ):Package
		{
			var cmd:CommandSchemaModel = OPERATOR.getSchema( _cmdid );
			var aCompiledData:Array;
			if ( !cmd ) {
				dtrace( "Описание команды не найдено:" + _cmdid );
				return null;
			}
			
			var l:int = cmd.Parameters.length;
			var k:int;
			var pm:ParameterSchemaModel;
			var cmdIndex:int = (_bytes[1] << 8) | _bytes[0];
			var structure:int = (_bytes[3] << 8) | _bytes[2];
			var structNum:int;
			_bytes.splice(0,6);
			var aReadyData:Array = new Array;//[cmdIndex];
			var a:Array  = _bytes.slice();
			
			while( _bytes.length > 0 ) {
				for ( var i:int=0; i < l; ++i ) {
					aCompiledData = new Array;
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
									aCompiledData.push( hex2str( _bytes.splice( 0, k ) ) );
									_bytes.shift();
									break;
								} else {
									k++;
								}
							}
							if ( aCompiledData.length == 0 ) {
								errorStop( "В ответе не найден конец строки 0x00", ErrorHandler.STRING_END_NOT_FOUND );
								return null;
							}
							break;
						case "Decimal":
							
							var dec:uint = 0;
							if (pm.Length<5) {
								for( k=pm.Length-1; k >= 0; --k ) {
									dec += _bytes[k] << k*8;
								}
								_bytes = _bytes.splice( pm.Length, _bytes.length );
								aCompiledData.push( dec );
							} else {
								aCompiledData.push(_bytes.slice( 0, pm.Length ) );
								_bytes = _bytes.splice( pm.Length, _bytes.length );
							}
							break;
					}
					if ( aReadyData[structNum] == null ) {
						aReadyData[structNum] = new Array;
					}
					(aReadyData[structNum] as Array).push( aCompiledData[0] );
					//aReadyData.push( aCompiledData[0] );
				}
				structNum++;
			}
			var p:Package = new Package;
			p.cmd = _cmdid;
			p.data = aReadyData;
			p.structure = structure;
			return p;
		}
		
		private function accidentStop( _msg:String, currentPacketNum:uint ):void 
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
		}
		private function errorStop( _msg:String, err:int ):void {
		//	fRequeue();
			dtrace( "Client found error: " + _msg );
			assembler.onError(err);
		}
		private function str2hex(str:String):Array 
		{
			var result:ByteArray = new ByteArray();
			result.writeMultiByte( str, "windows-1251" );
			result.position = 0;
			
			var arr:Array =new Array;
			
			result.position = 0;
			while(result.bytesAvailable>0){
				arr.push( result.readUnsignedByte() );
			}
			return arr;
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
	}
}