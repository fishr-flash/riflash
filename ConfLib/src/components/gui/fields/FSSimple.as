package components.gui.fields
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import components.abstract.servants.TabOperator;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.interfaces.IPositioner;
	import components.static.COLOR;
	
	public class FSSimple extends FormString implements IFormString, IPositioner, IFocusable
	{
		protected var _cell:TextField;
		private var _attach:String = "";
		protected var format:int;
		private var DO_VALIDATE:Boolean=true;
		private var _tabIgnore:Boolean;
		/// Флаг устанавливается чтобы предотвратить 
		/// повторное применение центрирования
		private var _verticalOrientToApplyed:Boolean;
		
		public static const F_SELECTABLE:int = 0x01;
		public static const F_NOTSELECTABLE:int = 0x02;
		public static const F_MULTYLINE:int = 0x04;
		public static const F_CELL_NOTSELECTABLE:int = 0x08;
		public static const F_CELL_ALIGN_LEFT:int = 0x10;
		public static const F_TEXT_RETURNS_HEXDATA:int = 0x20;
		public static const F_TEXT_AS_PASSWORD:int = 0x40;
		public static const F_HTML_TEXT:int = 0x80;
		public static const F_CELL_ALIGN_RIGHT:int = 0x100;
		public static const F_CELL_NOTEDITABLE_EDITBOX:int = 0x200;
		public static const F_CELL_SELECTABLE:int = 0x400;
		public static const F_TEXT_MINI:int = 0x800;
		public static const F_CELL_EDITABLE_EDITBOX:int = 0x1000;
		public static const F_CELL_NOTEDITABLE_NOTEDITBOX:int = 0x2000;
		public static const F_CELL_BOLD:int = 0x4000;
		public static const F_CELL_NO_BOLD:int = 0x8000;
		public static const F_CELL_ALIGN_CENTER:int = 0x10000;
		/**
		 * Располагает лейбл над элементом. Не учитывает
		 * реальную ширину самого текста, только ширину поля.
		 * Поэтому ширину поля следует подбирать максимально
		 * тщательно.
		 */		
		public static const F_COLOUMN_ORIENT:int = 0x20000;
		public static const F_CELL_MULTYLINE:int = 0x40000;
		public static const F_CELL_SINGLELINE:int = 0x80000;

		public static const F_CELL_NOEDITBOX:int = 0x100000;
		
		
		public function FSSimple()
		{
			super();
			construct();
		}

		public function get cell():TextField
		{
			return _cell;
		}

		private function construct():void
		{
			_cell = new TextField;
			addChild( _cell );
			_cell.x = 200;
			_cell.border = true;
			_cell.borderColor = 0x696969;
			_cell.selectable = true;
			_cell.height = 20;
			_cell.type = "input";
			//cell.maxChars = 20;
			_cell.backgroundColor = 0xffcccc;
			
			var cellTextFormat:TextFormat = new TextFormat;
			cellTextFormat.font = "Verdana";
			cellTextFormat.align = "center";
				
			_cell.defaultTextFormat = cellTextFormat;
			
			configureListeners();
		}
		public function set tabIgnore(b:Boolean):void
		{
			_tabIgnore = b;
		}
		override protected function configureListeners():void
		{
			if ( _cell ) {
				_cell.addEventListener(KeyboardEvent.KEY_UP, keyUp );
				_cell.addEventListener(Event.CHANGE, change );
			}
		}
		override protected function change(ev:Event):void
		{
			if (adapter) {
				cellInfo = String( adapter.change(_cell.text) );
			} else
				cellInfo = _cell.text;
			validate(cellInfo)
			send();	
			dispatchEvent(new Event(Event.CHANGE));
		}
		override protected function keyUp( ev:KeyboardEvent ):void
		{
			
			if ( !_cell.multiline && ( ev.keyCode == Keyboard.ENTER || ev.keyCode == 27 ) )
				stage.focus = null;
		}
		override public function setCellInfo( value:Object ):void
		{
			var _name:String
			if (adapter) {
				_name = String( adapter.adapt(value) );
				adapter.perform(this);
			} else
				_name = String(value);
			
			cellInfo = _name;
			if (IS_HTML_TEXT)
				_cell.htmlText = _name;	
			else
				_cell.text = _name + _attach;
			validate(cellInfo);
		}
		override public function getCellInfo():Object
		{
			if( RETURNS_HEXDATA )
				return "0x"+_cell.text;
			if (adapter)
				return adapter.recover(_cell.text);
			return _cell.text;
		}
		override public function setWidth(_num:int):void
		{
			tName.width = _num;
			_cell.x = tName.width;
		}
		
		override public function setHeight( _num:int ):void 
		{
			tName.height = _num;
			_cell.height = _num;
		}
		
		
		override public function setCellWidth(_num:int):void
		{
			_cell.width = _num;
		}
		public function setColoredBorder(c:int):void
		{
			_cell.borderColor = c;
			_cell.border = true;
		}
		public function setFieldLocation( _x:int=200 ):void
		{
			_cell.x = _x;
		}
		public function set attach( _val:String ):void
		{
			_attach = " " + _val;
		}
		override public function set disabled( _value:Boolean ):void
		{
			if( _disabled != _value ) {
				_disabled = _value;
				_cell.selectable = !_value;
				_cell.border = !_value;
				if ( _disabled ) {
					tName.textColor = disable_color;
					_cell.textColor = disable_color;
					_cell.type = TextFieldType.DYNAMIC;;
					valid = true;
				} else {
					tName.textColor = color;
					_cell.textColor = color;
					_cell.height = 20;
					_cell.type = TextFieldType.INPUT;
					isValid();
				}
			}
		}
		override public function get disabled():Boolean
		{
			return _disabled;
		}
		override public function setName( _name:String ):void 
		{
			if (_name.search("\r") )
				tName.multiline = true;
			super.setName(_name);
		}
		
		override protected function applyParam(param:int):void
		{
			var cellTextFormat:TextFormat;
			switch(param) {
				case F_SELECTABLE:
					tName.borderColor = 0x696969;
					tName.border = true;
					tName.selectable = true;
					tName.type = "input";
					break;
				case F_NOTSELECTABLE:
					tName.border = false;
					tName.selectable = false;
					tName.type = TextFieldType.DYNAMIC;
					break;
				case F_MULTYLINE:
					tName.multiline = true;
					textFormat.leading = leading;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					tName.height = tName.textHeight+5;
					tName.y = -int((tName.height - 22)/2);
					break;
				case F_CELL_BOLD:
					cellTextFormat = _cell.getTextFormat();
					cellTextFormat.bold = true;
					_cell.setTextFormat( cellTextFormat );
					_cell.defaultTextFormat = cellTextFormat;
					break;
				case F_CELL_NO_BOLD:
					cellTextFormat = _cell.getTextFormat();
					cellTextFormat.bold = false;
					_cell.setTextFormat( cellTextFormat );
					_cell.defaultTextFormat = cellTextFormat;
					break;
				case F_CELL_NOTSELECTABLE:
					_cell.border = false;
					_cell.selectable = false;
					_cell.type = TextFieldType.DYNAMIC;
					break;
				case F_CELL_SELECTABLE:
					_cell.border = true;
					_cell.selectable = true;
					_cell.type = TextFieldType.INPUT;
					break;
				case F_CELL_ALIGN_CENTER:
					cellTextFormat = new TextFormat;
					cellTextFormat.font = "Verdana";
					cellTextFormat.align = "center"
					
					_cell.setTextFormat( cellTextFormat );
					_cell.defaultTextFormat = cellTextFormat;
					break;
				case F_CELL_ALIGN_LEFT:
					cellTextFormat = new TextFormat;
					cellTextFormat.font = "Verdana";
					cellTextFormat.align = "left"
					
					_cell.setTextFormat( cellTextFormat );
					_cell.defaultTextFormat = cellTextFormat;
					break;
				case F_CELL_ALIGN_RIGHT:
					cellTextFormat = new TextFormat;
					cellTextFormat.font = "Verdana";
					cellTextFormat.align = "right"
					
					_cell.setTextFormat( cellTextFormat );
					_cell.defaultTextFormat = cellTextFormat;
					break;
				case F_TEXT_RETURNS_HEXDATA:
					RETURNS_HEXDATA = true;
					break;
				case F_TEXT_AS_PASSWORD:
					_cell.displayAsPassword = true;
					break;
				case F_HTML_TEXT:
					IS_HTML_TEXT = true;
					break;
				case F_CELL_NOTEDITABLE_EDITBOX:
					_cell.border = true;
					_cell.borderColor = COLOR.BLACK;
					_cell.selectable = true;
					_cell.background = true;
					_cell.backgroundColor = COLOR.LIGHT_DC_GREY;
					_cell.type = TextFieldType.DYNAMIC;
					DO_VALIDATE = false;
					break;
				case F_CELL_EDITABLE_EDITBOX:
					_cell.border = true;
					_cell.borderColor = COLOR.BLACK;
					_cell.selectable = true;
					_cell.type = TextFieldType.INPUT;
					DO_VALIDATE = true;
					isValid();
					break;
				case F_TEXT_MINI:
					textFormat.size = 9;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					break;
				case F_CELL_NOTEDITABLE_NOTEDITBOX:
					_cell.border = false;
					_cell.selectable = true;
					_cell.background = false;
					_cell.type = TextFieldType.DYNAMIC;
					DO_VALIDATE = false;
					break;
				
				case F_COLOUMN_ORIENT:
					
					if( _verticalOrientToApplyed ) break;
					_cell.y = tName.height - 5;
					
					
					const xx:int = ( _cell.width - tName.width ) / 2;
					if( _cell.width > tName.width )
					{
						tName.x = tName.x + xx;
						_cell.x = 0;
					}
					else 
					{
						_cell.x = xx;
					}
					
					
					_verticalOrientToApplyed = true;
					break;
				
				case F_CELL_MULTYLINE:
					
					_cell.multiline = true;
					break;
				
				case F_CELL_SINGLELINE:
					
					_cell.multiline = false;
					break;
				
				case F_CELL_NOEDITBOX:
					
					_cell.border = false;
					break;
				
				
			}
		}
		override public function restrict( _restrict:String, _maxChars:int=0 ):void
		{
			if ( _restrict != "" )
				_cell.restrict = _restrict;
			_cell.maxChars = _maxChars;
		}
		override protected function drawValid(value:Boolean):void
		{
			if(DO_VALIDATE) {
				if( value )
					_cell.background = false;
				else {
					_cell.backgroundColor = 0xffcccc;
					_cell.background = true;
				}
			}
		}
		override public function getWidth():int 
		{
			return tName.width + _cell.x + _cell.width;
		}
		override public function setTextColor( _color:uint ):void 
		{
			color = _color;
			_cell.textColor = color;
		}
		override public function displayAsPassword(b:Boolean):void
		{
			_cell.displayAsPassword = b;
		}
		override public function get width():Number
		{
			return _cell.x + _cell.width;
		}
		
		override public function getFocusField():InteractiveObject
		{
			return _cell;
		}
		override public function getFocusables():Object
		{
			return _cell;
		}
		public function getCellLines():int
		{
			return _cell.numLines;
		}
		override public function getType():int
		{
			if (_cell.selectable && focusable && !_tabIgnore)
				return TabOperator.TYPE_NORMAL;
			return TabOperator.TYPE_DISABLED;
		}
		override public function isPartOf(io:InteractiveObject):Boolean
		{
			return _cell == io;
		}
		override public function focusSelect():void		
		{
			_cell.setSelection(0, (_cell.text as String).length);
		}
		override public function set hint(value:String):void
		{
			if (_hint != "" && hintActive )	// если хинт уже какой то установлен и при этом активен, надо его занулить чтобы новый хинт отобразился
				_cell.text="";
			_hint = value;
			if (value == "") {
				_cell.removeEventListener( FocusEvent.FOCUS_OUT, focusOut );
				_cell.removeEventListener( FocusEvent.FOCUS_IN, focusIn );
				
				if (hintActive)
					applyHint( false );
			} else {
				_cell.addEventListener( FocusEvent.FOCUS_OUT, focusOut );
				_cell.addEventListener( FocusEvent.FOCUS_IN, focusIn );
				
				if (_cell.text == "") 
					applyHint( true );
			}
		}
		override protected function applyHint(value:Boolean):void
		{
			hintActive = value;
			if(value) {
				_cell.textColor = hintColor; 
				_cell.text = hint;
			} else {
				_cell.textColor = color; 
				_cell.text = "";
			}
		}
		override protected function focusOut(ev:FocusEvent):void
		{
			if( _cell.text == "" )
				applyHint( true );
			if (disabled)
				return;
		}
	}
}