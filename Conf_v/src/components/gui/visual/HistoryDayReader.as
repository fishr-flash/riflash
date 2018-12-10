package components.gui.visual
{
	import components.abstract.HistoryDataProvider;
	import components.abstract.functions.dtrace;
	import components.abstract.gearboxes.HistoryBox;
	import components.abstract.servants.HistoryTableServant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIHistoryTable;
	import components.static.CMD;
	
	public class HistoryDayReader
	{
		public var working:Boolean = false;
		
	//	private var fDate:FSSimple;
	//	private var bRun:TextButton;
		private var history:UIHistoryTable;
		private var gearbox:HistoryBox;
		private var servant:HistoryTableServant;
		private var requredDate:Date;
		private var foundDay:Boolean;
		
		private var shift:int;	// множитель на вычитывание структур при толстении
		private var search:int; // true вычитывание в сторону утра, false - вечера
		private const SEARCH_BEFORE:int = 1;
		private const SEARCH_AFTER:int = 2;
		private const COMPLETE:int = 2;
		
		private var sec_before:int;	// cекунд с утра до найденной точки
		private var sec_after:int;	// cекунд с найденной точки до вечера
		
		private var records:Array;
		
		private var HIS_LAST_INDEX_N1:uint;
		private var HIST_INDEX_IN_FIRST_BLOCK:uint;
		private var HIS_FIRST_INDEX_N2:uint;
		private var HIS_BLOCK_SIZE_BYTE:int;
		private var HIS_CMD_BLOCK_SIZE_BYTE:int;
		
		private var REQUEST_BLOCKS:Array;
		private var REQUESTED_LAST_INDEX:uint;
		private var total_required:uint;
		private var OLD_BINARY_BORDER:uint;
		
		private var min_min:uint, min_max:uint, max:uint, point:uint;
		
		public function HistoryDayReader(h:UIHistoryTable, s:HistoryTableServant)
		{
			super();
			
			history = h;
			servant = s;
			
			gearbox = HistoryBox.access();
			
			/*fDate = new FSSimple;
			addChild( fDate );
			fDate.setName( "date in utc" );
			fDate.setWidth( 130 );
			//fDate.setUp( onChange,  );
			fDate.setCellInfo("151210");
			fDate.restrict( "0-9",6 );
			fDate.hint = "YYMMDD";//("15.12.15 15:57:52");
			// воод в UTC
			
			
			bRun = new TextButton;
			addChild( bRun );
			bRun.setUp("run", onClick );
			bRun.y += 20;
			
			this.graphics.beginFill( COLOR.GREY_POPUP_FILL );
			this.graphics.drawRect(0,0, 100, 80 );

			this.visible = false;*/
			
			REQUEST_BLOCKS = [];
		}
		/*private function onClick():void
		{
			var datestring:String = String(fDate.getCellInfo());
			if (datestring.length == 6) {
				
				var a:Array = datestring.match( /\d\d/g );
				requredDate = new Date;
				requredDate.setUTCFullYear("20"+a[0], int(a[1])-1, a[2]);
				requredDate.setUTCHours(0,0,0,1);
				
				working = true;
				foundDay = false;
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_INDEX, history.put));
			}
		}*/
		
		public function init():void
		{
			HIS_LAST_INDEX_N1 = gearbox.HIS_LAST_INDEX_N1;
			HIST_INDEX_IN_FIRST_BLOCK = gearbox.HIST_INDEX_IN_FIRST_BLOCK;
			HIS_FIRST_INDEX_N2 = gearbox.HIS_FIRST_INDEX_N2;
			HIS_BLOCK_SIZE_BYTE = gearbox.HIS_BLOCK_SIZE_BYTE;
			HIS_CMD_BLOCK_SIZE_BYTE = gearbox.HIS_CMD_BLOCK_SIZE_BYTE;
			
			point = (HIS_LAST_INDEX_N1 + HIS_FIRST_INDEX_N2)/2;
			
			min_min = HIS_FIRST_INDEX_N2;
			min_max = point;
			max = HIS_LAST_INDEX_N1;
			
			total_required = 1;
			//startCalculation(point);
			foundDay = true;
			startCalculation( 1573001 );
		}
		
		private function startCalculation(index:uint):void
		{
			var forward_records:int = HIS_LAST_INDEX_N1 - HIST_INDEX_IN_FIRST_BLOCK;
			var backward_records:int = HIST_INDEX_IN_FIRST_BLOCK - HIS_FIRST_INDEX_N2;
			var block_with_last_index:int = Math.ceil(forward_records*HIS_BLOCK_SIZE_BYTE/HIS_CMD_BLOCK_SIZE_BYTE);
			var rest_bytes:int = HistoryDataProvider.TOTAL_MEMORY-Math.floor(HistoryDataProvider.TOTAL_MEMORY/HIS_BLOCK_SIZE_BYTE)*HIS_BLOCK_SIZE_BYTE;
			var block_with_first_index_bytes:int = HistoryDataProvider.TOTAL_MEMORY - (backward_records*HIS_BLOCK_SIZE_BYTE+rest_bytes);
			var block_with_first_index:int = Math.ceil(block_with_first_index_bytes/HIS_CMD_BLOCK_SIZE_BYTE);
			
			var total_history_lines:int = HIS_LAST_INDEX_N1 - HIS_FIRST_INDEX_N2;
			
		//	var requiredRecord:uint = index - HIS_FIRST_INDEX_N2;
			var requiredRecord:uint = HIS_LAST_INDEX_N1-index;
			
			REQUEST_BLOCKS.length = 0;
			var request_from:int = total_history_lines-requiredRecord;
			
			trace( "perc "+(requiredRecord/total_history_lines)*100 );
			
			var rblen:int=0;
			
			for(var i:int=0; i<total_required; ++i) {
				if ( total_history_lines < i || (request_from-i)<0 )
					break;
				dtrace( "надо запросить "+ (HIS_FIRST_INDEX_N2+request_from-i) );
				REQUESTED_LAST_INDEX = HIS_FIRST_INDEX_N2+request_from-i;
				getBlock( request_from-i );
				
				// если запись больше 128 байт, счетчик иногда пропускает один блок истории, эта функция нужна чтобы восполнять пробелы 
				rblen = REQUEST_BLOCKS.length;
				if (i > 0 && REQUEST_BLOCKS[rblen-1] != REQUEST_BLOCKS[rblen-2] - 1 )
					REQUEST_BLOCKS.splice(rblen-1,0,REQUEST_BLOCKS[rblen-1]+1);
			}
			
			dtrace("Запрос блоков "+REQUEST_BLOCKS.toString());
			
	//		REQUESTED_LAST_INDEX = index;
			
			RequestAssembler.getInstance().fireReadBlock( CMD.HISTORY_BLOCK, assembler, REQUEST_BLOCKS.reverse(), Request.NORMAL, Request.PARAM_DONT_CLEAN);
		}
		private function getBlock(n:int):void
		{
			if (n<0)
				dtrace("ВНИМАНИЕ: В UiHistory.getBlock() пришли данные меньше 0!")
			
			var unique_index:uint = n+HIS_FIRST_INDEX_N2;
			var shift:uint = getShift(unique_index);
			var value:uint;
			
			value = Math.ceil((shift*HIS_BLOCK_SIZE_BYTE+HIS_BLOCK_SIZE_BYTE)/HIS_CMD_BLOCK_SIZE_BYTE);
			
			if( REQUEST_BLOCKS.length == 0 || REQUEST_BLOCKS[ REQUEST_BLOCKS.length - 1 ] != value )
				REQUEST_BLOCKS.push( value );
			value = Math.floor(shift*HIS_BLOCK_SIZE_BYTE/HIS_CMD_BLOCK_SIZE_BYTE+1);
			if( REQUEST_BLOCKS.length == 0 || (REQUEST_BLOCKS[ REQUEST_BLOCKS.length - 1 ] != value && value > 0 )  )
				REQUEST_BLOCKS.push( value );
			//REQUESTED_LAST_INDEX = unique_index;
		}
		private function getShift(index:uint):uint
		{
			if (index >= HIST_INDEX_IN_FIRST_BLOCK)
				return index - HIST_INDEX_IN_FIRST_BLOCK;
			return (HIS_LAST_INDEX_N1 - HIST_INDEX_IN_FIRST_BLOCK) + (index - HIS_FIRST_INDEX_N2) + 1;
		}
		private function assembler(p:Package):void
		{
			var bytearray:Array = [];
			var len:uint = p.length;
			for(var i:int=0; i<len; ++i){
				bytearray = bytearray.concat( p.data[i] ); 
			}

if (!records)
records = [];
			
			var recde:Array = [];
			
			var lines:Array = new Array;
			
			if (p.length > 0) {
				for( var k:int=0; k<total_required; ++k ) {
					if ( HIS_LAST_INDEX_N1 - (REQUESTED_LAST_INDEX-(total_required-1)+k) > -1 ) {
						var sh:int = getLocalByteShift( REQUESTED_LAST_INDEX+k );
						if (foundDay) {
							var rec:Array = bytearray.slice( sh, sh + HIS_BLOCK_SIZE_BYTE );
							var recdecrypted:Array = servant.put(rec);
							var recd:Date = getDate(recdecrypted);
							recde.push(recdecrypted);
							/*if (!recd) {	// возможно попалось окно с плохой записью
								continue;
							} else if (recd.fullYearUTC == requredDate.fullYearUTC &&	
								recd.monthUTC == requredDate.monthUTC && 
								recd.dateUTC == requredDate.dateUTC ) {
								records[REQUESTED_LAST_INDEX-k] = rec;
								
							} else {	// попалось запись другого дня, больше в эту сторону нет смысла расширяться
								search++;
								break;
							}*/
						} else
							lines.push( bytearray.slice( sh, sh + HIS_BLOCK_SIZE_BYTE ) );
					}
				}
			}
			
			
total_required = 2;
startCalculation( 1573001 );
			
			return;
			
			if( foundDay ) {
				trace( "got lines" );
				shift++;
				
				switch(search) {
					case SEARCH_BEFORE:
						if( shift*total_required < sec_before ) {
							startCalculation( point-(shift*total_required) );
							break;
						} else {
							shift = 1;
							search++;
						}
					case SEARCH_AFTER:
						if( shift*total_required < sec_after) {
							startCalculation( point+(shift*total_required) );
							break;
						} else {
							search++;
						}
						break;
					case COMPLETE:
						trace("COMPLETE");
						break;
				}
				
			
			} else {
				// кидаем полученную запись на обработку в серванта, и сразу достаем оттуда дату
				var decrypted:Array = servant.put(lines[0]);
				var d:Date = getDate(decrypted);
				counter++;
				trace( "\t\t "+counter );
				if (!d) {
					trace("Record  date is NAN" );
					point++;
					if (point < max) {
						max = min_max;
						point = (min_min + max)/2;
						min_max = point;
					}
					startCalculation(point);					
					return;
				}
				
				trace("Record  date is " + d.toUTCString() );
				trace("Requred date is " + requredDate.toUTCString() );
				
				if (requredDate.fullYearUTC == d.fullYearUTC && 
					requredDate.monthUTC == d.monthUTC && 
					requredDate.dateUTC == d.dateUTC ) {
					
					//86400000 
					
					trace("Found " + d.toUTCString() );
					foundDay = true;
					
					var tommorow:Date = new Date;
					tommorow.setUTCFullYear( requredDate.fullYearUTC, requredDate.monthUTC, requredDate.dateUTC);
					tommorow.setUTCHours(23,59,59,999);
					
					sec_before = (d.time-requredDate.time)/1000;
					sec_after = (tommorow.time - d.time)/1000;
					
					records = [];
					total_required = 2;
					shift = 0;
					search = SEARCH_BEFORE;
					
					//startCalculation( point-(shift*total_required) );
					startCalculation( point );
					
					trace("Found " + d.toUTCString() );
				} else {
					var lastpoint:uint = point;
					if( requredDate.time > d.time ) {
						point = (max + lastpoint)/2;
						trace("max "+ max + " point "+point+ " max "+ max );
						min_min = lastpoint;
						min_max = point;
					} else {
						point = (min_min + min_max)/2;
						max = lastpoint;
						min_max = point;
						trace("min_min "+ min_min + " point "+point+ " min_max "+ min_max );
					}
					
					trace("delta "+(max-min_min));
					startCalculation(point);
				}
			}
			
		/* 
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			}*/
		}
		
		private var counter:int;
		
		private function getLocalByteShift(index:uint):uint
		{
			var shift:uint = getShift(index);
			var global_byte_shift:int = shift*HIS_BLOCK_SIZE_BYTE;
			var lastShift:int = getShift(REQUESTED_LAST_INDEX);
			var local_byte_shift:int = global_byte_shift - ( Math.floor( (lastShift*HIS_BLOCK_SIZE_BYTE)/HIS_CMD_BLOCK_SIZE_BYTE )*HIS_CMD_BLOCK_SIZE_BYTE );
			if (local_byte_shift < 0)
				return (HistoryDataProvider.TOTAL_MEMORY + local_byte_shift);
			return local_byte_shift;
		}
		
		/** PROCESS **/
		
		private function getDate(a:Array):Date
		{
			var reDate:RegExp = /\d\d\.\d\d\.\d\d/g;
			var reTime:RegExp = /\d\d:\d\d:\d\d/g;
			var d:Date = new Date;
			var b:Array;
			
			var foundDate:Boolean=false;
			var foundTime:Boolean=false;
			
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if(reDate.test(a[i])) {
					b = String(a[i]).split(".");
					if (b[2]=="70")	// битая дата
						return null;
					d.setFullYear("20"+b[2], int(b[1])-1, b[0]);
					foundDate = true;
				} else if (reTime.test(a[i])) {
					b = String(a[i]).split(":");
					d.setHours(b[0], b[1], b[2]);
					foundTime = true;
				}
				if (foundDate && foundTime)
					return d;
			}
			return null;
		}
	}
}