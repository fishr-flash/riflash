package foundation
{
	/** ver 4.2				*/
	
	import components.abstract.functions.dtrace;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.SystemCheckServant;
	import components.abstract.servants.TabOperator;
	import components.abstract.sysservants.LoaderServant;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.DevConsole;
	import components.gui.LocalConfig;
	import components.gui.MainNavigation;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.StatusBar;
	import components.gui.triggers.ButtonSave;
	import components.gui.triggers.VisualButton;
	import components.gui.visual.BlockRitm;
	import components.gui.visual.OnlineStatus;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.IFounder;
	import components.protocol.ProtocolHttp;
	import components.protocol.ProtocolHttpParams;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.protocol.statics.SHA256;
	import components.screens.OptionBuilder;
	import components.static.GuiLib;
	import components.static.KEYS;
	import components.static.MISC;
	import components.static.NAVI;
	import components.static.PAGE;
	import components.system.CONST;
	import components.system.Controller;
	import components.system.UTIL;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.SharedObject;
	import flash.system.fscommand;
	import flash.utils.ByteArray;
	
	import foundation.functions.addLabels;
	import foundation.functions.attuneCmd;
	import foundation.functions.attuneLabels;
	import foundation.functions.initShared;
	import foundation.functions.onChangeOnline;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import spark.components.Application;
	import spark.components.Button;

	public class Founder extends Application implements IFounder
	{
		[Binding]
		public var canvasBase:Canvas;
		[Binding]
		public var canvasTop:Canvas;
		[Binding]
		public var canvasMenuHolder:Canvas;
		[Binding]
		public var canvasMain:Canvas;
		[Binding]
		public var canvasSubMenu:Canvas;
		[Binding]
		public var canvasSubMenuHolder:Canvas;
		[Binding]
		public var cmdDefault:XML;
		[Binding]
		public var bConfig:Button;
	
		private static var instance:Founder;
		
		private var PAGE_READY:Boolean=true;
		private var PUPPET_RESIZE:Boolean=false;		// активируется когда требуется задать требуемые размер сцене
		public var MENU_READY:Boolean=false;			// при загрузке до initMenuSelection всегда false, после true
		
		public var mainLabel:SimpleTextField;
		public var pageLabel:SimpleTextField;
		public var pageLabelSecond:SimpleTextField;
		
		public var oBuilder:OptionBuilder;
		
		private var resizeWatcher:ResizeWatcher;
		private var keyWatcher:KeyWatcher;
		private var statusBar:StatusBar;
		private var navi:MainNavigation;
		private var screenBlock:ScreenBlock;
		private var localConfig:LocalConfig;
		private var onlineStatus:OnlineStatus;
		private var savebutton:ButtonSave;
		private var console:DevConsole;
		private var logo:BlockRitm;
		private var popUp:PopUp;
		private var sysCheck:SystemCheckServant;
		private var loader:LoaderServant;
		
		private var _subMenu:Boolean = false;
		
		public function Founder()
		{
			try {
				fscommand( "showmenu", "false" );				
			} catch(error:Error) {
				trace(error.message);
			}
			
			super();
			instance = this;
			
			MISC.COPY_CLIENT_VERSION = CONST.CLIENT_BUILD_VERSION;
			MISC.COPY_VER = CONST.VERSION;
			MISC.SAVE_PATH = CONST.SAVE_PATH;
			MISC.COPY_DEBUG = CONST.DEBUG;
			MISC.COPY_LEVEL = CONST.LEVEL;
			MISC.COPY_TARGET_SOFTWARE = CONST.TARGET_SOFTWARE;
			
			SHA256.k = [UTIL.enableCache(MISC.COPY_VER)];
			
			var so:SharedObject = SharedObject.getLocal( "RITM", "/" );
			
			if ( (so.data["debugkey"] && so.data["debugkey"] == MISC.DEBUG_KEY ) ) {
				try {
					fscommand( "showmenu", "true" );
				} catch(error:Error) {
					trace(error.message);
				}	
			}
			
			console = new DevConsole;
			this.addEventListener( Event.ADDED_TO_STAGE, addedToStage );
		}
		private function onUncaughtError(e:UncaughtErrorEvent):void 
		{
			if (e.error is Error) {
				var error:Error = e.error as Error;
				dtrace( "Exception : " + error.errorID + " " + error.message + " "+ error.name);
			} else if (e.error is ErrorEvent) {
				var errorEvent:ErrorEvent = e.error as ErrorEvent;
				dtrace( "Exception : " + errorEvent.errorID + " " + errorEvent.text + " "+ errorEvent.type );
			} else {
				dtrace( "Exception : " + (e.error as Object).toString() );
			}
			//e.preventDefault();
		}
		private function addedToStage(ev:Event):void
		{
			this.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			var ui:UIComponent = new UIComponent;
			canvasBase.addChild( ui );
			
			MISC.subMenuContainer = canvasSubMenuHolder;
			MISC.subMenu = canvasSubMenu;
			MISC.COPY_MENU = CONST.MENU;
			CONST.FLASH_VARS = stage.loaderInfo.parameters;
			
			loader = new LoaderServant(initMenuSelection, defaultMenu);
			addLabels( ui );
			
			initShared(MISC.COPY_VER + CONST.SAVE_PATH);
			
			console.x = -1;
			ui.addChild( console );
			
			statusBar = new StatusBar();
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onStatusBarChanged, catchStatus);
			ui.addChild( statusBar );
			statusBar.x = -1;
			
			navi = MainNavigation.getInst();
			canvasMenuHolder.addChild( navi );
			navi.setUp( chooseMenuItem );
			
			oBuilder = new OptionBuilder(canvasMain, canvasSubMenuHolder);
			
			screenBlock = new ScreenBlock(300,100,ScreenBlock.MODE_LOADING,"", 0xffffff);
			ui.addChild( screenBlock );
			screenBlock.visible = false;
			screenBlock.x = PAGE.MAINMENU_WIDTH;
			screenBlock.y = canvasTop.height - 1;
			
			OPERATOR.installSchema( cmdDefault );
			attuneCmd();
			
			savebutton = new ButtonSave;
			savebutton.visible = false;
			savebutton.setName("Сохранить изменения");
			ui.addChild( savebutton );
			Controller.getInstance().register( savebutton, Controller.REGISTER_SAVE );
			
			var but:VisualButton = new VisualButton(GuiLib.cConfig);
			ui.addChild( but );
			but.setUp("",show_config);
			but.x = 3;
			but.y = 4;
			but.onlyPicture = true;
			but.visible = CONST.DEBUG;
			
			onlineStatus = new OnlineStatus;
			ui.addChild( onlineStatus );
			onlineStatus.x = 33;
			onlineStatus.y = 4;
			onlineStatus.visible = CONST.DEBUG;
			
			logo = new BlockRitm;
			ui.addChild( logo );
			logo.x = 10;
			logo.visible = false;
			
			localConfig = new LocalConfig;
			ui.addChild( localConfig );
			localConfig.x = 10;
			localConfig.y = 10;
			localConfig.visible = false;
			
			popUp = PopUp.getInstance();
			ui.addChild( popUp );
			popUp.y = 60;//layerHeight - (additionalHeightCrop + popUp.height + 2);
			popUp.x = 246;//canvasMenuHolder.width + canvasSubMenu.width + 10;
			
			resizeWatcher = new ResizeWatcher(resize, puppetResize);
			resizeWatcher.add( statusBar );
			resizeWatcher.add( savebutton );
			resizeWatcher.add( console );
			resizeWatcher.add( navi );
			
			keyWatcher = new KeyWatcher;
			
			if(!CONST.DEBUG) {
				CLIENT.CONNECT_IP = "127.0.0.1";
				CLIENT.CONNECT_PORT = 53462;
			}
			
			if (SERVER.REMOTE_HOST != null) {
				CLIENT.CONNECT_IP = SERVER.REMOTE_HOST;
				CLIENT.CONNECT_PORT = SERVER.REMOTE_PORT;
			}
			
			//RequestAssembler.getInstance().
			dtrace("1");
			RequestAssembler.getInstance().HTTPSetUp( "http://188.134.10.212:30080/V15N/update/","","");
			dtrace("2");
			RequestAssembler.getInstance().HTTPErrorListener( onHTTPError );
			dtrace("3");
			ProtocolHttp.getParams().CONNECTION_TYPE = ProtocolHttpParams.CONNECTION_CLOSE;
		//	ProtocolHttp.getParams().IGNORE_CONTENTLENGTH = true;
			RequestAssembler.getInstance().HTTPRequest( "", onGetList );
			
		//	SocketProcessor.getInstance().performConnect();
			function onGetList(b:ByteArray):void
			{
				var s:String = b.readMultiByte(b.bytesAvailable, "windows-1251" );
				dtrace( "hhtp response \"" +s+"\"" );
			}
			function onHTTPError(e:Event):void
			{
				dtrace( "Error" );
			}
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.pageLoadLComplete, pageLoaded );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.menuReset, menuReset );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onChangeOnline );
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onNeedScreenBlock, onNeedScreenBlock );
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onNeedChangeLabel, onNeedChangeLabel );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onBlockNavigationSilent, onBlockSilent );
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp );
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
			
			this.removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
			this.addEventListener( ResizeEvent.RESIZE, resize );
			resize();
		}
		public function load():void
		{
			loader.load(CONST.LOADER_SEQUENCE);
		}
		public function set subMenu(b:Boolean):void
		{
			_subMenu = b;
			resize();
		}
		public function get subMenu():Boolean
		{
			return _subMenu;
		}
		private function puppetResize(w:int, h:int):void
		{
			PUPPET_RESIZE = true;
			
			canvasBase.height = h;
			canvasBase.width = w;
			
			resize();
		}
		private function resize(ev:Event=null):void
		{
			if (CLIENT.PREVENT_RESIZE)
				return;
			
			if (!PUPPET_RESIZE) {
				canvasBase.height = this.height - PAGE.BASE_MARGIN_TOP;
				canvasBase.width = this.width - PAGE.BASE_MARGIN_SIDE;				
			}
			
			var layerHeight:Number = canvasBase.height;
			var layerWidth:Number = canvasBase.width;
			
			statusBar.y = layerHeight - (statusBar.height + 2);
			statusBar.width = layerWidth;
			
			var additionalHeightCrop:int = statusBar.height;

			savebutton.y = layerHeight - (additionalHeightCrop + 2 + savebutton.CONSTANT_HEIGHT);
			savebutton.width = layerWidth;
			
			additionalHeightCrop += savebutton.height;
			
			if( console.visible ) {
				console.width = layerWidth;
				if (console.height > layerHeight - 140)
					console.height = layerHeight - 140;
				if (console.height < 48)
					console.height = 48;
				console.y = layerHeight - (additionalHeightCrop + console.height + 1);
				additionalHeightCrop += console.height - 1;
			}
			
			logo.y = layerHeight - (logo.height + additionalHeightCrop);
			if ( logo.y < navi.height + canvasMenuHolder.y + 10 )
				logo.hide(true);
			else
				logo.hide(false);
			
			canvasMenuHolder.height = layerHeight - (canvasMenuHolder.y + 2 + additionalHeightCrop);
		
			canvasSubMenu.width = ( _subMenu && SocketProcessor.getInstance().connected )? PAGE.SECONDMENU_WIDTH : 0;
			canvasSubMenu.height = layerHeight - additionalHeightCrop;
		
			var pixelCorrectionX:int = (_subMenu && SocketProcessor.getInstance().connected ) ? 2 : 1;
			var pixelCorrectionW:int = (_subMenu && SocketProcessor.getInstance().connected ) ? 1 : 0;

			canvasSubMenuHolder.width = canvasSubMenu.width;
			canvasSubMenuHolder.height = layerHeight - (canvasSubMenuHolder.y + additionalHeightCrop + 2);
			
			canvasTop.x = canvasMenuHolder.width + canvasSubMenu.width - pixelCorrectionX;
			canvasTop.width = layerWidth + pixelCorrectionW - (canvasMenuHolder.width + canvasSubMenu.width);
			
			canvasMain.x = canvasMenuHolder.width + canvasSubMenu.width - pixelCorrectionX;
			canvasMain.width = layerWidth + pixelCorrectionW - (canvasMenuHolder.width + canvasSubMenu.width);
			canvasMain.height = layerHeight + 1 - (canvasTop.height + additionalHeightCrop);
			
			attuneLabels( _subMenu );
			
			screenBlock.resize( canvasSubMenu.width + canvasMain.width, layerHeight - (additionalHeightCrop + 2 + screenBlock.y) );
			
			if (!PUPPET_RESIZE)
				resizeWatcher.resize(canvasMain.width,canvasMain.height);
			
			PUPPET_RESIZE = false;
		}
