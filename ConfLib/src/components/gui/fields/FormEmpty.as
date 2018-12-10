package components.gui.fields
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import components.abstract.servants.TabOperator;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.interfaces.IValidator;
	import components.static.COLOR;
	import components.system.SysManager;
	
	public class FormEmpty extends UIComponent implements IFormString, IFocusable
	{
		//Abstract class, do not instantiate
		private var _cmd:int;
		protected var stringId:int=-1;
		protected var fSend:Function; /// функция интерпретирующая данные предоставляемые эл-том для отправки на прибор
		protected var cellInfo:String;
		protected var _valid:Boolean;
		protected var adapter:IDataAdapter;
		public var disable_color:int = COLOR.SATANIC_INVERT_GREY;
		public var storedData:*;
		public var _rule:RegExp;// = new RegExp("A-z0-9*");
		public var vbot:IValidator;
		public var blank:Boolean = true;	// если в поле еще не занесли вообще никакой информации
		public var debugnum:int;
		public var watcher:Boolean=false; 	// Если есть следящий компонент за зименением информации, в делегат передается значение поля
		public var layoutgroup:int;
		public var forceValid:int;			// 0 - не проверять, 1- всегда валидно, 2 - всегда не валидно
		
		public function set rule(re:RegExp):void
		{
			_rule = re;
		}
		public function get rule():RegExp
		{
			return _rule;
		}
		public function getFocusable():InteractiveObject
		{
			return null;
		}
		private var _param:int;
		protected var _disabled:Boolean = false;

		private var auto_save:Boolean = false;
		public var focusSave:Boolean = false;
		
		public function FormEmpty()
		{
			super();
		//	addEventListener(Event.ACTIVATE, activateListener);
			
//debug			addEventListener( MouseEvent.MOUSE_WHEEL, t );
		}
		private function activateListener( ev:Event ):void
		{
			SysManager.clearFocus(stage);
		}
		public function setUp( _fsend:Function, _id:int=-1 ):void 
		{
			if (_id>-1)
				stringId = _id;
			if(_fsend != null)
				fSend = _fsend;
		}
		public function setCellInfo( value:Object ):void {}
		public function getCellInfo():Object {
			return null;
		}
		public function setName( _name:String ):void {}
		public function getName():String 
		{
			return "";
		}
		public function getWidth():int {
			return 0;
		}
		public function setWidth( _num:int ):void {}
		public function setCellWidth( _num:int ):void {}
		public function getHeight():int 
		{
			return 0;
		}
		public function getId():int
		{
			return stringId;
		}
		public function setId(_id:int):void
		{
			stringId = _id;
		}
		protected function change(ev:Event):void {}
		protected function send():void
		{
			if ( AUTOMATED_SAVE )
				fSend( this );
			else if (watcher)
				fSend( getCellInfo() );
			else {
				if ( fSend != null ) {
					if ( stringId > -1 )
						fSend( stringId );
					else
						fSend();
				}
			}
		}
		protected function validate( str:String, ignorSave:Boolean=false ):Boolean
		{
			if (forceValid>0) {
				valid = forceValid == 1;
				if (!valid && AUTOMATED_SAVE && !ignorSave )
					fSend( this )
				return forceValid == 1;
			}
			
			if ( rule && !_disabled )
				valid = Boolean( str.search( rule ) == 0 );
			else
				valid = true;
			
			// Если одтеьлное поле верно и есть валидирующий бот - надо протестить общую валидацию
			if (valid && vbot && !_disabled )
				valid = vbot.isValid(this);
			// Если обнаруживается неверное поле оно сразу отправляет себя что сохранялка знала что есть неверное поле
			if (!valid && AUTOMATED_SAVE && !ignorSave)
				fSend( this );
			
			return valid;
		}
		public function isValid(_str:String=null):Boolean
		{
			
			
			if ( _str == null )
				return validate(cellInfo == null ? "" : cellInfo);
			else
				return validate(_str);
		}
		public function set valid( value:Boolean ):void
		{
			_valid = value;
			drawValid( _valid );
		}
		public function get valid():Boolean
		{
			return _valid;
		}
		public function setList( _arr:Array, _selectedIndex:int=-1 ):void {	}
		public function restrict( _restrict:String, _maxChars:int=0 ):void { }
		public function set cmd(value:int):void
		{
			_cmd = value;
		}
		public function get cmd():int
		{
			return _cmd;
		}
		protected function drawValid(value:Boolean):void {}
		public function set disabled(value:Boolean):void 
		{
			enabled = !value;
		}
		public function get disabled():Boolean {return false}
		public function attune(value:int):void
		{
			var result:int;
			for(var i:int; i<value; ++i ) {
				result = value & (1 << i);
				if (result>0)
					applyParam(result);
			}
		}
		protected function applyParam(param:int):void	{}
		
/*debug		public function t(ev:MouseEvent):void
		{
			trace(this);
		}*/
		public function get param():int
		{
			return _param;
		}
		public function set param(value:int):void
		{
			_param = value;
		}
		public function set AUTOMATED_SAVE(value:Boolean):void
		{
			auto_save = value;
		}
		public function get AUTOMATED_SAVE():Boolean
		{
			return auto_save;
		}
		override public function get height():Number
		{
			return 20;
		}
		public function undraw():void
		{
			
		}
		public function setAdapter(a:IDataAdapter):void
		{
			adapter = a;
		}
		public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void		{		}
		
		public function getFocusField():InteractiveObject
		{
			return null;
		}
		public function getType():int
		{
			return TabOperator.TYPE_DISABLED;
		}
		public function isPartOf(io:InteractiveObject):Boolean
		{
			return false;
		}
		public function getFocusables():Object
		{
			return null;
		}
		public function focusSelect():void		{		}
		
		protected var _focusgroup:Number = 0;
		protected var _focusorder:Number = NaN;
		public function set focusgroup(value:Number):void
		{
			_focusgroup = value;
		}
		public function set focusorder(value:Number):void
		{
		//	if ( isNaN(_focusorder) )
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
	}
}