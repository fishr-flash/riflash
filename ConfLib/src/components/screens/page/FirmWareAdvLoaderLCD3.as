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
	import components.gui.Balloon;
	import components.gui.FileBrowser;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IFocusable;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.MISC;

	public class FirmWareAdvLoaderLCD3 extends UIComponent implements IServiceFrame
	{
		protected var CMD_PART:int = CMD.BOOT_SER;
		protected var CMD_WRITE:int = CMD.BOOT_WRITE;
		protected var CMD_CRC:int = CMD.BOOT_CRC32;
		
		protected const LABEL_LOAD_FROM_FILE:int=1;
		protected const LABEL_DO_UPDATE:int=2;
		protected const LABEL_UPDATE_COMPLETE:int=3;
		protected const LABEL_UPLOAD_ERROR:int=4;
		protected const LABEL_CANCEL_UPLOAD:int=5;
		
		private const FAIL_TIMEOUT:int = 100;
		private const ENDWRITE_TIMER:int = 100;
		
		public var ADDRESS:int = SERVER.ADDRESS_TOP;
		private var TOP_SHIFT:int = 20;
		
		private var bLoalUpdateFromFile:TextButton;
		private var bWriteUpdateToDevice:TextButton;
		private var bCancelUpdate:TextButton;
		private var tFileName:SimpleTextField;
		private var pBar:ProgressBar;
		private var tDeviceName:FSSimple;
		private var tObject:FSSimple;
		private var tObjectEgts:FSSimple;
/**		private var tMasterCode:FSSimple;		RELEASE 28+ */
		private var sep:Separator;
		
		private var endWriteTimer:Timer;
		private var failResponseTimer:Timer;
		private var reconnectTimer:Timer;
		
		protected var firmware:ByteArray;
		private var progressTotal:int;
		private var progress:int;
		private var errorHappens:Boolean = false;
		private var globalY:int;
		
		private var bot:HeightBot;
		protected var group:GroupOperator;	// не используется в родителе, зато испольузется в детях

		protected var structCounter:int = 0;
		
		public function FirmWareAdvLoaderLCD3(lbl:String="")
		{
			var l:String = lbl == "" ? loc("sys_device_ver") : lbl;
			createTitle(l);
			
			createVoyagerPart();
			
			
			
			createSep();
			
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
			if ( DS.isVoyager() )
				return [CMD.CONNECT_SERVER];
/** RELEASE 28+				return [CMD.CONNECT_SERVER, CMD.VR_MASTER_KEY];	*/
			return null;
		}
		public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.CONNECT_SERVER:
					tObject.setCellInfo( p.getStructure()[0] );
					if (tObjectEgts){
						
						
							if(   !DS.isfam( DS.F_V ) || ( DS.isfam( DS.F_V ) && DS.release > 54 )   ){
								
								
								if( Number( p.getStructure(4)[0] ) == 65535 && Number( p.getStructure(3)[0] ) == 65535 ){
									tObjectEgts.setCellInfo( 4294967295 );
								}
								else
								{
									tObjectEgts.setCellInfo( ( Number( p.getStructure(4)[0] ) << 16 ) + p.getStructure(3)[0] );
								}
								
							}
							else{
								tObjectEgts.setCellInfo( p.getStructure(3)[0] );
								tObjectEgts.setCellInfo( p.getStructure(4)[0] );
							}
							
						
					}
						
					break;
/** RELEASE 28+				
				case CMD.VR_MASTER_KEY:
					tMasterCode.setCellInfo( p.getStructure()[0] );
					break;
					 * */
			}
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
			bLoalUpdateFromFile.disabled = CLIENT.IS_WRITING_FIRMWARE;
			deviceLabel = SERVER.VER_FULL + " "+DS.getCommit();
		}
		public function reset():void
		{
			tFileName.text = "";
			pBar.visible = false;
			heightChanged();
			
			CLIENT.IS_WRITING_FIRMWARE = false;
			bWriteUpdateToDevice.disabled = true;
			bLoalUpdateFromFile.disabled = false;
		}
		public function resetAndDisable():void
		{
			tFileName.text = "";
			pBar.visible = false;
			heightChanged();
			
			firmware = null;
			
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
			removeChild( sep );
		}
		override public function get height():Number
		{
			var h:int = bot.calculate(TOP_SHIFT);
			sep.y = h-10;
			return h + 10;
		}
		private function heightChanged():void
		{
			sep.visible = !MISC.VERSION_MISMATCH;
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
		private function onLoadFileClick():void
		{
			FileBrowser.getInstance().open( onLoadComlete, getFileTypes() );
		}
		protected function onLoadComlete(b:ByteArray, fr:FileReference):void
		{
			
			firmware = FirmwareChecker.check(b,getVer());
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
		protected function writeToDevice( countStrc:int = 1 ):void
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
				//crc32 = CRC32.calculate( aFullFirmWare, aFullFirmWare.length );
				
				//RequestAssembler.getInstance().fireEvent( new Request( CMD_CRC, firmwareSent, 1, [crc32, firmware.length], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				/////TODO: Это то что отличает его от базового класса
				//RequestAssembler.getInstance().fireEvent( new Request( CMD_WRITE, firmwareSent, 1, [ 0x31 ], Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				
				progressTotal = Math.ceil(aFullFirmWare.length/128);
				
				
				pBar.setProgress( 0, progressTotal );
				label = loc("fw_loaded")+"0%";
				pBar.visible = true;
				
				GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
				heightChanged();
				
				
				
			}
		}
		private function writeToDeviceProgress( p:Package):void
		{
			if (CLIENT.IS_WRITING_FIRMWARE) {
				if ( p.success ) {
					progress++;
					pBar.setProgress( progress, progressTotal );
					label = loc("fw_loaded") +int((progress*100) / progressTotal) + "%";
					if( progress == progressTotal ) firmwareSent( null );
					
				} else { 
					errorHappens = true;
					cancelWrite();
					label = loc("ui_service_load_fail_happened");
				}
			}
		}
		private function monitorOnlineStatus( ev:SystemEvents ):void 
		{
			switch( ev.isConneted() ) {
				case true:
					label = loc("fw_loaded") +Math.round((progress*100) / progressTotal) + "%";
					break;
				case false:
					label = loc("fw_restore_conn")+" ("+loc("fw_loaded")+Math.round((progress*100) / progressTotal) + "%)";
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
			//RequestAssembler.getInstance().fireEvent( new Request( CMD_WRITE, testFailWrite, 1, null, Request.URGENT, 0, ADDRESS ));
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
				Balloon.access().show(loc("sys_error"), loc("fw_loaded_wrong") ); 
				//finishWritingFirmware();
				cancelWrite();
				label = loc("fw_loaded_wrong");
			}
			failResponseTimer.stop();
		}
		private function writeToDeviceComplete():void 
		{
			
			PopUp.getInstance().composeOfflineMessage(PopUp.wrapHeader(loc("sys_attention")), 
				PopUp.wrapMessage(loc("fw_device_updating") +" "
					+ DS.getDeviceFirmwareTime() + loc("fw_not_disable_power") ));
			
			finishWritingFirmware();
		}
		
		protected function finishWritingFirmware():void
		{
			//firmwareSent( null );
			
			tFileName.text = "";
			pBar.visible = false;
			heightChanged();
			
			CLIENT.IS_WRITING_FIRMWARE = false;
			GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			bWriteUpdateToDevice.disabled = true;
			bLoalUpdateFromFile.disabled = false;
		}
		
		private function set label(s:String):void
		{
			pBar.label = s;
		}
		private function onVoyagerObjectChange(e:GUIEvents):void
		{
			tObject.setCellInfo( OPERATOR.dataModel.getData(CMD.CONNECT_SERVER)[0][0] );
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable)
				TabOperator.getInst().add(child as IFocusable);
			return super.addChild(child);
		}
