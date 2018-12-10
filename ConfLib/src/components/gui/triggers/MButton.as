package components.gui.triggers
{
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.interfaces.IFocusable;
	import components.static.COLOR;
	import components.static.GuiLib;
	import components.static.KEYS;
	import components.system.SysManager;
	
	public class MButton extends Sprite implements IFocusable
	{
		private const NORMAL:int = 1;
		private const OVER:int = 3;
		private const DOWN:int = 5;
		private const DISABLED:int = 7;
		
		private var left:MovieClip;
		private var right:MovieClip;
		private var midle:MovieClip;
		private var sep:MovieClip;
		private var title:TextField;
		
		private var fClick:Function;
		public var id:int;
		
		private var _pressed:Boolean;
		private var _disabled:Boolean;
		
		public function MButton(name:String, f:Function, id:int=-1)
		{
			super();
			
			left = new GuiLib.m_button_left;
			addChild( left );
			left.gotoAndStop( NORMAL );
			
			midle = new GuiLib.m_button_midle;
			addChild( midle );
			midle.gotoAndStop( NORMAL );
			midle.x = left.width;
			
			right = new GuiLib.m_button_right;
			addChild( right );
			right.gotoAndStop( NORMAL );
			
			sep = new GuiLib.m_button_separator;
		//	addChild( sep );
			sep.gotoAndStop( NORMAL );
			
			title = new TextField;
			addChild( title );
			//title.border = false;
			title.selectable = false;
			title.height = 20;
			title.x = 2;
			//title.x = 30;
			//title.textColor = normalColor;
			
			var textFormat:TextFormat = new TextFormat;
			textFormat.font = "Verdana";
			//textFormat.underline = true;
			textFormat.size = "12";
			textFormat.align = TextFormatAlign.CENTER;
			
			title.defaultTextFormat = textFormat;
			
			this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
			this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
			this.addEventListener( MouseEvent.CLICK, click );
			this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			this.addEventListener( MouseEvent.MOUSE_UP, mUp );
			
			title.text = name;
			title.width = title.textWidth + 7;
			midle.width = (title.width + 4)- (right.width*2);
			right.x = midle.x + midle.width;
			
			fClick = f;
			this.id = id;
			
		}
		protected function rollOver( ev:MouseEvent ):void 
		{
			play(OVER);
		}
		protected function rollOut( ev:MouseEvent ):void 
		{
			play(NORMAL);
		}
		protected function click( ev:MouseEvent ):void 
		{
			if ( fClick is Function ) {
				if ( id > -1 )
					fClick( id );
				else
					fClick();
			}
		}
		protected function mDown( ev:MouseEvent ):void 
		{
			/*if (ev)
				TabOperator.getInst().iNeedFocus(this);*/
			play(DOWN);
		}
		protected function mUp( ev:MouseEvent ):void 
		{
			play(OVER);
		}
		private function play(n:int):void
		{
			left.gotoAndStop(n);
			midle.gotoAndStop(n);
			right.gotoAndStop(n);
			sep.gotoAndStop(n);
		}
		override public function set width(value:Number):void
		{
			var n:int = value;
			if (value < 9)
				n = 9;
			
			title.width = n-2;
			midle.width = (title.width + 4)- (right.width*2);
			right.x = midle.x + midle.width;
			
			/*
			title = 
			midle.width = title.width + 10;
			right.x = n - right.width;
			midle.width = n - (right.width*2);*/
		}
		
		public function setHTMLLabel( value:String ):void
		{
			title.htmlText = value;
		}
		
		override public function get width():Number
		{
			return right.x + right.width;
		}
		override public function get height():Number
		{
			return midle.height;
		}
		public function set disabled(v:Boolean):void
		{
			if (_disabled != v) {
				_disabled = v;
				if ( v ) {
					play(DISABLED);
					this.removeEventListener( MouseEvent.ROLL_OVER, rollOver);
					this.removeEventListener( MouseEvent.ROLL_OUT, rollOut);
					this.removeEventListener( MouseEvent.CLICK, click );
					this.removeEventListener( MouseEvent.MOUSE_DOWN, mDown );
					this.removeEventListener( MouseEvent.MOUSE_UP, mUp );
					title.textColor = 0xdcdcdc;
					if (TabOperator.getInst().currentFocus() == this.getFocusables())
						SysManager.clearFocus(stage);
				} else {
					play(NORMAL);
					this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
					this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
					this.addEventListener( MouseEvent.CLICK, click );
					this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
					this.addEventListener( MouseEvent.MOUSE_UP, mUp );
					title.textColor = COLOR.BLACK;
				}
			}
		}
		public function get disabled():Boolean 
		{
			return _disabled;
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
				play(DOWN);
			} else {
				this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
				this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
				this.addEventListener( MouseEvent.CLICK, click );
				this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
				this.addEventListener( MouseEvent.MOUSE_UP, mUp );
				play(NORMAL);
			}
		}
		public function get pressed():Boolean
		{
			return _pressed;
		}
		
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
			return this;
		}
		
		public function getFocusables():Object
		{
			return this;
		}
		
		public function getType():int
		{
			if(disabled || pressed || !focusable)
				return TabOperator.TYPE_DISABLED;
			return TabOperator.TYPE_ACTION;
		}
		
		public function isPartOf(io:InteractiveObject):Boolean
		{
			return io == this;
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