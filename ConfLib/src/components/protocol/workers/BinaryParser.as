package components.protocol.workers
{
	import flash.utils.ByteArray;
	
	import components.abstract.functions.dtrace;
	import components.protocol.ErrorHandler;
	import components.protocol.Package;
	import components.protocol.models.BinaryModel;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.CRC16;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.COLOR;
	import components.system.UTIL;

	public class BinaryParser
	{
		private var errors:String="";
		private var bm:BinaryModel;
		
		public function processResponse( b:Array ):BinaryModel
		{
			bm = new BinaryModel(UTIL.generateUId());
 			
			if (b[3]==1 || b[3]==2) {
			
				var protocol:int = b[3];				
				
				var responseCrc16:int = ( (b[ b.length-1 ] << 8) | b[ b.length-2 ] );
				
				var crcB1:int = b[ b.length-2 ];
				var crcB2:int = b[ b.length-1 ];
				
				var currentPacketNum:uint = (b[9] << 8) | b[8];
				var funct:uint = b[10];
				var error:uint = uint(b[10] & 0xF0);
				var cmdIndex:int = (b[13] << 8) | b[12];
				
				// bm.addLine( "Пакет целиком:",UTIL.showArray( b ), "" );
				
				bm.addLine( "Преамбула:", hex(b[0]) + " " + hex(b[1]) + " " + hex(b[2]), "" ); 
				bm.addLine( "Версия протокола:", hex(b[3]), b[3] );
				bm.addLine( "Длина всего пакета:", hex(b[4]) +" "+ hex(b[5]), ((b[5] << 8) | b[4]).toString() );
				bm.addLine( "Адрес \"откуда\":", hex(b[6]),b[6] );
				bm.addLine( "Адрес \"куда\":", hex(b[7]), b[7] );
				bm.addLine( "Номер пакета:", hex(b[8]) + " " + hex(b[9]), currentPacketNum.toString() );
				
				bm.addLine( "Функция:", hex(b[10]), getFunct(b[10]) );
				
				if (funct != 4)
					bm.addLine( "Количество команд:", hex(b[11]),b[11] );
				
				var realCRC:int = CRC16.calculate( b.slice(0, b.length-2 ), b.length-2 ); 
				if ( realCRC != responseCrc16 )
					addError( "Ошибка контрольной суммы" );
				
				if ( error == 0x80 ) {
					funct = b[11];
					var struct:int = (b[15] << 8) | b[14];
					var param:int = b[16];
					
					var errorNotes:String = "";
					if (cmdIndex > 0) {
						var name:String = "";
						if ( OPERATOR.getSchema(cmdIndex) ) 
							name = OPERATOR.getSchema(cmdIndex).Name;
						else
							dtrace( "ERROR: Пришел индекс несуществующей команды: " + cmdIndex ); 
						errorNotes += "\r          Команда "+ name + " ("+cmdIndex+")";
					} else
						errorNotes += "\r          Команда не указана";
					if (struct>0)
						errorNotes += ", Структура "+struct;
					if (param>0)
						errorNotes += ", Параметр "+param;
					
					if (funct < ErrorHandler.protocolErrors.length )
						addError( ErrorHandler.protocolErrors[funct] + errorNotes );
					else
						addError( "Сервер передал неизвестный номер ошибки: "+funct + errorNotes );
				}
				
				var k:int;
				var i:int;
				var p:Package;
				var oldCmdIndex:int = 0;
				var dataLength:uint;
				
				switch( funct ) {
					case SERVER.REQUEST_READ:
						/*	PR={0x80,0x80,0x80} - преамбула;
							VER={0x01} - версия протокола;
							LP={0xXXXX} - длина пакета “Запрос на чтение”;
							ADR={0xXX,0xXX} - адрес отправителя и адрес получателя;
							NP={0xXXXX} - номер пакета;
							F={0x01} - функция “чтение данных”;
							C={0xXX} - количество индексированных команд в пакете;
							I={0xXXXX} - индексированная команда;
							SN={0xXXXX} - номер структуры формализованных данных индексированной команды I;
							Если в пакете используется несколько индексированных команд, то указываются индексированная команда и номер структуры друг за другом в количестве C;
							I={0xXXXX} - индексированная команда;
							SN={0xXXXX} - номер структуры формализованных данных индексированной команды I;
							***
							I={0xXXXX} - индексированная команда;
							SN={0xXXXX} - номер структуры формализованных данных индексированной команды I;
							CRC={0xXXXX} - CRC16.
						*/
						
						
						/**	PR={0x80,0x80,0x80} - преамбула;
							VER={0x02} - версия протокола;
							LP={0xXXXX} - длина пакета “Запрос на чтение”;
							ADR={0xXX,0xXX} - адрес отправителя и адрес получателя;
							NP={0xXXXX} - номер пакета;
							F={0x01} - функция “чтение данных”;
							I={0xXXXX} - индексированная команда;
							SС={0xXXXX} - количество, начиная с первой, структур формализованных данных индексированной команды I, 0x0000- получить все структуры команды;
							CRC={0xXXXX} - CRC16.*/
						
						
						var shift:int;
						
						if (protocol == 1) {
							for( i=0; i < b[11]; ++i ) {
								cmdIndex = (b[13+shift] << 8) | b[12+shift];
								
								bm.addLine("","","");
								bm.addLine( "Индекс:", hex(b[12+shift]) + " " + hex(b[13+shift]), getCMD(cmdIndex) );
								bm.addLine( "Структура:", hex(b[14+shift]) + " " + hex(b[15+shift]), (b[15+shift] << 8) | b[14+shift] );
								shift+=4;
							}
						} else {
							cmdIndex = (b[12] << 8) | b[11];
							
							bm.addLine("","","");
							bm.addLine( "Индекс:", hex(b[11]) + " " + hex(b[12]), getCMD(cmdIndex) );
							bm.addLine( "Количество структур, с 1:", hex(b[13]) + " " + hex(b[14]), (b[14] << 8) | b[13] );
						}
						break;
					case SERVER.ANSWER_READ:
						for( i=0; i < b[11]; ++i ) {
							
							cmdIndex = (b[13] << 8) | b[12];
							dataLength = (b[17] << 8) | b[16];
							
							bm.addLine("","","");
							bm.addLine( "Индекс:", hex(b[12]) + " " + hex(b[13]), getCMD(cmdIndex) );
							bm.addLine( "Структура:", hex(b[14]) + " " + hex(b[15]), (b[15] << 8) | b[14] );
							bm.addLine( "Длина данных:", hex(b[16]) + " " + hex(b[17]), dataLength );
							p = disassembleReadPacket( b.splice( 12, dataLength + 6 ), cmdIndex , currentPacketNum);
						}
						break;
					case SERVER.ANSWER_WRITE:
						break;
					case SERVER.REQUEST_WRITE:
					case SERVER.ONE_WAY_WRITE:
							
						/*	PR={0x80,0x80,0x80} - преамбула;
						3	VER={0x01} - версия протокола;
						4	LP={0xXXXX} - длина пакета “Запись данных”;
						6	ADR={0xXX,0xXX} - адрес отправителя и адрес получателя;
						8	NP={0xXXXX} - номер пакета;
						10	F={0x03} - функция “запись данных”;
						11	C={0xXX} - количество индексированных команд в пакете для записи;
						12	I={0xXXXX} - индексированная команда;
						14	SN={0xXXXX} - номер структуры формализованных данных индексированной команды I;
						16	L={0xXXXX} - длина данных;
						18	D={0xXX,0xXX,0xXX,0xXX,***,0xXX} - данные, записываемые командой I;
							Если в пакете используется несколько индексированных команд, то указываются индексированная команда, номер структуры, длинна данных и данные, друг за другом в количестве C;
							***
							I={0xXXXX} - индексированная команда;
							SN={0xXXXX} - номер структуры формализованных данных индексированной команды I;
							L={0xXXXX} - длина данных;
							D={0xXX,0xXX,0xXX,0xXX,***,0xXX} - данные, записываемые командой I;
							CRC={0xXXXX} - CRC16.*/
						
						/**	PR={0x80,0x80,0x80} - преамбула;
						3	VER={0x02} - версия протокола;
						4	LP={0xXXXX} - длина пакета “запись”;
						6	ADR={0xXX,0xXX} - адрес отправителя и адрес получателя;
						8	NP={0xXXXX} - номер пакета;
						10	F={0x03} - функция “запись данных”;
						11	I={0xXXXX} - индексированная команда;
						13	SС={0xXXXX} - количество, начиная с первой, структур формализованных данных индексированной команды I, которые должны быть записаны;
						15	D={0xXX,0xXX,0xXX,0xXX,***,0xXX} - данные, записываемые командой I;
							CRC={0xXXXX} - CRC16.
							Размер L1*= LP-Размер(PR+VER+ADR+NP+F+I+SC+CRC)*/
						
						if (protocol == 1) {
							/*cmdIndex = (b[13] << 8) | b[12];
							dataLength = (b[17] << 8) | b[16];
							
							bm.addLine("","","");
							bm.addLine( "Индекс:", hex(b[12]) + " " + hex(b[13]), getCMD(cmdIndex) );
							bm.addLine( "Структура:", hex(b[14]) + " " + hex(b[15]), (b[15] << 8) | b[14] );
							bm.addLine( "Длина данных:", hex(b[16]) + " " + hex(b[17]), dataLength );
							disassembleReadPacket( b.splice( 12, dataLength+6 ), cmdIndex , currentPacketNum);*/
							
							
							for( i=0; i < b[11]; ++i ) {
								
								cmdIndex = (b[13] << 8) | b[12];
								dataLength = (b[17] << 8) | b[16];
								
								bm.addLine("","","");
								bm.addLine( "Индекс:", hex(b[12]) + " " + hex(b[13]), getCMD(cmdIndex) );
								bm.addLine( "Структура:", hex(b[14]) + " " + hex(b[15]), (b[15] << 8) | b[14] );
								bm.addLine( "Длина данных:", hex(b[16]) + " " + hex(b[17]), dataLength );
								 disassembleReadPacket( b.splice( 12, dataLength + 6 ), cmdIndex , currentPacketNum);
							}
							
							
						} else {
							cmdIndex = (b[12] << 8) | b[11];
							dataLength = (b[17] << 8) | b[16];
							
							bm.addLine("","","");
							bm.addLine( "Индекс:", hex(b[11]) + " " + hex(b[12]), getCMD(cmdIndex) );
							bm.addLine( "Количество структур, с 1:", hex(b[13]) + " " + hex(b[14]), (b[14] << 8) | b[13] );
							//bm.addLine( "Длина данных:", hex(b[16]) + " " + hex(b[17]), dataLength );
							disassembleStream(b.slice(15, b.length-2), cmdIndex);
							//disassembleStream( b.splice( 12, dataLength+6 ), cmdIndex , currentPacketNum);
						}
						break;
					case SERVER.REQUEST_COMPRESSED_WRITE:
						addError( "Не дописана расшифровка сжатых записей" );
						if (protocol == 2) {
							
							//BinaryCompressor.access().unpack(
						}	
						break;
					case SERVER.ONE_WAY_COMPRESSED_WRITE:
						cmdIndex = (b[12] << 8) | b[11];
						dataLength = (b[17] << 8) | b[16];
						
						bm.addLine("","","");
						bm.addLine( "Индекс:", hex(b[11]) + " " + hex(b[12]), getCMD(cmdIndex) );
						bm.addLine( "Кол-во структур, с первой:", hex(b[13]) + " " + hex(b[14]), (b[14] << 8) | b[13] );
						
						var unpack:Array = BinaryCompressor.access().unpack(b.slice(15,b.length-2));
						bm.addLine( "Raw:   ", UTIL.showArray( b.slice(15,b.length-2), 10 ),"" );
						bm.addLine( "Расшифровка:   ", UTIL.showArray( unpack, 10 ),"" );
						
						break;
					default:
						addError( "Ошибка: с сервера пришла неверная функция записи/чтения: "+funct.toString(16) );
						break;
				}
				
				bm.addLine( "CRC16:", hex(crcB1)+" "+hex(crcB2), responseCrc16.toString(16).toUpperCase() +"\t|\tпосчитано: "+realCRC.toString(16).toUpperCase() );
				
				if (errors != "") {
					bm.addLine("","","");
					bm.addLine(UTIL.wrapHtml("Ошибки:", COLOR.RED),"","",errors);
					errors = "";
				}
				return bm;
			} else if (b[3]==2) {
				
				bm.addLine( "Преамбула:", hex(b[0]) + " " + hex(b[1]) + " " + hex(b[2]), "" ); 
				bm.addLine( "Версия протокола:", hex(b[3]), b[3] );
				bm.addLine( "Длина всего пакета:", hex(b[4]) +" "+ hex(b[5]), ((b[5] << 8) | b[4]).toString() );
				bm.addLine( "Адрес \"откуда\":", hex(b[6]),b[6] );
				bm.addLine( "Адрес \"куда\":", hex(b[7]), b[7] );
				bm.addLine( "Номер пакета:", hex(b[8]) + " " + hex(b[9]), currentPacketNum.toString() );
				
				bm.addLine( "Функция:", hex(b[10]), getFunct(b[10]) );
				
				return bm;
			} else
				return null;
			
			function hex(n:int):String
			{
				return UTIL.formateZerosInFront(n.toString(16),2).toUpperCase();
			}
			function getCMD(n:int):String
			{
				const digits:Array =
				[
					0x00B0,
					0x00B9,
					0x00B2,
					0x00B3,
					0x2074,
					0x2075,
					0x2075,
					0x2077,
					0x2078,
					
				];
				
				//const sep:String = String.fromCharCode( 0x2022 );//bullet
				//const sepI:String = String.fromCharCode( 0x25E6 );//white bullet
				//const sepI:String = String.fromCharCode( 0x00AB );//white bullet
				//const sepII:String = String.fromCharCode( 0x00BB );//white bullet
				
				//const sepI:String = String.fromCharCode( 0x003C );//white bullet
				//const sepII:String = String.fromCharCode( 0x003E );//white bullet
				
				//const sepI:String = String.fromCharCode( 0x2039 );//white bullet
				//const sepII:String = String.fromCharCode( 0x203A );//white bullet
				
				//const sepI:String = String.fromCharCode( 0x2044 );//white bullet
				//const sepII:String = String.fromCharCode( 0x2044 );//white bullet
				
				const sepI:String = String.fromCharCode( 0x2022 ); ///black bullet
				//const sepI:String = String.fromCharCode( 0x02DA );
				//const sepI:String = String.fromCharCode( 0x007C );
				//const sepI:String = "|";
				const sepII:String = "";//white bullet
				
				
				if (OPERATOR.getSchema(n)) {
					//var name:String = OPERATOR.getSchema(n).Name + " " + sepI + "" + getNumAsString( n ) + "" + sepII;
					var name:String = OPERATOR.getSchema(n).Name + " " + sepI + " " + n + "" + sepII;
					bm.cmd = name;
					return n + "\t|\t" + name;
				}
				return n + "\t|\tUNKNOWN CMD";
			}
			function getFunct(n:int):String
			{
				/*
				0x01 - функция чтение структуры параметров;
				0x02 - функция подтверждения чтения структуры параметров;
				0x03 - функция записи структуры параметров;
				0x04 - функция подтверждения записи структуры параметров;
				*/
				
				var msg:String;
				
				switch(n) {
					case SERVER.REQUEST_READ:
						msg = UTIL.wrapHtml("запрос на чтение",COLOR.RED);
						break;
					case SERVER.ANSWER_READ:
						msg = UTIL.wrapHtml("ответ на чтение",COLOR.BLUE);
						break;
					case SERVER.REQUEST_WRITE:
						msg = UTIL.wrapHtml("запрос на запись",COLOR.RED);
						break;
					case SERVER.ANSWER_WRITE:
						msg = UTIL.wrapHtml("ответ на запись",COLOR.BLUE);
						break;
					case SERVER.REQUEST_COMPRESSED_WRITE:
						msg = UTIL.wrapHtml("сжатая запись",COLOR.RED);
						break;
					case SERVER.ANSWER_COMPRESSED_WRITE:
						msg = UTIL.wrapHtml("ответ на сжатую запись",COLOR.BLUE);
						break;
					case SERVER.ONE_WAY_WRITE:
						msg = UTIL.wrapHtml("запись без ответа",COLOR.GREEN_DARK);
						break;
					case SERVER.ONE_WAY_COMPRESSED_WRITE:
						msg = UTIL.wrapHtml("сжатая запись без ответа",COLOR.BROWN);
						break;
					default:
						msg = "неверная функция";
						break;
				}
				bm.func = msg;
				return n + "\t|\t" +  msg;
			}
		}
		private function disassembleStream( _bytes:Array, _cmdid:int ):void
		{
			var cmd:CommandSchemaModel = OPERATOR.getSchema( _cmdid );
			if ( !cmd ) {
				dtrace( "error@BinaryParser: Описание команды не найдено:" + _cmdid );
				return;
			}
			
			var l:int = cmd.Parameters.length;
			var k:int;
			var pm:ParameterSchemaModel;
			var data:Array = [];
			
			var raw:Object;
			var structure:int=1;
			
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
										addError( "Длина текстовой строки больше, чем в описании команды"+ " ("+cmd.Name+"|"+cmd.Id+")" );
										return;
									}
									data.push( hex2str( _bytes.splice( 0, k ) ) );
									
									raw = {label:"S,"+ pm.Length, data:UTIL.showArray(_bytes.slice( 0, k+1 ),10)};
									raw["result"] = data[data.length-1];
									
									_bytes.shift();
									break;
								} else {
									k++;
								}
							}
							if ( data.length == 0 ) {
								addError( "В ответе не найден конец строки 0x00"+ " ("+cmd.Name+"|"+cmd.Id+")" );
								return;
							}
							break;
						case "Decimal":
							
							var dec:uint = 0;
							for( k=pm.Length-1; k >= 0; --k ) {
								dec += _bytes[k] << k*8;
							}
							raw = {label:"D,"+ pm.Length, data:UTIL.showArray(_bytes.slice( 0, pm.Length ),10)}
							_bytes = _bytes.splice( pm.Length, _bytes.length );
							data.push( dec );
							raw["result"] = dec;
							break;
					}
					bm.addLine( "Структура "+structure +" п"+pm.Order, raw["data"], raw["label"] + "\t|\t"+raw["result"] );
				}
				structure++;
				bm.addLine("","","");
				if (data.length == cmd.Parameters.length) {
					data = new Array;
				}
			}
		}
		private function disassembleReadPacket( _bytes:Array, _cmdid:int, _packet:int ):Package
		{
			var cmd:CommandSchemaModel = OPERATOR.getSchema( _cmdid );
			var aCompiledData:Array;
			var aRawData:Array;
			var raw:Object;
			if ( !cmd ) {
				addError( "error@BinaryParser: Описание команды не найдено:" + _cmdid );
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
			
			bm.addLine( "Данные:", UTIL.showArray( _bytes, 10 ), "" );
			
			while( _bytes.length > 0 ) {
				for ( var i:int=0; i < l; ++i ) {
					var err:Boolean = false;
					aCompiledData = new Array;
					aRawData = new Array;
					pm = cmd.Parameters[i];
					switch( pm.Type ) {
						case "String":
							var rlen:int = _bytes.length
							k=0;
							while( k < rlen ) {
								if ( _bytes[k] == 0x00 ) {
									if ( k > pm.Length ) {
										addError( "Длина текстовой строки больше, чем в описании команды"+ " ("+cmd.Name+"|"+cmd.Id+")" );
										return null;
									}
									raw = {label:"S,"+ pm.Length, data:UTIL.showArray(_bytes.slice( 0, k+1 ),10)};
									aCompiledData.push( hex2str( _bytes.splice( 0, k ) ) );
									
									raw["result"] = aCompiledData[aCompiledData.length-1];
									aRawData.push( raw );
									_bytes.shift();
									break;
								} else {
									k++;
								}
							}
							if ( aCompiledData.length == 0 ) {
								addError( "В ответе не найден конец строки 0x00"+ " ("+cmd.Name+"|"+cmd.Id+")" );
								return null;
							}
							break;
						case "Decimal":
							
							var dec:uint = 0;
							for( k=pm.Length-1; k >= 0; --k ) {
								dec += _bytes[k] << k*8;
							}
							raw = {label:"D,"+ pm.Length, data:UTIL.showArray(_bytes.slice( 0, pm.Length ),10)}
							_bytes = _bytes.splice( pm.Length, _bytes.length );
							aCompiledData.push( dec );
							raw["result"] = dec;
							aRawData.push( raw );
							break;
					}
					if ( aReadyData[structNum] == null ) {
						aReadyData[structNum] = new Array;
					}
					(aReadyData[structNum] as Array).push( aCompiledData[0] );
					bm.addLine( "Структура "+structure +" п"+pm.Order, aRawData[0]["data"], aRawData[0]["label"] + "\t|\t"+aRawData[0]["result"] ); 
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
		private function checkCRC16( _arr:Array, _crc16:int ):Boolean
		{
			if ( CRC16.calculate( _arr, _arr.length ) != _crc16 )
				return false;
			return true;
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
		private function addError(msg:String):void
		{
			//errors.push( msg );
			errors += msg +"\r";
		}
		
		/**
		 *  Возвращает число в строковом формате
		 * собранное из специальных маленьких символов 
		 * шрифта юникода
		 * 
		 * n - число представление которого требуется
		 * 
		 * return представление n в специальном формате в качестве строки
		 * 
		 */
		private function getNumAsString( n:int ):String
		{
			const nums:String = n.toString();
			var lbl:String = "";
			const digits:Array =
			[
				0x00B0,
				0x00B9,
				0x00B2,
				0x00B3,
				0x2074,
				0x2075,
				0x2076,
				0x2077,
				0x2078,
				0x2079
				
			];
			
			var len:int = nums.length;
			for (var i:int=0; i<len; i++) 
			{
				lbl += String.fromCharCode( digits[ int( nums.charAt( i ) ) ] );
			}
			
			return lbl;
		}
	}
}