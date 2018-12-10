package components.abstract.servants
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import components.events.GUIEvents;
	import components.interfaces.IFirmwareEngine;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.UTIL;

	public class FirmwareEngine extends EventDispatcher implements IFirmwareEngine
	{
		private var fw:Vector.<String>;
		private var progressTotal:int;
		private var progress:int;
		
		public function put(b:ByteArray):void
		{
			var startshift:int = 9;
			var endshift:int = 2;
			var datalen:int = 32;
			var cycle:int = 1;
			var txt:String = b.readMultiByte( b.bytesAvailable, "windows-1251" );
			var a:Array = txt.match( /[0-9A-Fa-f]{40}/g );
			var len:int = a.length;
			var index:int;
			fw = new Vector.<String>( len/4 );
			for (var i:int=0; i<len; i++) {
				if (!fw[index])
					fw[index] = "";
				fw[index] += String(a[i]).slice(8);
				cycle++;
				if (cycle > 4) {
					cycle = 1;
					fw[index] += calcXorCrc(fw[index]);
					index++;
				}
			}
			// после запуска +BL и +BE прибор отвечает только на команды +v и +W[hex4digit]:[128bytes:2bytescrc]
			// концом прошивки считается записанна структура 0000, соответвенно она должна быть послана последней
			// в строке прошивки берется 32 байта с 10 байта
		}
		public function write():void
		{
		//	CLIENT.IS_WRITING_FIRMWARE = true;
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
			progressTotal = 0;
			progress = 0;
			
			WatchDog.access().stop();	// Если будет писаться отмена перепрошивки - ОБЯЗАТЕЛЬНО надо обратно включать watchdog
			
			if( !MISC.VINTAGE_BOOTLOADER_ACTIVE ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_BL_BOOTLOADER, writeToDeviceProgress, 0, null, Request.URGENT, Request.PARAM_SAVE ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_BE_BOOTLOADER_ENGAGE, writeToDeviceProgress, 0, null, Request.URGENT, Request.PARAM_SAVE  ));
				progressTotal = 2;
			}
			var len:int = fw.length;
			for (var i:int=1; i<len; i++) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_W_WRITE, writeToDeviceProgress, i*4, [fw[i]], Request.URGENT, Request.PARAM_SAVE ));
			}
			progressTotal += len - 1;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_W_WRITE, finishWritingFirmware, 0, [fw[0]], Request.URGENT, Request.PARAM_SAVE ));
		}
		public function get percload():int
		{
			return int((progress*100) / progressTotal);
		}
		public function set sendAddress(adr:int):void
		{
			// в текстовом протоколе не требуется адрес 
		}
		private function writeToDeviceProgress(p:Package):void
		{
			progress++;
			this.dispatchEvent( new Event( Event.CHANGE ));
		}
		private function finishWritingFirmware(p:Package):void
		{
		//	CLIENT.IS_WRITING_FIRMWARE = false;
			TaskManager.callLater( onComplete, TaskManager.DELAY_3SEC );
		}
		private function onComplete():void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
			SocketProcessor.getInstance().disconnect();
		}
		private function calcXorCrc(value:String):String
		{
			var len:int = value.length, crc:int, target:int;
			
			for (var i:int=0; i<len; i+=2) {
				target = int("0x"+value.slice(i,i+2)); 
				crc ^= target;
			}
			return ":"+UTIL.fz( crc.toString(16), 2 ).toUpperCase();
		}
	}
}