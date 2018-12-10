package components.screens.page
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.events.GUIEvents;
	import components.gui.OptList;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IFocusable;
	import components.interfaces.IResizeDependant;
	import components.interfaces.IServiceFrame;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.ProtocolHttp;
	import components.protocol.ProtocolHttpParams;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptFirmwareItem;
	import components.screens.ui.UIService;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;
	
	public class FirmWareAutoLoader extends UIComponent implements IResizeDependant, IServiceFrame
	{
		private var HTTP_URL:String = "";//"http://download.ritm.ru:30080/V15N/update/";//"http://192.168.13.156:80/test/";
		
		private var UPDATE_INSTALL:String;
		
		private const label:String=loc("service_current_device_ver");
		private const labelawtd:String=loc("service_current_coprocessor_ver");
		
		private const SERVER_START_UPDATE:int=1;
		private const SERVER_CANCEL_UPDATE:int=2;
		
		private const FW_CHANELS:Array = ["WIFI","GPRS","LAN", "ExtModem"];
		
		private var IS_WORKING:Boolean=false;	// указывает копоменет функционирует или страница закрыта
		
		private var netAddress:FSSimple;
		private var bConnect:TextButton;
		
		private var cbNetCnnection:FSComboBox;
		private var flashConnectStatus:FormString;
		private var pBar:ProgressBar;
		private var tDeviceName:FSSimple;
		private var tWatchdogName:FSSimple;
		private var list:OptList;
		private var sep:Separator;
		private var bUpdates:TextButton;

		private var buildVersion:int;
		private var globalY:int;
		private var STATUS:int;			// запоминает последний статус стейта
		private var _BLOCKED:Boolean;	// true если модуль блокирован извне
		private var SELECTED:int;		// выбранная строка в листе
		private var NO_INTERFACES:Boolean = false; // true - когда нет интерфейсов для прошивки, принудительно отключает кнопку загрузки
		
		public function set BLOCKED(value:Boolean):void
		{
			_BLOCKED = value;
		}
		public function get BLOCKED():Boolean
		{
			return _BLOCKED;
		}
		
		private var task:ITask;
		private var group:GroupOperator;
		private var lastList:Array;
		
		public function FirmWareAutoLoader()
		{
			UPDATE_INSTALL = loc("fw_update_install");
			
			super();
			
			group = new GroupOperator;
			
			tDeviceName = new FSSimple;
			addChild( tDeviceName );
			globalY += 30;
			tDeviceName.setName(label+":");
			tDeviceName.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			tDeviceName.setTextColor( COLOR.GREEN_DARK );
			tDeviceName.setWidth( 250 );
			tDeviceName.setCellWidth( 400 );
			
			tWatchdogName = new FSSimple;
			addChild( tWatchdogName );
			tWatchdogName.y = globalY;
			globalY += 30;
			tWatchdogName.setName(labelawtd+":");
			tWatchdogName.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			tWatchdogName.setTextColor( COLOR.GREEN_DARK );
			tWatchdogName.setWidth( 250 );
			tWatchdogName.setCellWidth( 400 );
			
			sep = new Separator(UIService.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = globalY;
			globalY += 20;
			
			flashConnectStatus = new FormString;
			addChild( flashConnectStatus );
			flashConnectStatus.y = globalY;
			globalY += 30;
			flashConnectStatus.setWidth( 400 );
			
			list = new OptList;
			addChild( list );
			list.attune(CMD.USER_PASS,1, OptList.PARAM_NEED_ADDITIONAL_EVENTS | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
			list.addEventListener( GUIEvents.onEventFiredSuccess, onListResize );
			list.buttonsExistance(false,false,false);
			list.width = 551;
			list.y = globalY;
			globalY += 300;
				
			sep = new Separator(UIService.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = globalY;
			globalY += 20;
			group.add("main", sep);
			
			cbNetCnnection = new FSComboBox;
			addChild( cbNetCnnection );
			cbNetCnnection.y = globalY;
			
			cbNetCnnection.setName(loc("fw_update_through"));
			cbNetCnnection.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbNetCnnection.setWidth( 250 );
			cbNetCnnection.setCellWidth( 100 );
			cbNetCnnection.setList( UTIL.getComboBoxList([[0,"WIFI"],[1,"GPRS"],[2,"LAN"],[3,"ExtModem"]]) );
			cbNetCnnection.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE; 
			group.add("main", cbNetCnnection);
			
			bUpdates = new TextButton;
			addChild( bUpdates );
			bUpdates.y = globalY;
			bUpdates.x = 392;
			bUpdates.setUp( UPDATE_INSTALL, onClick );
			bUpdates.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			group.add("main", bUpdates);
			
			globalY += 40;
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.y = globalY;
			//pBar.x = 1;
			pBar.width = 100;
			pBar.height = 10;
			//pBar.visible = false;
			pBar.mode = "manual";
			pBar.maximum = 100;
			pBar.minimum = 0;
			pBar.label = "";
			group.add("main", pBar);
			
			globalY += 50;
			
			netAddress = new FSSimple;
			addChild( netAddress );
			netAddress.y = globalY;
			netAddress.setName(loc("fw_http_server_adr"));
			netAddress.attune( FSSimple.F_CELL_ALIGN_LEFT );
			netAddress.setWidth( 150 );
			netAddress.setCellWidth( 400 );
			group.add("main", netAddress);
			
			bConnect = new TextButton;
			addChild( bConnect );
			bConnect.setUp( "connect", onClick1 );
			bConnect.y = netAddress.y;
			bConnect.x  = netAddress.width + 35;
			group.add("main", bConnect);
			
			globalY += 40;
			
			sep = new Separator(UIService.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = globalY;
			group.add("main", sep);
			
			globalY += 150;
		}
		public function init():void
		{
			IS_WORKING = true;
			BLOCKED = false;
			buildVersion = int(DS.getCommit());
			tDeviceName.setCellInfo( SERVER.VER_FULL + " " + buildVersion );
			flashStatus(loc("fw_server_conn"));
			ResizeWatcher.addDependent(this);
			SELECTED = 0;
		}
		public function close():void
		{
			IS_WORKING = false;
			if (task)
				task.stop();
			ResizeWatcher.removeDependent(this);
			RequestAssembler.getInstance().activeHandler();
		}
		public function isLast():void
		{
			sep.visible = false;
		}
		public function getLoadSequence():Array
		{
			return [CMD.UPDATE_FIRMWARE_STATUS,CMD.GET_UPDATE_FW_CHANEL,CMD.START_UPDATE_FIRMWARE];
		}
		public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VER_INFO:
					var vapp:String = p.getStructure(1)[1];
					var vsubv:Array = (p.getStructure(2)[0] as String).split(".");
					if (vapp is String && vsubv.length>1)
						tWatchdogName.setCellInfo( vapp +" "+vsubv[1] );
					break;
				case CMD.GET_BUF_SIZE:
					SERVER.BOTTOM_BUF_SIZE_SEND = p.getStructure(1)[1];
					SERVER.BOTTOM_BUF_SIZE_RECEIVE = p.getStructure(1)[0];
					break;
				case CMD.GET_MAX_IND_CMDS:
					SERVER.BOTTOM_MAX_IND_CMDS = int(p.getStructure(1)) > 0 ? int(p.getStructure(1)) : 0xFF;
					break;
				/*case CMD.START_UPDATE_FIRMWARE:
					if(!IS_WORKING)
						return;
					
				//	cbNetCnnection.setCellInfo( p.getStructure()[3] );
					
					HTTP_URL = p.getStructure()[1] + p.getStructure()[2]; 
					
					netAddress.setCellInfo( HTTP_URL );
					
					RequestAssembler.getInstance().HTTPSetUp( HTTP_URL,"","");
					RequestAssembler.getInstance().HTTPErrorListener( onHTTPError );
					ProtocolHttp.getParams().CONNECTION_TYPE = ProtocolHttpParams.CONNECTION_CLOSE;
				//	ProtocolHttp.getParams().IGNORE_CONTENTLENGTH = true;
					RequestAssembler.getInstance().HTTPRequest( "", onGetList );
					break;*/
				case CMD.GET_UPDATE_FW_CHANEL:
					/**"Команда GET_UPDATE_FW_CHANEL - получить каналы связи, через которые возможно загрузить обноление программного обеспечения

						Параметр 1 - каналы, через которые можно в приборе загрузить обновление программного обеспечения, каналы связи представляются побитно, 0-не доступно к выбору, 1-доступно к выбору.
						Бит 0 - WIFI;
						Бит 1 - GPRS;
						Бит 2 - LAN;
						Бит 3 - ExtModem" */
					
					var a:Array = [];
					var value:int = p.getStructure()[0];
					var itemnum:int = -1;
					if (value > 0) {
						var len:int = FW_CHANELS.length;
						for (var i:int=0; i<len; ++i) {
							if( (value & (1 << i)) > 0 ) {
								a.push([i,FW_CHANELS[i]]);
								if (itemnum == -1)
									itemnum = i;
							}
						}
					} else {
						
						a = [[0, loc("fw_no_available_interface")]];
						itemnum = 0;
					}
					NO_INTERFACES = value == 0;
					bUpdates.disabled = NO_INTERFACES;
					cbNetCnnection.setList( UTIL.getComboBoxList( a ) );
					cbNetCnnection.setCellInfo( itemnum );
					
					connectHttp();
					break;
				case CMD.UPDATE_FIRMWARE_STATUS:
					if(!IS_WORKING)
						return;
					/**	Параметр 1 - Статус обновления, 
					 * 0-ничего не показываем, 
					 * 1 - Соединение с сервером, 
					 * 2 - Загрузка прервана, 
					 * 3 - Ошибка загрузки, 
					 * 4 - Невозможно соединиться с сервером, 
					 * 5 - Загрузка обновления в прибор, осталось %			 */
					
					STATUS = p.getStructure()[0];
					
					doBlock(false);
					var current:int = 0;
					switch(STATUS) {
						case 0:
							pBar.label = "";
							bUpdates.setName(UPDATE_INSTALL);
							break;
						case 1:
							pBar.label = loc("fw_server_conn");
							bUpdates.setName(loc("fw_update_cancel"));
							doBlock(true);
							break;
						case 2:
							pBar.label = loc("fw_load_cancel");
							bUpdates.setName(UPDATE_INSTALL);
							break;
						case 3:
							pBar.label = loc("fw_load_error");
							bUpdates.setName(UPDATE_INSTALL);
							break;
						case 4:
							pBar.label = loc("fw_unable_conn");
							bUpdates.setName(UPDATE_INSTALL);
							break;
						case 5:
							current = p.getStructure()[1];
							pBar.label = loc("fw_load_to_device") + ", "+loc("fw_left")+" " + current+"%";
							bUpdates.setName(loc("fw_update_cancel"));
							doBlock(true);
							break;
					}
					pBar.setProgress( 100-current, 100 );
					if(!task)
						task = TaskManager.callLater( onTask, CLIENT.TIMER_EVENT_SPAM );
					else
						task.repeat();
					break;
			}
		}
		override public function get height():Number
		{
			return globalY + 30;
		}
		public function block(b:Boolean):void
		{
			BLOCKED = b;
			bUpdates.disabled = b || NO_INTERFACES;
			cbNetCnnection.disabled = b;
			list.disabled = b;
			if (task) {
				if (b)
					task.stop();
				else
					task.repeat();
			}
		}
		public function resetAndDisable():void
		{
			
		}
		
		private function connectHttp():void
		{
			var adr:String = "http://device.ritm.ru/linux/"
			
			switch(DS.alias) {
				case DS.V15:
					adr += "voyager-15/firmware/";
					break;
				case DS.V15IP:
					adr += "voyager-15ip/firmware/";
					break;
				case DS.K15:
					adr += "contact-15/firmware/";
					break;
				case DS.K15IP:
					adr += "contact-15ip/firmware/";
					break;
				case DS.R15:
				case DS.R15IP:
					adr += "recorder/firmware/";
					break;
				case DS.C15:
					adr += "ipcam/firmware/";
					break;
			}
			netAddress.setCellInfo( adr );
			
			RequestAssembler.getInstance().HTTPSetUp( adr,"","");
			RequestAssembler.getInstance().HTTPErrorListener( onHTTPError );
			ProtocolHttp.getParams().CONNECTION_TYPE = ProtocolHttpParams.CONNECTION_CLOSE;
			RequestAssembler.getInstance().HTTPRequest( "", onGetList );
		}
		private function onListResize():void
		{
			ResizeWatcher.doResizeMe(this);
		}
		
		private function flashStatus(msg:String, error:Boolean=false):void
		{
			if (error)
				flashConnectStatus.setTextColor( COLOR.RED );
			else
				flashConnectStatus.setTextColor( COLOR.BLACK );
			flashConnectStatus.setCellInfo( msg );
		}
		private function doBlock(b:Boolean, doFullBlock:Boolean=true):void
		{
			if (b) {
				this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
				bUpdates.disabled = BLOCKED || NO_INTERFACES;
				cbNetCnnection.disabled = true;
				list.disabled = true;
			} else {
				this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
				bUpdates.disabled = BLOCKED || NO_INTERFACES;
				cbNetCnnection.disabled = BLOCKED;
				list.disabled = BLOCKED;
			}
		}
		
/****	EVENTS			*****/
		
		private function onClick():void
		{
			switch(STATUS) {
				case 1:
				case 5:
					RequestAssembler.getInstance().fireEvent( new Request(CMD.START_UPDATE_FIRMWARE, null, 1, 
						[SERVER_CANCEL_UPDATE,"","",int(cbNetCnnection.getCellInfo())]));
					break;
				default:
					if (list.selectedLine > 0) {
						var opt:OptFirmwareItem = list.getLine(list.selectedLine) as OptFirmwareItem;
						var url:String = String(netAddress.getCellInfo()) + "upgrade."+opt.file+".tar.gz";
						RequestAssembler.getInstance().fireEvent( new Request(CMD.START_UPDATE_FIRMWARE, null, 1, 
							[SERVER_START_UPDATE,url.slice(0,63),url.slice(63,126),int(cbNetCnnection.getCellInfo())]));
					}
					break;
			}
		}
		private function onClick1():void
		{
			
			
			flashStatus(loc("fw_server_conn"));
			RequestAssembler.getInstance().HTTPSetUp( netAddress.getCellInfo() as String,"","");
			RequestAssembler.getInstance().HTTPErrorListener( onHTTPError );
			ProtocolHttp.getParams().CONNECTION_TYPE = ProtocolHttpParams.CONNECTION_CLOSE;
			RequestAssembler.getInstance().HTTPRequest( "", onGetList );
			
		}
		private function onGetList(b:ByteArray):void
		{
			var s:String = b.readMultiByte(b.bytesAvailable, "windows-1251" );
			
			
			if (s=="")
				return;
			var restring:String = "(>upgrade\\.\\d{1,5}\\.tar\\.gz<)";
			var re:RegExp = new RegExp( restring, "g");
			var a:Array = s.match( re );
			
			var reNum:RegExp = /\d{1,5}/;
			var reExt:RegExp = /\.tar\.gz/;
			
			var len:int = a.length;
			var line:String;
			var file:String;
			var listData:Array=[];
			var infonum:int = 0;
			for (var i:int=0; i<len; ++i) {
				line = a[i] as String;
				file = line.slice(line.search( reNum ),line.search( reExt ));
				if ( int(file) > buildVersion ) {
					infonum = s.search( "upgrade."+file + ".info");
					listData.push([file, infonum > -1]);
				}
			}
			if (listData.length > 0)
				flashStatus( loc("fw_is_update") );
			else
				flashStatus( loc("fw_no_updates") );
			
			if ( !lastList || !isIdentical(listData, lastList)) {
				lastList = listData.slice();
				list.putData(listData, OptFirmwareItem);
				if (SELECTED==0) {
					SELECTED = listData.length;
					//callLater(scrollTo);
					TaskManager.callLater(scrollTo,10);
				}
				list.select(SELECTED);
				
			}
		}
		private function isIdentical(a1:Array, a2:Array):Boolean
		{
			if (a1.length == a2.length) {
				var len:int = a1.length;
				for (var i:int=0; i<len; ++i) {
					if( a1[i][0] != a2[i][0] || a1[i][1] != a2[i][1] )
						return false;
				}
				return true;
			}
			return false;
		}
		private function scrollTo():void
		{
			list.scrollTo(SELECTED);
		}
		private function onHTTPError(e:Event):void
		{
			
			flashStatus( loc("fw_unable_conn"),true );
			list.putData([], OptFirmwareItem);
		}
		private function onTask():void
		{
			if (this.visible) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.UPDATE_FIRMWARE_STATUS, put));
				SELECTED = list.selectedLine;
				RequestAssembler.getInstance().HTTPRequest( "", onGetList );
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			//var calch:int = h<686?686:h;
			//var calch:int = h<701?701:h;
			var calch:int = h<501?501:h;
			var adds:int = 140;
			
			list.height = calch - (220+adds);
			group.movey("main", calch - (140+adds) );
			globalY = calch-adds;
			this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable)
				TabOperator.getInst().add(child as IFocusable);
			return super.addChild(child);
		}
	}
}