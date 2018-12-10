package components.screens.ui
{
	import com.fxpdf.doc.HPDF_Doc;
	import com.fxpdf.font.HPDF_Font;
	import com.fxpdf.page.HPDF_Page;
	import com.fxpdf.streams.HPDF_MemStreamAttr;
	import com.fxpdf.types.HPDF_Box;
	import com.fxpdf.types.enum.HPDF_PageDirection;
	import com.fxpdf.types.enum.HPDF_PageSizes;
	
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import components.abstract.Templates;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
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
	import components.static.COLOR;
	import components.static.PAGE;
	import components.system.CONST;
	
	import deng.fzip.FZip;
	
	public class UIHistory extends UI_BaseComponent implements IResizeDependant
	{
		public static var NOTIFY_LIST_SMS_ALARM:int;
		public static var NOTIFY_LIST_SMS_EVENT:int;
		public static var NOTIFY_LIST_VOICE_ALARM:int;
		
		public static const HIS_DELETE:int = 0x01;
		public static const HIS_DELETE_SUCCESS:int = 0x02;
		
		private var bXLSpage:TextButton;
		private var bPDFpage:TextButton;
		private var bClearHistory:TextButton;
		
		private var timerDeleting:Timer;

		private var HIS_LAST_INDEX_N1:uint;
		private var HIS_LAST_PAGE_REQUEST:uint;
		private var HIS_FIRST_INDEX_N2:Number;
		private var HIS_N1_STRUCTURE:int;
		private var HIS_MAX_STRUCTURES:int;
		private var HIS_TOTAL_RECORDS:int;
		private const HIS_CMD_BLOCK_SIZE_BYTE:int=128;
		private var HIST_INDEX_IN_FIRST_BLOCK:int; 
		
		private var HIS_UID_REQUESTED:Vector.<int>;	// хранятся запрошенные структуры
		private var HIS_SEND_DATA:Array;			// собирается информация для передачи в Opt
		
		private var REQUESTED_LAST_INDEX:uint;
		
		private var HASH_PDF_XPOS:Object = {0:10, 1:90, 2:225, 3:550, 4:625, 5:725};
		
		private var shared:Vector.<String>;	// для создания sharedStrings в xlsx
		private var shared_color_map:Vector.<String>;
		private var shared_count:int;		// макс длина строки для sharedStrings в xlsx
		
		public function UIHistory()
		{
			super();
			
			list = new OptList;
			list.attune( CMD.EVENT_LOG_REC, 0, 
				OptList.PARAM_DRAW_SEPARATOR | OptList.PARAM_DRAW_CHECKMATE | OptList.PARAM_DRAW_PAGES | OptList.PARAM_H_SCROLLING_WHEN_NEEEDED | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED, 
				{linesPerPage:CLIENT.HISTORY_LINES_PER_PAGE} );
			addChild( list );
			if (CONST.DEBUG)
				list.width = 1048;
			else
				list.width = 978;

			bXLSpage = new TextButton;
			bXLSpage.x = 10;
			bXLSpage.setUp( loc("evlog_export_excel"), export, 1);
			addChild( bXLSpage );
			
			bPDFpage = new TextButton;
			bPDFpage.x = 10;
			bPDFpage.setUp( loc("evlog_export_pdf"), export, 2);
			addChild( bPDFpage );
			
			bClearHistory = new TextButton;
			bClearHistory.x = 380;
			bClearHistory.setUp( loc("evlog_clear"), clear);
			addChild( bClearHistory );
			
			/***	Удаление	**********/
			popup = PopUp.getInstance();
			
			//HASH_PDF_XPOS = (new OptHistoryLine(0)).getHeaderDimensions();
		}
		override public function open():void
		{
			super.open();
			
			popup.PARAM_CLOSE_ITSELF = false;
			
			if ( OPERATOR.dataModel.getData( CMD.SMS_TEXT_K2 ) == null )
				RequestAssembler.getInstance().fireEvent( new Request(CMD.SMS_TEXT_K2) );
			RequestAssembler.getInstance().fireEvent( new Request(CMD.NOTIF_K2,put) );
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EVENT_LOG_INDEX,put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EVENT_LOG_INFO,put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EVENT_LOG_REC,put,1));
		}
		override public function close():void
		{
			super.close();
			HIS_LAST_PAGE_REQUEST = 0;			
			doCancel();
			list.clear();
			ResizeWatcher.removeDependent(this);
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.onNeedPage, getPageListener );
		}
		override public function put(p:Package):void
		{
			popup.close();
			
			switch(p.cmd) {
				case CMD.NOTIF_K2:
					NOTIFY_LIST_SMS_EVENT = 0;
					NOTIFY_LIST_SMS_ALARM = 0;
					NOTIFY_LIST_VOICE_ALARM = 0;
					
					var len:int = p.data.length;
					for (var i:int=0; i<len; ++i) {
						if (p.data[i][0] == 1) {
							
							if ( p.data[i][3] == 1) {
								NOTIFY_LIST_SMS_EVENT |= (1<<i);
							}
							
							switch( p.data[i][4] ) {
								case 1:
									NOTIFY_LIST_SMS_ALARM |= (1<<i); 
									break;
								case 2:
									NOTIFY_LIST_VOICE_ALARM |= (1<<i);
									break;
								case 3:
									NOTIFY_LIST_SMS_ALARM |= (1<<i);
									NOTIFY_LIST_VOICE_ALARM |= (1<<i);
									break;
							}
						}
					}
					dtrace("NOTIFY_LIST_SMS_ALARM="+NOTIFY_LIST_SMS_ALARM );
					dtrace("NOTIFY_LIST_SMS_EVENT="+NOTIFY_LIST_SMS_EVENT );
					dtrace("NOTIFY_LIST_VOICE_ALARM="+NOTIFY_LIST_VOICE_ALARM );
					break;
				case CMD.EVENT_LOG_INDEX:
					HIS_LAST_INDEX_N1 = p.getStructure()[0];
					HIS_FIRST_INDEX_N2 = p.getStructure()[1];
					HIS_TOTAL_RECORDS = HIS_LAST_INDEX_N1 - HIS_FIRST_INDEX_N2 + 1;
					dtrace("HIS_LAST_INDEX_N1="+HIS_LAST_INDEX_N1 );
					dtrace("HIS_FIRST_INDEX_N2="+HIS_FIRST_INDEX_N2 );
					dtrace("HIS_TOTAL_RECORDS="+HIS_TOTAL_RECORDS );
					break;
				case CMD.EVENT_LOG_INFO:
					HIS_MAX_STRUCTURES = p.getStructure()[1];
					OPERATOR.getSchema( CMD.EVENT_LOG_REC ).StructCount = HIS_MAX_STRUCTURES;
					dtrace("HIS_MAX_STRUCTURES="+HIS_MAX_STRUCTURES );
					break;
				case CMD.EVENT_LOG_REC:
					HIST_INDEX_IN_FIRST_BLOCK = p.getStructure()[0];
					HIS_N1_STRUCTURE = HIS_LAST_INDEX_N1 - HIST_INDEX_IN_FIRST_BLOCK + 1;
					HIS_LAST_PAGE_REQUEST = 1;
					
					dtrace("HIST_INDEX_IN_FIRST_BLOCK="+HIST_INDEX_IN_FIRST_BLOCK );
					
					getPage( HIS_LAST_PAGE_REQUEST );
					GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onNeedPage, getPageListener );
					ResizeWatcher.addDependent(this);
					break;
			}
		}
		private function getStruc(uid:int):int
		{
			var result:int = HIS_N1_STRUCTURE - (HIS_LAST_INDEX_N1 - uid);
			if (result < 1)
				result += HIS_MAX_STRUCTURES;
			dtrace("запрос структуры "+result + " по uid "+uid);
			return result;
		}
		private function getPageListener(ev:GUIEvents):void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.NOTIF_K2,put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EVENT_LOG_INDEX,updateInfo));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EVENT_LOG_REC,updateInfo,1));
			HIS_LAST_PAGE_REQUEST = int(ev.getData()); 
			loadStart();
		}
		private function updateInfo(p:Package):void
		{
			switch ( p.cmd ) {
				case CMD.EVENT_LOG_INDEX:  
					HIS_LAST_INDEX_N1 = p.getStructure()[0];
					HIS_FIRST_INDEX_N2 = p.getStructure()[1];
					HIS_TOTAL_RECORDS = HIS_LAST_INDEX_N1 - HIS_FIRST_INDEX_N2 + 1;
					break;
				case CMD.EVENT_LOG_REC:
					HIST_INDEX_IN_FIRST_BLOCK = p.getStructure()[0];
					HIS_N1_STRUCTURE = HIS_LAST_INDEX_N1 - HIST_INDEX_IN_FIRST_BLOCK + 1;
					getPage( HIS_LAST_PAGE_REQUEST );
					break;
			}
		}
		private function getPage(page:int):void
		{
			if( HIS_MAX_STRUCTURES == 0 ) {
				var p:Package = new Package;
				p.data = new Array;
				list.addHeader(OptHistoryLine);
				list.put( p, OptHistoryLine );
				loadComplete();
				return;
			}
			/*if( screenBlock.visible  )
				return;*/
			
		//	tClearSuccess.visible = false;
			
			HIS_LAST_PAGE_REQUEST = page;
			
			var start_line:int = (page-1)*CLIENT.HISTORY_LINES_PER_PAGE;
			HIS_SEND_DATA = new Array;
			HIS_SEND_DATA.length = start_line;
			
			var left:int=CLIENT.HISTORY_LINES_PER_PAGE + start_line;
			if (HIS_TOTAL_RECORDS - start_line < CLIENT.HISTORY_LINES_PER_PAGE )
				left = HIS_TOTAL_RECORDS;// + start_line;
			
			var s:int;
			for( var i:int=start_line; i<left; ++i) {
				if ( HIS_LAST_INDEX_N1 - i < 1 )
					//	s = HIS_LAST_STRUCTURE + HIS_MAX_STRUCTURES - i;
					s = HIS_LAST_INDEX_N1 + HIS_MAX_STRUCTURES - i;
				else
					s = HIS_LAST_INDEX_N1 - i;
				
				if(!HIS_UID_REQUESTED)
					HIS_UID_REQUESTED = new Vector.<int>;
				HIS_UID_REQUESTED.push(int(s));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.EVENT_LOG_REC, assembler, getStruc(s) ));
			}
		}
		private function assembler(p:Package):void
		{
			var start_line:int = (HIS_LAST_PAGE_REQUEST-1)*CLIENT.HISTORY_LINES_PER_PAGE;
			var darr:Array = p.data.slice();
			var len:int = darr.length;
			
			for( var i:int=0; i<len; ++i ) {
				var struc:int = HIS_UID_REQUESTED.shift();
				HIS_SEND_DATA.push( darr[i].concat( getStruc(struc) ) );
			}
			
			if(HIS_UID_REQUESTED.length==0) {
				
				len = HIS_SEND_DATA.length;
			/*	for(var n:int=start_line; n<len; n++) {
					HIS_SEND_DATA[n][21] = HIS_TOTAL_RECORDS - n;
				}*/
				
				HIS_SEND_DATA.length = HIS_TOTAL_RECORDS;
				
				var p:Package = new Package;
				p.data = HIS_SEND_DATA;
				
				list.addHeader(OptHistoryLine);
				list.put( p, OptHistoryLine );
				loadComplete();
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var pos:int = h - 70;
			if (pos<155)
				pos = 155;

			list.height = pos;
			list.width = w - 10;

			bXLSpage.y = pos;
			bPDFpage.y = pos + 25;
			bClearHistory.y = pos;
		}
		private function clear():void
		{
			popup.construct( PopUp.wrapHeader("evlog_sure_delete"), PopUp.wrapMessage("his_time_deleting"), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete,doCancel] );
			popup.open();
			bClearHistory.disabled = true;
		}
		private function doDelete():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.EVENT_LOG_DELETE, doClear, 1 ,[HIS_DELETE] ));
		}
		private function doCancel():void
		{
			bClearHistory.disabled = false;
			popup.close();
		}
		private function doClear(p:Package):void
		{
			if (p.success ) {
				var t:String = "<b><font face='"+PAGE.MAIN_FONT+"' size='14' color='#"+COLOR.RED.toString(16)+"'>" + loc("evlog_wait_until_delete") + "</font></b>";
				var m:String = "<b><font face='"+PAGE.MAIN_FONT+"' size='10' color='#"+COLOR.SATANIC_GREY.toString(16)+"'>" + loc("his_time_deleting") + "</font></b>";
				popup.construct( PopUp.wrapHeader(""), PopUp.wrapMessage("") );
				popup.open();
				loadStart();
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
				
				if (!timerDeleting) {
					timerDeleting = new Timer( CLIENT.HIS_DELETE_TIMEOUT, 1 );
					timerDeleting.addEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
					timerDeleting.reset();
					timerDeleting.start();
				}
				initSpamTimer( CMD.EVENT_LOG_DELETE );
				//RequestAssembler.getInstance().fireEvent( new Request( CMD.EVENT_LOG_DELETE, processState ));
			}
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if(p.getStructure()[0] == HIS_DELETE_SUCCESS) {
				timerDeleting.stop();
				timerDeleting.removeEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
				CLIENT.ALWAYS_TRY = false;
				
				bClearHistory.disabled = false;
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
				loadComplete();
				RequestAssembler.getInstance().doPing(true);
				deactivateSpamTimer();
				popup.close();
				list.selectPage(1);
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
			loadComplete();
			RequestAssembler.getInstance().clearStackLater();
			
			popup.construct(PopUp.wrapHeader("sys_error"), PopUp.wrapMessage(loc("evlog_delete_fail")),PopUp.BUTTON_OK,[doOk]);
		}
		private function doOk():void
		{
			popup.close();
		}
		private function export(num:int):void
		{
			var bytes:ByteArray;
			switch(num) {
				case 1:	// xls page
				case 2: // pdf page
					
					var res:Array = list.getFieldData();
					var book:Object = new Object;
					for( var key:String in res) {
						book[key] = new Object;
						for( var p:String in res[key]) {
							book[key][p] = res[key][p];
						}
					}
					var h:String;
					var row:String;
					var column:String;
					var date:Date = new Date;
					var filename:String = "history_export_"+SERVER.VER_FULL+"_"+date.date+"."+int(date.month+1)+"."+date.fullYear;
					var header:Array = list.getHeader();
					/*var header:Array = ['Номер п/п','Время события дата','Номер объекта','Код тревоги',
						'Событие', 'Раздел', 'Зона/пользов.', 'Направление','ContactID','Ошибка CRC'];*/
					
					switch(num) {
						case 1:	
							var byte:ByteArray = new Templates.XLSX_START;
							var start:String = byte.readUTFBytes( byte.length );
							byte = new Templates.XLSX_END;
							var end:String = byte.readUTFBytes( byte.length );
							
							shared = new Vector.<String>;
							shared_color_map = new Vector.<String>;
							shared_count = 0;
							
							var filling:String = "";
							var hash_letters:Object = {0:"A", 1:"B", 2:"C", 3:"D", 4:"E", 5:"F", 6:"G", 7:"H", 8:"I", 9:"J"};
							
							filling += "<row r=\"1\" spans=\"1:3\" x14ac:dyDescent=\"0.25\">";
							for(column in header) {
								if( header[column] is String ) {
									filling += "<c r=\"" + hash_letters[column] + "1\" t=\"s\"><v>"+placeSharedString(header[column])+"</v></c>";
								} else if ( header[column] is Array ) {
									filling += "<c r=\"" + hash_letters[column] + "1\"><v>"+placeSharedString(header[column][0])+"</v></c>";
								} else {
									filling += "<c r=\"" + hash_letters[column] + "1\"><v>"+placeSharedString(header[column])+"</v></c>";
								}
							}
							filling += "</row>";
							
							for( row in book) {
								filling += "<row r=\""+ int(int(row)+2) + "\" spans=\"1:3\" x14ac:dyDescent=\"0.25\">";
								for( column in book[row]) {
									
									if( book[row][column] is Array ) {
										filling += "<c r=\"" + hash_letters[column] + int(int(row)+2) + "\" t=\"s\"><v>"+placeSharedString(book[row][column][0], book[row][column][1])+"</v></c>";
									} else if( book[row][column] is String ) {
										filling += "<c r=\"" + hash_letters[column] + int(int(row)+2) + "\" t=\"s\"><v>"+placeSharedString(book[row][column])+"</v></c>";
									} else
										filling += "<c r=\"" + hash_letters[column] + int(int(row)+2) + "\"><v>"+book[row][column]+"</v></c>"; 
								}
								filling += "</row>";
							}
							var titlexml:String = "<dimension ref=\"A1:J"+int(int(row)+2)+"\"/><sheetViews><sheetView tabSelected=\"1\" workbookViewId=\"0\"><selection activeCell=\"A1\" sqref=\"A1\"/></sheetView></sheetViews><sheetFormatPr defaultRowHeight=\"15\" x14ac:dyDescent=\"0.25\"/>" +
							"<cols><col min=\"1\" max=\"1\" width=\"11\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"2\" max=\"2\" width=\"20\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"3\" max=\"3\" width=\"16\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"4\" max=\"4\" width=\"12\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"5\" max=\"5\" width=\"23\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"6\" max=\"6\" width=\"8\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"7\" max=\"7\" width=\"15\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"8\" max=\"8\" width=\"14\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"9\" max=\"9\" width=\"19\" bestFit=\"1\" customWidth=\"1\"/>" +
							"<col min=\"10\" max=\"10\" width=\"19\" bestFit=\"1\" customWidth=\"1\"/></cols>" +
							"<sheetData>"
							
							var sheet:ByteArray = new ByteArray;
							sheet.writeUTFBytes( start + titlexml + filling + end );
							
							var zip:FZip = new FZip();
							zip.addFile("_rels/.rels",new Templates.XLSX_RELS as ByteArray );
							zip.addFile("docProps/app.xml",new Templates.XLSX_APP as ByteArray );
							zip.addFile("docProps/core.xml",new Templates.XLSX_CORE as ByteArray );
							zip.addFile("xl/_rels/workbook.xml.rels",new Templates.XLSX_WORKBOOK_RELS as ByteArray );
							zip.addFile("xl/theme/theme1.xml",new Templates.XLSX_THEME as ByteArray );
							zip.addFile("xl/worksheets/sheet1.xml", sheet );
							zip.addFile("xl/sharedStrings.xml", compileSharedStrings() );
							zip.addFile("xl/styles.xml",new Templates.XLSX_STYLES as ByteArray );
							zip.addFile("xl/workbook.xml",new Templates.XLSX_WORKBOOK as ByteArray );
							zip.addFile("[content_types].xml",new Templates.XLSX_CONTENT_TYPES as ByteArray );
							bytes = new ByteArray();
							zip.serialize(bytes, true);
							filename += ".xlsx";
							break;
						case 2:
							
							var pdfDoc:HPDF_Doc; 
							var page:HPDF_Page;
							var rect:HPDF_Box = new HPDF_Box();
							var height:Number ; 
							var width:Number ; 
							
							pdfDoc = new HPDF_Doc( ) ; 
							
							// Add a new page object.  
							page = pdfDoc.HPDF_AddPage() ;  
							page.HPDF_Page_SetSize ( HPDF_PageSizes.HPDF_PAGE_SIZE_A4, HPDF_PageDirection.HPDF_PAGE_LANDSCAPE);
							
							height  = page.HPDF_Page_GetHeight () ;
							width   = page.HPDF_Page_GetWidth () ;
							
							var twidth:int = width/header.length;
							var theight:int = twidth*0.20;
							var	fsize:Number = 10//twidth*0.10;
							var fspace:Number = fsize/3;
							
							//"Courier","Courier-Bold","Courier-Oblique","Courier-BoldOblique","Helvetica","Helvetica-Bold","Helvetica-Oblique","Helvetica-BoldOblique","Times-Roman",
							//	var font:HPDF_Font = pdfDoc.HPDF_GetFont( "Courier", "CP1251");
							//var font:HPDF_Font = pdfDoc.HPDF_GetFont( "Helvetica", "CP1251");
							
							var font:HPDF_Font = pdfDoc.HPDF_GetFont( "Helvetica", "CP1251");
							
							page.HPDF_Page_BeginText ();
							page.HPDF_Page_SetFontAndSize ( font, fsize );
							
							var ypos:int;
							ypos = height-(int(row)*theight+10);
							for( row in header){
								
								if (header[row] is Array) {
								//	page.HPDF_Page_TextOut( HASH_PDF_XPOS[int(row)] ,ypos, header[row][0] );
									writeLetters(header[row][0], HASH_PDF_XPOS[int(row)]);
								} else
									writeLetters(header[row], HASH_PDF_XPOS[int(row)] );
							}
							
							for( row in book){
								ypos = height-((int(row)+1)*theight+15);
								for( column in book[row]) {
									if (book[row][column] is Array) {
										var colors:Vector.<String> = book[row][column][1];
										var len:int = colors.length;
										for(var i:int=0; i<len; ++i ) {
											
											var r:Number = Number("0x"+(colors[i] as String).slice(0,2))/255;
											var g:Number = Number("0x"+(colors[i] as String).slice(2,4))/255;
											var b:Number = Number("0x"+(colors[i] as String).slice(4,6))/255;
											page.HPDF_Page_SetRGBFill( r,g,b );
											page.HPDF_Page_TextOut( HASH_PDF_XPOS[int(column)] + i*8, ypos, (book[row][column][0] as String).charAt(i) );
											page.HPDF_Page_SetRGBFill( 0,0,0 );
										}
									} else
										writeLetters(getShortString(book[row][column]), HASH_PDF_XPOS[int(column)] );
								}
							}
							page.HPDF_Page_EndText ();  
							
							pdfDoc.HPDF_SaveToStream();  
							var memAttr : HPDF_MemStreamAttr = pdfDoc.stream.attr as HPDF_MemStreamAttr;
							memAttr.buf.position = 0;
							bytes = memAttr.buf;
							
							filename += ".pdf";
							break;
					}
					var fileRef:FileReference = new FileReference;
					fileRef.save(bytes, filename);
					break;
			}
			function writeLetters(s:String, current_pos:int):void
			{
				var lenj:int = s.length;
				var shift:int = current_pos;
				for (var j:int=0; j<lenj; ++j) {
					page.HPDF_Page_TextOut(  current_pos, ypos, s.charAt(j) );
					current_pos += getCharWidth( s.charAt(j) );
				}
			}
			function getCharWidth(s:String):int
			{
				if (s == "ф" || s=="ш"|| s=="м" || s == "O" || s == "О" )
					return 8;
				if ( s == "ю" || s == "w" )
					return 7;
				if (s == "з" || s == "к" || s == "т" || s == "у" || s == "J" || s=="Г" )
					return 5;
				if (s == "!" || s == "j"|| s == "I"|| s == "i"|| s == "l")
					return 3;
				if (s == "@" || s == "Ю" || s == "Ы" || s=="№")
					return 10;
				if (s == "r" || s == "t" || s == "f" || s == "г")
					return 4;
				if (s == "W" || s == "M")
					return 9;
				var code:int = s.charCodeAt(0);
				if (code == 0x2116 || code == 0x25 || code == 0x40 || code == 0x416 || code == 0x428 || code == 0x429 || code == 0x41c || code == 0x40b || code == 0x40e)
					return 9;
				if ( (code > 64 && code < 91) || (code >= 0x400 && code <= 0x42f ) || 
				code == 0x436 || code == 0x448 || code == 0x449 || code == 0x44B || code == 0x44E ) {
					return 7;
				}
				return 6;
			}
		}
		private function getShortString(o:Object):String
		{
			var s:String = o.toString();
			if (s.length > 50 )
				return s.slice(0,50)+"...";
			return s;
		}
		private function placeSharedString(value:String, color:String=""):int
		{
			shared_count++;
			var len:int = shared.length;
			for(var i:int; i<len; ++i ) {
				if (shared[i] == value && shared_color_map[i] == color )
					return i;
			}
			shared.push(value);
			shared_color_map[i] = color;
			return i;
		}
		private function compileSharedStrings():ByteArray
		{
			var len:int = shared.length;
			var sharedStrings:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><sst xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" count=\""+shared_count+"\" uniqueCount=\""+len+"\">";
			
			for(var i:int=0; i<len; ++i ) {
				
				if ((shared_color_map[i] as String).length > 0) {
					
					sharedStrings += "<si>";
					var colors:Array = (shared_color_map[i] as String).split(",");
					var colorlen:int = colors.length;
					for(var k:int=0; k<colorlen; ++k ) {
						sharedStrings += "<r><rPr><sz val=\"11\"/><color rgb=\"FF" + colors[k] +
							"\"/><rFont val=\"Calibri\"/><family val=\"2\"/><charset val=\"204\"/><scheme val=\"minor\"/></rPr><t>" +
							(shared[i] as String).charAt(k) + "</t></r>";
					}
					sharedStrings += "</si>";
				} else
					sharedStrings += "<si><t>" + shared[i] + "</t></si>";
			}
			sharedStrings += "</sst>";
			var byte:ByteArray = new ByteArray;
			byte.writeUTFBytes( sharedStrings );
			return byte;
		}		
	}
}