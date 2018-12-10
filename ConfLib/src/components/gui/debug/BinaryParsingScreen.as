package components.gui.debug
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import components.gui.SimpleTextField;
	import components.gui.triggers.SpriteVisualButton;
	import components.protocol.models.BinaryModel;
	import components.static.COLOR;
	import components.static.GuiLib;
	
	public class BinaryParsingScreen extends Sprite
	{
		private var title:SimpleTextField;
		private var hex:SimpleTextField;
		private var dec:SimpleTextField;
		private var errors:SimpleTextField;
		private var b_close:SpriteVisualButton;
		
		
		public function BinaryParsingScreen()
		{
			super();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
			this.addEventListener(MouseEvent.ROLL_OVER, mOver);
			this.addEventListener(MouseEvent.ROLL_OUT, mOut);
			
			this.doubleClickEnabled = true;
			
			var filter:DropShadowFilter = new DropShadowFilter(3,45,20,0.5);
			this.filters = [filter];
			
			title = new SimpleTextField("", 170);
			addChild( title );
			title.setSimpleFormat("left");
			//title.wordWrap = false;
			hex = new SimpleTextField("", 200);
			addChild( hex );
			hex.setSimpleFormat("center");
			hex.x = title.width;
			//hex.wordWrap = false;
			dec = new SimpleTextField("", 450);
			addChild( dec );
			//dec.wordWrap = false;
			dec.setSimpleFormat("left");
			dec.x = hex.x + hex.width + 30;
			
			
			errors = new SimpleTextField("", 410);
			addChild( errors );
			errors.setSimpleFormat("left");
			errors.x = title.width;
			errors.wordWrap = true;
			
			b_close = new SpriteVisualButton( GuiLib.close );
			addChild( b_close );
			b_close.setUp("", onClose );
			b_close.onlyPicture = true;
			b_close.x = 570;
			b_close.y = -5;
			
		}
		public function open(bm:BinaryModel):void
		{
			title.htmlText = bm.title;
			//title.height = title.textHeight + 10;
			hex.text = bm.hex;
			//hex.height = title.textHeight + 10;
			dec.htmlText = bm.dec;
			//dec.height = title.textHeight + 10;
			errors.text = bm.error;
			//errors.height = title.textHeight + 10;
			draw(title.textHeight + 10+ 20);
			
			
			if (this.x == 0 && this.y == 0 ) {
				this.x = 400;
			}
			
			this.visible = true;
			
			
			/*this.x = 267;
			this.y = 0;//-(title.textHeight + 10+ 20);

			var p:Point = new Point(x,y);
			var pg:Point = this.localToGlobal( p );*/
		}
		
		private function mDown(e:MouseEvent):void
		{
			if (e.shiftKey) {
				onClose();
			} else if (e.ctrlKey) {
				this.y = -200;
			} else { 
				stage.addEventListener(MouseEvent.MOUSE_UP, mUp );
		//		var p:Point = globalToLocal( new Point );
				//var r:Rectangle = new Rectangle(p.x,p.y, + ResizeWatcher.lastWidth,  ResizeWatcher.lastHeight);
				this.startDrag();///false,r);
			}
		}
		private function mUp(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mUp );
			this.stopDrag();
		}
		private function mOver(e:MouseEvent):void
		{
		}
		private function mOut(e:MouseEvent):void
		{
		}
		private function draw(h:int):void
		{
			this.graphics.clear();
			this.graphics.beginFill( COLOR.WHITE_GREY );
			const padding:int = -10;
			//this.graphics.drawRoundRect(-10,-10,600,h,10,10);
			this.graphics.drawRect(padding,padding,this.width,h);
			this.graphics.endFill();
			
			var draw:Boolean = false;
			
			const  ellipseWidth:int = 5;
			const ww:int = this.width - ( ellipseWidth - ( padding * 2 ) );
			for (var i:int=0; i<h; i) {
				if (draw) {
					if (i+3+14 > h)
						break;
					this.graphics.beginFill( COLOR.ANGELIC_GREY );
					this.graphics.drawRoundRect( 0,i+3,ww,14, ellipseWidth,5);
					this.graphics.endFill();
				}
				draw = !draw;
				i+=14;
			}
			
			b_close.x = this.width - b_close.width - 20;
			
			
		}
		private function onClose():void
		{
			this.visible = false;
		}
	}
}