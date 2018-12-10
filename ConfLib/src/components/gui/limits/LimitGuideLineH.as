package components.gui.limits
{
	import components.abstract.AccEngine;
	import components.events.AccEvents;
	import components.gui.SimpleTextField;
	import components.interfaces.IFocusable;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class LimitGuideLineH extends LimitGuideLine implements IFocusable
	{
		protected var value:SimpleTextField;
		
		private var w:int;
		
		public function LimitGuideLineH(_w:int, c:int)
		{
			super();
			
			w = _w;
			
			ring = new Shape;
			addChild( ring );
			ring.visible = false;
			
			triangle = new Sprite;
			addChild( triangle );
			
			value = new SimpleTextField("-", 50, c );
			addChild( value );
			value.x = w + 17;
			value.y = -9;
			value.height = 20;
			
			color = c;
			
			triangle.addEventListener( MouseEvent.MOUSE_OVER, mOver );
			triangle.addEventListener( MouseEvent.MOUSE_OUT, mOut );
		}
		private function draw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 2, color );
			var i:int=5;
			var alteration:Boolean = false;
			this.graphics.moveTo( 1,0 );
			while(i<w) {
				if (alteration)
					this.graphics.moveTo( i,0 );
				else
					this.graphics.lineTo( i,0);
				alteration = !alteration;
				i += 5;
			}
			
			triangle.graphics.clear();
			triangle.graphics.beginFill(color);
			triangle.graphics.moveTo( w,0 );
			triangle.graphics.lineTo( w+15,-6 );
			triangle.graphics.lineTo( w+15, 6 );
			triangle.graphics.lineTo( w,0 );
			
			triangle.graphics.endFill();
			triangle.graphics.beginFill(color,0 );
			triangle.graphics.drawCircle(w+9,0,20);
			
			ring.graphics.clear();
			ring.graphics.beginFill(color,0.2 );
			ring.graphics.drawCircle(w+9,0,20);
			
			value.textColor = color;
		}
		public function resize(n:int):void
		{
			w = n;
			value.x = w + 17;
			draw();
			
			if (AccEngine.EXPAND)
				limit = 679;
			else
				limit = 339;
		}
		override public function set text(s:String):void
		{
			value.text = s;
		}
		override public function set color(c:uint):void
		{
			super.color = c;
			draw();
		}
		override public function set dragging(b:Boolean):void
		{
			if (b)
				this.addEventListener(Event.ENTER_FRAME, updateCoords );
			else
				this.removeEventListener(Event.ENTER_FRAME, updateCoords );
		}
		override public function updateCoords(ev:Event=null):void
		{
			var result:Number = AccEngine.getGbyY( this.y );
			if (result > 0)
				this.text = "+"+result.toFixed(2)+"g";
			else
				this.text = result.toFixed(2)+"g";
			this.dispatchEvent( new AccEvents( AccEvents.onSharedGuideLineMove, this.y));
		}
	}
}