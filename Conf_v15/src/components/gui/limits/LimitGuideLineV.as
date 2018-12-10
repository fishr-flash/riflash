package components.gui.limits
{
	import components.abstract.AccEngine;
	import components.events.AccEvents;
	import components.gui.SimpleTextField;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class LimitGuideLineV extends LimitGuideLine
	{
		public function LimitGuideLineV(h:int, c:int)
		{
			super();
			
			color = c;
			
			ring = new Shape;
			addChild( ring );
			ring.visible = false;
			
			ring.graphics.clear();
			ring.graphics.beginFill(color,0.2 );
			ring.graphics.drawCircle(0,0,20);
			
			triangle = new Sprite;
			addChild( triangle );
			triangle.graphics.beginFill(c);
			//triangle.graphics.moveTo( 0,0 );
			triangle.graphics.lineTo( -6, 15 );
			triangle.graphics.lineTo( 6, 15);
			triangle.graphics.lineTo( 0,0 );
			triangle.graphics.endFill();
			triangle.graphics.beginFill(color,0 );
			triangle.graphics.drawCircle(0,9,20);
			
			resize(h);
			
			triangle.addEventListener( MouseEvent.MOUSE_OVER, mOver );
			triangle.addEventListener( MouseEvent.MOUSE_OUT, mOut );
		}
		public function resize(n:int):void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 2, color );
			var i:int=5;
			var alteration:Boolean = false;
			this.graphics.moveTo( 0,0 );
			while(i<n) {
				if (alteration)
					this.graphics.moveTo( 0,i );
				else
					this.graphics.lineTo( 0,i);
				alteration = !alteration;
				i += 5;
			}
			
			triangle.y = n;
			ring.y = n+9;
			
			if (AccEngine.EXPAND)
				limit = 519;
			else
				limit = 229;
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
			this.dispatchEvent( new AccEvents( AccEvents.onSharedGuideLineMove, this.x));
		}
	}
}