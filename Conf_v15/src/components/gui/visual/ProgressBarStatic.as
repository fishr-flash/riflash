package components.gui.visual
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	import components.system.Library;
	
	public final class ProgressBarStatic extends Sprite
	{
		public var measure:String = "%";
		
		private var bg1:Bitmap;
		private var bg2:Bitmap;
		private var bg3:Bitmap;
		private var fillbox:Sprite;
		private var fill1:Bitmap;
		private var fill2:Bitmap;
		private var fill3:Bitmap;
		private var m:Shape;
		private var tf:SimpleTextField;
		
		private var w:int = 100;
		private var h:int;
		private var progress:Number;
		
		public function ProgressBarStatic(left:Class, middle:Class, right:Class, fillLeft:Class, fillmiddle:Class, fillRight:Class)
		{
			super();
			
			bg1 = new Library.c_pb_bg_left;
			addChild( bg1 );
			
			bg2 = new Library.c_pb_bg;
			addChild( bg2 );
			bg2.x = bg1.width;
			
			bg3 = new Library.c_pb_bg_right;
			addChild( bg3 );
			bg3.x = bg2.width + bg2.x;
			
			fillbox = new Sprite;
			addChild( fillbox );
			
			fill1 = new Library.c_pb_fill_left;
			fillbox.addChild( fill1 );
			
			fill2 = new Library.c_pb_fill;
			fillbox.addChild( fill2 );
			fill2.x = fill1.width;
			
			fill3 = new Library.c_pb_fill_right;
			fillbox.addChild( fill3 );
			fill3.x = fill2.width + fill2.x;
			
			m = new Shape;
			addChild( m );
			fillbox.mask = m;
			
			tf = new SimpleTextField("",w);
			tf.setSimpleFormat("center", 0, 11);
			addChild( tf );
			
			setProgress(0,10);
			
			h = bg1.height;
			tf.height = h+6;
			tf.y = -4;
			width = w;
		}
		public function setProgress(current:Number, total:Number):void
		{
			progress = current/total;
			tf.text = Math.round(progress*100) + measure;
			
			updateMask();
		}
		override public function set width(value:Number):void
		{
			w = value;
			
			bg2.width = w - (bg1.width + bg3.width);
			bg3.x = w - bg3.width;
			
			fill2.width = w - (fill3.width+fill1.width);
			fill3.x = w - fill3.width;
			
			updateMask();
			
			tf.width = value;
		}
		override public function get width():Number
		{
			return w;
		}
		override public function set height(value:Number):void		{		}
		override public function get height():Number
		{
			return h;
		}
		private function updateMask():void
		{
			m.graphics.clear();
			m.graphics.beginFill(COLOR.BLUE);
			m.graphics.drawRect(0,0,w*progress,h);
		}
	}
}