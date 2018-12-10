package components.gui.fields
{
	import flash.display.InteractiveObject;
	
	import mx.core.UIComponent;
	
	import components.abstract.servants.TabOperator;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.KEYS;
	
	public class FSRadioGroup extends UIComponent implements IFormString, IFocusable
	{
		public static const TRIGGER_SPACE:int=1;
		
		private var aRadioButtons:Array;
		private var gy:int;
		private var selected:int;
		private var fChange:Function;
		private var idnum:int;
		private var auto_save:Boolean;
		private var structureId:int;
		private var _cmd:int;
		private var _param:int;
		private var adapter:IDataAdapter;
		private var _type:int;
		
		/**	new FSRadioGroup( [ {label:"Запретить синхронизацию даты и времени", selected:false, id:0x01 },
		 * 			{label:"Синхронизировать дату и время с сервером приема\rтревожных событий при подключении по GPRS, LAN", selected:false, id:0x02 },
		 * 			{label:"Синхронизировать дату и время с сервером точного\rвремени NTP при любом сетевом соединении", selected:true, id:0x03 }], 1 );	*/
		public function FSRadioGroup( arr:Array, _structure:int, leadingHeight:int=40 )
		{
			super();
			
			structureId = _structure;
			
			aRadioButtons = new Array;
			var radio:FSTextRadio;
			for( var key:String in arr ) {
				if ( arr[key].trigger ) {
					switch(arr[key].trigger) {
						case TRIGGER_SPACE:
							gy += leadingHeight;
							break;
					}
				} else {
					radio = new FSTextRadio;
					addChild( radio );
					if (arr[key].resety)
						gy = 0;
					radio.y = gy;
					radio.setName( arr[key].label );
					radio.selected = arr[key].selected;
					radio.setUp( changed, arr[key].id );
					aRadioButtons.push( radio );
					gy += leadingHeight;// radio.getHeight() < 20?30:30
					if( arr[key].x is int )
						radio.x = arr[key].x; 						
					//x>y?4:7
					//gy += radio.getHeight() + 5;
					if ( arr[key].selected ) {
						selected = arr[key].id;
					}
				}
			}
			height = gy;
			
			_type = TabOperator.TYPE_ACTION;
		}
		override public function set width(value:Number):void
		{
			super.width = value;
			
			for(var key:String in aRadioButtons) {
				(aRadioButtons[key] as FSTextRadio).setWidth( value );
			}
		}
		public function getHeight():int
		{
			return height;
		}
		public function setUp( _delegate:Function, _id:int=-1 ):void
		{
			idnum = _id;
			fChange = _delegate;
		}
		
		private function changed( _id:int ):void 
		{
			if ( selected == _id ) {
				TabOperator.getInst().iNeedFocus(this);
				return;
			}
			var len:int = aRadioButtons.length;
			for( var i:int; i<len; ++i ) {
				(aRadioButtons[i] as FSTextRadio).selected = Boolean((aRadioButtons[i] as FSTextRadio).getId() == _id );
				selected = _id;
			}
			TabOperator.getInst().iNeedFocus(this);
			
			if ( AUTOMATED_SAVE )
				fChange( this );
			else {
				if ( fChange != null ) {
					if ( idnum > -1 )
						fChange( idnum );
					else
						fChange();
				}
			}
		}
		private function doNavigate(forward:Boolean):void
		{
			var len:int = aRadioButtons.length;
			var i:int;
			var r:FSTextRadio;
			var sel:int = -1;
			if (forward) {
				for (i=0; i<len; ++i) {
					if( (aRadioButtons[i] as FSTextRadio).selected ) {
						(aRadioButtons[i] as FSTextRadio).selected = false;
						if (i+1 < len) {
							(aRadioButtons[i+1] as FSTextRadio).selected = true;
							sel = (aRadioButtons[i+1] as FSTextRadio).getId();
						} else {
							(aRadioButtons[0] as FSTextRadio).selected = true;
							sel = (aRadioButtons[0] as FSTextRadio).getId();
						}
						TabOperator.getInst().iNeedFocus(this);
						break;
					}
				}
			} else {
				for (i=0; i<len; ++i) {
					if( (aRadioButtons[i] as FSTextRadio).selected ) {
						(aRadioButtons[i] as FSTextRadio).selected = false;
						if (i > 0) {
							(aRadioButtons[i-1] as FSTextRadio).selected = true;
							sel = (aRadioButtons[i-1] as FSTextRadio).getId();
						} else {
							(aRadioButtons[len-1] as FSTextRadio).selected = true;
							sel = (aRadioButtons[len-1] as FSTextRadio).getId();
						}
						TabOperator.getInst().iNeedFocus(this);
						break;
					}
				}	
			}
			if (sel < 0) {
				(aRadioButtons[0] as FSTextRadio).selected = true;
				sel = (aRadioButtons[0] as FSTextRadio).getId();
			}
			changed(sel);
		}
		public function getCellInfo():Object
		{
			if (adapter)
				return adapter.recover( selected );
			return String(selected);
		}
		public function setCellInfo(value:Object):void
		{
			var len:int = aRadioButtons.length;
			for( var i:int; i<len; ++i ) {
				(aRadioButtons[i] as FSTextRadio).selected = Boolean((aRadioButtons[i] as FSTextRadio).getId() == int(value) );
				selected = int(value);
			}
		}
		
		public function setName( _name:String ):void {}
		public function getName():String
		{
			return "";
		}
		public function getId():int
		{
			return structureId;
		}
		public function set cmd(value:int):void
		{
			_cmd = value;
		}
		public function get cmd():int
		{
			return _cmd;
		}
		public function get param():int
		{
			return _param;
		}
		public function set param(value:int):void
		{
			_param = value;
		}
		public function set disabled(value:Boolean):void
		{
			
			if(value) {
				var arr:Array = new Array;
				var len:int = aRadioButtons.length;
				for(var i:int=0; i<len; ++i ) {
					arr.push(i);
				}
				block(arr);
			} else
				block();
		}
		public function get disabled():Boolean
		{
			return false;
		}
		public function get AUTOMATED_SAVE():Boolean
		{
			return auto_save;
		}
		public function set AUTOMATED_SAVE(value:Boolean):void
		{
			auto_save = value;
		}
		public function isValid(_str:String=null):Boolean
		{
			return true;
		}
		public function block(arr:Array=null):void
		{
			if ( arr ) {
				var len:int = aRadioButtons.length;
				for( var i:int=0; i<len; ++i ) {
					var arrlen:int = arr.length;
					for(var k:int=0; k<arrlen; ++k ) {
						if ( arr[k] == i ) {
							(aRadioButtons[i] as FSTextRadio).disabled = true;
							break;
						}
					}
				}
			} else {
				for( var key:String in aRadioButtons ) {
					(aRadioButtons[key] as FSTextRadio).disabled = false;
				}
			}
			
			_type = TabOperator.TYPE_DISABLED;
		}
		
		public function deblock():void
		{
			var len:int = aRadioButtons.length;
			for( var i:int; i<len; ++i ) {
				(aRadioButtons[i] as FSRadio).enabled = true;
			}
			
			_type = TabOperator.TYPE_ACTION;
		}
		
		override public function get width():Number
		{
			for(var key:String in aRadioButtons) {
				return (aRadioButtons[key] as FSTextRadio).x + (aRadioButtons[key] as FSTextRadio).getWidth();
			}
			return 0;
		}
		public function setAdapter(a:IDataAdapter):void
		{
			adapter = a;
		}
		public function get valid():Boolean
		{
			return true;
		}
		public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			switch(key) {
				case KEYS.RightArrow:
				case KEYS.DownArrow:
					doNavigate(true);
					break;
				case KEYS.LeftArrow:
				case KEYS.UpArrow:
					doNavigate(false);
					break;
			}
		}
		public function getFocusables():Object
		{
			return aRadioButtons;
		}
		
		public function getFocusField():InteractiveObject
		{
			var len:int = aRadioButtons.length;
			for (var i:int=0; i<len; ++i) {
				if( (aRadioButtons[i] as FSTextRadio).selected ) {
					return aRadioButtons[i];
				}
			}
			return aRadioButtons[0];
		}
		public function getType():int
		{
			 return _type;
		}
		
		public function isPartOf(io:InteractiveObject):Boolean
		{
			var len:int = aRadioButtons.length;
			for (var i:int=0; i<len; ++i) {
				if( aRadioButtons[i] == io )
					return true;
			}
			return false;
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
			if ( isNaN(_focusorder) )
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