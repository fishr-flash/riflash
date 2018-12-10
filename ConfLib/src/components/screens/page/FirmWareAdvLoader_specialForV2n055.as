package components.screens.page
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.CRC32;

	public class FirmWareAdvLoader_specialForV2n055 extends FirmWareAdvLoader
	{

		private var _crc32_true:int;
		public function FirmWareAdvLoader_specialForV2n055(lbl:String="")
		{
			
			
			super(lbl);
		}
		
		override protected function writeToDevice( countStrc:int = 1 ):void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
			
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			CLIENT.IS_WRITING_FIRMWARE = true;
			
			bWriteUpdateToDevice.disabled = true;
			//tFileName.text = "";
			bLoalUpdateFromFile.disabled = true;
			bCancelUpdate.visible = true;
			errorHappens = false;
			
			//	trace( UTIL.showByteArray( firmware ));
			
			progress = 0;
			var crc32:int = 0;
			if ( firmware ) {
				// TODO Сделать более акуратный перебор				
				var i:int;
				var len:int;
				
				/// В расширяющем классе IconLoader структуры будут начинаться не с единицы
				/// поэтому сначала узнаем присвоен ли номер структуре
				//if( !structCounter ) structCounter = 1;
				structCounter = countStrc;
				var byte:int;
				firmware.position = 0;
				var aFullFirmWare:Array = new Array;
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
							aFullFirmWare.push( byte );
						} else {
							arr[sNum].push( 0xFF );
							aFullFirmWare.push( 0xFF );
						}
					}
					if ( errorHappens ) return; 
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD_PART, writeToDeviceProgress, structCounter, arr, Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
					structCounter++;
				}
				
				_crc32_true = CRC32.calculate( aFullFirmWare, aFullFirmWare.length );
				crc32 = CRC32.calculate( aFullFirmWare, 256);
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD_CRC, null, 1, [crc32, 256], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD_WRITE, sentTrueCRC, 1, [ 0x31 ], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				
				progressTotal = Math.ceil(firmware.length/128);
				
				
				pBar.setProgress( 0, progressTotal );
				label = loc("fw_loaded")+"0%";
				pBar.visible = true;
				
				GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
				heightChanged();
			}
		}
		
		private function sentTrueCRC( p:Package ):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD_CRC, firmwareSent, 1, [_crc32_true, firmware.length], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
			
		}
	}
	
}