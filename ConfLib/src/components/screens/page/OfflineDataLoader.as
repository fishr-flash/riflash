package components.screens.page
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.offline.OfflineTaskManager;
	import components.abstract.servants.LcdIsoServant;
	import components.abstract.servants.TabOperator;
	import components.abstract.sysservants.StructureManager;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.FileBrowser;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSListCheckBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FSSimpleConnectServerEGTS;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ProgressBarExt;
	import components.gui.visual.Separator;
	import components.interfaces.ICommandOperator;
	import components.interfaces.IDataEngine;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.models.FSCBListAssembler;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.protocol.statics.SHA256;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	
	import functions.replaceCommand_906;
	
	public class OfflineDataLoader extends UIComponent implements IServiceFrame
	{
		private var TOP_SHIFT:int;
		
		public static const LOADER_EVOKE_HIDE:String = "LOADER_EVOKE_HIDE";
		public static const LOADER_EVOKE_SHOW:String = "LOADER_EVOKE_SHOW";
		
		public static var CODE_OBJECT:int;
		public static var CODE_OBJECT_EGTS:int;

		private const LIST_HEIGHT:int = 300;
		private const LIST_WIDTH:int = 320;
		
		protected var go:GroupOperator;
		protected var manager:OfflineTaskManager;
		
		private var bSave:TextButton;
		private var bLoad:TextButton;
		private var bInterrupt:TextButton;
		private var pBar:ProgressBar;		
		private var bAction:TextButton;
		private var bCancel:TextButton;
		private var pLoader:ProgressBarExt;
		private var tObject:FSSimple;
		private var tObjectEgts:FSSimple;
		private var tFileName:SimpleTextField;
		
		private var pageList:FSListCheckBox;
		private var bot:Bot;
		private var progressLabel:String;
		private var sep:Separator;
		private var lastsep:Separator;
		private var sepAboveAction:Separator;
		private var activeErrorHandler:ActiveErrorHandler;
		
		public function OfflineDataLoader(ibot:ICommandOperator, ieng:IDataEngine)
		{
			super();
			
			bot = new Bot;
			
			if (DS.isVoyager()) {
				tObject = new FSSimple;
				addChild( tObject );
				tObject.setName(loc("service_object_ritm")+":");
				tObject.restrict( "0-9", 5 );
				tObject.rule = new RegExp( RegExpCollection.REF_0to65535);
				tObject.setWidth( 200 );
				tObject.setCellWidth( 60 );
				tObject.setUp( onObject );
				
				TOP_SHIFT = 70;
				
				if ( OPERATOR.getSchema(CMD.CONNECT_SERVER).StructCount > 2) {
					tObjectEgts = new FSSimpleConnectServerEGTS;
					addChild( tObjectEgts );
					tObjectEgts.setName(loc("service_object_egts")+":");
					tObjectEgts.restrict( "0-9", 10 );
					tObjectEgts.setWidth( 160 );
					tObjectEgts.setCellWidth( 100 );
					tObjectEgts.setUp( onObjectEgts );
					
					TOP_SHIFT += 30;
				}
				
				sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
				addChild( sep );
				sep.x = -20;
				sep.y = 25;
			}
			
			
			bLoad = new TextButton;
			addChild( bLoad );
			
			bLoad.setUp(loc("ui_service_load_cfg_from_file"), onCall, bot.LOAD );
			
			if( DS.isfam( DS.V2 ) && ( DS.release == 56 || DS.release == 55 ) )
			{
				bLoad.alpha = 0;
				bLoad.mouseChildren = bLoad.mouseEnabled = false;
			}
				
			bSave = new TextButton;
			addChild( bSave );
			bSave.setUp(loc("ui_service_save_cfg_to_file"), onCall, bot.SAVE );
			bSave.y = bLoad.getHeight()-4;
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.y = bSave.y + bSave.getHeight() + 10;
			pBar.x = 1;
			pBar.width = 100;
			pBar.height = 10;
			pBar.label = "";
		//	pBar.visible = false;
			pBar.mode = "manual";
			pBar.maximum = 100;
			pBar.minimum = 0;
			
			pBar.setProgress( 0, 50 );
			pBar.label = loc("fw_loaded")+"0%";
			
			bInterrupt = new TextButton;
			addChild( bInterrupt );
			bInterrupt.setUp(loc("service_interrupt_load_to_device"), onCall, bot.INTERRUPT );
			bInterrupt.y = pBar.y + 40;
			
			bAction = new TextButton;
			addChild( bAction );
			bAction.setUp("action", onCall, bot.ACTION );
		//	bAction.y = bSave.getHeight() + 76 - 20;
			//bAction.x = 30;
			
			bCancel = new TextButton;
			addChild( bCancel );
			bCancel.setUp(loc("g_cancel"), onCall, bot.CANCEL );
			//bCancel.y = bSave.getHeight() + 80;
			bCancel.x = 270;
			
			tFileName = new SimpleTextField("", 500);
			addChild( tFileName );
			
			sepAboveAction = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sepAboveAction );
			sepAboveAction.x = -20;
			
			pageList = new FSListCheckBox;
			addChild( pageList );
			pageList.x = bSave.x + 500;
			pageList.y = bSave.y + 500;
			
			pLoader = new ProgressBarExt;
			addChild( pLoader );
			pLoader.y = 400;
			pLoader.x = 1;
			pLoader.width = 100;
			pLoader.height = 10;
			pLoader.label = "";
			pLoader.mode = "manual";
			pLoader.maximum = 100;
			pLoader.minimum = 0;
			
			this.height = bSave.y + bLoad.getHeight() + 12;
			
			lastsep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( lastsep );
			lastsep.x = -20;
			lastsep.y = 60;		
			
			go = new GroupOperator;
			go.add("1", [bSave, bLoad, lastsep] );
			go.add("2save", [pageList,bAction,bCancel,pLoader,sepAboveAction] );
			go.add("2load", [pageList,bAction,bCancel,pLoader,sepAboveAction,tFileName] );
			go.add("3", [bSave, bLoad, pBar, bInterrupt, lastsep] );
			
			if ( DS.isVoyager() ) {
				if (tObjectEgts)
					go.add("2load", [tObject,tObjectEgts,sep] );
				else
					go.add("2load", [tObject,sep] );
			}
			
			heightChanged("1");
			
			manager = new OfflineTaskManager(ibot, ieng);
			manager.fUpdate = onProgress;
			manager.addEventListener( ProgressEvent.PROGRESS, onLoadProgress );
			
			activeErrorHandler = new ActiveErrorHandler(abort);
		}
		public function setMenu(menu:Array):void
		{
			var a:Array = FSCBListAssembler.getList(menu)
			pageList.setList( a );
			
			
		}
		
		public function close():void
		{
	//		manager.abort();
			heightChanged("1");
			pageList.close();
			this.dispatchEvent( new Event(LOADER_EVOKE_SHOW));
			pageList.removeEventListener(Event.CHANGE, onChange );
		}
		public function block(b:Boolean):void
		{
			if (b)
				heightChanged("1");
			
			bSave.disabled = b;
			bLoad.disabled = b;
		}
		override public function get height():Number
		{
			if (bInterrupt.visible)
				return bInterrupt.y + bInterrupt.getHeight() + 12 + 20;
			return bSave.y + bLoad.getHeight() + 12 + 20;
		}
		private function onCall(n:int):void
		{
			switch(n) {
				case bot.SAVE:
					bAction.setName( bot.getName(n) );
					pageList.setList( FSCBListAssembler.getList(manager.getSaveList()) );
					pageList.open(LIST_WIDTH,LIST_HEIGHT,PAGE.CONTENT_LEFT_SHIFT + PAGE.MAINMENU_WIDTH + 10,PAGE.CONTENT_TOP_SHIFT + 91 );
					if (SocketProcessor.getInstance().connected) {
						pageList.addEventListener(Event.CHANGE, onChange );
						bAction.disabled = true;
						manager.newSession();
					}
					showMenu(true);
					PopUp.getInstance().close();
					
					break;
				case bot.LOAD:
					bAction.setName( bot.getName(n) );
					FileBrowser.getInstance().open( onGotFile, FileBrowser.type( "RITM Config file (*.rcf)", "*.rcf" ));
					break;
				case bot.ACTION:
					var a:Array = pageList.getCellInfo() as Array;
					switch(bot.operation) {
						case bot.LOAD_FILE:
							manager.mergeSelected( a );
							break;
						case bot.LOAD_FILE_TO_DEVICE:
							if (a.length > 0) {
								onProgress(0,1);
								doActionLoadToDeviceArgs = a;
								if ( !manager.needSpecialActions(a, doActionLoadToDevice, doInterrupt) )
									doActionLoadToDevice();
							} else {
								close();									
								return;
							}
							break;
						case bot.SAVE_FILE:
						case bot.SAVE_FILE_FROM_DEVICE:
							FileBrowser.getInstance().save( SHA256.encrypt( manager.saveListToFile( a ) ), manager.getExtension() );
							//FileBrowser.getInstance().save( manager.saveListToFile( a ), manager.getExtension() );	
							break;
					}
				case bot.CANCEL:
					close();
					if (n == bot.ACTION && bot.operation == bot.LOAD_FILE_TO_DEVICE)
						heightChanged("3");
					if(n == bot.CANCEL && bot.operation == bot.SAVE_FILE_FROM_DEVICE) {
						manager.abort();
						RequestAssembler.getInstance().clearStackLater();
					}
					break;
				case bot.INTERRUPT:
					doInterrupt();
					break;
			//	дописать
			}
		}
		private function abort():void
		{
			manager.abort();
			doInterrupt();
		}
		private function doInterrupt():void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE ));
			GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
			PopUp.getInstance().close();
			close();
			block(false);
			manager.interrupt();
			RequestAssembler.getInstance().clearStackLater();
		}
		private var doActionLoadToDeviceArgs:Array;
		private function doActionLoadToDevice():void
		{
			
			RequestAssembler.getInstance().activeHandler( activeErrorHandler );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onChangeOnline);
			manager.uploadSelected( doActionLoadToDeviceArgs, onProgress );
			
			// Сообщает о режиме блокировки
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK ));
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
			block(true);
			heightChanged("3");
		}
		private function onProgress(current:int, total:int):void
		{
			
			trace(current + "\t/\t" +total)
			pBar.setProgress( current, total );
			progressLabel = loc("fw_loaded") +int((current*100) / total) + "%";
			pBar.label = progressLabel;
			if (current == total) {
				heightChanged("1");
				// Сообщает о режиме снятия блокировки
				this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE ));
				GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
				block(false);
				GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, onChangeOnline);
				if (tObject)
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onVoyagerObjectChange );
				if( manager.needRestart() )
					SocketProcessor.getInstance().reConnect();
				
				
			}
		}
		private function onChangeOnline(e:SystemEvents):void
		{
			GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, onChangeOnline);
			if (!e.isConneted()) {
				PopUp.getInstance().composeOfflineMessage( PopUp.wrapHeader("sys_attention"), 
					PopUp.wrapMessage("conf_load_interrupt"));
				PopUp.getInstance().releaseOfflineMsg();
			}
		}
		private function monitorOnlineStatus( ev:SystemEvents ):void 
		{
			switch( ev.isConneted() ) {
				case true:
					pBar.label = progressLabel;
					break;
				case false:
					pBar.label = loc("fw_restore_conn")+" ("+progressLabel+")";
					break;
			}
		}
		private function showMenu(save:Boolean):void
		{
			if (save)
				heightChanged("2save");
			else
				heightChanged("2load");
			pLoader.visible = false;
			var p:Point = globalToLocal( new Point(0, PAGE.HEADER_HEIGHT + LIST_HEIGHT - 20) );
			
			var shift:int = save==true?0:TOP_SHIFT;
			
			bAction.y = p.y + 25 + shift;
			bCancel.y = p.y + 25 + shift;
			pLoader.y = p.y + 50 + 25 + shift;
			sepAboveAction.y = p.y+5+  shift; 
			tFileName.y = p.y + 50 +  shift;
			this.dispatchEvent( new Event(LOADER_EVOKE_HIDE));
			GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
		}
		protected function onGotFile(b:ByteArray, fr:FileReference):void
		{
			SHA256.decrypt(b);
			
			/**
			 *  В результате модификации комнады CMD.VOLTAGE_LIMITS ( 906 ) 
			 * возникла необходимость при записи настроек сформированных в более
			 * ранних приборах корректировать кол-во параметров и значения команды
			 * 
			 */
			if( DS.isfam( DS.K16 ) ) 
			{
				var release_bottom:int
				
				if( SERVER.BOTTOM_VER_INFO )
				{
					release_bottom = String( SERVER.BOTTOM_VER_INFO[ 0 ][ 1 ] ).split(".")[2];
				}
				else
				{
					release_bottom = String( SERVER.VER_FULL ).split(".")[2];
				}
				
				
				
				if( release_bottom > 16 )
						b = replaceCommand_906( b );
			}
			
			
			
			if( DS.isfam( DS.LCD3 ) )
			{
				LcdIsoServant.self.inputRaw( b );
			}
			
			

			var len:int = fr.name.length;
			tFileName.htmlText = cutString( fr.name, len);//"Прошивка <b>"+fr.name+"</b> готова к загрузке";
			while (tFileName.numLines > 1) {
				len -= 5;
				tFileName.htmlText = cutString(fr.name, len);
			}
			///TODO: Кастылик в текст вставлен локально, надо выработать системный подход
			tFileName.height += 10;
			function cutString(s:String, l:int):String
			{
				if (s.length > l)
					return s.slice(0,l-3) + "... .rcf";
				return s;
			}
			
			bAction.disabled = false;
			pageList.setList( FSCBListAssembler.getList( manager.getLoadList(b),1 ));
			if (tObject) {
				tObject.setCellInfo( OPERATOR.dataModel.getData(CMD.CONNECT_SERVER)[0][0] );
				onObject(); 
			}
			if (tObjectEgts) {
				
				if(   !DS.isfam( DS.F_V ) || ( DS.isfam( DS.F_V ) && DS.release > 54 )   ){
					
					tObjectEgts.setCellInfo( configureX32Nm( int( OPERATOR.dataModel.getData(CMD.CONNECT_SERVER)[3][0] )  
												, int( OPERATOR.dataModel.getData(CMD.CONNECT_SERVER)[2][0] ) ) );
					
				}
				else{
					tObjectEgts.setCellInfo( OPERATOR.dataModel.getData(CMD.CONNECT_SERVER)[2][0] );
					tObjectEgts.setCellInfo( OPERATOR.dataModel.getData(CMD.CONNECT_SERVER)[3][0] );
				}
				
				
				onObjectEgts();
			}
			pageList.open(LIST_WIDTH,LIST_HEIGHT,PAGE.CONTENT_LEFT_SHIFT + PAGE.MAINMENU_WIDTH + 10,PAGE.CONTENT_TOP_SHIFT + 91 + TOP_SHIFT);
			resizeObject();
			
			showMenu(false);
		}
		
		private function configureX32Nm( n:int, nn:int ):Number 
		{
			/// самый старший разряд в десятичном представлении
			const hight_bit:Number = 2147483648;
			/// включен ли старший бит
			const hb:Boolean = ( n & 0x8000 ) > 0;
			/// первая половина числа исключая знаковый старший бит
			const i_int:Number = n & 0x7FFF;
			
			var res:Number = ( i_int << 16 ) + nn;
			
			
			if ( hb )
				res += hight_bit;
			
			return res;
		}
		
		private function onChange(e:Event):void
		{
			if (SocketProcessor.getInstance().connected) {
				
				manager.addEventListener( Event.COMPLETE, onComplete );
				bAction.disabled = true;
				var a:Array = pageList.getCellInfo() as Array;
				if ( a.length > 0 ) {
					
					manager.doListIntegration( FSCBListAssembler.getList(manager.getSaveList()), a, e.currentTarget as IFormString );
					manager.saveOnlineListToFile(a);
					//ErrorHandler.activeHandler( activeErrorHandler );
					RequestAssembler.getInstance().activeHandler( activeErrorHandler );
				}else {
					manager.abort();
					pLoader.visible = false;
				}
			}
		}
		private function onComplete(e:Event):void
		{
			
			bAction.disabled = (pageList.getCellInfo() as Array).length < 1;
			manager.removeEventListener( Event.COMPLETE, onComplete );
	//		pLoader.visible = false;
			RequestAssembler.getInstance().activeHandler();
			//ErrorHandler.activeHandler();
		}
		private function onLoadProgress(e:Event):void
		{
			
			
			if( !manager.ABORTED )
				pLoader.visible = manager.VISUAL_LOAD_PROGRESS < manager.LOAD_TOTAL && pageList.visible;
			pLoader.setProgress( manager.VISUAL_LOAD_PROGRESS, manager.LOAD_TOTAL );
		}
		private function heightChanged(num:String):void
		{
			switch(num) {
				case "1":
					lastsep.y = 60;
					break;
				case "3":
					lastsep.y = 135;
					break;
			}
			go.show(num);
			this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
		}
		private function resizeObject():void
		{
			var yvalue:int = PAGE.CONTENT_TOP_SHIFT + 91;
			if (tObject) {
				if (yvalue == 0) {
					tObject.visible = false;
					if (tObjectEgts)
						tObjectEgts.visible = false;
					sep.visible = false;
				} else {
					var p:Point = globalToLocal( new Point);
					
					var gy:int = p.y + yvalue - 10
					tObject.y = gy;
					gy += 30; 
						
					if (tObjectEgts) {
						tObjectEgts.y = gy;
						gy += 30;	
					}
					
					sep.y = gy + 10;
				}
			}
		}
		private function onObject():void
		{
			CODE_OBJECT = int(tObject.getCellInfo());
		}
		private function onObjectEgts():void
		{
			CODE_OBJECT_EGTS = int(tObjectEgts.getCellInfo());
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable)
				TabOperator.getInst().add(child as IFocusable);
			return super.addChild(child);
		}
		
		public function getLoadSequence():Array
		{
			if (DS.isVoyager())
				return [CMD.CONNECT_SERVER];
			return null;
		}
		public function isLast():void
		{
			removeChild( lastsep );
		}
		
		public function put(p:Package):void
		{
			
		}
		public function init():void
		{
			StructureManager.access().launch();
		}
	}
}
import components.abstract.functions.loc;
import components.gui.PopUp;
import components.interfaces.IActiveErrorHandler;
import components.protocol.RequestAssembler;
import components.protocol.SocketProcessor;

