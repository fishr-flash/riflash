package components.gui.visual
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import components.gui.SimpleTextField;
	import components.gui.triggers.MButton;
	import components.static.GuiLib;
	
	/** ScreenBlock v 1.0	*/
	
	public class ScreenBlock extends Sprite
	{
		public static var MODE_SIMPLE_TEXT:int = 0x00;  
		public static var MODE_WARNING:int = 0x01;
		public static var MODE_ONLY_BLOCK:int = 0x02;
		public static var MODE_LOADING:int = 0x03;
		public static var MODE_LOADING_TEXT:int = 0x04;
		
		private var message:SimpleTextField;
		private var w:int;
		private var h:int;
		private var c:int;
		private var modeId:int;
		private var field:Array
		private var customColor:uint = 0xffffffff;
		
		private var progress:MovieClip;
		private var preloading:GUILoading;
		private var button:MButton;
		
		public var alphalevel:Number=0.7;
		
		public function ScreenBlock( _width:int, _height:int, _mode:int, _message:String="", _color:uint=0xffffff, _rect:Array=null )
		{
			super();
			
			w = _width;
			h = _height;
			c = _color;
			modeId = _mode;

			progress = new GuiLib.load_gears;
			addChild( progress );
			
			preloading = new GUILoading;
			addChild( preloading );
			preloading.visible = false;
			
			message = new SimpleTextField( _message, _width );
			addChild( message );
			message.setSimpleFormat("center",-7,18, true);
			message.text = _message;
			message.height = message.textHeight + 10;
			message.x = int((_width - message.width)/2);
			message.y = int((_height - message.height)/2);
			
			field = new Array;
			field.push( [0,0,w,h] );
			if ( _rect )
				field = field.concat( _rect );
			
			this.mode( modeId );
		}
		public function setCustomPicture(c:Class):void
		{
			if (progress)
				removeChild( progress );
			progress = new c;
			addChild( progress );
		}
		public function setCustomColor(c:uint):void
		{
			customColor = c;
		}
		public function resize( _w:int, _h:int ):void
		{
			w = _w;
			h = _h;
			this.field[0] = [0,0,w,h];
			message.width = _w-20; 
			message.x = int((_w - message.width)/2);
			message.y = int((_h - message.height)/2);
			
			progress.x = int((_w - progress.width)/2 + progress.width/2) ;
			progress.y = int((_h - progress.height)/2 + progress.width/2);
			
			preloading.x = int((_w - progress.width)/2 + progress.width/2);
			preloading.y = int((_h - progress.height)/2 + progress.width/2)+ 30;
			
			if (button) {
				button.x = int((_w - button.width)/2);
				button.y = int((_h - button.height)/2 + button.width/2);
			}
			
			mode( modeId,"" );
		}
		public function mode( _mode:int, _text:String="" ):void 
		{
			this.graphics.clear();
			
			modeId = _mode;
			
			if ( _text != "" )
				text = _text;
			
			if (progress)
				progress.visible = false;
			
			switch ( _mode ) 
			{
				case MODE_SIMPLE_TEXT:
					this.graphics.beginFill( 0xffffff, alphalevel);
					message.textColor = 0x000000;
					message.visible = true;
					break;
				case MODE_WARNING:
					message.textColor = 0xff0000;
					message.visible = true;
					this.graphics.beginFill( c, alphalevel + 0.2 );
					break;
				case MODE_ONLY_BLOCK:
					message.visible = false;
					this.graphics.beginFill( c, alphalevel );
					break;
				case MODE_LOADING:
					this.graphics.beginFill( customColor < 0xffffffff? customColor:0xecf0f6, alphalevel );
					progress.visible = true;
					text = "";
					break;
				case MODE_LOADING_TEXT:
					this.graphics.beginFill( 0xecf0f6, alphalevel );
					progress.visible = true;
					message.visible = true;
					break;
			}
			var len:int = field.length;
			for(var i:int; i<len; ++i) {
				this.graphics.drawRect( field[i][0],field[i][1],field[i][2],field[i][3]);
			}
			this.graphics.endFill();
		}
		public function set text( _value:String ):void
		{
			message.text = _value;
			message.height = message.textHeight + 15;
			message.y = int((h - message.height)/2);
		}
		public function linkage(f:Function):void
		{	// скинуть линк для прелоадинга управляющему компоненту
			preloading.link(f);
			preloading.visible = true;
		}
		public function createbutton(args:Object):void
		{
			if( button )
				removeChild( button );
			button = new MButton(args.title,args.callback);
			button.width = 142;
			addChild( button );
		}
		private function forceVisible():void
		{
			preloading.halt();
			visible = false;
		}
		override public function set visible(value:Boolean):void
		{
			if (this.visible && !value && preloading.visible )
				preloading.execWhenFinish(close);
			else
				super.visible = value;
			if(!value)
				removeButton();
		}
		private function close():void
		{
			this.visible = false;
		}
		private function removeButton():void
		{
			if (button) {
				removeChild( button );
				button = null;
			}
		}
	}
}