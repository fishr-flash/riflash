package components.screens.ui
{
	//	+HISTORY_ENABLE=1,1
	
	/** STANDART VOYAGER HISTORY 2.0 	*/
	
	import flash.utils.ByteArray;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import components.abstract.GroupOperator;
	import components.abstract.HistoryDataProvider;
	import components.abstract.LOC;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.gearboxes.HistoryBox;
	import components.abstract.servants.HistoryExporterJSON;
	import components.abstract.servants.HistoryExporterKML;
	import components.abstract.servants.HistoryReceiver;
	import components.abstract.servants.HistorySaverVyagerServant;
	import components.abstract.servants.HistoryTableServant;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.PDFVoyagerServant;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TXTServant;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.XLSServant;
	import components.abstract.servants.primitive.ProgressSpy;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.FileBrowser;
	import components.gui.MHistoryTable;
	import components.gui.PopUp;
	import components.gui.PopWindow;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSDate;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.triggers.VisualButton;
	import components.gui.visual.HistoryDayReader;
	import components.gui.visual.HistoryNaviPanel;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.THistoryColumnSelector;
	import components.interfaces.IFormString;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.GuiLib;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class UIHistoryTable extends UI_BaseComponent implements IResizeDependant
	{
		private const XLS:int = 1;
		private const PDF:int = 2;
		private const DELETE:int = 3;
		private const START:int = 6;
		private const TXT:int = 7;
		private const KML:int = 8;
		private const JSON:int = 9;
		private const JSON_DATE:int = 10;
		private const JSON_INDEX:int = 11;
		
		private const TXT_MAX_LINES:int = 5000;
		
		private const HASH_PDF_XPOS:Object = {0:5, 1:65, 2:175, 3:255, 4:330, 5:460+70, 6:510+70, 7:595+70, 8:670+70, 9:780+70};
		
		private var bExport:TextButton;
		private var bClearHistory:TextButton;
		private var bGatherHistory:TextButton;
		private var tAmount:FormString;
		
		private var tHi:FormString;
		private var tLow:FormString;
		private var fHiSelect:FSDate;
		private var fLoSelect:FSDate;
		
		private var cbSource:FSComboBox;
		
		private var servant:HistorySaverVyagerServant;
		private var selector:THistoryColumnSelector;
		
		private var HIS_SHIFT_Q:uint;
		private var HIS_SHIFT_Q_BYTE:uint;
		private var HIS_LAST_PAGE_REQUEST:uint;
		private var HIS_TOTAL_BLOCKS:int;
		private var HIS_REAL_FIRST_BLOCK:Number;
		private var HIS_SECTOR_SHIFT:int;
		private var HIS_BLOCK_SHIFT:int;
		
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
		private var historyDayReader:HistoryDayReader;
		
		private var gearbox:HistoryBox;
		private var go:GroupOperator;
		private var gom:GroupOperator;
		private var btnsAnchor:int;
		
		public function UIHistoryTable()
		{
			super();
			
			gearbox = HistoryBox.access();
			
			cont = new Canvas;
			addChild( cont );
			cont.x = 10;
			cont.y = 10;
			
			tservat = new HistoryTableServant;
			
			ftable = new MHistoryTable(tservat.getAdapter());
			cont.addChild( ftable );
			ftable.width = 200;
			ftable.height = 200;
			ftable.visible = false;
			
			whitepixel = new UIComponent;
			cont.addChild( whitepixel );
			
			globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT;
			
			FLAG_SAVABLE = false; 
			if (DS.release >= 41) {
				cbSource = createUIElement( new FSComboBox, 0, loc("his_export_format"), onExportType, 1, 
					UTIL.getComboBoxList( [ [TXT, "TXT"],[KML, "KML"],[JSON, "JSON"],[JSON_DATE, "JSON" + " "+ loc("vhis_7")],[JSON_INDEX, "JSON" + " " +loc("vhis_4")]] ) ) as FSComboBox;
				
				historyDayReader = new HistoryDayReader(this, tservat);
			} else {
				cbSource = createUIElement( new FSComboBox, 0, loc("his_export_format"), onExportType, 1, 
					UTIL.getComboBoxList( [ [TXT, "TXT"],[KML, "KML"]] ) ) as FSComboBox;
			}
			attuneElement(125,100,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbSource.setCellInfo(TXT);
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
			
			globalX += 140;
			
			FLAG_SAVABLE = false;
			tAmount = new FormString;
			tAmount.setWidth(55);
			tAmount.attune( FormString.F_EDITABLE | FormString.F_OFF_KEYBOARD_REACTIONS );
			addChild( tAmount );
			tAmount.x = globalX;
			tAmount.focusorder = 19;
			tAmount.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			tAmount.restrict("0-9",6);
			
			go = new GroupOperator;
			go.add("0", tAmount );
			
			tHi = addField(false, FormString) as FormString;
			tLow = addField(true, FormString) as FormString;
			fHiSelect = addField(false, FSDate) as FSDate;
			fLoSelect = addField(true, FSDate) as FSDate;
			
			go.show("0");
			
			globalX += 110;
			
			bExport = new TextButton;
			bExport.setUp( loc("his_do_export"), onExport)
			bExport.x = globalX;
			addChild( bExport );
			
			gom = new GroupOperator;
			gom.add("0", bExport );
			
			btnsAnchor = globalX;
			
			globalX += 100;
			
			bClearHistory = new TextButton;
			bClearHistory.setUp( loc("his_clear_history"), clear)
			bClearHistory.x = globalX;
			addChild( bClearHistory );
			bClearHistory.width = 137;
			
			gom.add("0", bClearHistory );
			
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
			
			starterCMD = [CMD.HISTORY_INDEX];
			if (!OPERATOR.dataModel.getData(CMD.CONNECT_SERVER))
				(starterCMD as Array).splice( 0,0, CMD.CONNECT_SERVER );
			if (!OPERATOR.dataModel.getData(CMD.VER_INFO1))
				(starterCMD as Array).splice( 0,0, CMD.VER_INFO1);
			
			this.width = 950;
			this.height = 300;
		}
		private function addField(second:Boolean, cls:Class):IFormString
		{
			var t:FormString = new cls;
			
			if (t is FSDate) {
				go.add( JSON_DATE.toString(), t );
				t.setWidth(140);
				addChild( t );
				if (second)
					t.x = globalX + 160;
				else
					t.x = globalX;
			} else {
				go.add( JSON_INDEX.toString(), t );
				t.attune( FormString.F_EDITABLE | FormString.F_OFF_KEYBOARD_REACTIONS );
				t.setWidth(100);
				addChild( t );
				if (second)
					t.x = globalX + 120;
				else
					t.x = globalX;
			}
			t.focusorder = 19;
			t.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			t.restrict("0-9", String(int.MAX_VALUE).length );
			return t;
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
			
			npanel.page_current = 1;
			KeyWatcher.add(npanel);
		}
		override public function close():void
		{
			super.close();
			gearbox.HIS_BLOCK_SIZE_BYTE = 0;
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
					gearbox.HIS_LAST_INDEX_N1 = p.getStructure()[0];
					gearbox.HIS_FIRST_INDEX_N2 = p.getStructure()[1];
					
					dtrace("HIS_LAST_INDEX_N1="+gearbox.HIS_LAST_INDEX_N1 );
					dtrace("HIS_FIRST_INDEX_N2="+gearbox.HIS_FIRST_INDEX_N2 );
					
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
					
					gearbox.HIS_BLOCK_SIZE_BYTE = arr[0];
					//	HIS_TOTAL_BLOCKS = arr[1];
					HIS_TOTAL_BLOCKS = HistoryDataProvider.TOTAL_MEMORY/gearbox.HIS_CMD_BLOCK_SIZE_BYTE;
					dtrace("HIS_BLOCK_SIZE_BYTE="+gearbox.HIS_BLOCK_SIZE_BYTE );
					dtrace("HIS_TOTAL_BLOCKS="+HIS_TOTAL_BLOCKS );
					//HistoryDataProvider.TOTAL_MEMORY = HIS_TOTAL_BLOCKS*HIS_CMD_BLOCK_SIZE_BYTE;
					if (HIS_TOTAL_BLOCKS > 0)
						load();
					else {
						dtrace("HistoryDataProvider.TOTAL_MEMORY("+HistoryDataProvider.TOTAL_MEMORY+")/HIS_CMD_BLOCK_SIZE_BYTE("+gearbox.HIS_CMD_BLOCK_SIZE_BYTE+") меньше 1, страница истории не может загрузиться");
						
						loadComplete();
					}
					break;
				case CMD.HISTORY_BLOCK:
					gearbox.HIST_INDEX_IN_FIRST_BLOCK = getIndex(p.getStructure());
					dtrace("HIST_INDEX_IN_FIRST_BLOCK="+gearbox.HIST_INDEX_IN_FIRST_BLOCK );
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
				if( gearbox.HIS_BLOCK_SIZE_BYTE == 0 ) {
					if (!HIS_BLOCK_SIZE_BYTE_REQUESTED) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_SELECT_PAR, put ));
						HIS_BLOCK_SIZE_BYTE_REQUESTED = true;
					}
					complete = false;
				}
				if (complete)
					checkHistoryCycles();
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
		private function checkHistoryCycles():void
		{
			// Если N1 - N2 >= количесва записей всего значит возможно история была записана по кругу
			if( gearbox.HIS_LAST_INDEX_N1 - gearbox.HIS_FIRST_INDEX_N2 + 1 >= Math.floor(HistoryDataProvider.TOTAL_MEMORY/gearbox.HIS_BLOCK_SIZE_BYTE) )
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_BLOCK, put, 1));
			else {
				gearbox.HIST_INDEX_IN_FIRST_BLOCK = gearbox.HIS_FIRST_INDEX_N2;
				startCalculation();
			}
		}
		private function startCalculation():void
		{
			// если запущено суточное вычитывание, движок истории трогать не надо
			if (historyDayReader && historyDayReader.working) {
				historyDayReader.init();
				return;
			}
			
			
			var forward_records:int = gearbox.HIS_LAST_INDEX_N1 - gearbox.HIST_INDEX_IN_FIRST_BLOCK;
			var backward_records:int = gearbox.HIST_INDEX_IN_FIRST_BLOCK - gearbox.HIS_FIRST_INDEX_N2;
			var block_with_last_index:int = Math.ceil(forward_records*gearbox.HIS_BLOCK_SIZE_BYTE/gearbox.HIS_CMD_BLOCK_SIZE_BYTE);
			var rest_bytes:int = HistoryDataProvider.TOTAL_MEMORY-Math.floor(HistoryDataProvider.TOTAL_MEMORY/gearbox.HIS_BLOCK_SIZE_BYTE)*gearbox.HIS_BLOCK_SIZE_BYTE;
			var block_with_first_index_bytes:int = HistoryDataProvider.TOTAL_MEMORY - (backward_records*gearbox.HIS_BLOCK_SIZE_BYTE+rest_bytes);
			var block_with_first_index:int = Math.ceil(block_with_first_index_bytes/gearbox.HIS_CMD_BLOCK_SIZE_BYTE);
			
			var RECORDS_PER_PAGE:int = CLIENT.HISTORY_LINES_PER_PAGE;
			
			var total_history_lines:int = gearbox.HIS_LAST_INDEX_N1 - gearbox.HIS_FIRST_INDEX_N2;
			var total_pages:int = total_history_lines / RECORDS_PER_PAGE;
			
			if( HIS_LAST_PAGE_REQUEST == 0 )
				HIS_LAST_PAGE_REQUEST = 1;
			
			REQUEST_BLOCKS.length = 0;
			var request_from:int = total_history_lines-(HIS_LAST_PAGE_REQUEST-1)*RECORDS_PER_PAGE;
			
			if (servant.isReading) {
				if (int(tAmount.getCellInfo())>TXT_MAX_LINES)
					tAmount.setCellInfo(TXT_MAX_LINES);
				RECORDS_PER_PAGE = int(tAmount.getCellInfo());
			} else
				tAmount.setCellInfo(total_history_lines > 5000 ? 5000 : total_history_lines);
			
			servant.total_history_lines = total_history_lines;
			
			var rblen:int=0;
			
			for(var i:int=0; i<RECORDS_PER_PAGE; ++i) {
				if ( total_history_lines < i || (request_from-i)<0 )
					break;
				dtrace( "надо запросить "+ (gearbox.HIS_FIRST_INDEX_N2+request_from-i) );
				getBlock( request_from-i );
				
				// если запись больше 128 байт, счетчик иногда пропускает один блок истории, эта функция нужна чтобы восполнять пробелы 
				rblen = REQUEST_BLOCKS.length;
				if (i > 0 && REQUEST_BLOCKS[rblen-1] != REQUEST_BLOCKS[rblen-2] - 1 )
					REQUEST_BLOCKS.splice(rblen-1,0,REQUEST_BLOCKS[rblen-1]+1);
			}
			
			dtrace("Запрос блоков "+REQUEST_BLOCKS.toString());
			HIS_SHIFT_Q = total_history_lines;
			
			var spy:ProgressSpy;
			if (servant.isReading)
				spy = servant.getSpy();
			RequestAssembler.getInstance().fireReadBlock( CMD.HISTORY_BLOCK, assembler, REQUEST_BLOCKS.reverse(), Request.NORMAL, Request.PARAM_DONT_CLEAN,spy);
		}
		
		private function getBlock(n:int):void
		{
			if (n<0)
				dtrace("ВНИМАНИЕ: В UiHistory.getBlock() пришли данные меньше 0!")
			
			var unique_index:uint = n+gearbox.HIS_FIRST_INDEX_N2;
			var shift:uint = getShift(unique_index);
			var value:uint;
			
			value = Math.ceil((shift*gearbox.HIS_BLOCK_SIZE_BYTE+gearbox.HIS_BLOCK_SIZE_BYTE)/gearbox.HIS_CMD_BLOCK_SIZE_BYTE);
			
			if( REQUEST_BLOCKS.length == 0 || REQUEST_BLOCKS[ REQUEST_BLOCKS.length - 1 ] != value )
				REQUEST_BLOCKS.push( value );
			value = Math.floor(shift*gearbox.HIS_BLOCK_SIZE_BYTE/gearbox.HIS_CMD_BLOCK_SIZE_BYTE+1);
			if( REQUEST_BLOCKS.length == 0 || (REQUEST_BLOCKS[ REQUEST_BLOCKS.length - 1 ] != value && value > 0 )  )
				REQUEST_BLOCKS.push( value );
			REQUESTED_LAST_INDEX = unique_index;
		}
		private function getShift(index:uint):uint
		{
			if (index >= gearbox.HIST_INDEX_IN_FIRST_BLOCK)
				return index - gearbox.HIST_INDEX_IN_FIRST_BLOCK;
			return (gearbox.HIS_LAST_INDEX_N1 - gearbox.HIST_INDEX_IN_FIRST_BLOCK) + (index - gearbox.HIS_FIRST_INDEX_N2) + 1;
		}
		private function getLocalByteShift(index:uint):uint
		{
			var shift:uint = getShift(index);
			var global_byte_shift:int = shift*gearbox.HIS_BLOCK_SIZE_BYTE;
			var lastShift:int = getShift(REQUESTED_LAST_INDEX);
			var local_byte_shift:int = global_byte_shift - ( Math.floor((getShift(REQUESTED_LAST_INDEX)*gearbox.HIS_BLOCK_SIZE_BYTE)/gearbox.HIS_CMD_BLOCK_SIZE_BYTE)*gearbox.HIS_CMD_BLOCK_SIZE_BYTE );
			if (local_byte_shift < 0)
				return (HistoryDataProvider.TOTAL_MEMORY + local_byte_shift);
			return local_byte_shift;
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
			// Error 1502 A script has executed for longer
			for(var i:int=0; i<len; ++i){
				bytearray = bytearray.concat( p.data[i] ); 
			}
			
			var lines:Array = new Array;
			var HISTORY_SHIFT:uint = gearbox.HIS_FIRST_INDEX_N2 - 1;
			
			var total:int = CLIENT.HISTORY_LINES_PER_PAGE;
			if (servant.isReading) {
				if (int(tAmount.getCellInfo())>TXT_MAX_LINES)
					tAmount.setCellInfo(TXT_MAX_LINES);
				total = int(tAmount.getCellInfo());
			} else
				lines.length = HIS_SHIFT_Q +1;
			if (p.length > 0) {
				for( var k:int=0; k<total; ++k ) {
					if ( gearbox.HIS_LAST_INDEX_N1 - (REQUESTED_LAST_INDEX-(total-1)+k) > -1 ) {
						var sh:int = getLocalByteShift( REQUESTED_LAST_INDEX+k );
						lines[gearbox.HIS_LAST_INDEX_N1 - (REQUESTED_LAST_INDEX+k)] = bytearray.slice( sh, sh + gearbox.HIS_BLOCK_SIZE_BYTE );
					}
				}
			}
			
			var assemblege:Package = new Package;
			assemblege.cmd = CMD.HISTORY_BLOCK;
			assemblege.data = lines;
			
			
			if (servant.isReading)
				servant.put(lines);
			else {
				
				var a:Array = assemblege.data.slice((npanel.page_current-1)*CLIENT.HISTORY_LINES_PER_PAGE,npanel.page_current*CLIENT.HISTORY_LINES_PER_PAGE);
				ftable.put( tservat.getContent( a ));
				ftable.headers = tservat.getHeader();
				ftable.width = tservat.getWidth();
				
				npanel.update( assemblege.data.length );
				
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
			var total_history_lines:int = gearbox.HIS_LAST_INDEX_N1 - gearbox.HIS_FIRST_INDEX_N2;
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
		private function getIndex(target:Array):uint
		{
			var index:uint = 4-1;
			var arr_index:uint = 0;
			var value:uint;
			for(var i:int=0; i<256; ++i ) {
				if (i==index) {
					value = target[i+HIS_BLOCK_SHIFT] | target[i+1+HIS_BLOCK_SHIFT] << 8 | target[i+2+HIS_BLOCK_SHIFT] << 16 | target[i+3+HIS_BLOCK_SHIFT] << 24;
					return value;
				} else {
					if( HistoryDataProvider.HIS_COLLAPSED_PARAMS[i] > 0 )
						arr_index++;
				}
			}
			return 0;
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if ( w-20 < this.width )
				cont.width = width;
			else
				cont.width = w - 20;
			
			bGear.x = w - 32;
			
			var pos:int = h - 45;
			cont.height = pos-65;
			ftable.height = pos-65;
			
			npanel.y = pos - 35;
			
			bExport.y = pos;
			cbSource.y = pos;
			bClearHistory.y = pos;
			bGatherHistory.y = pos;
			tAmount.y = pos;
			
			tHi.y = pos;
			tLow.y = pos;
			fHiSelect.y = pos;
			fLoSelect.y = pos;
			tLow.y = pos;
		}
		private function clear():void
		{
			popup.construct( PopUp.wrapHeader(LOC.loc("his_do_delete")), PopUp.wrapMessage(LOC.loc("his_time_deleting")), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete,doCancel] );
			popup.open();
			bClearHistory.disabled = true;
		}
		private function doDelete():void
		{
			//new HistoryDeletingBot( CLIENT.TIMER_EVENT_SPAM, VoyagerBot.getHistoryDeleteTimeOut(), deleteComplete, HistoryDeletingBot.HISTORY );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, deleteComplete, 1, [1] ));
			
			/*GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
			{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete ); = true;*/
		}
		private function doCancel():void
		{
			bClearHistory.disabled = false;
			popup.close();
		}
		private function deleteComplete(p:Package):void
		{
			bClearHistory.disabled = false;
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedPage, {"getData":1});
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
			var n:int = int(cbSource.getCellInfo());
			switch(n) {
				case JSON_DATE:
				case JSON_INDEX:
					switch(n) {
						case JSON_DATE:
							/*	var d:Date = new Date;
							tHi.setCellInfo( UTIL.fz(d.date,2)+UTIL.fz(d.month+1,2)+String(d.fullYear).slice(2,4)+UTIL.fz(d.hours,2)+UTIL.fz(d.minutes,2)+UTIL.fz(d.seconds,2) );
							d = new Date(2012,0,1,0,0,1);
							tLow.setCellInfo( UTIL.fz(d.date,2)+UTIL.fz(d.month+1,2)+String(d.fullYear).slice(2,4)+UTIL.fz(d.hours,2)+UTIL.fz(d.minutes,2)+UTIL.fz(d.seconds,2) );
							tHi.restrict("0-9",12);
							tLow.restrict("0-9",12);*/
							fHiSelect.setCellInfo( new Date );
							fLoSelect.setCellInfo( new Date );
							break;
						case JSON_INDEX:
							tHi.hint = "";
							tLow.hint = "";
							tHi.setCellInfo( gearbox.HIS_LAST_INDEX_N1 );
							tLow.setCellInfo( gearbox.HIS_FIRST_INDEX_N2 );
							tHi.restrict("0-9",10);
							tLow.restrict("0-9",10);
							break;
					}
					go.show(n.toString());
					gom.movex("0", btnsAnchor + 210);
					disableExport(HistoryReceiver.access().isExportButtonDisabled());
					break;
				default:
					go.show("0");
					gom.movex("0", btnsAnchor);
					disableExport(servant.isExportButtonDisabled());
					break;
			}
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
				case START:
					var n:int = int(cbSource.getCellInfo());
					switch(n) {
						case JSON_DATE:
							HistoryReceiver.access().start( String(fHiSelect.getCellInfo()), String(fLoSelect.getCellInfo()), HistoryReceiver.DATE, disableExport );
							break;
						case JSON_INDEX:
							HistoryReceiver.access().start( String(tHi.getCellInfo()), String(tLow.getCellInfo()), HistoryReceiver.INDEX, disableExport );
							break;
						default:
							GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
								{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
							RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INDEX, put));
							servant.start();
							break;
					}
					//HIS_LAST_PAGE_REQUEST = uint(ev.getData());
					break;
				default:
					// только для XLS и PDF, остальные достаются из servant
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
					var header:Array = tservat.getHeaderLabelsForExport();
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
						case JSON:
							bytes = (new HistoryExporterJSON).compile(tservat.getFields(),servant.bookraw);
							filename += ".json";
							break;
						case JSON_DATE:
						case JSON_INDEX:
							bytes = HistoryReceiver.access().getBytes();
							//bytes = (new HistoryExporterJSON).compile(tservat.getHeaderLocalsForExport(),HistoryReceiver.access().getFields());
							filename += ".json";
							break;
					}
					FileBrowser.getInstance().save(bytes, filename);
					break;
			}
		}
	}
}