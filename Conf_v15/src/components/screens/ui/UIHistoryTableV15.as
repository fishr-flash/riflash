package components.screens.ui
{
	//	+HISTORY_ENABLE=1,1
	
	/** STANDART VOYAGER HISTORY 2.0 	*/
	
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import avmplus.getQualifiedClassName;
	
	import components.abstract.HistoryDataProvider;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.HistoryExporterKML;
	import components.abstract.servants.HistorySaverVyagerServant;
	import components.abstract.servants.HistoryTableServant;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.PDFVoyagerServant;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TXTServant;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.XLSServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.FileBrowser;
	import components.gui.MHistoryTable;
	import components.gui.PopUp;
	import components.gui.PopWindow;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.triggers.VisualButton;
	import components.gui.visual.HistoryNaviPanel;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.THistoryColumnSelector;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.GuiLib;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class UIHistoryTableV15 extends UI_BaseComponent implements IResizeDependant
	{
		private const XLS:int = 1;
		private const PDF:int = 2;
		private const DELETE:int = 3;
		private const START:int = 6;
		private const TXT:int = 7;
		private const KML:int = 8;
		private const TIME_DELAY_DELETE_HISTORY:int = 3000;
		private const TIME_DELAY_REQUEST_RESULT_DELETE:int = 1000;
		
		private const HASH_PDF_XPOS:Object = {0:5, 1:65, 2:175, 3:255, 4:330, 5:460+70, 6:510+70, 7:595+70, 8:670+70, 9:780+70};
		
		private var bExport:TextButton;
		private var bClearHistory:TextButton;
		private var bGatherHistory:TextButton;
		private var tAmount:FormString;
		
		private var cbSource:FSComboBox;
		
		private var servant:HistorySaverVyagerServant;
		private var selector:THistoryColumnSelector;
		
		public var HIS_LAST_INDEX_N1:uint;
		private var HIS_LAST_PAGE_REQUEST:uint;
		public var HIS_FIRST_INDEX_N2:Number;
		private var HIS_BLOCK_SIZE_BYTE:int;
		private const HIS_CMD_BLOCK_SIZE_BYTE:int=128;
		
		private var his_total_records:uint;
		private var his_total_pages:uint;
		
		public var REQUEST_BLOCKS:Array;
		private var REQUESTED_LAST_INDEX:uint;
		
		private var shared:Vector.<String>;	// для создания sharedStrings в xlsx
		private var shared_color_map:Vector.<String>;
		private var shared_count:int;		// макс длина строки для sharedStrings в xlsx
		
		private var TOTAL_MEMORY_REQUESTED:Boolean = false;
		private var HIS_BLOCK_SIZE_BYTE_REQUESTED:Boolean = false;
		private var JUST_OPENED:Boolean = false;;
		
		private var ftable:MHistoryTable;
		private var tservat:HistoryTableServant;
		private var cont:Canvas;
		private var bGear:VisualButton;
		private var npanel:HistoryNaviPanel;
		private var whitepixel:UIComponent;
		private var timerIdleDeleteHistory:Timer;
		
		public function UIHistoryTableV15()
		{
			super();
			
			CLIENT.HISTORY_LINES_PER_PAGE = 64;
			
			cont = new Canvas;
			addChild( cont );
			cont.x = 10;
			cont.y = 10;
			
			tservat = new HistoryTableServant;
			
			
			
			ftable = new MHistoryTable(tservat.getAdapter());
			cont.addChild( ftable );
			ftable.width = 200;
			ftable.height = 25*66;
			ftable.visible = false;
			
			whitepixel = new UIComponent;
			cont.addChild( whitepixel );
			
			globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT;
			
			FLAG_SAVABLE = false; 
			cbSource = createUIElement( new FSComboBox, 0, loc("his_export_format"), onExportType, 1,
				UTIL.getComboBoxList( [ [XLS, "XLS"],[PDF,"PDF"]] ) ) as FSComboBox;
//				UTIL.getComboBoxList( [ [XLS, "XLS"],[PDF,"PDF"],[TXT, "TXT"],[KML, "KML"]] ) ) as FSComboBox;
			attuneElement(125,100,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbSource.setCellInfo(XLS);
			cbSource.focusorder = 17;
			cbSource.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			cbSource.x = globalX;
			FLAG_SAVABLE = true;
			
			globalX += 245;
			
			bGatherHistory = new TextButton;
			bGatherHistory.setUp( loc("his_read_amount_of_lines"), onButton, START);
			bGatherHistory.x = globalX;
			addChild( bGatherHistory );
			bGatherHistory.focusorder = 20;
			bGatherHistory.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			bGatherHistory.visible = false;
			
			globalX += 140;
			
			FLAG_SAVABLE = false;
			tAmount = new FormString;
			tAmount.setWidth(60);
			tAmount.attune( FormString.F_EDITABLE + FormString.F_OFF_KEYBOARD_REACTIONS );
			addChild( tAmount );
			tAmount.x = globalX;
			tAmount.focusorder = 19;
			tAmount.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			tAmount.restrict("0-9",6);
			
			globalX += 70;
			
			bExport = new TextButton;
			bExport.setUp( loc("his_do_export"), onExport)
			bExport.x = bGatherHistory.x;//globalX;
			addChild( bExport );
			
			globalX += 100;
			
			bClearHistory = new TextButton;
			bClearHistory.setUp( loc("his_clear_history"), clear)
			bClearHistory.x = globalX;
			addChild( bClearHistory );
			bClearHistory.width = 137;
			
			globalX += 100;
			
			servant = new HistorySaverVyagerServant(disableExport);
			
			bGear = new VisualButton( GuiLib.cGear );
			addChild( bGear );
			bGear.y = 12;
			bGear.setUp( "", onTogle );

			npanel = new HistoryNaviPanel;
			addChild( npanel );
			npanel.x = 10;
			
			selector = new THistoryColumnSelector(refresh);
			addChild( selector );
			//selector.x = ResizeWatcher.lastWidth - (selector.width + 40);
			selector.y = 10;
			
			/***	Удаление	**********/
			popup = PopUp.getInstance();
			
			REQUEST_BLOCKS = new Array;
			
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.EVOKE_TOGLE, onTogle );
			
			this.width = 840;
			this.height = 300;
			
			
		}
		override public function open():void
		{
			// Требуется обнулить переменные для загрузки
			JUST_OPENED = true;
			TOTAL_MEMORY_REQUESTED = false;
			HIS_BLOCK_SIZE_BYTE_REQUESTED = false;
			
			super.open();
			popup.PARAM_CLOSE_ITSELF = false;
			ResizeWatcher.addDependent(this);
			
			if (!OPERATOR.dataModel.getData(CMD.CONNECT_SERVER))
				RequestAssembler.getInstance().fireEvent( new Request(CMD.CONNECT_SERVER));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.HISTORY_INDEX,put));
			
			npanel.page_current = 1;
			KeyWatcher.add(npanel);
		}
		override public function close():void
		{
			super.close();
			HIS_BLOCK_SIZE_BYTE = 0;
			HIS_LAST_PAGE_REQUEST = 0;
			ResizeWatcher.removeDependent(this);
			doCancel();
			servant.halt();
			selector.close(false);
			KeyWatcher.remove(npanel);
		}
		override public function put(p:Package):void
		{
			popup.close();
			
			switch(p.cmd) {
				case CMD.HISTORY_INDEX:
					HIS_LAST_INDEX_N1 = p.getStructure()[0];
					HIS_FIRST_INDEX_N2 = p.getStructure()[1];
					
					dtrace("HIS_LAST_INDEX_N1="+HIS_LAST_INDEX_N1 );
					dtrace("HIS_FIRST_INDEX_N2="+HIS_FIRST_INDEX_N2 );
					
					load();
					break;
				case CMD.HISTORY_SIZE:
					HistoryDataProvider.TOTAL_MEMORY = p.getStructure()[0];
					dtrace("TOTAL_MEMORY="+HistoryDataProvider.TOTAL_MEMORY );
					
					if ( HistoryDataProvider.TOTAL_MEMORY > 0 )
						load();
					else
						loadComplete();
					break;
				case CMD.HISTORY_SELECT_PAR:
					var arr:Array = HistoryDataProvider.caclHistoryBlockSize(p); 
					selector.init();
					servant.register(HistoryDataProvider.HIS_COLLAPSED_PARAMS,HistoryDataProvider.HIS_PERBLOCK_PARAMS);
					
					ftable.headers = tservat.generateHeader();
					ftable.width = tservat.getWidth();
					
					HIS_BLOCK_SIZE_BYTE = arr[0];
					dtrace("HIS_BLOCK_SIZE_BYTE="+HIS_BLOCK_SIZE_BYTE );
					if (HIS_BLOCK_SIZE_BYTE > 0)
						load();
					else {
						dtrace("HistoryDataProvider.TOTAL_MEMORY("+HistoryDataProvider.TOTAL_MEMORY+")/HIS_CMD_BLOCK_SIZE_BYTE("+HIS_CMD_BLOCK_SIZE_BYTE+") меньше 1, страница истории не может загрузиться");
						loadComplete();
					}
					break;
				case CMD.HISTORY_BLOCK:
					startCalculation();
					break;
			}
			function load():void
			{
				var complete:Boolean = true;
				
				if (HistoryDataProvider.TOTAL_MEMORY == 0 ) {
					if (!TOTAL_MEMORY_REQUESTED) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_SIZE, put ) );
						TOTAL_MEMORY_REQUESTED = true;
					}
					complete = false;
				}
				if( HIS_BLOCK_SIZE_BYTE == 0 ) {
					if (!HIS_BLOCK_SIZE_BYTE_REQUESTED) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_SELECT_PAR, put ));
						HIS_BLOCK_SIZE_BYTE_REQUESTED = true;
					}
					complete = false;
				}
				if (complete)
					startCalculation();
			}
		}
		private function refresh():void
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
			
			ftable.headers = tservat.generateHeader();
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INDEX, put));
			HIS_LAST_PAGE_REQUEST = npanel.page_current;
		}
		private function startCalculation():void
		{
			if( HIS_LAST_PAGE_REQUEST == 0 )
				HIS_LAST_PAGE_REQUEST = 1;
			
			his_total_records = HIS_LAST_INDEX_N1 - HIS_FIRST_INDEX_N2 + 1;
			var RECORDS_PER_PAGE:int = his_total_records < CLIENT.HISTORY_LINES_PER_PAGE ? his_total_records : CLIENT.HISTORY_LINES_PER_PAGE;
			his_total_pages = his_total_records/RECORDS_PER_PAGE;
			
			var request_from:int = HIS_LAST_INDEX_N1-(HIS_LAST_PAGE_REQUEST*RECORDS_PER_PAGE) + 1;
			/*if( request_from < 1)
				request_from = 1;*/
			RequestAssembler.getInstance().fireEvent( new Request(CMD.SET_HISTORY_INDEX, null, 1, [request_from]));
			
			var blocks_request_amount:int = Math.ceil((HIS_BLOCK_SIZE_BYTE*RECORDS_PER_PAGE)/128);
				
			RequestAssembler.getInstance().fireReadSequence( CMD.HISTORY_BLOCK, assembler, blocks_request_amount );
		}
		private function assembler(p:Package):void
		{
			if (JUST_OPENED) {
				JUST_OPENED = false;
				if (HistoryDataProvider.isAtleast1Invisible()) {
					var popWindow:PopWindow = PopWindow.getInst();
					popWindow.construct( "his_table_not_shown_fully", 
						selector.reset );
					popWindow.open();
				}
			}
			
			var bytearray:Array = [];
			var len:uint = p.length;
			for(var i:int=0; i<len; ++i){
				bytearray = bytearray.concat( p.data[i] ); 
			}
			
			bytearray.length = (his_total_records*HIS_BLOCK_SIZE_BYTE);
			
			var lines:Array = new Array;
			var HISTORY_SHIFT:uint = HIS_FIRST_INDEX_N2 - 1;
			
			var total:int = CLIENT.HISTORY_LINES_PER_PAGE;
			if (servant.isReading)
				total = int(tAmount.getCellInfo());
			else
				lines.length = (HIS_LAST_PAGE_REQUEST-1)*CLIENT.HISTORY_LINES_PER_PAGE;
			
			var sh:int = 0;
			
			if (p.length > 0) {
				for( var k:int=0; k<total; ++k ) {
					lines.push(bytearray.slice( sh, sh + HIS_BLOCK_SIZE_BYTE ));
					sh += HIS_BLOCK_SIZE_BYTE;
				}
			}
			
			var assemblege:Package = new Package;
			assemblege.cmd = CMD.HISTORY_BLOCK;
			assemblege.data = lines;
			
			lines.length;
			
			if (servant.isReading)
				servant.put(lines);
			else {
				
			//	var a:Array = assemblege.data.slice((npanel.page_current-1)*CLIENT.HISTORY_LINES_PER_PAGE,npanel.page_current*CLIENT.HISTORY_LINES_PER_PAGE);
				ftable.put( tservat.getContent( lines.reverse() ));
				ftable.headers = tservat.getHeader();
				ftable.width = tservat.getWidth();
				
				npanel.update( his_total_records );
				
				whitepixel.graphics.clear();
				whitepixel.graphics.beginFill(COLOR.WHITE);
				whitepixel.graphics.drawRect(0,0,ftable.width,1);
				
				callLater( ftable.resize );
				callLater( showtable );
			}
			
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onNeedPage, getPageListener );
			
			//			resize();
			loadComplete();
			if( !servant.isReading ) { 
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			}
		}
		private function showtable():void
		{
			ftable.visible = true;
		}
		private function getPageListener(ev:GUIEvents):void
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INDEX, put));
			HIS_LAST_PAGE_REQUEST = uint(ev.getData());
		}
		private function nextPage():void
		{
			var RECORDS_PER_PAGE:int = CLIENT.HISTORY_LINES_PER_PAGE;
			var total_history_lines:int = HIS_LAST_INDEX_N1 - HIS_FIRST_INDEX_N2;
			var total_pages:int = total_history_lines / RECORDS_PER_PAGE;
			
			if( HIS_LAST_PAGE_REQUEST < total_pages ) {
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
					{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
				//	RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INDEX, put));
				list.selectPage( HIS_LAST_PAGE_REQUEST+1 );
				//++;
			}
		}
		private function currentPage():void
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INDEX, put));
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if ( w-20 < this.width )
				cont.width = width;
			else
				cont.width = w - 20;
			
			bGear.x = w - (32+10);
			
			var pos:int = h - 35;
			cont.height = pos-65;
		/*	ftable.height = pos-65;
			ftable.width = w;*/
			
			npanel.y = pos - 35;
			
			bExport.y = pos;
			cbSource.y = pos;
			bClearHistory.y = pos;
			bGatherHistory.y = pos;
			tAmount.y = pos
		}
		private function clear():void
		{
			popup.construct( PopUp.wrapHeader("his_do_delete"), PopUp.wrapMessage("his_time_deleting"), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete,doCancel] );
			popup.open();
			bClearHistory.disabled = true;
		}
		private function doDelete():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, waiteDel, 1, [1] ));
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
		}
		private function doCancel():void
		{
			bClearHistory.disabled = false;
			popup.close();
		}
		
		private function waiteDel( p:Package ):void
		{
			
			if( popup.visible )
			{
				popup.close();
				
				
				timerIdleDeleteHistory = new Timer( TIME_DELAY_DELETE_HISTORY );
				timerIdleDeleteHistory.addEventListener(TimerEvent.TIMER, onTimeDelete );
				timerIdleDeleteHistory.start();
				
				return;
				
			}
			
			if( p.getParam( 1, 1 ) == 0x02 )
			{
				deleteComplete();
			}
			else
			{
				timerIdleDeleteHistory.reset();
				timerIdleDeleteHistory.delay = TIME_DELAY_REQUEST_RESULT_DELETE;
				timerIdleDeleteHistory.start();
				
			}
			
		}
		
		protected function onTimeDelete(event:TimerEvent):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, waiteDel, 1 ));
		}		
		
		
		private function deleteComplete():void
		{
			timerIdleDeleteHistory.removeEventListener(TimerEvent.TIMER, onTimeDelete );
			timerIdleDeleteHistory.stop();

			bClearHistory.disabled = false;
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedPage, {"getData":0x01});
			
		}
		private function onTogle(e:GUIEvents=null):void
		{
			selector.togle();
		}
		private function disableExport(b:Boolean):void
		{
			switch(int(cbSource.getCellInfo())) {
				case XLS:
				case PDF:
					bExport.disabled = false;
					bGatherHistory.disabled = true;
					tAmount.disabled = true;
					break;
				default:
					bExport.disabled = b;
					bGatherHistory.disabled = false;
					tAmount.disabled = false;
					break;
			}
		}
		private function onExportType():void
		{
			disableExport(servant.isExportButtonDisabled());
		}
		private function onExport():void
		{
			onButton(int(cbSource.getCellInfo()));
		}
		private function onButton(num:int):void
		{
			var bytes:ByteArray;
			var book:Object;
			switch(num) {
				case XLS:
				case PDF: 
				case TXT:  
				case KML: 
					//if (servant.isReading) {
					var res:Array = tservat.getExistingContent();
					book = new Object;
					for( var key:String in res) {
						book[key] = new Object;
						for( var p:String in res[key]) {
							book[key][p] = res[key][p];
						}
					}
					//}
					var h:String;
					var row:String;
					var column:String;
					var date:Date = new Date;
					var filename:String = "history_export_"+SERVER.VER_FULL+"_"+date.date+"."+int(date.month+1)+"."+date.fullYear;
					var header:Array = tservat.getHeaderLabels();
					switch(num) {
						case XLS:
							bytes = (new XLSServant).compile(header,book);
							filename += ".xlsx";
							break;
						case PDF:
							bytes = (new PDFVoyagerServant).compile(header,book);
							filename += ".pdf";
							break;
						case TXT:
							bytes = (new TXTServant).compile(header,servant.book);
							filename += ".txt";
							break;
						case KML:
							bytes = (new HistoryExporterKML).compile(header,servant.book);
							filename += ".kml";
							break;
					}
					FileBrowser.getInstance().save(bytes, filename);
					break;
				case START:
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
						{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INDEX, put));
					servant.start();
					//HIS_LAST_PAGE_REQUEST = uint(ev.getData());
					break;
			}
		}
	}
}