/***************************** ACTIONS				*/
		private function showLoadingBlock():void
		{
			screenBlock.mode( ScreenBlock.MODE_LOADING );
			resize(null);
			screenBlock.visible = true;
			TabOperator.ACTIVE = false;
		}
/***************************** PUBLIC ACTIONS			*/
		public function show_config():void
		{
			localConfig.open();
		}
		public function clickMenu(_id:int):void
		{
			navi.update(_id);
		}
		public function initMenuSelection():void
		{
			if (!MENU_READY) {
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":CLIENT.IS_WRITING_FIRMWARE} );
				MENU_READY = true;
			}
			
			if (CLIENT.IS_WRITING_FIRMWARE) {
				chooseMenuItem(NAVI.SERVICE);
			} else if ( CLIENT.AUTO_SELECT_PAGE > -1 ) {
				navi.selection = CLIENT.AUTO_SELECT_PAGE;
				chooseMenuItem(CLIENT.AUTO_SELECT_PAGE,true);
			} else if (navi.selection > -1 )
				chooseMenuItem(navi.selection,true);
		}
		private function chooseMenuItem( _id:int, auto:Boolean=false ):void
		{
			var cmdSwitch:int = _id;
			if ( !PAGE_READY )
				return;
			if ( !MENU_READY )
				return;
			PAGE_READY = false;
			navi.isReady = false;
			oBuilder.hideAllUI();
			if (!auto)
				popUp.close();
			
			CLIENT.PROTOCOL_BlOCK_BINARY = false;
			var internal_menu:Boolean = false;
			showLoadingBlock();
			
			var menu:Array = MainNavigation.getInst().getMenu();
			var notExist:Boolean = true;
			for (var key:String in menu) {
				if( menu[key].data == cmdSwitch ) {
					if (menu[key].needsystem && MISC.SYSTEM_INACCESSIBLE) {
						if (!sysCheck)
							sysCheck = new SystemCheckServant(onSystem);
						sysCheck.check(cmdSwitch, NAVI.RF_SYSTEM );
						return;
					}
					Controller.getInstance().saveButtonActive(true);
					setPageLabel( menu[key].label );
					notExist = false;
					internal_menu = Boolean(menu[key].submenu);
//					if (menu[key].binary) {
//						CLIENT.PROTOCOL_BlOCK_BINARY = true;
//						localConfig.switchToBinary();
//					}
					/*if( Boolean(menu[key].bottom) ) {
						SERVER.ADDRESS = SERVER.ADDRESS_BOTTOM;
					} else
						SERVER.ADDRESS = SERVER.ADDRESS_TOP;*/
					break;
				}
			}
			if (notExist) {
				setPageLabel( "Страница отсутствует" );
				PAGE_READY = true;
				screenBlock.visible = false;
				navi.isReady = true;
				cmdSwitch = -1;
			} else
				oBuilder.initProcess( cmdSwitch );
			
			subMenu = internal_menu;
		}
		private function defaultMenu():void
		{
			navi.generate( CONST.MENU_UNDEFINED );
		}
		public function menu(m:Array):void
		{
			navi.generate( m );
		}
		public function setPageLabel(s:String):void
		{
			pageLabel.htmlText = s;
			if( pageLabel.numLines == 1 ) {
				pageLabel.y = 17;
				pageLabel.height = 43;
			} else {
				pageLabel.y = 10;
				pageLabel.height = 50;
			}
		}
		private function onSystem(_id:int):void
		{
			PAGE_READY = true;
			navi.selection = _id;
			chooseMenuItem(_id);
		}
		
