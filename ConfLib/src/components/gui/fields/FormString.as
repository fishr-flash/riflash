package components.gui.fields
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import components.abstract.servants.TabOperator;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.COLOR;
	import components.system.SysManager;
	
	/**
	 *  Реализует простую строку, без полей ввода, 
	 * но является классом входящим во фреймворк конфигуратора. 
	 * Через setCellInfo() меняет значения этой строки.
	 */
	public class FormString extends FormEmpty implements IFormString, IFocusable
	{
		private const MIN_SIZE:int = 23;
		
		public static const F_EDITABLE:int = 0x01;
		public static const F_NOTSELECTABLE:int = 0x02;
		public static const F_MULTYLINE:int = 0x04;
		//public static const F_CELL_NOTSELECTABLE:int = 0x08;
		public static const F_ALIGN_CENTER:int = 0x10;
		public static const F_RETURN_0OR1:int = 0x20;
		public static const SEND_EVEN_WHEN_DATA_NOT_CHANGED:int = 0x40;
		public static const F_TEXT_RETURNS_HEXDATA:int = 0x80;
		public static const F_HTML_TEXT:int = 0x100;
		public static const F_TEXT_MINI:int = 0x200; 
		public static const F_TEXT_BOLD:int = 0x400;
		public static const F_TEXT_NOT_BOLD:int = 0x800;
		public static const F_BORDER_WHILE_DISABLED:int = 0x1000;
		public static const F_TRIM_SPACES:int = 0x2000;
		public static const F_OFF_KEYBOARD_REACTIONS:int = 0x4000;
		public static const F_UPPERCASE:int = 0x8000;
		public static const F_ALIGN_RIGHT:int = 0x10000;
		public static const F_NOT_EDITABLE_WITH_BORDER:int = 0x20000;
		
		protected var RETURNS_HEXDATA:Boolean = false;
		protected var IS_HTML_TEXT:Boolean = false;
		private var ISBORDER:Boolean = false;
		private var ISSELECTABLE:Boolean = false;
		private var ISBORDER_WHILE_DISABLED:Boolean = false;
		private var DO_TRIM:Boolean = false;
		private var UPPERCASE:Boolean=false;
		
		protected var tName:TextField;
		protected var textFormat:TextFormat;
		
		private var mode0or1:Boolean;
		protected var color:uint=0x000000;
		protected var hintColor:uint = COLOR.SATANIC_GREY;
		
		private var sendWhenDataNotChanged:Boolean = false;
		protected var _hint:String;
		protected var hintActive:Boolean = false;
		public var mathMultiplication:int = 0;
		public var leading:int = 0;
		private var fillBlankData:String;
		
		public function FormString()
		{
			super();
			construct();
		}
		private function construct():void {
			tName = new TextField;
			addChild( tName );
			tName.border = false;
			tName.selectable = false;
			tName.height = 20;
			tName.width = 195;
			//tName.border  =true;
			tName.backgroundColor = 0xffcccc;
			textFormat = new TextFormat;
			textFormat.font = "Verdana";
			
			tName.defaultTextFormat = textFormat;
		
			configureListeners();
		}
		protected function configureListeners():void
		{
			tName.addEventListener(KeyboardEvent.KEY_UP, keyUp );
			tName.addEventListener(Event.CHANGE, change );
		}
		override public function getFocusable():InteractiveObject
		{
			return tName;
		}
		override protected function change(ev:Event):void
		{
			if (UPPERCASE)
				tName.text = tName.text.toUpperCase();
			if (adapter) {
				cellInfo = String( adapter.change(tName.text) );
			} else
				cellInfo = tName.text;
			validate(cellInfo)
			send();
			dispatchEvent(new Event(Event.CHANGE));
		}
		protected function keyUp( ev:KeyboardEvent ):void
		{
			if ( ev.keyCode == 13 || ev.keyCode == 27 )
				SysManager.clearFocus(stage);
		}
		override public function setName( _name:String ):void 
		{
			if (_name.search("\r") > 0 )
				tName.multiline = true;
			
			if (IS_HTML_TEXT)
				tName.htmlText = UPPERCASE ? _name.toUpperCase() : _name;	
			else
				tName.text = UPPERCASE ? _name.toUpperCase() : _name;
			
			if ( tName.multiline ) {
				tName.height = tName.textHeight + 10;
				if (tName.height < MIN_SIZE)
					tName.height = MIN_SIZE;
				tName.y = -int((tName.height - 22)/2);
			}
			cellInfo = _name;
			if(_name == "" && hint != "")
				applyHint(true);
		}
		override public function getName():String 
		{
			if(hintActive)
				return "";
			return tName.text;
		}
		override public function setCellInfo( value:Object ):void 
		{
			blank = false;
			var _name:String
			if (adapter) {
				_name = String( adapter.adapt(value) );
				adapter.perform(this);
			} else
				_name = String(value);
			
			setName( _name );
			validate( _name );
			if(_name!="") {
				hintActive = false;
				if (!IS_HTML_TEXT && !_disabled)
					tName.textColor = color;
			}
			if (vbot)
				vbot.added();
		}
		override public function getCellInfo():Object 
		{
			if ( mode0or1 )
				return int( getName() ) == 0 ? 0:1;
			if ( mathMultiplication > 0 )
				return String(Number(getName())*mathMultiplication);
			if( RETURNS_HEXDATA )
				return "0x"+getName();
			if (adapter)
				return adapter.recover(getName());
			return getName();
		}
		override public function getWidth():int {
			return tName.width;
		}
		override public function setWidth( _num:int ):void {
			tName.width = _num;
		}
		public function setHeight( _num:int ):void {
			tName.height = _num;
		}
		override public function getHeight():int 
		{
			if (tName.height < MIN_SIZE)
				return MIN_SIZE;
			return tName.height;
		}
		override protected function applyParam(param:int):void
		{
			switch( param ) {
				case F_EDITABLE:
					tName.borderColor = 0x696969;
					tName.border = true;
					tName.selectable = true;
					tName.type = "input";
					ISBORDER = true;
					ISSELECTABLE = true;
					break;
				case F_NOTSELECTABLE:
					tName.border = false;
					tName.selectable = false;
					tName.type = TextFieldType.DYNAMIC;
					ISBORDER = false;
					ISSELECTABLE = false;
					break;
				case F_MULTYLINE:
					tName.multiline = true;
					textFormat.leading = leading;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					tName.height = tName.textHeight+5;
					tName.y = -int((tName.height - 22)/2);
					break;
				case F_ALIGN_CENTER:
					textFormat.align = "center";
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					break;
				case F_RETURN_0OR1:
					mode0or1 = true;
					break;
				case SEND_EVEN_WHEN_DATA_NOT_CHANGED:
					sendWhenDataNotChanged = true;
					break;
				case F_TEXT_RETURNS_HEXDATA:
					RETURNS_HEXDATA = true;
					break;
				case F_HTML_TEXT:
					IS_HTML_TEXT = true;
					break;
				case F_TEXT_MINI:
					textFormat.size = 9;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					break;
				case F_TEXT_BOLD:
					textFormat.bold = true;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					break;
				case F_TEXT_NOT_BOLD:
					textFormat.bold = false;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					break;
				case F_BORDER_WHILE_DISABLED:
					ISBORDER_WHILE_DISABLED = true;
					tName.border = true;
					break;
				case F_TRIM_SPACES:
					DO_TRIM = true;
					break;
				case F_OFF_KEYBOARD_REACTIONS:
					tName.removeEventListener(KeyboardEvent.KEY_UP, keyUp );
					break;
				case F_UPPERCASE:
					UPPERCASE = true;
					break;
				case F_ALIGN_RIGHT:
					textFormat.align = "right";
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					break;
				case F_NOT_EDITABLE_WITH_BORDER:
					tName.borderColor = 0x696969;
					tName.border = true;
					tName.selectable = false;
					tName.type = TextFieldType.DYNAMIC;
					ISBORDER = true;
					ISSELECTABLE = false;
					break;
			}
		}
		public function selectAll():void
		{
			tName.setSelection(0, tName.text.length );
		}
		public function displayAsPassword(b:Boolean):void
		{
			tName.displayAsPassword = b;
		}
		public function setBGcolor(c:uint):void
		{
			tName.background = true;
			tName.backgroundColor = c;
		}
		public function setTextColor( _color:uint ):void 
		{
			color = _color;
			tName.textColor = color;
		}
		
		public function setRangeBold( fst:int = 0, lst:int = -1 ):void
		{
			const frm:TextFormat = new TextFormat( null, null, null, true );
			tName.setTextFormat( frm, fst, lst );
		}
		
		
		override public function set disabled( _value:Boolean ):void
		{
			
			if( _disabled == _value ) return;
			
			_disabled = _value;
			if ( _disabled ) {
				focusOut(null);
				tName.type = TextFieldType.DYNAMIC;
				tName.textColor = disable_color;
			} else {
				if (!IS_HTML_TEXT)
					tName.textColor = color;
				if (ISSELECTABLE)
					tName.type = TextFieldType.INPUT;
				if (hintActive )
					applyHint( true );
			}
			if( ISSELECTABLE )
				tName.selectable = !_value;
			else
				tName.selectable = false;
			if (ISBORDER_WHILE_DISABLED)
				tName.border = true;
			else {
				if (ISBORDER)
					tName.border = !_value;
				else
					tName.border = false;
			}
			
			super.disabled = _value;
		}
		override public function get disabled():Boolean 
		{
			return _disabled;
		}
		override public function restrict( _restrict:String, _maxChars:int=0 ):void
		{
			if ( _restrict != "" )
				tName.restrict = _restrict;
			tName.maxChars = _maxChars;
		}
		public function setFormat(_size:int):void
		{
			textFormat.size = _size;
			tName.setTextFormat( textFormat );
			tName.defaultTextFormat = textFormat;
		}
		
		override protected function drawValid(value:Boolean):void
		{
			if( value )
				tName.background = false;
			else {
				tName.backgroundColor = COLOR.RED_INVALID;
				tName.background = true;
			}
		}
/********************* INPUTDATA *********************************************************/
		
		public function fillBlank(txt:String):void
		{
			tName.addEventListener( FocusEvent.FOCUS_OUT, focusOutFill );
			
			fillBlankData = txt;
		}
		
		private function focusOutFill(ev:FocusEvent):void
		{
			if( tName.text == "")
				tName.text = fillBlankData;
			
			if( DO_TRIM )
				tName.text = tName.text.replace( /^\s+|\s+$/g, '' );

			if (cellInfo != tName.text) {
				cellInfo = tName.text;
				validate(cellInfo)
				send();
			}
		}
			
/********************* HINT **************************************************************/		
		
		public function set hint(value:String):void
		{
			if (_hint != "" && hintActive )	// если хинт уже какой то установлен и при этом активен, надо его занулить чтобы новый хинт отобразился
				tName.text="";
			_hint = value;
			if (value == "") {
				tName.removeEventListener( FocusEvent.FOCUS_OUT, focusOut );
				tName.removeEventListener( FocusEvent.FOCUS_IN, focusIn );
				
				if (hintActive)
					applyHint( false );
			} else {
				tName.addEventListener( FocusEvent.FOCUS_OUT, focusOut );
				tName.addEventListener( FocusEvent.FOCUS_IN, focusIn );
				
				if (tName.text == "") 
					applyHint( true );
			}
		}
		protected function applyHint(value:Boolean):void
		{
			hintActive = value;
			if(value) {
				tName.textColor = hintColor; 
				tName.text = hint;
			} else {
				tName.textColor = color; 
				tName.text = "";
			}
		}
		public function get hint():String
		{
			if (_hint is String)
				return _hint;
			return "";
		}
		
		protected function focusOut(ev:FocusEvent):void
		{
			// Зачем то было принуждение ставить хинт, даже если его нет
			if( tName.text == "" && hintActive)
				applyHint( true );
			if (disabled)
				return;
		}
		protected function focusIn(ev:FocusEvent):void
		{
			if (disabled)
				return;
			if( hintActive )
				applyHint(false);
		}
		override public function get width():Number
		{
			return tName.x + tName.width;
		}
		override public function get height():Number
		{
			return tName.height;
		}
		override public function undraw():void
		{
			tName.removeEventListener( KeyboardEvent.KEY_UP, keyUp );
			tName.removeEventListener( Event.CHANGE, change );
			tName.removeEventListener( FocusEvent.FOCUS_OUT, focusOutFill );
			tName.removeEventListener( FocusEvent.FOCUS_OUT, focusOut );
			tName.removeEventListener( FocusEvent.FOCUS_IN, focusIn );
		}
		
		override public function getFocusField():InteractiveObject
		{
			return tName;
		}
		override public function getFocusables():Object
		{
			return tName;
		}
		override public function getType():int
		{
			if (!_disabled && ISSELECTABLE && focusable)
				return TabOperator.TYPE_NORMAL
			return TabOperator.TYPE_DISABLED;
		}
		override public function isPartOf(io:InteractiveObject):Boolean
		{
			return tName == io;
		}
		override public function focusSelect():void		
		{
			tName.setSelection(0, (tName.text as String).length);
		}
	}
}