package components.gui.visual.wire
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import components.abstract.Utility;
	import components.abstract.functions.loc;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class WireThreshold extends UIComponent
	{
		private var threshhold:TextField;
		private var unit:WireUnit;
		private var rect:Rectangle;
		
		private var canSlideFurther:Function;
		private var pushNext:Function;
		private var pullPrev:Function;
		
		private var isDragging:Boolean=false;
		public var itemId:int;
		private var globalHeight:int = 35;
		private var _leftBorder:int;
		private var _hiddenControl:Boolean = false;
		private var measure_unit:String;
		private var lastx:int=-1;	//	нужно запоминать последнюю точку перемещения по mouseMove, чтобы не было непредвиденных скачков
		
		public var calcXAcp:Function;
		
		public var color:uint;
		public var isPassive:Boolean=false;
		
		public function WireThreshold( _title:String, _color:uint, _id:int, _width:int, _x:int, _isEnd:Boolean, _measure:String, _passive:Boolean )
		{
			super();
			
			measure_unit = _measure;
			isPassive = _passive;
			itemId = _id;
			color = _color;
			
			var tf:TextFormat = new TextFormat;
			tf.color = 0xffffff;
			tf.size = 12;
			tf.font = PAGE.MAIN_FONT;
			tf.align = "center";
			/*if ( _title.search("\r") > -1 )
				tf.leading = -7;
			else
				tf.leading = -12;*/
			
			threshhold = new TextField;
			addChild( threshhold );
			threshhold.defaultTextFormat = tf;
			
			/*if ( _title.search("\r") > -1 )
				threshhold.text = _title;
			else
				threshhold.text = "\r"+_title;*/
				threshhold.text =_title;
			threshhold.height = globalHeight;
			threshhold.width = _width;
			threshhold.selectable = false;
			threshhold.background = true;
			threshhold.backgroundColor = _color;
			threshhold.x = _x;
			this.width = _width;
			
			_leftBorder = _width + _x;
				
			if ( !_isEnd ) {
				unit = new WireUnit(_color, _passive);
				addChild( unit );

				unit.x = threshhold.width + threshhold.x;
				unit.y = globalHeight+10;
				unit.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
				unit.addEventListener( MouseEvent.MOUSE_UP, mUp );
			}
			rect = new Rectangle;
		}
		public function set hiddenControl(value:Boolean):void
		{
			if(unit) {
				unit.visible = !value;
				if (value) {
					if ( unit.hasEventListener( MouseEvent.MOUSE_DOWN ) ) {
						unit.removeEventListener( MouseEvent.MOUSE_DOWN, mDown );
						unit.removeEventListener( MouseEvent.MOUSE_UP, mUp );
					}
				} else {
					if ( !unit.hasEventListener( MouseEvent.MOUSE_DOWN ) ) {
						unit.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
						unit.addEventListener( MouseEvent.MOUSE_UP, mUp );
					}					
				}
			}
			_hiddenControl = value;
		}
		private function setLabel(value:int):void
		{
			var acp:Number = calcXAcp(value);
			unit.label = UTIL.formateNumbersToLetters( Utility.mathACPtoOM(acp) ) + loc("measure_resist_s");
		}
		public function register( _canSlide:Function, _push:Function, _pull:Function):void
		{
			canSlideFurther = _canSlide;
			pushNext = _push;
			pullPrev = _pull;
		}
		private function mDown( ev:MouseEvent ):void
		{
			if ( ev.target is Sprite ) {
				isDragging = true;
				stage.addEventListener( MouseEvent.MOUSE_UP, mUp);
				stage.addEventListener( MouseEvent.MOUSE_MOVE, mMove);
				
trace("--------------");
				// для Костыля, чтобы подвинуть край пассивного края в ту или другую сторону до начала движения ползунка
				pushNext( threshhold.width + threshhold.x, itemId );
				pullPrev( threshhold.width + threshhold.x, itemId );
				
				unit.startDrag(false,rect);
			}
		}
		private function mUp( ev:MouseEvent ):void
		{
			isDragging = false;
			unit.stopDrag();
			if ( threshhold.width < 10 || unit.x < threshhold.x ) {
				threshhold.width = 10;
				unit.x = threshhold.x + 10;
			} else {
				if (lastx>0)
					unit.x = lastx;
			}
			stage.removeEventListener( MouseEvent.MOUSE_UP, mUp);
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mMove);
		}
		private function mMove( ev:MouseEvent ):void
		{
			if ( isDragging && canSlideFurther( itemId ) &&
				( this.mouseX - 15 < unit.x  && this.mouseX + 10 > unit.x ) ) {
				
				doMovement();
				//unit.x = leftBorder;
			} else		
				unit.x = leftBorder;
			lastx = unit.x;
		}
		private function doMovement():void
		{
			threshhold.width = unit.x-threshhold.x;
			if (!isPassive) {
				if ( threshhold.width < 10 || unit.x < threshhold.x ) {
					threshhold.width = 10;
					unit.x = threshhold.x + 10;
				}
			}
			setLabel( (threshhold.width + threshhold.x) );
			
			pushNext( threshhold.width + threshhold.x, itemId );
			pullPrev( threshhold.width + threshhold.x, itemId );
			leftBorder = threshhold.width + threshhold.x;
		}
		public function set globalWidth(value:int):void
		{
			rect.x = 0;
			rect.y = globalHeight+10;
			rect.height = 0;
			rect.width = value; 
		}
		public function push( _x:int ):void
		{
			var delta:int = _x - threshhold.x;
			threshhold.width -= delta;
			threshhold.x += delta;
trace("push x:"+_x +" res:"+threshhold.x);
		}
		public function set leftBorder(value:int):void
		{
			_leftBorder = value;
		}
		public function get leftBorder():int
		{
			return _leftBorder;
		}
		public function get xpos():int
		{
			return unit ? unit.x:0;
		}
		public function set xpos(value:int):void
		{
			if ( unit ) {
				unit.x = value;
				doMovement();
			}
		}
		public function undraw():void
		{
			getStage().removeEventListener( MouseEvent.MOUSE_UP, mUp);
			getStage().removeEventListener( MouseEvent.MOUSE_MOVE, mMove);
			function getStage():Stage
			{
				if (!stage)
					return FlexGlobals.topLevelApplication.stage;
				return stage;
			}
		}
		public function getBorder():Object
		{
			return { left:threshhold.x, right:threshhold.width + threshhold.x };
		}
		public function set text(value:String):void
		{
			threshhold.text = value;
			
			
		}
		public function get text():String
		{
			if(threshhold)
				return threshhold.text;
			return "";
		}
		public function getHitTestBoject():DisplayObject
		{	// возвращает обьект который нужно проверить на пересечение с остальными
			if (unit)
				return unit.getHitTestObject();
			return null;
		}
		
		private var _layer:int;
		public function set layer(value:int):void
		{	// установить номер слоя по высоте
			_layer = value;
			
			if( unit )
				unit.textShift = WireUnit.TEXT_PREFERRED_SHIFTY*value;
		}
		public function get layer():int
		{
			return _layer;
		}
		override public function set visible(value:Boolean):void
		{
if (!value)
var t:int =2;
			super.visible = value;
		}
	}
}