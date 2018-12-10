package components.gui.fields.lowlevel
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	
	public class MSlider extends Sprite
	{
		protected var CONTROL:Boolean=true; 		// при true выводить и отрабатывать ползунок 
		
		private var tRight:SimpleTextField;
		private var tLeft:SimpleTextField;
		private var rect:Rectangle;
		private var isDragging:Boolean = false;
		
		protected var _width:Number;
		
		protected var pointer:Sprite;
		protected var line:Shape;
		
		public var position:Number=0;
		
		public function MSlider(w:int=180)
		{
			super();
			_width = w;
			construct();
		}
		protected function construct():void
		{
			line = new Shape;
			addChild( line );
			
			tLeft = new SimpleTextField(loc("g_min"), 40);
			tLeft.setSimpleFormat( "left" );
			addChild( tLeft );
			tLeft.y = 1;
			tLeft.x = -40;
			
			tRight = new SimpleTextField(loc("g_max"), 40);
			tRight.setSimpleFormat( "right" );
			tRight.x = _width;//-(50-4);
			addChild( tRight );
			tRight.y = 1;
			
			this.addEventListener( Event.ADDED_TO_STAGE, added );
			
			draw();
		}
		protected function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill( COLOR.WHITE, 0 );
			this.graphics.drawRect(0,0,_width,20);
			this.graphics.endFill();
			
			line.graphics.beginFill( COLOR.SATANIC_GREY );
			line.graphics.drawRect(0,0,_width,2);
			line.graphics.endFill();
			line.graphics.beginFill( COLOR.SATANIC_GREY );
			line.graphics.drawRect(0,2,1,2);
			for (var i:int=1; i<_width; i) {
				i+=2;
				if (i+2>_width)
					break;
				line.graphics.drawRect(i,2,2,2);
				i+=2;
			}
			line.graphics.drawRect(i,2,1,2);
			line.graphics.endFill();
		}
		public function setUp(min:String, max:String):void
		{
			tLeft.text = min;
			tRight.text = max;
			tLeft.height = 20;
			tRight.height = 20;
		}
		public function setPosition(coef:Number):void
		{
			if (pointer)
				pointer.x = int(_width*coef);
			position = coef;
		}
		public function update(o:Object):void {}
		public function control(b:Boolean):void
		{
			if (pointer)
				pointer.visible = b;
			CONTROL = b;
		}
		public function isControlled():Boolean
		{
			return CONTROL;
		}
		private function drawPointer():void
		{
			if ( !pointer ) {
				pointer = new Sprite;
				addChild( pointer );
				this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
				stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
					
				pointer.y = sliderPosY;
				rect = new Rectangle(0,sliderPosY,_width,0);
			}
			pointer.graphics.beginFill( COLOR.WHITE_GREY);
			pointer.graphics.moveTo(-7, 7);
			pointer.graphics.lineTo(0, -7);
			pointer.graphics.lineTo(7, 7);
			pointer.graphics.lineTo(-7, 7);
			pointer.graphics.endFill();
			pointer.graphics.lineStyle( 1, COLOR.MEDIUM_GREY );
			pointer.graphics.moveTo(-7, 7);
			pointer.graphics.lineTo(0, -7);
			pointer.graphics.lineTo(7, 7);
			pointer.graphics.lineTo(-7, 7);
			pointer.graphics.endFill();
		}
		private function mDown(ev:MouseEvent):void
		{
			isDragging = true;
			pointer.startDrag( true, rect );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mMove );
		}
		protected function mUp(ev:MouseEvent):void
		{
			pointer.stopDrag();
			if (isDragging && position != pointer.x/_width) {
				position = pointer.x/_width;
				this.dispatchEvent( new Event(Event.CHANGE) );
			}
			isDragging = false;
			if (stage)
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, mMove );
		}
		protected function added(ev:Event):void
		{
			if (CONTROL)
				drawPointer();
		}
		protected function get sliderPosY():int
		{
			return 12;
		}
		protected function mMove(ev:Event):void
		{
			if (position != pointer.x/_width) {
				position = pointer.x/_width;
				this.dispatchEvent( new Event(Event.CHANGE) );
			}
		}
		override public function get width():Number
		{
			return _width;
		}
	}
}