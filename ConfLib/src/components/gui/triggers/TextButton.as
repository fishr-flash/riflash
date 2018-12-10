package components.gui.triggers
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.interfaces.IFocusable;
	import components.interfaces.IVisualFilter;
	import components.static.KEYS;
	import components.system.SysManager;
	
	public class TextButton extends UIComponent implements IFocusable
	{
		protected var tName:TextField;
		protected var textFormat:TextFormat;
		protected var idNum:int;
		protected var fClick:Function;
		protected var normalColor:int = 0x287bbf;
		protected var overColor:int = 0x000000;
		
		protected var defaultPlaceX:int;
		protected var defaultPlaceY:int;
		protected var shiftPlaceX:int;
		protected var shiftPlaceY:int;
		protected var vfilter:IVisualFilter;
		
		private var _disabled:Boolean;
		private var _pressed:Boolean;
		private var _data:int;
		
		public var debug:String="";
		
		public function TextButton()
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
			//tName.border = true;
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
			this.height = tName.height;
			this.width = tName.width;
			
			defaultPlaceX = 0;
			defaultPlaceY = 0;
			shiftPlaceX = 1;
			shiftPlaceY = 1;
		}
		public function set visualfilter(vf:IVisualFilter):void
		{
			vfilter = vf;
		}
		public function setFormat( _underline:Boolean, _size:int=10, _align:String="left",_leading:int= 0):void 
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
			if (ev)
				TabOperator.getInst().iNeedFocus(this);
			tName.x = shiftPlaceX;
			tName.y = shiftPlaceY;
		}
		protected function mUp( ev:MouseEvent ):void {
			tName.x = defaultPlaceX;
			tName.y = defaultPlaceY;
		}
		public function getId():int { return this.idNum };
		public function setId(n:int):void { this.idNum = n };
		public function setName( _name:String ):void
		{
			if(vfilter)
				tName.text = vfilter.filter(_name);
			else
				tName.text = _name;
			if (_name == "") {
				tName.width = 0;
				tName.height = 0;
			} else {
				tName.width = tName.textWidth + 20;
				tName.height = tName.textHeight + 12;				
			}
			this.height = tName.height;
			this.width = tName.width;
		}
		public function setUp( _name:String, _clickFunc:Function, _id:int=-1 ):void 
		{
			setName( _name );
			idNum = _id;
			fClick = _clickFunc;
		}
		public function setFunction(f:Function):void
		{
			fClick = f;
		}
		public function recalculateWidthForSmallButtons(add:int):void
		{
			tName.width = tName.textWidth + add;
		}
		public function set disabled( _value:Boolean ):void 
		{
			if (debug == "1") {
				trace("TextButton.disabled(_value)");
				
			}
			if (_disabled != _value) {
				_disabled = _value;
				if ( _value ) {
					this.removeEventListener( MouseEvent.ROLL_OVER, rollOver);
					this.removeEventListener( MouseEvent.ROLL_OUT, rollOut);
					this.removeEventListener( MouseEvent.CLICK, click );
					this.removeEventListener( MouseEvent.MOUSE_DOWN, mDown );
					this.removeEventListener( MouseEvent.MOUSE_UP, mUp );
					tName.textColor = 0xdcdcdc;
					if (TabOperator.getInst().currentFocus() == this.getFocusables())
						SysManager.clearFocus(stage);
				} else {
					this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
					this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
					this.addEventListener( MouseEvent.CLICK, click );
					this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
					this.addEventListener( MouseEvent.MOUSE_UP, mUp );
					tName.textColor = normalColor;
				}
			}
		}
		public function getName():String
		{
			if (vfilter)
				return vfilter.source;
			return tName.text;
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
		public function getPrecisionWidth():int
		{
			return tName.textWidth;
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
		public function select( _select:Boolean ):void {}
		
/** IFOCUSABLE		***/		
		public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			switch(key) {
				case KEYS.Enter:
				case KEYS.Spacebar:
					mDown(null);
					click(null);
					TaskManager.callLater( mUp, 100, [null] );
					break;
			}
		}
		
		public function getFocusField():InteractiveObject
		{
			return tName;
		}
		
		public function getFocusables():Object
		{
			return tName;
		}
		
		public function getType():int
		{
			if(disabled || pressed || !focusable)
				return TabOperator.TYPE_DISABLED;
			return TabOperator.TYPE_ACTION;
		}
		
		public function isPartOf(io:InteractiveObject):Boolean
		{
			return io == tName;
		}
		public function focusSelect():void		{		}
		protected var _focusgroup:Number = TabOperator.GROUP_BUTTONS;
		protected var _focusorder:Number = NaN;
		public function set focusgroup(value:Number):void
		{
			_focusgroup = value;
		}
		public function set focusorder(value:Number):void
		{
			_focusorder = value;
		}
		public function get focusorder():Number
		{
 			return _focusorder + _focusgroup;
		}
		protected var _focusable:Boolean=true;
		public function set focusable(value:Boolean):void
		{
			_focusable = value;
		}
		public function get focusable():Boolean
		{
			return _focusable;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
		}
	}
}