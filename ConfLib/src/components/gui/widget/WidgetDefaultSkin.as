package components.gui.widget
{
	import components.static.GuiLib;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class WidgetDefaultSkin extends Sprite
	{
		private var s1:Bitmap;
		private var s2:Bitmap;
		private var s3:Bitmap;
		private var s4:Bitmap;
		private var s5:Bitmap;
		private var s6:Bitmap;
		private var s7:Bitmap;
		private var s8:Bitmap;
		private var s9:Bitmap;
		private var sep:Sprite;
		
		public function WidgetDefaultSkin()
		{
			super();
			
			s1 = new GuiLib.cWindow_1;
			addChild( s1 );
			s2 = new GuiLib.cWindow_2;
			addChild( s2 );
			s3 = new GuiLib.cWindow_3;
			addChild( s3 );
			s4 = new GuiLib.cWindow_4
			addChild( s4 );
			s5 = new GuiLib.cWindow_5;
			addChild( s5 );
			s6 = new GuiLib.cWindow_6;
			addChild( s6 );
			s7 = new GuiLib.cWindow_7;
			addChild( s7 );
			s8 = new GuiLib.cWindow_8;
			addChild( s8 );
			s9 = new GuiLib.cWindow_9;
			addChild( s9 );
			
			sep = new Sprite;
			addChild( sep );
		}
		public function resize(w:int, h:int, opened:Boolean):void
		{
			/*
			this.graphics.clear();
			this.graphics.beginFill( 0xff0077 );
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
			*/
			s1.y = h-s1.height;
			
			s2.x = s1.width;
			s2.y = h-s2.height;
			s2.width = w - (s1.width + s3.width);
			
			s3.x = w-s3.width;
			s3.y = h-s3.height;
			
			s4.y = s7.height;
			s4.height = h - (s7.height + s1.height);
			
			s5.x = s7.width;
			s5.y = s7.height;
			s5.width = w - (s7.width + s9.width);
			s5.height = h - (s7.height + s1.height);
			
			s6.x = w-s6.width;
			s6.y = s9.width+1;
			s6.height = h - (s3.height + s9.height);
			
			s8.x = s7.width;
			s8.y = 3;
			s8.width = w - (s7.width + s9.width);
			
			s9.x = w-s9.width;

			sep.graphics.clear();
			if (opened) {
				sep.graphics.beginFill( 0xdedede );
				sep.graphics.drawRect(9,40,w-18,1);
				sep.graphics.endFill();
			}
		}
	}
}