package components.abstract.servants
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import components.events.GUIEvents;
	import components.interfaces.IFirmwareEngine;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.CRC32;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;

	public class FirmwareServant extends EventDispatcher implements IFirmwareEngine
	{
		protected const ENDWRITE_TIMER:int = 3000;
		protected const FAIL_TIMEOUT:int = 1000;
		
		protected var ADDRESS:int = SERVER.ADDRESS_TOP;
		protected var CMD_PART:int = CMD.BOOT_SER;
		protected var CMD_WRITE:int = CMD.BOOT_WRITE;
		protected var CMD_CRC:int = CMD.BOOT_CRC32;
		
		protected var progressTotal:int;
		protected var progress:int;
		protected var errorHappens:Boolean = false;
		
		protected var endWriteTimer:Timer;
		protected var failResponseTimer:Timer;
		protected var reconnectTimer:Timer;
		
		protected var firmware:ByteArray;
		
		public function put(b:ByteArray):void
		{
			//firmware = b;
			firmware = FirmwareChecker.check(b,getVer());
		}
		public function write():void
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
				
				
				crc32 = CRC32.calculate( aFullFirmWare, aFullFirmWare.length );
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD_CRC, null, 1, [crc32, aFullFirmWare.length], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD_WRITE, firmwareSent, 1, [ 0x31 ], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				
				progressTotal = Math.ceil(aFullFirmWare.length/128);
			}
		}
		public function get percload():int
		{
			return int((progress*100) / progressTotal);
		}
		protected function writeToDeviceProgress( p:Package):void
		{
			if (CLIENT.IS_WRITING_FIRMWARE) {
				if ( p.success ) {
					progress++;
					this.dispatchEvent( new Event( Event.CHANGE ));
				} else {
					errorHappens = true;
					cancelWrite();
				}
			}
		}
		protected function cancelWrite():void
		{
			CLIENT.IS_WRITING_FIRMWARE = false;
			RequestAssembler.getInstance().clearStackLater();
			this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
		}
		protected function firmwareSent(p:Package):void
		{
			if( !endWriteTimer ) {
				endWriteTimer = new Timer(ENDWRITE_TIMER,1);
				endWriteTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sendTesting );
			}
			endWriteTimer.reset();
			endWriteTimer.start();
		}
		private function sendTesting(ev:TimerEvent):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD_WRITE, testFailWrite, 1, null, Request.URGENT, 0, ADDRESS ));
			if( !failResponseTimer ) {
				failResponseTimer = new Timer(FAIL_TIMEOUT,1);
				failResponseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, failTimeOut );
			}
			failResponseTimer.reset();
			failResponseTimer.start();
		}
		private function failTimeOut( ev:TimerEvent ):void 
		{
			writeToDeviceComplete();
		}
		private function testFailWrite(p:Package):void
		{
			if (p.getStructure()[0] != 0x33 )
				writeToDeviceComplete();
			else
				finishWritingFirmware();
			failResponseTimer.stop();
		}
		private function finishWritingFirmware():void
		{
			CLIENT.IS_WRITING_FIRMWARE = false;
			this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
		}
		private function writeToDeviceComplete():void 
		{
			if (!reconnectTimer) {
				reconnectTimer = new Timer(2000,1);
			}
			reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doDisconnect );
			reconnectTimer.reset();
			reconnectTimer.start();
		}
		private function doDisconnect(ev:TimerEvent):void
		{
			finishWritingFirmware();
			SocketProcessor.getInstance().reConnect();
			reconnectTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, doDisconnect );
		}
		
		public function set sendAddress(adr:int):void
		{
			ADDRESS = adr; 
		}
		private function getVer():String
		{
			if (SERVER.DUAL_DEVICE && ADDRESS != 0xff)
				return SERVER.BOTTOM_VER_INFO[0][1];
			return DS.fullver;
		}
	}
}