package components.screens.page
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.BitmapfontUploadServant;
	import components.abstract.servants.RawIconServant;
	import components.gui.triggers.TextButton;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.system.CONST;
	import components.abstract.IconLoader;
	
	public class UploaderGraphicsForLCD3 extends UIComponent implements IServiceFrame
	{

		private var iconLoader:IconLoader;
		private var btnUpload:TextButton;
		private var totalItems:int;
		private var currentItem:int;

		private var pBar:ProgressBar;
		
		public function UploaderGraphicsForLCD3()
		{
			super();
			
			btnUpload = new TextButton();
			if( CONST.DEBUG ) btnUpload.y = 100;
			this.addChild( btnUpload );
			btnUpload.setUp( loc( "load_font_and_icon" ), onUpload );
			
			iconLoader = new IconLoader();
			
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.y = btnUpload.y + btnUpload.height + 20;
			pBar.x = 1;
			pBar.width = 100;
			pBar.height = 10;
			pBar.label= "";
			pBar.visible = false;
			pBar.mode = "manual";
			pBar.maximum = 100;
			pBar.minimum = 0;
			
			/*addChild( iconLoader );
			iconLoader.y = 100;*/
			//iconLoader.x = btnUpload.x;
		}
		
		private function onUpload():void
		{
			totalItems = 0;
			const fontData:Array = BitmapfontUploadServant.instance.getFontData();
			
			
			
			
			
			
			//viewSymbols( fontData );
			
			var len:int = fontData.length;
			for (var i:int= 0; i< len; i++) 
			{
				
				/**
				 *  пример содержания эл-та
				 * fontData[ i ] ) : Array(3):
					[0] => (str,12) 0x00	0x0000	
					[1] => (str,4) 0x00
					[2] => (str,6) 0x0000
					[unicode] => (str,6) 0x0000
					[value] => (str,1) 
					[symbol] => [object Bitmap]
					[index] => (int,1) 0
					[code_cp] => (str,4) 0x00
					[input] => (str,12) 0x00	0x0000	
				 */
				
				if( fontData[ i ][ 'code_cp' ] == 0 ) continue;
				
				
				iconLoader.setAnyImageForLCD( 256 + int( fontData[ i ][ 'code_cp' ] ), fontData[ i ][ 'symbol' ], null,  onProgress  );
				totalItems++;
			}
			
			/**
			 * Ожидаемое значение:
			 * 
			 *  => Object (3): 
			 id:(int,2) 21
			 b16data:ByteArray (5): 
			 bytesAvailable:  0 ( int,1 ) 
			 endian: littleEndian ( str,12 ) 
			 length: 5408 ( int,4 ) 
			 objectEncoding: 3 ( int,1 ) 
			 position: 5408 ( int,4 ) 
			 bmdata:[object BitmapData]
			 
			 */
			const icons:Array = RawIconServant.inst.getMaterials();
			len = icons.length;
			
			for (var j:int=0; j<len; j++) 
			{
				
				iconLoader.setAnyImageForLCD(  icons[ j ].id, new Bitmap( icons[ j ].bmdata ), icons[ j ].b16data, onProgress  );
				totalItems++;
				//iconLoader.setAnyImageForLCD(   icons[ j ].id, new Bitmap( icons[ j ].bmdata ) );
				
			}
				
			
			
			btnUpload.disabled = true;
			
			pBar.setProgress( 0, totalItems );
			pBar.label = loc("fw_loaded")+"0%";
			pBar.visible = true;
			
		}
		
		
		private function viewSymbols( fontData:Array ):void
		{
			///INFO: Отладочный вывод символов на экран
			var len:int = fontData.length;
			var xx:int = 0;
			var yy:int = 0;
			var maxW:int = 0;
			var maxH:int = 0;
			for (var i:int=0; i<len; i++) 
			{
				const dO:DisplayObject = this.addChild( fontData[ i ][ 'symbol' ] );
				dO.x = xx;
				xx += dO.width + 20;
				dO.y = yy;
				if( !( i%20 ) )
				{
					yy += maxH + 10;
					xx = 0;
				}
				
				if( dO.width > maxW ) maxW = dO.width;
				if( dO.height > maxH ) maxH = dO.height;
				
			}
		}
		
		private function onProgress( value:int ):void
		{
			
			
			if( value > -1 )
			{
				currentItem = totalItems - value;
				pBar.setProgress( currentItem, totalItems );
				pBar.label = pBar.label = loc("fw_loaded") + Math.ceil( ( currentItem  /  totalItems ) * 100 ) +"%";
			}
			else
			{
				pBar.visible = false;
				btnUpload.disabled = false;
			}
			
		}
		public function close():void
		{
		}
		
		public function init():void
		{
		}
		
		public function block(b:Boolean):void
		{
			//pBar.enabled != btnUpload.disabled = b;
				
		}
		
		public function put(p:Package):void
		{
		}
		
		public function getLoadSequence():Array
		{
			return null;
		}
		
		public function isLast():void
		{
		}
	}
}