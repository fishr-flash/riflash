package components.abstract
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import components.Decoder;
	import components.abstract.functions.loc;
	import components.events.GUIEvents;
	import components.gui.PopUp;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.screens.page.FirmWareAdvLoaderLCD3;

	public class IconLoader extends FirmWareAdvLoaderLCD3
	{
		
		private const PSEUDO_ALPHA:uint = 0xFFFF;
		private const AS_ALPHA:uint = 0x0F000000;
		
		
		private const FILE_TYPES:Array = [new FileFilter("Picture", "*.png;*.jpg;*.bmp;*.tif;*.gif")];
		
		private const ADRRESSES_AREA:int = 16384; // область памяти отведенная под размещение данных о месте хранения и свойствах изображенийй
		private const LOGO_SIZE:int = 153600; // размер лого в байтах
		private const BACKGROUND_SIZE:int = 2; // размер образца цвета фона в байтах
		private const SIZE_ONE_PART:int = 128;
		private const WIDTH_ICON:int = 52;
		private const HEIGHT_ICON:int = 52;
		private const WIDTH_LOGO:int = 320;
		private const HEIGHT_LOGO:int = 240;
		
		private static var FIRST_BUSY_PARTS:int; /// кол-во первых структур которые займут лого и пиксель цвета бэка
		private static var SECOND_BUSY_PARTS:int; /// кол-во структур которые займут 100 иконок по утвержденным размерам ( сейчас 52х52 )
		private static var THIRD_BUSY_PARTS:int; /// кол-во структур которые займут 100 иконок по утвержденным размерам ( сейчас 52х52 )
		private static var VALUE_PARTS_OF_ICON:int;
		private static var VALUE_PARTS_OF_TEXT_LABEL:int;
		private static var VALUE_PARTS_OF_BITMAPFONT:int;
		private const ONE_PX_SIZE:int = 2; /// Один пиксель выражается 2мя байтами ( 16 бит, 5 - красное, 6 зеленое, 5 голубое )
		
		
		
		
		private var pic:Bitmap;
		
		private var border:Shape;
		private var _firstPart:int;

		private var _addressPart:int;
		
		private var _chainImages:Array;
		private var _buseSys:Boolean;

		private var progressCall:Function;
		
		public function IconLoader( )
		{
			super();
			
			
			
			CMD_PART = CMD.KBD_ICO_STORAGE;
			CMD_WRITE = CMD.LCD_LOGO_WRITE;
			CMD_CRC = CMD.LCD_LOGO_CRC32;
			FIRST_BUSY_PARTS = Math.ceil( LOGO_SIZE / SIZE_ONE_PART ) + Math.ceil( BACKGROUND_SIZE / SIZE_ONE_PART );
			VALUE_PARTS_OF_ICON = Math.ceil( ( HEIGHT_ICON * WIDTH_ICON * ONE_PX_SIZE ) / SIZE_ONE_PART );
			SECOND_BUSY_PARTS = ( VALUE_PARTS_OF_ICON  * 98 ); /// под иконки, бэкграунд и лого выделяется 100 первых разделов, соотв. чисто под иконки 98
			VALUE_PARTS_OF_TEXT_LABEL = Math.ceil( ( TextSnapshoter.HEIGHT_TEXTFIELD * TextSnapshoter.WIDTH_TEXTFIELD * ONE_PX_SIZE ) / SIZE_ONE_PART );
			THIRD_BUSY_PARTS = ( VALUE_PARTS_OF_TEXT_LABEL * ( 185 - 100 ) );
			VALUE_PARTS_OF_BITMAPFONT = Math.ceil( ( 28 * 31  * ONE_PX_SIZE ) / SIZE_ONE_PART );
			
			
			isLast();
		}

		

		override public function reset():void
		{
			super.reset();
			if (pic && !CLIENT.IS_WRITING_FIRMWARE) {
				removeChild(pic);
				pic = null;
				/*removeChild(border);
				border = null;*/
				group.movey("1",0 );
			}
		}
		override public function init():void
		{
			super.init();
			
			if (pic && pic.parent && !CLIENT.IS_WRITING_FIRMWARE) {
				pic.parent.removeChild(pic);
				pic = null;
				/*removeChild(border);
				border = null;*/
				group.movey("1",0 );
			}
		}
		
		
		public function setAnyImageForLCD(  structId:int, image:Bitmap, b16data:ByteArray = null, _progressCall:Function = null ):void
		{
			
			
			if( !_chainImages ) _chainImages = new Array();
			
			if( image )
				_chainImages.push( [ image, structId, b16data ] );
			
			if( _progressCall != null )progressCall = _progressCall;
			
			
			if( !_buseSys )
			{
				const pack:Array = _chainImages.shift();
				
				placeBitmap( pack[ 0 ] );
				if( pack[ 2 ] ) 
				{
					firmware = new ByteArray;
					firmware.endian = Endian.LITTLE_ENDIAN;
					firmware.writeBytes(  pack[ 2 ] as ByteArray );
				}
				setNewId( pack[ 1 ] );
				_buseSys = true;
				
				
				writeToDevice();
			}
			
			
			if( progressCall != null ) progressCall( _chainImages.length );
			
		}
		
		
		
		public function setNewId( id:int):void
		{
			if( id == 1 )
				_firstPart =  0;
			else if( id > 2 && id < 101 )
				/// первые два раздела отводятся на лого и пиксель фона отнимаем их от введенного ид
				_firstPart =  FIRST_BUSY_PARTS + ( ( id - 3 ) * VALUE_PARTS_OF_ICON ) ;
			else if( id > 100 && id < 186 )
				_firstPart = FIRST_BUSY_PARTS + SECOND_BUSY_PARTS + ( ( id - 101 ) * VALUE_PARTS_OF_TEXT_LABEL ) ;
			else if( id > 255 && id < 512 )
				_firstPart =  FIRST_BUSY_PARTS + SECOND_BUSY_PARTS + THIRD_BUSY_PARTS +  ( ( id - 255 ) * VALUE_PARTS_OF_BITMAPFONT ) ;
			
				
			
			_addressPart = id;

		}
		
		override protected function onLoadComlete(b:ByteArray, fr:FileReference):void
		{
			const loader:Loader = new Loader();
			loader.loadBytes( b );
			
			const dec:BMPDecoder = new BMPDecoder();
			
			super.onLoadComlete(b,fr);
			//placeBitmap( Bitmap( loader.getChildAt( 0 )  ));
			if( _addressPart == 1 )
				Decoder.getInst().decode( b, placeBitmap, WIDTH_LOGO, HEIGHT_LOGO );
			else if( _addressPart > 2 && _addressPart < 101 )
			{
				//Decoder.getInst().decode( b, placeBitmap, WIDTH_ICON, HEIGHT_ICON );
				placeBitmap( new Bitmap( dec.decode( b ) ) );
				///Тут мы прямо складываем исходные бин данные изображения в битмассив который уйдет на прибор
				firmware = new ByteArray;
				firmware.endian = Endian.LITTLE_ENDIAN;
				firmware = dec.b16data;
				
			}
			else
			{
				Decoder.getInst().decode( b, placeBitmap, WIDTH_ICON, HEIGHT_ICON );
				
			}
				
			
		}
		
		private function placeBitmap(bitmap:Bitmap):void
		{
			
			const spr:Sprite = new Sprite();
			this.addChild( spr );
			if (bitmap) {
				
				if( _addressPart == 1 ) spr.scaleX = spr.scaleY = .5;
				if (pic && pic.parent )
					pic.parent.removeChild(pic);
				pic = bitmap;
				replace(pic.bitmapData);
				spr.addChild( pic );
				group.movey("1",130 );
				
				/*if (!border) {
					border = new Shape;
					border.graphics.beginFill( 0x666666 );
					border.graphics.lineStyle(1,COLOR.GREY_GLOBAL_OUTLINE,0.5);
					border.graphics.drawRect(-1,-1,WIDTH_ICON, HEIGHT_ICON);
					addChild( border );
				}*/
				
			} else {	// значит произошла ошибка кодировки
				
				PopUp.getInstance().construct( PopUp.wrapHeader(LOC.loc("sys_attention")), PopUp.wrapMessage(LOC.loc("logoloader_wrong_format")), PopUp.BUTTON_OK );
				PopUp.getInstance().open();
				reset();
			}
			this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
		}
		private function replace(bmd:BitmapData):void
		{
			/*firmware = new ByteArray;
			firmware.endian = Endian.LITTLE_ENDIAN;
			var color:uint;
			var alpha:uint;
			alpha = AS_ALPHA;
			var len:int = bmd.height;
			for (var i:int=0; i<len; ++i) {
				var lenj:int = bmd.width;
				for (var j:int=0; j<lenj; ++j) {
					color = bmd.getPixel32(j,i);
					
					
					
					const clr:uint = get16bitColor(color);
					
					
					if( color > alpha )firmware.writeShort( clr );
					else firmware.writeShort( PSEUDO_ALPHA );
				}
			}*/
			
			firmware = new ByteArray;
			firmware.endian = Endian.LITTLE_ENDIAN;
			var color:uint, bgcolor:uint = 0x00ffffff;
			var a:Number, alpha:uint, a_bg:Number, r:uint, g:uint, b:uint, bg:uint, _r:uint = bgcolor & 0x00ff0000 >> 16, _g:uint = bgcolor & 0x0000ff00 >> 8, _b:uint = bgcolor & 0x000000ff;
			var len:int = bmd.height;
			for (var i:int=0; i<len; ++i) {
				var lenj:int = bmd.width;
				for (var j:int=0; j<lenj; ++j) {
					color = bmd.getPixel32(j,i);
					alpha = ((color & 0xff000000) >> 24) & 0xff;
					
					if( alpha < 0xff ) {
						a = alpha/256 ;
						a_bg = 1-a;
						r = (color & 0x00ff0000) >> 16;
						g = (color & 0x0000ff00) >> 8;
						b = color & 0x000000ff;
						
						color = 0xff000000 + 
							((r*a + _r*a_bg) << 16) + 
							((g*a + _g*a_bg) << 8) +
							(b*a + _b*a_bg);
						
						bmd.setPixel32(j,i, color);
					
						
					}
					
					firmware.writeShort( get16bitColor(color) );
					
					
				}
			}
		}
		private function get16bitColor(color:uint):uint
		{
			var r8:uint = (color & 0x00ff0000) >> 16, g8:uint= (color & 0x0000ff00) >> 8, b8:uint = color & 0x000000ff;
			var r5:uint = r8*(0x1f/0xff), g6:uint = g8*(0x3f/0xff), b5:uint = b8*(0x1f/0xff);
			var _r5:uint = r5 << 11, _g6:uint = g6 << 5, _b5:uint = b5;
			var result:uint = _b5 + _g6 + _r5;
			return result;
		}
		override protected function writeToDevice( countStrc:int = 1 ):void
		{
			var data:Array = new Array();
			data = 
				[
					( _firstPart * SIZE_ONE_PART ) + ADRRESSES_AREA,
					firmware.length,
					pic.width,
					pic.height,
					0x00,
					0x00
				];
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.KBD_ICO_VECT_TABLE_STORAGE, onWriteToDevice, _addressPart, data, Request.URGENT, Request.PARAM_SAVE, ADDRESS ) );
			
			
		}
		
		private function onWriteToDevice( obj:* ):void
		{
			structCounter = _firstPart + 1; /// отсчет структур начинается с 1ой, а не с нулевой, поэтому добавляем 1
			super.writeToDevice( structCounter );
			
		}
		override protected function cancelWrite():void
		{
			CLIENT.AUTOPAGE_WHILE_WRITING = 0;
			super.cancelWrite();
		}
		
		
		
		override protected function finishWritingFirmware():void
		{
			
			_buseSys = false;
			
			if( _chainImages && _chainImages.length )
			{
				setAnyImageForLCD(  0, null );
			}
			else
			{
				
				CLIENT.AUTOPAGE_WHILE_WRITING = 0;
				super.finishWritingFirmware();
				if( progressCall != null ) progressCall( -1 );
			}
			
			
			
			
		}
		override protected function getLabel(key:int):String
		{
			switch(key) {
				case LABEL_LOAD_FROM_FILE:
					return loc("lcdkey_load");
				case LABEL_DO_UPDATE:
					return loc("lcdkey_save_logo");
				case LABEL_UPDATE_COMPLETE:
					if( !_chainImages )
					{
						RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT, null, 1, [ 1 ] ) );
						
					}
					return loc("lcdkey_load_complete");
				case LABEL_DO_UPDATE:
					return loc("lcdkey_load_fail");
				case LABEL_CANCEL_UPLOAD:
					return loc("lcdkey_load_cancel");
			}
			return "-";
		}
		override protected function getFileTypes():Array
		{
			return FILE_TYPES;
		}
		override protected function createSep():void {}
		override protected function createTitle(label:String):void {}
		
		
		public function interrupt():void
		{
			
			_chainImages = null;
		}
	}
}