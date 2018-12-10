package components.screens.page
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import components.Decoder;
	import components.abstract.LOC;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.events.GUIEvents;
	import components.gui.PopUp;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.NAVI;
	
	import su.fishr.utils.Dumper;

	public class LogoLoader extends FirmWareAdvLoader
	{
		private const FILE_TYPES:Array = [new FileFilter("Picture", "*.png;*.jpg;*.bmp;*.tif;*.gif")];
		private const MAX_WIDTH:int = 64;
		private const MAX_HEIGHT:int = 64;
		
		private var pic:Bitmap;
		
		private var border:Shape;
		
		public function LogoLoader()
		{
			super();
			
			CMD_PART = CMD.LCD_LOGO_IMG;
			CMD_WRITE = CMD.LCD_LOGO_WRITE;
			CMD_CRC = CMD.LCD_LOGO_CRC32;
			
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
			
			if (pic && !CLIENT.IS_WRITING_FIRMWARE) {
				removeChild(pic);
				pic = null;
				/*removeChild(border);
				border = null;*/
				group.movey("1",0 );
			}
		}
		override protected function onLoadComlete(b:ByteArray, fr:FileReference):void
		{
			super.onLoadComlete(b,fr);
			Decoder.getInst().decode( b, placeBitmap, MAX_WIDTH, MAX_HEIGHT );
		}
		private function placeBitmap(bitmap:Bitmap):void
		{
			if (bitmap) {
				if (pic)
					removeChild(pic);
				pic = bitmap;
				replace(pic.bitmapData);
				addChild( pic );
				group.movey("1",130 );
				
				/*if (!border) {
					border = new Shape;
					border.graphics.lineStyle(1,COLOR.GREY_GLOBAL_OUTLINE,0.5);
					border.graphics.drawRect(-1,-1,201,121);
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
			firmware = new ByteArray;
			firmware.endian = Endian.LITTLE_ENDIAN;
			var color:uint, bgcolor:uint = 0x00e7e7e7;
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
			
			
			////////////////////TRACE//////////////////////////////
			///TODO: trace
			trace
			(
				"project:  Conf_lcd",
				"file:  LogoLoader.as"
				,"\r  firmware: ", Dumper.dump( firmware )
			);
			
			firmware.position = 0;
			for(  i = 0; i < 128; i++ )
			{
				dtrace( "#" + i + ", " + firmware.readByte() ) ;
				trace( "#" + i + ", " + firmware.readByte() ) ;
			}
			////////////////////////////////////////////////////////
		}
		private function get16bitColor(color:uint):uint
		{
			var r8:uint = (color & 0x00ff0000) >> 16, g8:uint= (color & 0x0000ff00) >> 8, b8:uint = color & 0x000000ff;
			var r5:uint = r8*(0x1f/0xff), g6:uint = g8*(0x3f/0xff), b5:uint = b8*(0x1f/0xff);
			var _r5:uint = r5 << 11, _g6:uint = g6 << 5, _b5:uint = b5;
			var result:uint = _b5 + _g6 + _r5;
			return result;
		}
		override protected function writeToDevice():void
		{
			CLIENT.AUTOPAGE_WHILE_WRITING = NAVI.LOGO;
			super.writeToDevice();
		}
		override protected function cancelWrite():void
		{
			CLIENT.AUTOPAGE_WHILE_WRITING = 0;
			super.cancelWrite();
		}
		override protected function finishWritingFirmware():void
		{
			CLIENT.AUTOPAGE_WHILE_WRITING = 0;
			super.finishWritingFirmware();
		}
		override protected function getLabel(key:int):String
		{
			switch(key) {
				case LABEL_LOAD_FROM_FILE:
					return loc("lcdkey_load");
				case LABEL_DO_UPDATE:
					return loc("lcdkey_save_logo");
				case LABEL_UPDATE_COMPLETE:
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
	}
}