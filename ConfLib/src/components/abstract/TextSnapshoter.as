package components.abstract
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;

	public class TextSnapshoter
	{
		[Embed(source = "../../assets/fonts/3947.ttf", unicodeRange="U+0-7F,U+400-4FF", mimeType = "application/x-font-truetype", fontName = "snapshot_font", embedAsCFF = "false")] 
		private const SNAP_FONT:Class;
		
		private var FONT_SIZE:int = 14;
		private const COLOR_BACKGROUND_SYMBOL:uint = 0xFFFFFF;
		
		public static var WIDTH_TEXTFIELD:int = 86;
		public static var HEIGHT_TEXTFIELD:int = 36;
		
		static private var _self:TextSnapshoter;

		private var _tfSymbols:TextField;
		
		private var _snapshot:Bitmap;
		
		public function get tfSymbols():TextField
		{
			return _tfSymbols;
		}
		

		static public function get self():TextSnapshoter
		{
			if( !_self ) _self = new TextSnapshoter();
			
			return _self;
		}
		
		public function TextSnapshoter()
		{
			init();
		}
		
		public function snapshotText( txt:String, size:int = 0 ):Bitmap
		{
			const format:TextFormat = _tfSymbols.getTextFormat();
			format.align = flash.text.TextFormatAlign.LEFT;
			format.size = size?size:FONT_SIZE;
			_tfSymbols.defaultTextFormat =  format ;
			
			_tfSymbols.text = txt;
			
			if( ( !_tfSymbols.textWidth || !_tfSymbols.textHeight ) && _tfSymbols.text.charCodeAt( 0 ) != Keyboard.SPACE ) _tfSymbols.text = ".";
			
			_snapshot = drawSymbols();
			
			return _snapshot;
		}
		
		public function snapshotTextField( txt:String, size:int = 0 ):Bitmap
		{
			const format:TextFormat = _tfSymbols.getTextFormat();
			format.size = size?size:FONT_SIZE;
			format.align = flash.text.TextFormatAlign.CENTER;
			_tfSymbols.defaultTextFormat =  format ;
			
			_tfSymbols.text = txt;
			
			const rect:Rectangle = new Rectangle( 0, 0, WIDTH_TEXTFIELD, HEIGHT_TEXTFIELD );
			
			var color:uint = uint( String( "0x" + rndF() + rndF() + rndF() + rndF() + rndF() + rndF() ) );
			
			
			//var bdata:BitmapData = new BitmapData( rect.width + rect.x + 4, rect.height + rect.y + 4, false );
			const bdata:BitmapData = new BitmapData( rect.width, rect.height, false, COLOR_BACKGROUND_SYMBOL?COLOR_BACKGROUND_SYMBOL:color );
			//const bdata:BitmapData = new BitmapData( rect.width, rect.height + rect.y, false, 0xFFFFFF );
			const matrix:Matrix = new Matrix();
			matrix.tx -= 1;
			matrix.ty -= 1;
			bdata.draw( _tfSymbols, matrix, null, null, null, true );
			
			function rndF():String
			{
				var d:uint = 0xD + ( 3 * Math.random() );
				
				
				
				return d.toString( 16 );
			}
			
			return new Bitmap( bdata );
		}
		
		
		
		
		private function init():void
		{
			_tfSymbols = createTFSymbols();
			
			
		}
		
		private function drawSymbols( ):Bitmap
		{
			
			
			const rect:Rectangle = _tfSymbols.getRect( _tfSymbols );
			
			var color:uint = uint( String( "0x" + rndF() + rndF() + rndF() + rndF() + rndF() + rndF() ) );
			
			
			
			const bdata:BitmapData = new BitmapData( rect.width, rect.height, false, COLOR_BACKGROUND_SYMBOL?COLOR_BACKGROUND_SYMBOL:color );
			const matrix:Matrix = new Matrix();
			matrix.tx -= rect.x;
			matrix.ty -= rect.y;
			bdata.draw( _tfSymbols, matrix, null, null, null, true );
			
			function rndF():String
			{
				var d:uint = 0xD + ( 3 * Math.random() );
				
				
				
				return d.toString( 16 );
			}
			
			return new Bitmap( bdata );
		}
		
		
		
		private function createTFSymbols( ):TextField
		{
			const fnt:Font = new SNAP_FONT();
			
			
			
			const tfr:TextFormat = new TextFormat( fnt.fontName, FONT_SIZE );
			tfr.align = TextFormatAlign.CENTER;
			
			const tf:TextField  = new TextField();
			tf.width = WIDTH_TEXTFIELD;
			tf.height = HEIGHT_TEXTFIELD;
			tf.wordWrap = false;
			tf.embedFonts = true;
			tf.multiline = true;
			tf.defaultTextFormat = tfr;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.text = "Съешь еще этих мягких французских булок. Да выпей чаю! Jkdlsdf dksldfkd";
			
			
			
			
			return tf;
		}
		
		
		
		
		
	}
}