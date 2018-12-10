package components.abstract.servants
{
	import com.fxpdf.doc.HPDF_Doc;
	import com.fxpdf.font.HPDF_Font;
	import com.fxpdf.page.HPDF_Page;
	import com.fxpdf.streams.HPDF_MemStreamAttr;
	import com.fxpdf.types.HPDF_Box;
	import com.fxpdf.types.enum.HPDF_PageDirection;
	import com.fxpdf.types.enum.HPDF_PageSizes;
	
	import flash.utils.ByteArray;

	public class PDFVoyagerServant
	{
		public function compile(header:Array, book:Object):ByteArray
		{
			var pdfDoc:HPDF_Doc; 
			var page:HPDF_Page;
			var rect:HPDF_Box = new HPDF_Box();
			var pheight:Number ; 
			var pwidth:Number ; 
			
			var row:String;
			var column:String;
			
			pdfDoc = new HPDF_Doc( ) ; 
			
			// Add a new page object.  
			page = pdfDoc.HPDF_AddPage() ;  
			page.HPDF_Page_SetSize ( HPDF_PageSizes.HPDF_PAGE_SIZE_A4, HPDF_PageDirection.HPDF_PAGE_LANDSCAPE);
			
			pheight  = page.HPDF_Page_GetHeight () ;
			pwidth   = page.HPDF_Page_GetWidth () ;
			
			var twidth:int = pwidth/header.length;
			var theight:int = twidth*0.20;
			var	fsize:Number = twidth*0.10;
			var fspace:Number = fsize/3;
			
			//"Courier","Courier-Bold","Courier-Oblique","Courier-BoldOblique","Helvetica","Helvetica-Bold","Helvetica-Oblique","Helvetica-BoldOblique","Times-Roman",
			//	var font:HPDF_Font = pdfDoc.HPDF_GetFont( "Courier", "CP1251");
			var font:HPDF_Font = pdfDoc.HPDF_GetFont( "Helvetica", "CP1251");
			rect.left = 25;
			rect.top = 545;
			rect.right = pwidth - 50;
			rect.bottom = rect.top - 340;                           
			
			page.HPDF_Page_BeginText ();
			page.HPDF_Page_SetFontAndSize ( font, fsize );
			
			var ypos:int;
			ypos = pheight-(int(row)*theight+10);
			for( row in header){
				page.HPDF_Page_SetCharSpace ( isRussian(header[row]) ? fspace : 0 );
				page.HPDF_Page_TextOut( int(row)*twidth+10 ,ypos, String(header[row]).replace("\r","") );
			}
			
			for( row in book){
				ypos = pheight-((int(row)+1)*theight+15);
				for( column in book[row]) {
					page.HPDF_Page_SetCharSpace ( isRussian(book[row][column]) ? fspace : 0 );
					page.HPDF_Page_TextOut( int(column)*twidth+10 ,ypos, book[row][column] );
				}
			}
			page.HPDF_Page_EndText ();  
			
			pdfDoc.HPDF_SaveToStream();  
			var memAttr : HPDF_MemStreamAttr = pdfDoc.stream.attr as HPDF_MemStreamAttr;
			memAttr.buf.position = 0;
			return memAttr.buf;
		}
		private function isRussian(s:String):Boolean
		{
			return s.charCodeAt(0) > 127;
		}
	}
}