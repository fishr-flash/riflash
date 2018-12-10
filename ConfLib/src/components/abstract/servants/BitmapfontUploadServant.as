package components.abstract.servants
{
	import flash.display.Bitmap;
	
	import components.abstract.TextSnapshoter;

	public class BitmapfontUploadServant
	{
		
		private static var  _instance:BitmapfontUploadServant;
		private const DOTA_SYMBOL:uint = 0x002E;
		
		[Embed(source = "../../../assets/fonts/3947.ttf", unicodeRange="U+0-7F,U+400-4FF", mimeType = "application/x-font-truetype", fontName = "DroidSansFont", embedAsCFF = "false")] 
		private const FONT_CLASS:Class;
		
		[Embed(source = "../../../assets/fonts/cp1251.txt", mimeType = "application/octet-stream")]
		private const TABLE_CP1251:Class;
		
		
		public static function get instance():BitmapfontUploadServant
		{
			if( !_instance ) _instance = new BitmapfontUploadServant();
			
			return _instance;
		}
		
		public function BitmapfontUploadServant()
		{
			
			init();
		}
		
		public function getFontData():Array
		{
			var dataSymbols:Array = prepareCodeSymbols();
			
	
			preapareBMField( dataSymbols );
			
			return dataSymbols;
		}
		
		
		private function init():void
		{
			
			
			
		}
		
		private function prepareCodeSymbols():Array 
		{
			var tblSymbols:String = new TABLE_CP1251();
			var tblSymbols1:String = tblSymbols.slice( tblSymbols.indexOf( "0x00" ) );
			const pattern:RegExp = /(?P<code_cp>0x[0-9ABCDEF]{2}).+?(?P<unicode>0x[0-9ABCDEF]{4}).+?/g;
			const pattern1:RegExp = /(?P<code_cp>0x[0-9ABCDEF]{2}).+?(?P<unicode>0x[0-9ABCDEF]{4}).+?/s;
			var arrCodes:Array = tblSymbols1.match( pattern );
			var arrCodes1:Array = new Array();// = pattern1.exec( arrCodes[ 0 ] );
			
			var excludedSymbols:Array = [ "0x000A", "0x0009", "0x000B" ];
			
			for  ( var key:String in arrCodes )
			{
				arrCodes1.push( pattern1.exec( arrCodes[ key ] ) );
				if ( excludedSymbols.indexOf( arrCodes1[ arrCodes1.length - 1 ][ "unicode" ] ) > -1 ) arrCodes1[ arrCodes1.length - 1 ][ "unicode" ] = DOTA_SYMBOL;
				
			}
			
			
			/**
			 *  Сформированные объекты массива имеют вид:
			 * 	[11] => Array(3):
			 [0] => (str,12) 0x11	0x0011	
			 [1] => (str,4) 0x11
			 [2] => (str,6) 0x0011
			 [input] => (str,12) 0x11	0x0011	
			 [code_cp] => (str,4) 0x11
			 [unicode] => (str,6) 0x0011
			 [index] => (int,1) 0
			 
			 
			 */
			
			
			
			return arrCodes1;
		}
		
		private function preapareBMField( arrCodes:Array ):void
		{
			const len:int = arrCodes.length;
			var txt:String;
			var xx:int = 0;
			var yy:int = 100;
			var bmap:Bitmap;
			var maxW:int = 0;
			var maxH:int = 0;
			for ( var i:int = 0; i < len; i++ )
			{
				txt = String.fromCharCode( arrCodes[ i ]["unicode" ] );
				
				
				arrCodes[ i ][ "value" ] = txt;
				
				
				
				bmap = TextSnapshoter.self.snapshotText( txt, 24 );
				
				if ( bmap.width > maxW ) maxW = bmap.width;
				if ( bmap.height > maxH ) maxH = bmap.height;
				
				
				arrCodes[ i ][ "symbol" ] = new Bitmap( bmap.bitmapData.clone() );
				
				
			}
			
			/*_tField.text = "max width: " + maxW + ", max height: " + maxH + ". ";
			_tField.y = yy + 30;
			this.addChild( _tField );*/
		}

	}
}