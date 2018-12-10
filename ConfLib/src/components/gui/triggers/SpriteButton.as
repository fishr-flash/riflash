package components.gui.triggers
{
	import components.interfaces.IVisualFilter;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class SpriteButton extends Sprite
	{
		protected var tName:TextField;
		protected var textFormat:TextFormat;
		protected var idNum:int;
		protected var fClick:Function;
		protected var normalColor:int = 0x287bbf;
		protected var overColor:int = 0x000000;
		protected var vfilter:IVisualFilter;
		
		protected var defaultPlaceX:int;
		protected var defaultPlaceY:int;
		protected var shiftPlaceX:int;
		protected var shiftPlaceY:int;
		
		private var _disabled:Boolean;
		private var _pressed:Boolean;
		private var _data:int;
		private var cellInfo:String;
		
		public function SpriteButton()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			tName = new TextField;
			addChild( tName );
			tName.border = false;
			tName.selectable = false;
			tName.height = 20;
			tName.width = 195;
			//tName.x = 30;
			tName.textColor = normalColor;
			
			textFormat = new TextFormat;
			textFormat.font = "Verdana";
			textFormat.underline = true;
			textFormat.size = "12";
			
			tName.defaultTextFormat = textFormat;
			
			this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
			this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
			this.addEventListener( MouseEvent.CLICK, click );
			this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			this.addEventListener( MouseEvent.MOUSE_UP, mUp );
		//	this.height = tName.height;
		//	this.width = tName.width;
			
			defaultPlaceX = 0;
			defaultPlaceY = 0;
			shiftPlaceX = 1;
			shiftPlaceY = 1;
		}
		public function setFormat( _underline:Boolean, _size:int=10, _align:String="left",_leading:int=-7 ):void 
		{
			textFormat.underline = _underline;
			textFormat.size = _size;
			textFormat.align= _align;
			textFormat.leading = _leading;
			tName.defaultTextFormat = textFormat;
			tName.setTextFormat( textFormat );
			tName.width = tName.textWidth+5;
			tName.height = tName.textHeight + 12;
		}
		protected function rollOver( ev:MouseEvent ):void 
		{
			tName.textColor = overColor;
		}
		protected function rollOut( ev:MouseEvent ):void 
		{
			tName.textColor = normalColor;
			tName.x = defaultPlaceX;
			tName.y = defaultPlaceY;
		}
		protected function click( ev:MouseEvent ):void 
		{
			if ( fClick != null ) {
				if ( idNum > -1 )
					fClick( idNum );
				else
					fClick();
			}
		}
		protected function mDown( ev:MouseEvent ):void 
		{
			tName.x = shiftPlaceX;
			tName.y = shiftPlaceY;
		}
		protected function mUp( ev:MouseEvent ):void 
		{
			tName.x = defaultPlaceX;
			tName.y = defaultPlaceY;
		}
		public function getId():int { return this.idNum };
		public function setName( _name:String ):void
		{
			if(vfilter)
				tName.text = vfilter.filter(_name);
			else
				tName.text = _name;
			tName.width = tName.textWidth + 20;
			tName.height = tName.textHeight + 12;
		}
		public function getName():String
		{
			if (vfilter)
				return vfilter.source;
			return tName.text;
		}
		public function setUp( _name:String, _clickFunc:Function, _id:int=-1 ):void 
		{
			setName( _name );
			idNum = _id;
			fClick = _clickFunc;
		}
		public function recalculateWidthForSmallButtons(add:int):void
		{
			tName.width = tName.textWidth + add;
		}
		public function set visualfilter(vf:IVisualFilter):void
		{
			vfilter = vf;
		}
		public function set disabled( _value:Boolean ):void 
		{
			_disabled = _value;
			if ( _value ) {
				this.removeEventListener( MouseEvent.ROLL_OVER, rollOver);
				this.removeEventListener( MouseEvent.ROLL_OUT, rollOut);
				this.removeEventListener( MouseEvent.CLICK, click );
				this.removeEventListener( MouseEvent.MOUSE_DOWN, mDown );
				this.removeEventListener( MouseEvent.MOUSE_UP, mUp );
				tName.textColor = 0xdcdcdc;
			} else {
				this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
				this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
				this.addEventListener( MouseEvent.CLICK, click );
				this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
				this.addEventListener( MouseEvent.MOUSE_UP, mUp );
				tName.textColor = normalColor;
			}
		}
		public function get disabled():Boolean 
		{
			return _disabled;
		}
		public function getHeight():int 
		{
			return tName.height;
		}
		public function getWidth():int
		{
			return tName.width;
		}
		public function setWidth(value:int):void
		{
			tName.width = value;
		}
		public function set pressed(value:Boolean):void
		{
			_pressed = value;
			if ( value ) {
				this.removeEventListener( MouseEvent.ROLL_OVER, rollOver);
				this.removeEventListener( MouseEvent.ROLL_OUT, rollOut);
				this.removeEventListener( MouseEvent.CLICK, click );
				this.removeEventListener( MouseEvent.MOUSE_DOWN, mDown );
				this.removeEventListener( MouseEvent.MOUSE_UP, mUp );
				tName.textColor = 0x000000;
				textFormat.underline = false;
			} else {
				this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
				this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
				this.addEventListener( MouseEvent.CLICK, click );
				this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
				this.addEventListener( MouseEvent.MOUSE_UP, mUp );
				tName.textColor = normalColor;
				textFormat.underline = true;
			}
			tName.setTextFormat( textFormat );
		}
		public function get pressed():Boolean
		{
			return _pressed;
		}
		public function setColor( _normal:int,_over:int ):void 
		{
			tName.textColor = _normal;
			normalColor = _normal;
			overColor = _over;
		}
		public function undraw():void
		{
			this.removeEventListener( MouseEvent.ROLL_OVER, rollOver);
			this.removeEventListener( MouseEvent.ROLL_OUT, rollOut);
			this.removeEventListener( MouseEvent.CLICK, click );
			this.removeEventListener( MouseEvent.MOUSE_DOWN, mDown );
			this.removeEventListener( MouseEvent.MOUSE_UP, mUp );
		}
		public function set data( value:int ):void
		{
			_data = value;
		}
		public function get data():int
		{
			return _data;
		}
		override public function set width(value:Number):void	{};
		override public function get width():Number
		{
			return tName.width;
		}
		override public function set height(value:Number):void	{};
		override public function get height():Number
		{
			return tName.height;
		}
	}
}