package components.gui.visual.charsGraphic.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import aze.motion.eaze;
	
	import components.gui.visual.charsGraphic.ChartEvent;
	
	public class HLine extends BaseLine{
		
		public static const VALIGN_TOP:String = "valignTop";
		public static const VALIGN_BOTTOM:String = "valignBottom";
		public static const DURATION_TWEEN:Number = .7;
		public static const ALPHA_TWEEN:Number = .30;
		
		private var _mainW:int;
		private var _stepDotted:int = 10;
		private var _pointer:Sprite;
		private var _line:Sprite = new Sprite;
		private var _touchField:Sprite;
		private var _customInfo:TextField;
		private var _legend:TextField;
		private var _dragable:Boolean;
		private var _dragRect:Rectangle;
		private var _oldY:Number;
		private var _valign:String;
		
		
		
		
		
		public function get dragable():Boolean 
		{
			return _dragable;
		}
		
		public function get dragRect():Rectangle
		{
			return _dragRect;
		}
		public function set dragRect(value:Rectangle):void 
		{
			
			_dragRect = value;
			
			
		}
		
		public function HLine( mainw:int, color:uint, dragable:Boolean = false, valign:String = "valignTop" )
		{
			
			_mainW = mainw;
			_valign = valign;
			_dragable = dragable;
			initLine( color );
			
		}
		
		public function getRealY():Number
		{
			return this.y;
		}
		
		public function setYPos( ypos:Number ):void
		{
			this.y = ypos;
		}
		
		public function replaceValign( valign:String ):void
		{
			if ( !valign.length )
			{
				if ( _valign == VALIGN_TOP ) _legend.y = -25;
				else _legend.y = 0;
			}
			else if ( valign == VALIGN_BOTTOM ) _legend.y = 0;
			else _legend.y = -25;
		}
		
		public function startSilent():void
		{
			eaze( this ).to( DURATION_TWEEN, { alpha:ALPHA_TWEEN} );
		}
		
		public function stopSilent():void
		{
			eaze( this ).to( DURATION_TWEEN, { alpha:1} );
		}
		
		public function setCustomInfo( rel:String, legend:String = "" ):void
		{
			_customInfo.text = rel;
			if ( legend.length ) 
			{
				_legend.text = legend;
				_legend.x = ( _mainW -  _legend.width ) / 2;
			}
			
		}
		
		
		
		private function initLine( color:uint ):HLine
		{
			_line = drawLine( _mainW, color );
			
			//if ( _dragable ) this.alpha = ALPHA_TWEEN;
			
			this.addChild( _line );
			
			if ( _dragable )
				_pointer = createTriangle( color );
			else
				_pointer = createSquare( color );
			this.addChild( _pointer );
			_pointer.x = _mainW;
			_pointer.y = int( -_pointer.height / 2 );
			
			if ( _dragable )
			{
				_pointer.addEventListener(MouseEvent.MOUSE_DOWN, onmDown );
				_pointer.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver );
			}
			else
			{
				this.mouseChildren = this.mouseEnabled = _dragable;
			}
			
			
			_touchField = drawTouchField( color );
			this.addChild( _touchField );
			_touchField.x = _mainW + ( _pointer.width / 2 );
			_touchField.visible = false;
			_touchField.mouseEnabled = false;
			
			
			_customInfo = createTFInfo( color );
			_customInfo.x = _mainW + _pointer.width + 10;
			_customInfo.y = -_customInfo.height * 2;
			this.addChildAt( _customInfo, 0 );
			
			_legend = createTFInfo( color );
			_legend.autoSize = TextFieldAutoSize.LEFT;
			_legend.width = _mainW;
			_legend.x = 0;
			if ( _valign == VALIGN_TOP )_legend.y = -25;
			//else _legend.y = +25;
			this.addChildAt( _legend, 0 );
			
			
			
			return this;
		}
		
		
		
		private function onmDown(e:MouseEvent):void 
		{
			this.dispatchEvent( new ChartEvent( ChartEvent.LINE_ONM, false, false, { name: this.name } ) );
			_pointer.removeEventListener(MouseEvent.MOUSE_DOWN, onmDown );
			_pointer.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut );
			this.parent.addChild( this );
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onmUp );
			this.stage.addEventListener(Event.MOUSE_LEAVE, onmUp );
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove );
			this.alpha = 1;
			this.startDrag( false, _dragRect );
			
		}
		
		private function onMove(e:Event):void 
		{
			//if ( this.y  ==  _oldY  ) return;
			_oldY = this.y;
			
			this.dispatchEvent( new ChartEvent( ChartEvent.DRAG_LINE, false, false, { name: this.name, ypos: this.y } ) );
			
			
		}
		
		private function onmUp(e:MouseEvent):void 
		{
			
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove );
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onmUp );
			this.stage.removeEventListener(Event.MOUSE_LEAVE, onmUp );
			onMouseOut( null );
			this.stopDrag();
			_pointer.addEventListener(MouseEvent.MOUSE_DOWN, onmDown );
			
			if( _oldY == _dragRect.height || _oldY == 0 )
				this.dispatchEvent( new ChartEvent( ChartEvent.DRAG_LINE, false, false, { name: this.name, ypos: this.y } ) );
			this.dispatchEvent( new ChartEvent( ChartEvent.LINE_UPM, false, false, { name: this.name } ) );
			
		}
		
		
		
		private function onMouseOver(e:MouseEvent):void 
		{
			_pointer.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver );
			_touchField.visible = true;
			Mouse.cursor = MouseCursor.BUTTON;
			_pointer.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut );
		}
		
		private function onMouseOut(e:MouseEvent):void 
		{
			this.removeEventListener(Event.ENTER_FRAME, onMove );
			_pointer.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut );
			_touchField.visible = false;
			Mouse.cursor = MouseCursor.AUTO;
			_pointer.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver );
			
		}
		
		private function createTriangle( color:uint ):Sprite
		{
			const rectscale:int = 12;
			
			const triangle:Sprite = new Sprite;
			triangle.graphics.beginFill( color );
			triangle.graphics.lineStyle( 1, color, 1 );
			triangle.graphics.moveTo( 0, rectscale / 2 );
			triangle.graphics.lineTo( rectscale * 1.5, 0 );
			triangle.graphics.lineTo( rectscale * 1.5, rectscale );
			triangle.graphics.lineTo( 0, rectscale / 2 );
			triangle.graphics.endFill();
			
			return triangle;
			
		}
		
		private function createCircle( color:uint ):Sprite
		{
			const rectscale:int = 6;
			
			const figure:Sprite = new Sprite;
			figure.graphics.beginFill( color );
			figure.graphics.lineStyle( 1, color, 1 );
			figure.graphics.drawCircle( rectscale , rectscale, rectscale );
			figure.graphics.endFill();
			
			return figure;
			
		}
		
		private function createSquare( color:uint ):Sprite
		{
			const rectscale:int = 10;
			
			const figure:Sprite = new Sprite;
			figure.graphics.beginFill( color );
			figure.graphics.lineStyle( 1, color, 1 );
			figure.graphics.drawRect(0, 0,  rectscale, rectscale );
			figure.graphics.endFill();
			
			return figure;
			
		}
		
		private function drawTouchField( color:uint ):Sprite 
		{
			const rectscale:uint = 25;
			
			const field:Sprite = new Sprite;
			field.graphics.beginFill( color, .3 );
			field.graphics.drawCircle( 0, 0,  rectscale );
			field.graphics.endFill();
			
			return field;
			
		}
		
		private function createTFInfo( color:uint ):TextField 
		{
			const tfInfo:TextField = new TextField()
			tfInfo.width = 20;
			tfInfo.height = 20;
			tfInfo.autoSize = TextFieldAutoSize.LEFT;
			
			tfInfo.wordWrap = false;
			tfInfo.type = TextFieldType.DYNAMIC;
			//tfInfo.border = true;
			//tfInfo.borderColor = 0xff;
			tfInfo.defaultTextFormat = new TextFormat( "Verdana", 12, color, false,null, null, null, null, TextFormatAlign.CENTER );
			tfInfo.mouseEnabled  = false;
			
			return tfInfo;
		}
		
		private function drawLine( len:int, color:uint ):Sprite
		{
			
			const line:Sprite = new Sprite
			line.graphics.lineStyle( 2, color, 1 );
			
			const len:int = _mainW / _stepDotted;
			for ( var i:int = 1; i < len; i++ )
			{
				
				if ( i % 2 )
				{
					line.graphics.moveTo( ( i - 1 ) * _stepDotted, 0 );
					line.graphics.lineTo(  i  * _stepDotted, 0 );
				}
			}
			
			line.graphics.endFill();
			
			return line;
		}
		
		
		
		
		
	}
	
	
}