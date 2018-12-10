package components.screens.ui
{
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.PDFServant;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TXTServant;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.XLSServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.FileBrowser;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.PopUp;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IKeyUser;
	import components.interfaces.IKontaktHistorySaverServant;
	import components.interfaces.IResizeDependant;
	import components.protocol.ErrorHandler;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.KEYS;
	import components.static.MISC;
	
	public class UIHistory extends UI_BaseComponent implements IResizeDependant, IKeyUser
	{
		public static const HIS_DELETE:int = 0x01;
		public static const HIS_DELETE_SUCCESS:int = 0x02;
		
		private const XLS:int = 1;
		private const PDF:int = 2;
		private const DELETE:int = 3;
		private const START:int = 6;
		private const TXT:int = 7;
		
		protected var HIS_HARD_MAX_STRUCTURES:int = 0;
		private var HIS_MAX_STRUCTURES:int = 0;
		private var HIS_LAST_STRUCTURE:int = 0;
		private var HIS_LAST_PAGE_REQUEST:int = 0;	// хранится какая страница по счету была запрошена из Opt
		private var HIS_STRUCTURES_REQUESTED:Array;	// хранятся запрошенные структуры
		private var HIS_SEND_DATA:Array;			// собирается информация для передачи в Opt
		
		protected var HISTORY_REC_CMD:int;
		protected var askDelay:int;
		
		protected var bXLSpageAll:TextButton;
		protected var bTXTpageAll:TextButton;
		private var bGatherHistory:TextButton;
		protected var tAmount:FormString;
		private var bClearHistory:TextButton;
		protected var servant:IKontaktHistorySaverServant;

		private const HASH_PDF_XPOS:Object = {0:5, 1:65, 2:175, 3:255, 4:330, 5:460+70, 6:510+70, 7:595+70, 8:670+70, 9:780+70};
		
		private var shared:Vector.<String>;	// для создания sharedStrings в xlsx
		private var shared_color_map:Vector.<String>;
		private var shared_count:int;		// макс длина строки для sharedStrings в xlsx
		private var esupporter:HistoryErrorSupporter;
		
		private var timerDeleting:Timer;
		public function UIHistory()
		{
			super();
			
			var header:Header = getHeader();
			
			addChild( header );
			header.x = 20;
			header.y = 15;
			
			list = new OptList
			addChild( list );
			list.y = 50;
			list.width = 660+199 + 197-60;
			list.attune( HISTORY_REC_CMD,0, OptList.PARAM_DRAW_SEPARATOR | OptList.PARAM_DRAW_CHECKMATE | OptList.PARAM_DRAW_PAGES | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED, {linesPerPage:CLIENT.HISTORY_LINES_PER_PAGE} );
			
			bXLSpageAll = new TextButton;
			bXLSpageAll.x = 10;
			bXLSpageAll.setUp( loc("his_export_to_excel"), onButton, XLS);
			addChild( bXLSpageAll );
			bXLSpageAll.disabled = true;
			bXLSpageAll.focusorder = 21;
			bXLSpageAll.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			
			bTXTpageAll = new TextButton;
			bTXTpageAll.x = 10;
			bTXTpageAll.setUp( loc("his_export_to_txt"), onButton, TXT);
			addChild( bTXTpageAll );
			bTXTpageAll.disabled = true;
			bTXTpageAll.focusorder = 22;
			bTXTpageAll.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			
			bClearHistory = new TextButton;
			bClearHistory.x = 380;
			bClearHistory.setUp( loc("his_clear_history"), onButton, DELETE);
			addChild( bClearHistory );
			bClearHistory.focusorder = 18;
			bClearHistory.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			
			bGatherHistory = new TextButton;
			bGatherHistory.x = 380;
			bGatherHistory.setUp( loc("his_read_amount_of_lines"), onButton, START);
			addChild( bGatherHistory );
			bGatherHistory.focusorder = 20;
			bGatherHistory.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			
			FLAG_SAVABLE = false;
			tAmount = new FormString;
			tAmount.setWidth(60);
			tAmount.attune( FormString.F_EDITABLE + FormString.F_OFF_KEYBOARD_REACTIONS );
			addChild( tAmount );
			tAmount.x = 515;
			tAmount.focusorder = 19;
			tAmount.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			
			askDelay = 5000;
			
			starterCMD = [ CMD.HISTORY_INFO ];
			
			if( DS.isfam( DS.K14 ) || DS.isDevice( DS.K16 ) )
								( starterCMD as Array ).unshift( CMD.CH_COM_LINK );  
			
			popup = PopUp.getInstance();
		//	servant = new HistorySaverServant([bXLSpageAll, bTXTpageAll]);
			
			width = 1080;
			height = 200;
			
			historyRec();
		}
		override public function close():void
		{
			if(!this.visible)
				return;
			super.close();

			HIS_MAX_STRUCTURES = 0;
			
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.onNeedPage, getPageListener );
			ResizeWatcher.removeDependent(this);
			servant.halt();
			if( timerDeleting ) {
				timerDeleting.stop();
				timerDeleting.removeEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
				timerDeleting = null;
			}
		}
		override public function open():void
		{
			super.open();
			KeyWatcher.add(this);
			ResizeWatcher.addDependent(this);
			ErrorHandler.PROTOCOL_CMD_NOT_EXIST
		}
		override public function put(p:Package):void
		{
			
			switch( p.cmd )
			{
				case CMD.CH_COM_LINK:
					getPage(1);
					
					break;
				case CMD.HISTORY_VER:
					
					loadSequence();
					
					break;
				case CMD.HISTORY_INFO:
					
					
					localResize(ResizeWatcher.lastWidth,ResizeWatcher.lastHeight);
					bClearHistory.disabled = false;
					// Обновляем информацию о реальном количестве структур
					
					HIS_LAST_STRUCTURE = p.getStructure()[0];
					HIS_MAX_STRUCTURES = p.getStructure()[1];
					if (!servant.READING)
						tAmount.setCellInfo( HIS_MAX_STRUCTURES );
					
					OPERATOR.getSchema( HISTORY_REC_CMD ).StructCount = HIS_MAX_STRUCTURES;
					loadSequence();
					break;
			}
		}
		protected function getHeader():Header
		{
			return new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
				{label:loc("his_object_num"), align:"center", xpos:195}, {label:loc("his_alarm_code"), align:"center", xpos:230+49-9}, {label:loc("his_event"), xpos:350-4},
				{label:loc("his_partition"), xpos:420+173+13+1},{label:loc("his_zone_user"), align:"center", xpos:480+183},{label:loc("his_direction"), xpos:535+190},
				{label:loc("his_cid"), xpos:650+212+2} ], {size:11} );
		}
		protected function historyRec():void
		{
			HISTORY_REC_CMD = CMD.HISTORY_REC;
		}
		protected function loadSequence():void
		{
			
			if( !OPERATOR.dataModel.getData( CMD.HISTORY_VER ) ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_VER, put ));
				return;
			} else
				///FIXME: Debug value! Remove it now!
				//HIS_HARD_MAX_STRUCTURES = OPERATOR.dataModel.getData( CMD.HISTORY_VER )[0][1];
				HIS_HARD_MAX_STRUCTURES = 8192;//OPERATOR.dataModel.getData( CMD.HISTORY_VER )[0][1];
		
			
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onNeedPage, getPageListener );
			
			
			if( !OPERATOR.dataModel.getData( CMD.CH_COM_LINK ) )
				RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_LINK, put ));
			else
				getPage(1);
		}
		private function updateInfo(p:Package):void
		{
			if ( p.cmd == CMD.HISTORY_INFO ) {  
				
				HIS_LAST_STRUCTURE = p.getStructure()[0];
				HIS_MAX_STRUCTURES = p.getStructure()[1];
				OPERATOR.getSchema( HISTORY_REC_CMD ).StructCount = HIS_MAX_STRUCTURES;
				if (!servant.READING)
					tAmount.setCellInfo( HIS_MAX_STRUCTURES );
				getPage( HIS_LAST_PAGE_REQUEST );
			}
		}
			
		private function assembler(p:Package):void
		{
			
			if (this.visible) {
				var start_line:int = (HIS_LAST_PAGE_REQUEST-1)*CLIENT.HISTORY_LINES_PER_PAGE;
				var darr:Array = p.data.slice();
				var len:int = darr.length;
				
				for( var i:int=0; i<len; ++i ) {
					var struc:int = HIS_STRUCTURES_REQUESTED.shift();
					HIS_SEND_DATA.push( darr[i] );
				}
				
				
				if(HIS_STRUCTURES_REQUESTED.length==0) {
					
					len = HIS_SEND_DATA.length;
					for(var n:int=start_line; n<len; n++) {
						HIS_SEND_DATA[n][21] = HIS_MAX_STRUCTURES - n;
					}
					
					var pr:Package = new Package;
					
					HIS_SEND_DATA.sortOn( "0", Array.NUMERIC );
					HIS_SEND_DATA = HIS_SEND_DATA.reverse();
					
					pr.data = HIS_SEND_DATA.concat( new Array( HIS_MAX_STRUCTURES - HIS_SEND_DATA.length ) );
					
					
					list.put( pr, getClass() );
					load(false);
				}
			}
		}
		protected function getPageListener(ev:GUIEvents):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INFO, updateInfo));
			HIS_LAST_PAGE_REQUEST = int(ev.getData()); 
			load(true);
		}
		
		protected function getPage(page:int):void
		{
			if( HIS_MAX_STRUCTURES == 0 ) {
				var p:Package = new Package;
				p.data = new Array;
				list.put( p, getClass() );
				load(false);
				return;
			}
			HIS_LAST_PAGE_REQUEST = page;
			
			loadStart();
			
			
			var start_line:int = (page-1)*CLIENT.HISTORY_LINES_PER_PAGE;
			HIS_SEND_DATA = new Array;
			HIS_SEND_DATA.length = start_line;
			
			var left:int=CLIENT.HISTORY_LINES_PER_PAGE + start_line;
			if (HIS_MAX_STRUCTURES - start_line < CLIENT.HISTORY_LINES_PER_PAGE )
				left = HIS_MAX_STRUCTURES;// + start_line;
		
			var s:int;
			HIS_STRUCTURES_REQUESTED = [];
			
			
			for( var i:int=start_line; i<left; ++i) {
				
				
				
				if ( HIS_LAST_STRUCTURE - i < 1 )
					s = HIS_LAST_STRUCTURE + HIS_HARD_MAX_STRUCTURES - i;
				else
					s = HIS_LAST_STRUCTURE - i;
					
				
				HIS_STRUCTURES_REQUESTED.push(int(s)); 
				
				
				RequestAssembler.getInstance().fireEvent( new Request( HISTORY_REC_CMD, assembler, s ));
				
				
			}
			
			
			
			
			
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			list.height = h - 110;
			var pos:int = h - 110;
			
			bXLSpageAll.y = pos + 40;
			bTXTpageAll.y = pos + 65;
			
			bClearHistory.y = pos + 40;
			bGatherHistory.y = pos + 65;
			tAmount.y = pos + 65;
		}
		private function clear():void
		{
			
			popup.construct( PopUp.wrapHeader("his_do_delete"), PopUp.wrapMessage("his_time_deleting"), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete,doCancel] );
			popup.open();
		}
		private function doDelete():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear, 1 ,[HIS_DELETE] ));
		}
		private function doCancel():void
		{
			bClearHistory.disabled = false;
			popup.close();
		}
		private function doClear(p:Package):void
		{
			
			if (p.success ) {
				popup.construct( PopUp.wrapHeader("his_wait_for_delete"), PopUp.wrapMessage("his_time_deleting") );
				popup.open();
				loadStart();
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
				TaskManager.callLater(startClear,askDelay);
				RequestAssembler.getInstance().doPing(false);
			}
		}
		private function startClear():void
		{
			RequestAssembler.getInstance().fireEvent(new Request( CMD.HISTORY_DELETE, processState ));
			if (!timerDeleting) {
				timerDeleting = new Timer( CLIENT.HIS_DELETE_TIMEOUT, 1 );
				timerDeleting.addEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
				timerDeleting.reset();
				timerDeleting.start();
			}
			initSpamTimer( CMD.HISTORY_DELETE );
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if(p.getStructure()[0] == HIS_DELETE_SUCCESS && stateRequestTimer) {
				if (timerDeleting) {
					timerDeleting.stop();
					timerDeleting.removeEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
					timerDeleting = null;
				}
				deactivateSpamTimer();
				CLIENT.ALWAYS_TRY = false;
				
				bClearHistory.disabled = false;
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
				load(false);
				RequestAssembler.getInstance().doPing(MISC.DEBUG_DO_PING==1);
				popup.close();
				list.selectPage( 1 );
			}
		}
		private function deleteIncomplete(ev:TimerEvent):void
		{
			timerDeleting.stop();
			timerDeleting.removeEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
			timerDeleting = null;
			
			bClearHistory.disabled = false;
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedPage, {"getData":1});
			load(false);
			RequestAssembler.getInstance().clearStackLater();
			
			popup.construct(PopUp.wrapHeader("sys_error"), PopUp.wrapMessage("his_not_deleted"),PopUp.BUTTON_OK);
			
			RequestAssembler.getInstance().doPing(MISC.DEBUG_DO_PING==1);
		}
		protected function getHistoryExportHeader():Array
		{
			return [loc("his_exp_index"),loc("his_exp_date"),loc("his_exp_object"),loc("his_exp_alarm_code"),
				loc("his_exp_event"), loc("his_exp_part"), loc("his_exp_zone_user"), loc("his_exp_direction"),loc("his_exp_cid")];
		}
		private function onButton(num:int):void
		{
			var key:String;
			var p:String;
			var bytes:ByteArray;
			
			switch(num) {
				case XLS:	// xls page
				case PDF: // pdf page
				case TXT:
					var res:Array = servant.getFieldData();
					
					var book:Object = new Object;
					for( key in res) {
						book[key] = new Object;
						for( p in res[key]) {
							book[key][p] = res[key][p];
							
							
						}
					}
					var date:Date = new Date;
					var filename:String = "history_export_"+SERVER.VER_FULL+"_"+date.date+"."+int(date.month+1)+"."+date.fullYear;
					var header:Array = getHistoryExportHeader();
					
					
					switch(num) {
						case XLS:
							bytes = (new XLSServant).compile(header,book);
							filename += ".xlsx";
							break;
						case PDF:
							bytes = (new PDFServant).compile(header,book,HASH_PDF_XPOS, 8);
							filename += ".pdf";
							break;
						case TXT:
							
							var a:Array = [];
							for( key in res) {
								a[key] = new Array;
								for( p in res[key]) {
									a[key][p] = res[key][p];
								}
							}
							
							bytes = (new TXTServant).compile(header,a);
							filename += ".txt";
							break;
					}
					FileBrowser.getInstance().save(bytes, filename);
					break;
				case DELETE:	// clear history
					popup.construct( PopUp.wrapHeader("his_do_delete"), PopUp.wrapMessage("his_time_deleting"), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete,doCancel] );
					popup.open();
					break;
				case START:
					var rq:int = int(tAmount.getCellInfo());
					var max:int = HIS_MAX_STRUCTURES - (HIS_LAST_PAGE_REQUEST-1)*CLIENT.HISTORY_LINES_PER_PAGE;
					if( rq > max )
						rq = max;
					servant.start( rq, HIS_LAST_PAGE_REQUEST, HIS_MAX_STRUCTURES, HIS_HARD_MAX_STRUCTURES, HIS_LAST_STRUCTURE );
					if (!esupporter)					
						esupporter = new HistoryErrorSupporter(acidentStopLoading);
					RequestAssembler.getInstance().activeSupporter(esupporter);
					break;
			}
		}
		public function onKeyUp(ev:KeyboardEvent):void
		{
			if (stage.focus == tAmount.getFocusable() && ev.keyCode == KEYS.Enter ) {
				onButton(START);
			}
		}
		protected function getClass():Class
		{
			return null;
		}
		private function load(b:Boolean):void
		{
			if (b) {
				loadStart();
				TabOperator.getInst().block = true;
				//blockNavi = true;
				blockNaviSilent = true;
			} else {
				loadComplete();
				TabOperator.getInst().block = false;
				blockNaviSilent = false;
			}
		}
		private function acidentStopLoading():void
		{
			servant.halt();
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
		}
	}
}
import components.interfaces.IActiveErrorSupporter;

class HistoryErrorSupporter implements IActiveErrorSupporter
{
	private var fstop:Function;
	
	public function HistoryErrorSupporter(f:Function)
	{
		fstop = f;
	}
	public function handle(e:int):void
	{
		fstop();
	}
}