/***************************** EVENTS				*/
		private function catchStatus(ev:SystemEvents):void
		{
			statusBar.show( ev.getText(), ev.getType(), ev.getStatus() );
		}
		private function menuReset( ev:SystemEvents ):void
		{
			PAGE_READY = true;
			navi.isReady = true;
		//	navi.selection = 0;
		}
		private function pageLoaded( ev:SystemEvents ):void
		{
			PAGE_READY = true;
			navi.isReady = true;
			screenBlock.visible = false;
		}
		private function onNeedScreenBlock(ev:GUIEvents):void
		{
			if( ev.getScreenMode() == -1 )
				screenBlock.visible = false;
			else {
				resize();
				screenBlock.visible = true;
				screenBlock.mode( ev.getScreenMode(), ev.getScreenMsg() );
				if (ev.getLink() != null )
					screenBlock.linkage(ev.getLink() as Function);
			}
		}
		private function onNeedChangeLabel(ev:GUIEvents):void
		{
			switch( ev.getData().labelnum ) {
				case 1:
					pageLabel.text = ev.getData().label;
					break;
				case 2:
					pageLabelSecond.htmlText = ev.getData().label;
					break;
			}
		}
		private function onBlockSilent(e:SystemEvents):void
		{	// разрешать разблокировать меню только если страница полностью загружена
			if (!e.isBlock())
				navi.isReady = PAGE_READY;
			else
				navi.isReady = false;
			//navi.isReady = !e.isBlock() && PAGE_READY;
		}
		private function onKeyDown(ev:KeyboardEvent):void
		{
			if (ev.keyCode == KEYS.Tilde && ev.ctrlKey && CONST.DEBUG)
				console.visible = !console.visible;
			if ( (ev.keyCode == KEYS.Tab || ev.keyCode == KEYS.Enter) && console.visible && !console.isFocused() )
				callLater(console.focus);
			else if ( !console.visible &&
				(ev.keyCode == KEYS.ESC || ev.keyCode == KEYS.Enter ||
				ev.keyCode == KEYS.Tab || ev.keyCode == KEYS.Spacebar || 
				ev.keyCode == KEYS.LeftArrow  || ev.keyCode == KEYS.UpArrow  || 
				ev.keyCode == KEYS.RightArrow || ev.keyCode == KEYS.DownArrow) )
				TabOperator.getInst().onKey(ev.keyCode, ev.shiftKey, ev.ctrlKey);
			else if ( ev.keyCode == KEYS.KEY_S && ev.ctrlKey ) {
				Controller.getInstance().save();
			}
		}
		private function onKeyUp(ev:KeyboardEvent):void
		{
			keyWatcher.onKeyUp(ev);
		}
/***************************** STATIC				*/
		public static function get app():Founder
		{
			return instance;
		}
	}
}