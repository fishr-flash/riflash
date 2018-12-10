package components.gui.fields
{
	import flash.display.InteractiveObject;
	
	import mx.controls.RadioButtonGroup;
	import mx.core.UIComponent;
	
	import components.abstract.servants.TabOperator;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.KEYS;
	
	public class FSRadioGroupH extends UIComponent implements IFormString, IFocusable
	{
		private var aRadioButtons:Array;
		private var gx:int;
		private var selected:int;
		private var fChange:Function;
		private var idnum:int;
		private var auto_save:Boolean;
		private var structureId:int;
		private var _cmd:int;
		private var _param:int;
		private var _type:int;
		private var rg:RadioButtonGroup;
		
		public static var F_RADIO_RETURNS_OBJECT:int = 0x0A;
		private var RADIO_RETURNS_OBJECT:Boolean = false;
		
		public function FSRadioGroupH( arr:Array, _structure:int )
		{
			super();
			
			structureId = _structure;
			_type = TabOperator.TYPE_ACTION;
			aRadioButtons = new Array;
			var radio:FSRadio;
			for( var key:String in arr ) {
				radio = new FSRadio;
				addChild( radio );
				radio.setName( arr[key].label );
				radio.x = gx;
				gx += radio.width+10;
				radio.setUp( changed, arr[key].id );
				aRadioButtons.push( radio );
				radio.selected = arr[key].selected;
				if ( arr[key].selected ) {
					selected = arr[key].id;
				}
			}
			width = gx;
			height = 25;
		}
		public function setUp( _delegate:Function, _id:int=-1 ):void
		{
			idnum = _id;
			fChange = _delegate;
		}
		public function getHeight():int
		{
			return height;
		}
		private function changed(_id:int):void 
		{
			if ( selected == _id ) {
				TabOperator.getInst().iNeedFocus(this);
				return;
			}
			var len:int = aRadioButtons.length;
			for( var i:int; i<len; ++i ) {
				(aRadioButtons[i] as FSRadio).selected = Boolean((aRadioButtons[i] as FSRadio).getId() == _id );
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
		{/*
			var len:int = aRadioButtons.length;
			var i:int;
			if (forward) {
				for (i=0; i<len; ++i) {
					if( (aRadioButtons[i] as FSRadio).selected ) {
						(aRadioButtons[i] as FSRadio).selected = false;
						if (i+1 < len) {
							(aRadioButtons[i+1] as FSRadio).selected = true;
						} else
							(aRadioButtons[0] as FSRadio).selected = true;
						TabOperator.getInst().iNeedFocus(this);
						break;
					}
				}
			} else {
				for (i=0; i<len; ++i) {
					if( (aRadioButtons[i] as FSRadio).selected ) {
						(aRadioButtons[i] as FSRadio).selected = false;
						if (i > 0) {
							(aRadioButtons[i-1] as FSRadio).selected = true;
						} else
							(aRadioButtons[len-1] as FSRadio).selected = true;
						TabOperator.getInst().iNeedFocus(this);
						break;
					}
				}	
			}*/
			var len:int = aRadioButtons.length;
			var i:int;
			var r:FSRadio;
			var sel:int = 0;
			if (forward) {
				for (i=0; i<len; ++i) {
					if( (aRadioButtons[i] as FSRadio).selected ) {
						(aRadioButtons[i] as FSRadio).selected = false;
						if (i+1 < len) {
							(aRadioButtons[i+1] as FSRadio).selected = true;
							sel = (aRadioButtons[i+1] as FSRadio).getId();
						} else {
							(aRadioButtons[0] as FSRadio).selected = true;
							sel = (aRadioButtons[0] as FSRadio).getId();
						}
						TabOperator.getInst().iNeedFocus(this);
						break;
					}
				}
			} else {
				for (i=0; i<len; ++i) {
					if( (aRadioButtons[i] as FSRadio).selected ) {
						(aRadioButtons[i] as FSRadio).selected = false;
						if (i > 0) {
							(aRadioButtons[i-1] as FSRadio).selected = true;
							sel = (aRadioButtons[i-1] as FSRadio).getId();
						} else {
							(aRadioButtons[len-1] as FSRadio).selected = true;
							sel = (aRadioButtons[len-1] as FSRadio).getId();
						}
						TabOperator.getInst().iNeedFocus(this);
						break;
					}
				}	
			}
			if (sel == 0) {
				(aRadioButtons[0] as FSRadio).selected = true;
				sel = (aRadioButtons[0] as FSRadio).getId();
			}
			changed(sel);
		}
		public function getCellInfo():Object
		{
			return selected;
		}
		public function setCellInfo(value:Object):void
		{
			var len:int = aRadioButtons.length;
			for( var i:int; i<len; ++i ) {
				(aRadioButtons[i] as FSRadio).selected = Boolean((aRadioButtons[i] as FSRadio).getId() == int(value) );
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
			enabled = !value;
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
		public function switchFormat( _format:int ):void {
			switch( _format ) {
				case F_RADIO_RETURNS_OBJECT:
					RADIO_RETURNS_OBJECT = true;
					break;
			}
		}
		public function block(arr:Array):void
		{
			var len:int = aRadioButtons.length;
			for( var i:int; i<len; ++i ) {
				(aRadioButtons[i] as FSRadio).enabled = false;
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
			var len:int = aRadioButtons.length;
			for( var i:int; i<len; ++i ) {
				return (aRadioButtons[i] as FSRadio).x + (aRadioButtons[i] as FSRadio).width;
			}
			return 0;
		}
		public function get disabled():Boolean
		{
			return false;
		}
		public function setAdapter(a:IDataAdapter):void
		{
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
				if( (aRadioButtons[i] as FSRadio).selected )
					return aRadioButtons[i];
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