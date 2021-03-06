package components.screens.page
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.FirmwareChecker;
	import components.abstract.servants.TabOperator;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.FileBrowser;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IFocusable;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.CRC32;
	import components.protocol.statics.SERVER;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.MISC;

	public class FirmWareSimpleLoader extends UIComponent implements IServiceFrame
	{
		protected var CMD_PART:int = CMD.BOOT_SER;
		protected var CMD_WRITE:int = CMD.BOOT_WRITE;
		protected var CMD_CRC:int = CMD.BOOT_CRC32;
		
		protected const LABEL_LOAD_FROM_FILE:int=1;
		protected const LABEL_DO_UPDATE:int=2;
		protected const LABEL_UPDATE_COMPLETE:int=3;
		protected const LABEL_UPLOAD_ERROR:int=4;
		protected const LABEL_CANCEL_UPLOAD:int=5;
		
		private const FAIL_TIMEOUT:int = 1000;
		private const ENDWRITE_TIMER:int = 3000;
		
		public var ADDRESS:int = SERVER.ADDRESS_TOP;
		private var TOP_SHIFT:int = 25;
		
		protected var bLoalUpdateFromFile:TextButton;
		protected var bWriteUpdateToDevice:TextButton;
		protected var bCancelUpdate:TextButton;
		protected var tFileName:SimpleTextField;
		protected var pBar:ProgressBar;
		private var tDeviceName:FSSimple;
		private var tObject:FSSimple;
		private var sep:Separator;
		
		private var endWriteTimer:Timer;
		private var failResponseTimer:Timer;
		private var reconnectTimer:Timer;
		
		protected var firmware:ByteArray;
		protected var progressTotal:int;
		protected var progress:int;
		protected var errorHappens:Boolean = false;
		private var globalY:int;
		
		private var bot:HeightBot;
		protected var group:GroupOperator;	// не используется в родителе, зато испольузется в детях
		
		public function FirmWareSimpleLoader()
		{
			
			createTitle(loc("sys_device_ver"));
			deviceLabel  = SERVER.VER_FULL + " "+DS.getCommit();
			
			bLoalUpdateFromFile = new TextButton;
			createButton( bLoalUpdateFromFile );
			bLoalUpdateFromFile.setUp( getLabel(LABEL_LOAD_FROM_FILE),onLoadFileClick );
			
			group = new GroupOperator;
			group.add("1",bLoalUpdateFromFile);
			bWriteUpdateToDevice = new TextButton;
			createButton( bWriteUpdateToDevice );
			bWriteUpdateToDevice.setUp( getLabel(LABEL_DO_UPDATE),writeToDevice );
			bWriteUpdateToDevice.disabled = true;
			group.add("1",bWriteUpdateToDevice);
			
			tFileName = new SimpleTextField("", 500);
			addChild( tFileName );
			tFileName.x = bWriteUpdateToDevice.width + 10;
			tFileName.y = bWriteUpdateToDevice.y;
			group.add("1",tFileName);
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.y = bWriteUpdateToDevice.y+25;
			pBar.x = 1;
			pBar.width = 100;
			pBar.height = 10;
			label= "";
			pBar.visible = false;
			pBar.mode = "manual";
			pBar.maximum = 100;
			pBar.minimum = 0;
			group.add("1",pBar);
			
			bCancelUpdate = new TextButton;
			createButton( bCancelUpdate );
			bCancelUpdate.setUp( getLabel(LABEL_CANCEL_UPLOAD),cancelWrite );
			bCancelUpdate.y = pBar.y + 40;
			bCancelUpdate.visible = false;
			group.add("1",bCancelUpdate);
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			group.add("1",sep);
			
			bot = new HeightBot([pBar,bCancelUpdate]);
			
			//this.height = bCancelUpdate.y + bCancelUpdate.getHeight()+80;
		}
		public function getLoadSequence():Array
		{
			return null;
		}
		public function block(b:Boolean):void
		{
			if (b) {
				bLoalUpdateFromFile.disabled = true;
				bWriteUpdateToDevice.disabled = true;
				pBar.visible = false;
				tFileName.visible = false;
				tFileName.text = "";
				heightChanged();				
			} else {
				bLoalUpdateFromFile.disabled = false;
				bWriteUpdateToDevice.disabled = firmware==null;
				tFileName.visible = true;
			}
		}
		public function init():void
		{
			if (!CLIENT.IS_WRITING_FIRMWARE)
				resetAndDisable();
			bLoalUpdateFromFile.disabled = false;
			deviceLabel = SERVER.VER_FULL;
		}
		public function resetAndDisable():void
		{
			tFileName.text = "";
			pBar.visible = false;
			heightChanged();
			
			CLIENT.IS_WRITING_FIRMWARE = false;
			bWriteUpdateToDevice.disabled = true;
			bLoalUpdateFromFile.disabled = true;
		}
		public function set deviceLabel(s:String):void
		{
			if (tDeviceName)
				tDeviceName.setCellInfo(s);
		}
		public function isLast():void
		{
			sep.visible = false;
		}
		override public function get height():Number
		{
			var h:int = bot.calculate(TOP_SHIFT);
			sep.y = h-10;
			return h + 10;
		}
		protected function heightChanged():void
		{
			this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
		}
		private function createButton( _but:TextButton ):void 
		{
			addChild( _but );
			_but.y = globalY;
			_but.setFormat( true, 12 );
			globalY += _but.getHeight() + 10;
		}
		protected function cancelWrite():void
		{
			CLIENT.IS_WRITING_FIRMWARE = false;
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			label = loc("fw_load_cancel");
			bWriteUpdateToDevice.disabled = false;
			bLoalUpdateFromFile.disabled = false;
			bCancelUpdate.visible = false;
			RequestAssembler.getInstance().clearStackLater();
			heightChanged();
			this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
		}
		protected function createTitle(label:String):void
		{
			tDeviceName = new FSSimple;
			addChild( tDeviceName );
			globalY += 30;
			tDeviceName.setName(label+":");
			tDeviceName.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			tDeviceName.setTextColor( COLOR.GREEN );
			tDeviceName.setWidth( 150 );
			tDeviceName.setCellWidth( 400 );
		}
		private function onLoadFileClick():void
		{
			FileBrowser.getInstance().open( onLoadComlete, getFileTypes() );
		}
		protected function onLoadComlete(b:ByteArray, fr:FileReference):void
		{
			
			firmware = FirmwareChecker.check(b, getVer());
			
			if (firmware) {
				
				bWriteUpdateToDevice.disabled = false;
				var len:int = fr.name.length;
				tFileName.htmlText = cutString(fr.name, len);//"Прошивка <b>"+fr.name+"</b> готова к загрузке";
				while (tFileName.numLines > 1) {
					len -= 5;
					tFileName.htmlText = cutString(fr.name, len);
				}
			} else 
				tFileName.htmlText = loc("fw_wrong_file");
			
			function cutString(s:String, l:int):String
			{
				if (s.length > l)
					return s.slice(0,l-3) + "... .rtm";
				return s;
			}
		}
		private function getVer():String
		{
			if (SERVER.DUAL_DEVICE && ADDRESS != 0xff)
				return SERVER.BOTTOM_VER_INFO[0][1];
			return DS.fullver;
		}
		protected function writeToDevice():void
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
				
				pBar.setProgress( 0, progressTotal );
				label = loc("fw_loaded")+"0%";
				pBar.visible = true;
				
				GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
				heightChanged();
			}
		}
		protected function writeToDeviceProgress( p:Package):void
		{
			if (CLIENT.IS_WRITING_FIRMWARE) {
				if ( p.success ) {
					progress++;
					pBar.setProgress( progress, progressTotal );
					label = loc("fw_loaded")+" " +int((progress*100) / progressTotal) + "%";
				} else {
					errorHappens = true;
					cancelWrite();
					label = loc("ui_service_load_fail_happened");
				}
			}
		}
		protected function monitorOnlineStatus( ev:SystemEvents ):void 
		{
			switch( ev.isConneted() ) {
				case true:
					label = loc("fw_loaded")+" " +Math.round((progress*100) / progressTotal) + "%";
					break;
				case false:
					label = loc("fw_restore_conn")+" ("+loc("fw_loaded")+" " +Math.round((progress*100) / progressTotal) + "%)";
					break;
			}
		}
		protected function firmwareSent(p:Package):void
		{
			label = getLabel(LABEL_UPDATE_COMPLETE);
			bCancelUpdate.visible = false;
			heightChanged();
			
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
			else {
				label = getLabel(LABEL_UPLOAD_ERROR);
				finishWritingFirmware();
			}
			failResponseTimer.stop();
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
		private function finishWritingFirmware():void
		{
			tFileName.text = "";
			firmware = null;
			pBar.visible = false;
			heightChanged();
			
			CLIENT.IS_WRITING_FIRMWARE = false;
			GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			bWriteUpdateToDevice.disabled = true;
			bLoalUpdateFromFile.disabled = false;
		}
		
		protected function set label(s:String):void
		{
			pBar.label = s;
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable)
				TabOperator.getInst().add(child as IFocusable);
			return super.addChild(child);
		}