/** BUILD UI			***/		
		protected function createSep():void
		{
			var sep:Separator = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = globalY;
			globalY += 20;
		}
		protected function createTitle(label:String):void
		{
			tDeviceName = new FSSimple;
			addChild( tDeviceName );
			globalY += 30;
			tDeviceName.setName(label+":");
			tDeviceName.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			tDeviceName.setTextColor( COLOR.GREEN );
			tDeviceName.setWidth( 170 );
			tDeviceName.setCellWidth( 400 );
		}
		protected function createVoyagerPart():void
		{
			if ( DS.isVoyager() ) {
				tObject = new FSSimple;
				addChild( tObject );
				tObject.y = globalY-5;
				globalY += 30;
				tObject.setName(loc("service_object_ritm")+":");
				tObject.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
				tObject.setTextColor( COLOR.GREEN );
				tObject.setWidth( 170 );
				GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onVoyagerObjectChange, onVoyagerObjectChange );
				TOP_SHIFT += 30;
				
				if ( OPERATOR.getSchema(CMD.CONNECT_SERVER).StructCount > 2) {
					tObjectEgts = new FSSimple;
					addChild( tObjectEgts );
					tObjectEgts.y = globalY-10;
					globalY += 20;
					tObjectEgts.setName(loc("service_object_egts")+":");
					tObjectEgts.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					tObjectEgts.setTextColor( COLOR.GREEN );
					tObjectEgts.setWidth( 170 );
					
					TOP_SHIFT += 20;
				}
				
/** RELEASE 28+				
				tMasterCode = new FSSimple;
				addChild( tMasterCode );
				tMasterCode.y = globalY-5;
				globalY += 25;
				tMasterCode.setUp( onMasterCode );
				tMasterCode.setName("Мастер Код:");
				tMasterCode.setWidth( 150 );
				tMasterCode.restrict("0-9", 4);
				tMasterCode.rule = new RegExp(/\d{4}/g)
				tMasterCode.param = 1;
				tMasterCode.cmd = CMD.VR_MASTER_KEY;
				SavePerformer.add( CMD.VR_MASTER_KEY, 1, tMasterCode );
				TOP_SHIFT += 25;
				 * */
			}
		}
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
					return loc("service_fw_load_incorrect");
				case LABEL_CANCEL_UPLOAD:
					return loc("service_cancel_load_update");
			}
			return "-";
		}
		protected function getFileTypes():Array
		{
			return MISC.FILE_TYPES;
		}
/** RELEASE 28+
		private function onMasterCode():void
		{
			SavePerformer.remember( 1, tMasterCode );
		}
		*/
		public function close():void {		}
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
		return height + h;
	}
}