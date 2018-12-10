package components.abstract.servants
{
	import com.fxpdf.doc.HPDF_Doc;
	import com.fxpdf.font.HPDF_Font;
	import com.fxpdf.page.HPDF_Page;
	import com.fxpdf.streams.HPDF_MemStreamAttr;
	import com.fxpdf.types.enum.HPDF_PageDirection;
	import com.fxpdf.types.enum.HPDF_PageSizes;
	
	import flash.utils.ByteArray;
	
	public class PDFServant
	{
		public function compile(header:Array, book:Object, HASH_PDF_XPOS:Object, fontsize:int):ByteArray
		{
			var h:String;
			var row:String;
			var column:String;
			
			var pdfDoc:HPDF_Doc = new HPDF_Doc(); 
			var page:HPDF_Page;
			var yPageMultiplier:int = 0;
			
			page = pdfDoc.HPDF_AddPage() ;  
			page.HPDF_Page_SetSize ( HPDF_PageSizes.HPDF_PAGE_SIZE_A4, HPDF_PageDirection.HPDF_PAGE_LANDSCAPE);
			
			var height:Number = page.HPDF_Page_GetHeight();
			var width:Number = page.HPDF_Page_GetWidth () ;
			
			var twidth:int = width/header.length;
			var theight:int = twidth*0.20;
			var	fsize:Number = fontsize;//twidth*0.10;
			var fspace:Number = fsize/3;
			
			var font:HPDF_Font = pdfDoc.HPDF_GetFont( "Helvetica", "CP1251");
			
			page.HPDF_Page_BeginText ();
			page.HPDF_Page_SetFontAndSize ( font, fsize );
			
			var ypos:int;
			ypos = height-(int(row)*theight+10);
			for( row in header){
				if (header[row] is Array) {
					writeLetters(header[row][0], HASH_PDF_XPOS[int(row)]);
				} else
					writeLetters(header[row], HASH_PDF_XPOS[int(row)] );
			}
			
			for( row in book){
				ypos = height-((int(row)+1)*theight+15) + yPageMultiplier;
				if (ypos < 0) {
					page = pdfDoc.HPDF_AddPage() ;  
					page.HPDF_Page_SetSize ( HPDF_PageSizes.HPDF_PAGE_SIZE_A4, HPDF_PageDirection.HPDF_PAGE_LANDSCAPE);
					page.HPDF_Page_BeginText ();
					page.HPDF_Page_SetFontAndSize ( font, fsize );
					yPageMultiplier += 594;
					ypos += 594;
				}
				for( column in book[row]) {
					if (book[row][column] is Array) {
						var colors:Vector.<String> = book[row][column][1];
						var len:int = colors.length;
						for(var i:int=0; i<len; ++i ) {
							
							var r:Number = Number("0x"+(colors[i] as String).slice(0,2))/255;
							var g:Number = Number("0x"+(colors[i] as String).slice(2,4))/255;
							var b:Number = Number("0x"+(colors[i] as String).slice(4,6))/255;
							page.HPDF_Page_SetRGBFill( r,g,b );
							page.HPDF_Page_TextOut( HASH_PDF_XPOS[int(column)] + i*getNumberWidth(), ypos, (book[row][column][0] as String).charAt(i) );
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
			
			return memAttr.buf;
			
			function getNumberWidth():Number
			{
				return 7/10*fontsize;
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
			function getCharWidth(s:String):Number
			{
				return getKerning()*(fontsize/10);
				function getKerning():int
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
		}
		private function getShortString(s:String):String
		{
			if (s.length > 40 )
				return s.slice(0,40)+"...";
			return s;
		}
	}
}