class Bot
{
	public const SAVE:int = 0;
	public const LOAD:int = 1;
	public const ACTION:int = 2;
	public const CANCEL:int = 3;
	public const INTERRUPT:int = 4;
	
	public const LOAD_FILE:int = 1;
	public const LOAD_FILE_TO_DEVICE:int = 2;
	public const SAVE_FILE:int = 3;
	public const SAVE_FILE_FROM_DEVICE:int = 4;
	
	public var operation:int;
	
	public function getName(s:int):String
	{
		var name:String;
		switch(s) {
			case SAVE:
				if (isOnline()) {
					name = loc("service_save_from_device_to_file");
					operation = SAVE_FILE_FROM_DEVICE;
				} else { 
					name = loc("service_save_to_file");
					operation = SAVE_FILE;
				}
				break;
			case LOAD:
				if (isOnline()) {
					name = loc("ui_service_load_form_file_to_device");
					
					operation = LOAD_FILE_TO_DEVICE;
					
				} else {
					name = loc("service_add_from_file");
					operation = LOAD_FILE;
				}
				break;
		}
		return name;
		function isOnline():Boolean
		{
			return SocketProcessor.getInstance().connected;
		}
	}
}
class ActiveErrorHandler implements IActiveErrorHandler
{
	private var fAbort:Function;
	
	public function ActiveErrorHandler(abort:Function)
	{
		fAbort = abort;
	}
	public function handle(e:int):void
	{
		RequestAssembler.getInstance().clearRequest();
		fAbort();
		PopUp.getInstance().construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("error_communicating"), PopUp.BUTTON_OK );
		PopUp.getInstance().open();
		/*GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
			{getScreenMode:ScreenBlock.MODE_WARNING, getScreenMsg:RES.EHANDLER_COMMUNICATION, getLink:null} );*/
	}
}