/** BUILD UI			***/		
		protected function getLabel(key:int):String
		{
			switch(key) {
				case LABEL_LOAD_FROM_FILE:
					return loc("service_load_update_from_file");
				case LABEL_DO_UPDATE:
					return loc("service_update_device_ver");
				case LABEL_UPDATE_COMPLETE:
					return loc("service_load_complete_device_restart");
				case LABEL_DO_UPDATE:
					return loc("service_fw_load_incorrect")
				case LABEL_CANCEL_UPLOAD:
					return loc("service_cancel_load_update");
			}
			return "-"
		}
		protected function getFileTypes():Array
		{
			return MISC.FILE_TYPES;
		}
		
		public function close():void {	}
		
		public function put(p:Package):void	{	}
		
	}
}
import flash.display.DisplayObject;

import mx.controls.ProgressBar;

class HeightBot
{
	private var objects:Vector.<DisplayObject>;
	private var height:int=100;
	
	public function HeightBot(a:Array)
	{
		objects = new Vector.<DisplayObject>;
		var len:int = a.length;
		for (var i:int=0; i<len; ++i) {
			objects.push( a[i] );
		}
		
	}
	public function calculate(top:int):int
	{
		var h:int=top;
		var len:int = objects.length;
		for (var i:int=0; i<len; ++i) {
			if ( objects[i].visible )
				if (objects[i] is ProgressBar)
					h += 50;
				else
					h += 25;
		}
		return height + h - 25;
	}
}