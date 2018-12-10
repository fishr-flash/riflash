package components.screens.ui
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.ProgressBar;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.DS;
	import components.static.NAVI;
	
	public class UIUpdateLight extends UI_BaseComponent
	{
		private var bUpdate:TextButton;
		private var fb:FirmwareBot;
		private var fwservant:FWServant;
		private var fmessage:FSSimple;
		private var fnote:SimpleTextField;
		private var rtmpath:String;
		private var pbar:ProgressBar;
		
		public function UIUpdateLight()
		{
			super();
			
			fnote = new SimpleTextField(loc("fw_too_old"));
			addChild( fnote );
			fnote.x = globalX;
			fnote.y = globalY;
			globalY += 50;
			
			bUpdate = new TextButton;
			addChild( bUpdate );
			bUpdate.y = globalY;
			bUpdate.x = 400;
			bUpdate.setUp(loc("g_update"), startUpdate );
			
			fmessage = addui( new FSSimple, 0, "", null, 1 ) as FSSimple;
			attuneElement(240, 100, FSSimple.F_CELL_NOTSELECTABLE );
			
			pbar = new ProgressBar;
			addChild( pbar );
			pbar.y = globalY;
			pbar.x = globalX;
			pbar.width = 200;
			pbar.height = 40;
			pbar.label= "";
			pbar.mode = "manual";
			pbar.maximum = 100;
			pbar.minimum = 0;
		}
		override public function open():void
		{
			super.open();

			pbar.visible = false;
			
			bUpdate.disabled = true;
			
			fmessage.setName( loc("fw_selected_update")+": " );
			fmessage.setCellInfo("");
			
			RequestAssembler.getInstance().HTTPSetUp( SERVER.UPDATE_SERVER_ADR+":"+SERVER.UPDATE_SERVER_PORT+"/","","");
			RequestAssembler.getInstance().HTTPErrorListener( onHTTPError );
			RequestAssembler.getInstance().HTTPRequest( "/device.json", onGetJson );
		}
		private function onHTTPError(e:Event):void
		{
			trace("error " + e.type );
			
			fmessage.setName( loc("fw_update_server_inaccessible") );
			fmessage.setCellInfo("");
			
			loadComplete();
		}
		private function onGetJson(b:ByteArray):void
		{
			var s:String = b.readUTFBytes(b.bytesAvailable);
			var d:Object = JSON.parse(s);
			fb = new FirmwareBot;
			
			var isupdate:Boolean = fb.isUpdate(d);
			
			if (isupdate) {
				var a:Array = fb.getTableList();
				if (a && a.length > 0) {
					rtmpath = a[a.length - 1][2];
					fmessage.setCellInfo(a[a.length - 1][1]);
				}
				bUpdate.disabled = !(rtmpath && rtmpath.length > 0)
			}
			loadComplete();
		}
		private function startUpdate():void
		{
			blockNavi = true;
			bUpdate.disabled = true;
			RequestAssembler.getInstance().HTTPRequest( rtmpath, onRtm );
		}
		private function onRtm(b:ByteArray):void
		{
			if (!fwservant) {
				fwservant = new FWServant;
				fwservant.addEventListener( GUIEvents.EVOKE_BLOCK, onFwStart );
				fwservant.addEventListener( Event.CHANGE, onFwProgress );
			}
			fwservant.put(b);
			fwservant.write();
		}
		private function onFwStart(e:Event):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			pbar.setProgress( 0, 100 );
			pbar.visible = true;
			pbar.label= loc("fw_load_to_device");
			//firmwareInProgress = true;
			CLIENT.AUTOPAGE_WHILE_WRITING = NAVI.UPDATE;
		}
		private function onFwProgress(e:Event):void
		{
			if (fwservant.percload == 100) {
				pbar.label= loc("fw_firmware_loaded");
				PopUp.getInstance().composeOfflineMessage(PopUp.wrapHeader("sys_attention"), 
					PopUp.wrapMessage(loc("fw_device_updating")	+" "+ DS.getDeviceFirmwareTime() + loc("fw_not_disable_power") ));
			} else
				pbar.label= loc("fw_load_to_device")+", "+loc("fw_left")+" "+(100-fwservant.percload)+"%";
			pbar.setProgress( fwservant.percload, 100 );
		}
	}
}
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;

import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.protocol.SocketProcessor;
import components.protocol.statics.CLIENT;
import components.protocol.statics.CRC32;
import components.protocol.statics.SERVER;
import components.static.CMD;
import components.static.DS;

class FirmwareBot 
{
	private var device:Object;
	private var patch:Array;
	
	public function isUpdate(a:Object):Boolean
	{
		device = getDevice(a as Array);
		
		var keyword:String = DS.getFullVersion()+"."+DS.getBootloader();
		
		if (!device || !device.Firmware)
			return false;
		
		var len:int = device.Firmware.length;
		patch = [];
		
		for (var i:int=0; i<len; i++) {
			if( isPartOf( device.Firmware[i].VersionOld, keyword ) )
				patch.push( {desc:device.Firmware[i].Description, rtm:device.Firmware[i].Rtm, ver:device.Firmware[i].Version } );
		}
		return patch.length > 0;
	}
	public function getTableList():Array
	{
		var a:Array;
		var len:int = patch.length;
		for (var i:int=0; i<len; i++) {
			if (!a)
				a = [];
			a.push( [String(patch[i].desc), getVersionByApp(patch[i].ver), patch[i].rtm] );
		}
		return a;
	}
	private function getVersionByApp(a:Array):String
	{
		
		var currentapp:String = DS.app;
		
		var len:int = a.length;
		var v:Array;
		for (var i:int=0; i<len; i++) {
			v = String(a[i]).split(".");
			if (v && v[1] && currentapp == v[1] )
				return a[i];
		}
		
		
		return "$error.getting.app";
	}
	public function getDevice(a:Array):Object
	{
		var keyname:String = DS.deviceAlias;
		var len:int = a.length;
		for (var i:int=0; i<len; i++) {
			if( a[i].ShortName == keyname )
				return a[i];
		}
		return null;
	}
	private function getfw():Array
	{
		return null;
	}
	private function isPartOf(a:Array, s:String):Boolean
	{
		if (a) {
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if( a[i] == s )
					return true;
			}
		}
		return false;
	}
}
class FWServant extends EventDispatcher
{
	public static const EVOKE_BLOCK:String = "EVOKE_BLOCK";
	
	private const ENDWRITE_TIMER:int = 3000;
	private const FAIL_TIMEOUT:int = 1000;
	
	private var ADDRESS:int = SERVER.ADDRESS_TOP;
	private var CMD_PART:int = CMD.BOOT_SER;
	private var CMD_WRITE:int = CMD.BOOT_WRITE;
	private var CMD_CRC:int = CMD.BOOT_CRC32;
	
	private var progressTotal:int;
	private var progress:int;
	private var errorHappens:Boolean = false;
	
	private var endWriteTimer:Timer;
	private var failResponseTimer:Timer;
	private var reconnectTimer:Timer;
	
	private var firmware:ByteArray;
	
	public function put(b:ByteArray):void
	{
		firmware = b;
	}
	
	public function write():void
	{
		if (!firmware)
			return;
		
		this.dispatchEvent( new Event( EVOKE_BLOCK));
		
		CLIENT.IS_WRITING_FIRMWARE = true;
		
		errorHappens = false;
		
		progress = 0;
		var crc32:int = 0;
		if ( firmware ) {
			// TODO Сделать более акуратный перебор				
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
	//	this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
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
	//	this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
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
}