package components.gui.fields
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	import components.abstract.servants.TabOperator;
	import components.gui.fields.lowlevel.MCheckBox;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.KEYS;
	
	public class FSCheckBox extends FormString implements IFormString, IFocusable
	{
		public static var F_MULTYLINE:int = 0x04;
		
		public static var CB_WIDTH:int = 13;
		
		private var checkBox:MCheckBox;
		private var bitvalue:uint = 0;
		public var bitnum:int = -1;
		
		public function FSCheckBox()
		{
			super();
			construct();
		}
		
		private function construct():void 
		{
			checkBox = new MCheckBox;
			addChild( checkBox );
			checkBox.x = 200;
			checkBox.y = 9;
			
			checkBox.addEventListener( MouseEvent.CLICK, boxClick );
			
			checkBox.tabEnabled = false;
			this.valid = true;
		}
		private function boxClick( ev:MouseEvent ):void
		{
			if (!disabled) {
				send();
				callLater( TabOperator.getInst().iNeedFocus, [this] );
			}
		}
		override public function setCellInfo( value:Object ):void
		{
			var _name:String;
			
			if (adapter) {
				_name = String( adapter.adapt(value) );
				adapter.perform(this);
			} else
				_name = String(value);
			
			if (bitnum > -1) {
				bitvalue = int(value);
				if ( (bitvalue & 1<<bitnum) > 0 )
					checkBox.selected = true;
				else
					checkBox.selected = false;
			} else
				checkBox.selected = int(_name) == 1 || _name == "true";
		}
		override public function getCellInfo():Object
		{
			if (adapter)
				return adapter.recover(checkBox.selected);
			if (bitnum > -1) {
				var bf:uint = 0;
				var len:int = Math.max(bitvalue.toString(2).length, bitnum) + 1;
				for (var i:int=0; i<len; i++) {
					if (i == bitnum) {
						if (checkBox.selected)
							bf |= 1 << i;
						else
							bf |= 0 << i;
					} else {
						if ( (bitvalue & 1 << i) > 0)
							bf |= 1 << i;
						else
							bf |= 0 << i;
					}
				}
				return bf;
			}
			if ( checkBox.selected )
				return 1;
			return 0;
		}
		/**
		 * read only
		 */
		public function get selected():Boolean
		{
			return checkBox.selected;
		}
		public function switchState():void
		{
			checkBox.selected = !checkBox.selected;
		}
		public function setXPos(pos:int):void
		{
			checkBox.x = pos;
		}
		override public function setWidth(_num:int):void
		{
			super.setWidth(_num);
			checkBox.x = tName.width;
		}
		override public function setCellWidth(_num:int):void
		{
			checkBox.x = tName.width + _num - 12;
		}
		override public function getWidth():int {
			return tName.width+checkBox.x+checkBox.width;
		}
		public function getWidthBody():int {
			return tName.width+checkBox.width;
		}
		override public function get valid():Boolean
		{
			return true;
		}
		override public function set disabled(_value:Boolean):void
		{
			super.disabled = _value;
			checkBox.enabled = !_value;
			if (_value)
				checkBox.removeEventListener( MouseEvent.CLICK, boxClick );
			else
				checkBox.addEventListener( MouseEvent.CLICK, boxClick );
		}
		override public function get width():Number
		{
			return checkBox.x + checkBox.width;
		}
		
		override public function getFocusField():InteractiveObject
		{
			return this;
		}
		override public function getFocusables():Object
		{
			return this;
		}
		override public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			switch(key) {
				case KEYS.Spacebar:
				case KEYS.Enter:
					switchState();
					boxClick(null);
					break;
			}
		}
		override public function getType():int
		{
			if (checkBox.enabled)
				return TabOperator.TYPE_ACTION;
			return TabOperator.TYPE_DISABLED;
		}
		override public function isPartOf(io:InteractiveObject):Boolean
		{
			return this == io;
		}
		override public function undraw():void
		{
			super.undraw();
			fSend = null;
		}
		override public function setName( _name:String ):void 
		{
			//var n:String = _name.replace("\r", "\r" );
			var n:String = _name;
			if (n.search("\r") ) {
				attune( F_MULTYLINE );
			} else if (n.search("\r") )
				tName.multiline = true;
			super.setName(n);
		}
	}
}