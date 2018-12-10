package components.screens.page
{
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import components.abstract.functions.loc;
	import components.events.GUIEvents;
	import components.interfaces.IServiceFrame;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	
	public class FirmWareK1Loader extends FirmWareSimpleLoader implements IServiceFrame
	{
		private var fe:FirmwareEngine;
		
		public function FirmWareK1Loader()
		{
			super();
			
			fe = new FirmwareEngine;
			fe.addEventListener( GUIEvents.EVOKE_ERROR, onError );
			fe.addEventListener( GUIEvents.EVOKE_READY, onComplete);
			fe.addEventListener( Event.CHANGE, onFwProgress );
		}
		override public function init():void
		{
			super.init();
			
			firmware = null;
			
			var v:String = loc("service_not_identified");
			try {
				v = (OPERATOR.dataModel.getData(CMD.OP_v_VER_INFO)[0][0] as String).slice(4);
			} catch(error:Error) {	}
			deviceLabel = v;
			
			bCancelUpdate.visible = false;
		}
		override protected function onLoadComlete(b:ByteArray, fr:FileReference):void
		{
			super.onLoadComlete(b,fr);
			
			fe.put( firmware );
		}
		override protected function writeToDevice():void
		{
			//GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			CLIENT.IS_WRITING_FIRMWARE = true;
			
			bWriteUpdateToDevice.disabled = true;
			bLoalUpdateFromFile.disabled = true;
			bCancelUpdate.visible = true;
			bCancelUpdate.disabled = true;
			
			pBar.setProgress( 0, 100 );
			label = loc("service_prepairing")+"...";
			pBar.visible = true
			
			heightChanged();
			
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
			fe.write();
		}
		override public function block(b:Boolean):void
		{
			if (b) {
				bLoalUpdateFromFile.disabled = true;
				bWriteUpdateToDevice.disabled = true;
				pBar.visible = false;
				tFileName.visible = false;
				tFileName.text = "";
				heightChanged();				
			} else {
				if (!CLIENT.IS_WRITING_FIRMWARE) { 
					bLoalUpdateFromFile.disabled = false;
					bWriteUpdateToDevice.disabled = firmware==null;
					tFileName.visible = true;
				}
			}
		}
		private function onFwProgress(e:Event):void
		{
			if( bCancelUpdate.disabled )
				bCancelUpdate.disabled = false;
			pBar.setProgress( fe.percload, 100);
			if( CLIENT.IS_WRITING_FIRMWARE )
				label = loc("fw_loaded")+fe.percload+"%";
		}
		private function onError(e:Event):void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
			bLoalUpdateFromFile.disabled = false;
			bWriteUpdateToDevice.disabled = false;
			tFileName.visible = true;
			bCancelUpdate.visible = false;
			this.dispatchEvent( new Event( GUIEvents.EVOKE_CHANGE_HEIGHT));
			label = loc("service_error_happened");
		}
		private function onComplete(e:Event):void
		{
			bCancelUpdate.disabled = true;
			bCancelUpdate.visible = false;
			heightChanged();
		}
	}
}
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import components.abstract.functions.dtrace;
import components.abstract.servants.TaskManager;
import components.events.GUIEvents;
import components.interfaces.IFirmwareEngine;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.protocol.SocketProcessor;
import components.protocol.statics.CLIENT;
import components.static.CMD;
import components.system.UTIL;

class FirmwareEngine extends EventDispatcher implements IFirmwareEngine
{
	private var fw:Vector.<String>;
	private var progressTotal:int;
	private var progress:int;
	private var finalcrc:String;
	
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
		
		var crcs:Array = [];
		var crc:String = "";
		
		fw = new Vector.<String>( len/4 );
		for (var i:int=0; i<len; i++) {
			if (!fw[index])
				fw[index] = "";
			fw[index] += String(a[i]).slice(8);
			cycle++;
			if (cycle > 4) {
				cycle = 1;
				
				crc = calcXorCrc(fw[index]);
				crcs.push( int("0x"+crc ) );
				
				fw[index] += ":"+crc;
				index++;
			}
		}
		
		var ee:Array = [0,0,0,0];
		cycle = 0;	// 0-1
		index = 0;	// 0-3
		len = crcs.length;
		for (i=0; i<len; i++) {
			ee[index] ^= crcs[i];
			cycle++;
			if (cycle == 2) {
				cycle = 0;
				index++;
				if (index > 3)
					index = 0;
			}
		}
		
