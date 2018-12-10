package components.abstract.servants
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import components.abstract.functions.dtrace;
	import components.events.GUIEvents;
	import components.interfaces.IFirmwareEngine;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.CRC32;

	public class FirmwareServant_specialForV2n055 extends FirmwareServant
	{

		private var _crc32_true:int;

		private var _aFullFirmWare:Array;
		
		
		public  function FirmwareServant_specialForV2n055()
		{
			
			super();
		}
		
		override public function write():void
		{
			if (!firmware) {
				this.dispatchEvent( new Event( GUIEvents.EVOKE_ERROR ) );
				return;
			}
			
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
			
			CLIENT.IS_WRITING_FIRMWARE = true;
			
			errorHappens = false;
			
			progress = 0;
			var crc32:int = 0;
			if ( firmware ) {
				var i:int;
				var len:int;
				var structCounter:int=1;
				var byte:int;
				firmware.position = 0;
				_aFullFirmWare = new Array;
				while( firmware.bytesAvailable > 0 ) {
					var arr:Array = new Array;
					arr.push( new Array );
					var sCounter:int=0;
					var sNum:int=0;
					
					for( i=0; i < 128; ++i, ++sCounter ) {
						if ( sCounter == 32 ) {
							sCounter = 0;
							sNum++;
							arr.push( new Array );
						}
						
						if ( firmware.bytesAvailable > 0 ) {
							
							byte = firmware.readUnsignedByte();
							arr[sNum].push( byte );
							_aFullFirmWare.push( byte );
						} else {
							arr[sNum].push( 0xFF );
							_aFullFirmWare.push( 0xFF );
						}
					}
					if ( errorHappens ) return;
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD_PART, writeToDeviceProgress, structCounter, arr, Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
					structCounter++;
				}
				
				_crc32_true = CRC32.calculate( _aFullFirmWare, _aFullFirmWare.length );
				crc32 = CRC32.calculate( _aFullFirmWare, 256 );
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD_CRC, null, 1, [crc32, 256 ], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD_WRITE, sentTrueCRC, 1, [ 0x31 ], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				
				progressTotal = Math.ceil(firmware.length/128);
			}
			
			
			
		}
		
		private function sentTrueCRC( p:Package ):void
		{
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD_CRC, firmwareSent, 1, [_crc32_true, _aFullFirmWare.length ], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
			
		}
	}
}