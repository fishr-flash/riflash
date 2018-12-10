package components.gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.static.COLOR;
	
	public class PopWindow extends UIComponent implements IResizeDependant
	{
		private var bg:Sprite;
		private var mess:TextField;
		private var buttons:Vector.<TextButton>;
		private var callback:Function;
		private var DO_FADE_OUT:Boolean;
		private var task:ITask;
		
		private static var inst:PopWindow;
		public static function getInst():PopWindow
		{
			if (!inst)
				inst = new PopWindow;
			return inst;
		}
		
		public function PopWindow()
		{
			super();
			
			var dropShadow:DropShadowFilter = new DropShadowFilter(); 
			dropShadow.distance = 0; 
			dropShadow.angle = 45; 
			dropShadow.color = COLOR.BLACK; 
			dropShadow.alpha = 1; 
			dropShadow.blurX = 5; 
			dropShadow.blurY = 5; 
			dropShadow.strength = 1; 
			dropShadow.quality = BitmapFilterQuality.HIGH; 
			dropShadow.inner = false; 
			dropShadow.knockout = false; 
			dropShadow.hideObject = false; 
			
			bg = new Sprite;
			addChild( bg );
			bg.filters = [dropShadow];
			
			var tf:TextFormat = new TextFormat;
			tf.align = TextFormatAlign.CENTER;
			
			mess = new TextField;
			addChild( mess );
			mess.x = 10;
			mess.y = 5;
			mess.width = 400;
			mess.height = 1;
			//				mess.border = true;
			mess.selectable = false;
			mess.wordWrap = true;
			mess.defaultTextFormat = tf;
			
			buttons = new Vector.<TextButton>;
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.ROLL_OVER,onOver);
			this.addEventListener(MouseEvent.ROLL_OUT,onOut);
			
			this.visible = false;
		}
		/** buttons[ {title,edlegate}, {title, delegate}.... ]	*/
		public function construct( msg:String, delegate:Function):void
		{
			mess.htmlText = "<b><font face='Tahoma' size='12' color='#"+COLOR.TRIPLE_GREY.toString(16)+"'>" + loc(msg) + "</font></b>"; 
			callback = delegate;

			mess.height = mess.textHeight + 10;
			mess.height = mess.textHeight + 10;
			
			bg.graphics.clear();
			bg.graphics.beginFill( COLOR.ANGELIC_GREY );
			bg.graphics.drawRoundRect(0,0,mess.width+20,mess.height+5,25,25);
			bg.graphics.endFill();
		}
		public function close():void
		{
			if (this.visible) {
				this.visible = false;
				ResizeWatcher.removeDependent(this);
				if( task )  
					task.stop();
			}
		}
		public function open():void
		{
			task = TaskManager.callLater(fade, 5000, [true]);
			ResizeWatcher.addDependent(this);
			this.alpha = 0;
			this.visible = true;
			fade(false);
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			this.x = int(w/2 - this.width/2);
			this.y = h - 100;
		}
		private function fade(out:Boolean):void
		{
			if (out && task )  
				task.stop();
			DO_FADE_OUT = out;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame );
		}
		private function onEnterFrame(e:Event):void
		{
			if (DO_FADE_OUT) {
				if (this.alpha > 0.1 )
					this.alpha -= 0.04;
				else {
					close();
					this.alpha = 1;
					this.removeEventListener(Event.ENTER_FRAME, onEnterFrame );
				}
			} else {
				if (this.alpha < 0.95 )
					this.alpha += 0.04;
				else {
					this.alpha = 1;
					this.removeEventListener(Event.ENTER_FRAME, onEnterFrame );
				}
			}
		}
		private function onClick(value:int):void
		{
			if( callback is Function )
				callback();
			close();
		}
		private function onOver(e:Event):void
		{
			this.alpha = 1;
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame );
			if( task )  
				task.stop();
		}
		private function onOut(e:Event):void
		{
			if (task)
				task.repeat();
			else
				task = TaskManager.callLater(fade, 5000, [true]);
		}
	}
}