		finalcrc = UTIL.fz( int(ee[0]).toString(16),2) + UTIL.fz( int(ee[1]).toString(16),2) + UTIL.fz( int(ee[2]).toString(16),2)+ UTIL.fz( int(ee[3]).toString(16),2);
		// после запуска +BL и +BE прибор отвечает только на команды +v и +W[hex4digit]:[128bytes:2bytescrc]
		// концом прошивки считается записанна структура 0000, соответвенно она должна быть послана последней
		// в строке прошивки берется 32 байта с 10 байта
	}
	public function write():void
	{
		//	CLIENT.IS_WRITING_FIRMWARE = true;
	//	this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
		progressTotal = 0;
		progress = 0;
		
		RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_BE_BOOTLOADER_ENGAGE, continueFirmware, 0, null, Request.URGENT, Request.PARAM_SAVE  ));
		CLIENT.TIMER_IDLE_INCOMPLETE = 10000;
	}
	
	private function continueFirmware(p:Package):void
	{
		CLIENT.TIMER_IDLE_INCOMPLETE = 4000;
		var len:int = fw.length;
		fwarray = {};
		fwreask = {};
		for (var i:int=0; i<len; i++) {
			fwarray[ UTIL.fz( (i*4).toString(16),4) ] = (fw[i] as String).slice(129);
			fwreask[ UTIL.fz( (i*4).toString(16),4) ] = [i*4, fw[i]];
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_W_WRITE, writeToDeviceProgress, i*4, [fw[i]], Request.URGENT, Request.PARAM_SAVE ));
		}
		progressTotal += len - 1;
		RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_EE_FW_WRITE, finishWritingFirmware, 0, [finalcrc.toUpperCase()], Request.URGENT, Request.PARAM_SAVE ));
	}
	public function get percload():int
	{
		return int((progress*100) / progressTotal);
	}
	public function set sendAddress(adr:int):void
	{
		// в текстовом протоколе не требуется адрес 
	}
	
	private var fwreask:Object;
	private var fwarray:Object;
	private var lastcrc:String;
	private var lastrequest:String;
	private var lastnum:String;
	private function writeToDeviceProgress(p:Package):void
	{
		var fromdevice:String = p.data[0];
		var num:String = fromdevice.slice(0,4).toLowerCase();
		var crcdevice:String = fromdevice.slice(5,7);
		
		if (!fwarray[num]) {
			num = UTIL.fz(int(int("0x"+lastnum)+4).toString(16),4);
			num = num.toLowerCase();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_W_WRITE, writeToDeviceProgress, fwreask[num][0], [fwreask[num][1]], Request.EXTREME, Request.PARAM_SAVE ));
			return;
		}
/*	для эмуляции перепрошивки		
if (num=="0008") {
	CLIENT.IS_WRITING_FIRMWARE = false;
	RequestAssembler.getInstance().clearStackLater();
	onComplete();
	return;
}*/		
		if ( fwarray[num] != crcdevice ) {
			dtrace( fromdevice );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_W_WRITE, writeToDeviceProgress, fwreask[num][0], [fwreask[num][1]], Request.EXTREME, Request.PARAM_SAVE ));
		} else {
			lastnum = num;
			progress++;
			this.dispatchEvent( new Event( Event.CHANGE ));
		}
	}
	private function finishWritingFirmware(p:Package):void
	{
		CLIENT.IS_WRITING_FIRMWARE = false;
		if (p.error) {
			this.dispatchEvent( new Event(GUIEvents.EVOKE_ERROR) );
		} else
			TaskManager.callLater( onComplete, TaskManager.DELAY_30SEC );
	}
	private function onComplete():void
	{
		this.dispatchEvent( new Event( GUIEvents.EVOKE_READY));
		SocketProcessor.getInstance().disconnect();
	}
	private function calcXorCrc(value:String):String
	{
		var len:int = value.length, crc:int, target:int;
		
		for (var i:int=0; i<len; i+=2) {
			target = int("0x"+value.slice(i,i+2)); 
			crc ^= target;
		}
		return UTIL.fz( crc.toString(16), 2 ).toUpperCase();
	}
}