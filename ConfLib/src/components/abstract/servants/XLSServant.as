package components.abstract.servants
{
	import components.abstract.Templates;
	
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;

	public class XLSServant
	{
		private var shared:Vector.<String>;	// для создания sharedStrings в xlsx
		private var shared_color_map:Vector.<String>;
		private var shared_count:int;		// макс длина строки для sharedStrings в xlsx
		
		public function compile(header:Array, book:Object):ByteArray
		{
			///var h:String;
			var row:String;
			var column:String;
			
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
				} else
					filling += "<c r=\"" + hash_letters[column] + "1\"><v>"+header[column]+"</v></c>"; 
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
			var bytes:ByteArray = new ByteArray();
			zip.serialize(bytes, true);
			return bytes;
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