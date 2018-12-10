package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.PDFServant;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.XLSServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.PopUp;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptHistoryLine;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIHistoryBottom extends UI_BaseComponent implements IResizeDependant
	{
		public static const HIS_DELETE:int = 0x01;
		public static const HIS_DELETE_SUCCESS:int = 0x02;
		
		private var HIS_HARD_MAX_STRUCTURES:int = 0;
		private var HIS_MAX_STRUCTURES:int = 0;
		private var HIS_LAST_STRUCTURE:int = 0;
		private var HIS_LAST_PAGE_REQUEST:int = 0;	// хранится какая страница по счету была запрошена из Opt
		private var HIS_STRUCTURES_REQUESTED:Array;	// хранятся запрошенные структуры
		private var HIS_SEND_DATA:Array;			// собирается информация для передачи в Opt
		
		private var bXLSpage:TextButton;
		private var bPDFpage:TextButton;
		private var bClearHistory:TextButton;

		private const HASH_PDF_XPOS:Object = {0:5, 1:65, 2:175, 3:255, 4:330, 5:460, 6:510, 7:595, 8:670, 9:780};
		
		private var shared:Vector.<String>;	// для создания sharedStrings в xlsx
		private var shared_color_map:Vector.<String>;
		private var shared_count:int;		// макс длина строки для sharedStrings в xlsx
		
		private const XLS:int = 1;
		private const PDF:int = 2;
		private const DELETE:int = 3;
		
		private var timerDeleting:Timer;
		public function UIHistoryBottom()
		{
			super();
			
			var header:Header;
			if( DS.release >= 7 ) {
				header = new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
					{label:loc("his_object_num"), align:"center", xpos:160+54}, {label:loc("his_alarm_code"), align:"center", xpos:230+49}, {label:loc("his_event"), xpos:350},
					{label:loc("his_exp_part"), xpos:420+173+13},{label:loc("his_zone_user"), align:"center", xpos:480+183},{label:loc("his_sent"), xpos:535+190},
					{label:loc("his_cid"), xpos:650+212},{label:"",align:"center", xpos:755+192},
					{label:loc("his_power_supply"), width:150, align:"center", xpos:650+212+2+61} ], {size:11} );
			} else {
				header = new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
					{label:loc("his_object_num"), align:"center", xpos:160+54}, {label:loc("his_alarm_code"), align:"center", xpos:230+49}, {label:loc("his_event"), xpos:350},
					{label:loc("his_exp_part"), xpos:420+173+13},{label:loc("his_zone_user"), align:"center", xpos:480+183},{label:loc("his_sent"), xpos:535+190},
					{label:loc("his_cid"), xpos:650+212},{label:"",align:"center", xpos:755+192} ], {size:11} );
			}
			
			addChild( header );
			header.x = 20;
			header.y = 15;
			
			list = new OptList
			addChild( list );
			list.y = 50;
			list.width = 660+199 + 197;
			list.attune( CMD.HISTORY_REC,0, OptList.PARAM_DRAW_SEPARATOR | OptList.PARAM_DRAW_CHECKMATE | OptList.PARAM_DRAW_PAGES | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED, {linesPerPage:CLIENT.HISTORY_LINES_PER_PAGE} );
			
			bXLSpage = new TextButton;
			bXLSpage.x = 10;
			bXLSpage.setUp( loc("his_export_opened_xls"), onButton, XLS);
			addChild( bXLSpage );
			
			bPDFpage = new TextButton;
			bPDFpage.x = 10;
			bPDFpage.setUp( "", onButton, PDF);
			addChild( bPDFpage );

			bClearHistory = new TextButton;
			bClearHistory.x = 380;
			bClearHistory.setUp( loc("his_clear_history"), onButton, DELETE);
			addChild( bClearHistory );
			
			starterCMD = CMD.HISTORY_INFO;
			popup = PopUp.getInstance();
			
			width = 1080;
			height = 200;
		}
		override public function close():void
		{
			if(!this.visible)
				return;
			super.close();
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.onNeedPage, getPageListener );
			ResizeWatcher.removeDependent(this);
			
			if( timerDeleting ) {
				timerDeleting.stop();
				timerDeleting.removeEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
				timerDeleting = null;
			}
		}
		override public function open():void
		{
			super.open();
			ResizeWatcher.addDependent(this);
		}
		override public function put(p:Package):void
		{
			RequestAssembler.getInstance().doPing(false);
			switch( p.cmd )
			{
				case CMD.HISTORY_VER:
					loadSequence();
					break;
				case CMD.HISTORY_INFO:
					localResize(ResizeWatcher.lastWidth,ResizeWatcher.lastHeight);
					bClearHistory.disabled = false;
					// Обновляем информацию о реальном количестве структур
					HIS_LAST_STRUCTURE = p.getStructure()[0];
					HIS_MAX_STRUCTURES = p.getStructure()[1];
					
					OPERATOR.getSchema( CMD.HISTORY_REC ).StructCount = HIS_MAX_STRUCTURES;
					loadSequence();
					break;
			}
		}
		private function loadSequence():void
		{
			if( !OPERATOR.dataModel.getData( CMD.HISTORY_VER ) ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_VER, put ));
				return;
			} else
				HIS_HARD_MAX_STRUCTURES = OPERATOR.dataModel.getData( CMD.HISTORY_VER )[0][1];
						
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onNeedPage, getPageListener );
	
			getPage(1);
		}
		private function updateInfo(p:Package):void
		{
			if ( p.cmd == CMD.HISTORY_INFO ) {  
				HIS_LAST_STRUCTURE = p.getStructure()[0];
				HIS_MAX_STRUCTURES = p.getStructure()[1];
				OPERATOR.getSchema( CMD.HISTORY_REC ).StructCount = HIS_MAX_STRUCTURES;
				
				getPage( HIS_LAST_PAGE_REQUEST );
			}
		}
			
		private function assembler(p:Package):void
		{
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
				
				HIS_SEND_DATA.length = HIS_MAX_STRUCTURES;
				var p:Package = new Package;
				p.data = HIS_SEND_DATA;
				
				list.put( p, OptHistoryLine );
				loadComplete();
			}
		}
		private function getPageListener(ev:GUIEvents):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INFO, updateInfo));
			HIS_LAST_PAGE_REQUEST = int(ev.getData()); 
			loadStart();
		}
		
		private function getPage(page:int):void
		{
			if( HIS_MAX_STRUCTURES == 0 ) {
				var p:Package = new Package;
				p.data = new Array;
				list.put( p, OptHistoryLine );
				loadComplete();
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
			for( var i:int=start_line; i<left; ++i) {
				if ( HIS_LAST_STRUCTURE - i < 1 )
				//	s = HIS_LAST_STRUCTURE + HIS_MAX_STRUCTURES - i;
					s = HIS_LAST_STRUCTURE + HIS_HARD_MAX_STRUCTURES - i;
				else
					s = HIS_LAST_STRUCTURE - i;
				
				if(!HIS_STRUCTURES_REQUESTED)
					HIS_STRUCTURES_REQUESTED = [];
				HIS_STRUCTURES_REQUESTED.push(int(s)); 
				trace( "request "+s)
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_REC, assembler, s ));
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			list.height = h - 110;
			var pos:int = h - 110;
			
			bXLSpage.y = pos + 40;
			bPDFpage.y = pos + 65;

			bClearHistory.y = pos + 40;
		}
		private function doDelete():void
		{
			popup.construct( PopUp.wrapHeader("his_wait_for_delete"), PopUp.wrapMessage("his_time_deleting") );
			popup.open();
			
			blockNavi = true;
			loadStart();
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
				if (!timerDeleting) {
					timerDeleting = new Timer( CLIENT.HIS_DELETE_TIMEOUT, 1 );
					timerDeleting.addEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
					timerDeleting.reset();
					timerDeleting.start();
				}
				initSpamTimer( CMD.HISTORY_DELETE );
			}
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if(p.getStructure()[0] == HIS_DELETE_SUCCESS) {
				if (timerDeleting) {
					timerDeleting.stop();
					timerDeleting.removeEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
					timerDeleting = null;
				}
				deactivateSpamTimer();
				CLIENT.ALWAYS_TRY = false;
				
				bClearHistory.disabled = false;
				blockNavi = false;
				loadComplete();
				RequestAssembler.getInstance().doPing(true);
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
			blockNavi = false;
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedPage, {"getData":1});
			loadComplete();
			RequestAssembler.getInstance().clearStackLater();
			
			popup.construct(PopUp.wrapHeader("sys_error"), PopUp.wrapMessage("his_not_deleted"),PopUp.BUTTON_OK);
		}
		private function onButton(num:int):void
		{
			
			var bytes:ByteArray;
			switch(num) {
				case XLS:	// xls page
				case PDF: // pdf page
					var res:Array = list.getFieldData();
					
					
					var book:Object = new Object;
					for( var key:String in res) {
						book[key] = new Object;
						for( var p:String in res[key]) {
							book[key][p] = res[key][p];
						}
					}
					var date:Date = new Date;
					var filename:String = "history_export_"+SERVER.VER_FULL+"_"+date.date+"."+int(date.month+1)+"."+date.fullYear;
					var header:Array = [loc("his_exp_index"),loc("his_exp_date"),loc("his_exp_object"),loc("his_exp_alarm_code"),
						loc("his_exp_event"), loc("his_exp_part"), loc("his_exp_zone_user"), loc("his_sent"),loc("his_cid"),loc("his_exp_crc_error")];
					
					switch(num) {
						case XLS:
							
							bytes = (new XLSServant).compile(header,book);
							filename += ".xlsx";
							break;
						case PDF:
							bytes = (new PDFServant).compile(header,book,HASH_PDF_XPOS, 8);
							filename += ".pdf";
							break;
					}
					var fileRef:FileReference = new FileReference;
					fileRef.save(bytes, filename);
					break;
				case DELETE:	// clear history
					popup.construct( PopUp.wrapHeader("his_do_delete"), PopUp.wrapMessage("his_time_deleting"), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete,doCancel] );
					popup.open();
					break;
			}
		}
	}
}