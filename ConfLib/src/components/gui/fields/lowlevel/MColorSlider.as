package components.gui.fields.lowlevel
{
	import components.static.COLOR;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MColorSlider extends MSlider
	{
		private var lineOver:Shape;
		private var lineMask:Shape;
		
		public function MColorSlider(w:int=180)
		{
			super(w);
		}
		override protected function construct():void
		{
			line = new Shape;
			addChild( line );
			
			this.addEventListener( Event.ADDED_TO_STAGE, added );
			
			this.graphics.clear();
			this.graphics.beginFill( COLOR.WHITE, 0 );
			this.graphics.drawRect(0,0,_width,20);
			this.graphics.endFill();
			
			lineOver = new Shape;
			addChild( lineOver );
			
			lineMask = new Shape;
			addChild( lineMask );
			
			lineMask.graphics.beginFill( COLOR.WHITE );
			lineMask.graphics.drawRect(0,0,_width,20);
			lineMask.graphics.endFill();
			
			lineOver.mask = lineMask;
			
			draw();
		}
		override public function setUp(min:String, max:String):void {}
		override public function update(o:Object):void
		{
			var n:Number = Number(o) > 1 ? 1 : Number(o);
			n = n < 0 ? 0 : n; 
			var w:int = Math.round(((n*_width)/6))*6;
			
			lineMask.graphics.clear();
			lineMask.graphics.beginFill( COLOR.WHITE );
			lineMask.graphics.drawRect(0,0,w,20);
			lineMask.graphics.endFill();
		}
		override public function setPosition(coef:Number):void
		{
			super.setPosition(coef);
			draw();
		}
		override protected function draw():void
		{
			paintOn( line, position, 0.4 );
			paintOn( lineOver, position );
		}
		override protected function mMove(ev:Event):void
		{
			super.mMove(ev);
			draw();
		}
		override protected function mUp(ev:MouseEvent):void
		{
			super.mUp(ev);
			draw();
		}
		private function paintOn(s:Shape, center:Number=0.5, a:Number=1):void
		{
			s.graphics.clear();
			s.graphics.beginFill( COLOR.GREEN_SIGNAL, a );
			
			var square:int = 5;
			var shift:int = square + 1;
			var total:int = 30;
			
			for (var i:int=0; i<total; ++i) {
				if (i == Math.round(total*position) )
					s.graphics.beginFill( COLOR.RED, a );
				
				s.graphics.drawRect(shift*i,0,square,8);				
			}
			
			s.graphics.endFill();
		}
		override protected function get sliderPosY():int
		{
			return 15;
		}
	}
}