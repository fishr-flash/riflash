package components.gui.fields
{
	import components.abstract.servants.TabOperator;
	import components.gui.SimpleTextField;
	import components.interfaces.IFocusable;
	import components.static.KEYS;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class FSRadioStandAlone extends FSRadio implements IFocusable
	{
		public static const F_HTML_TEXT:int = 0x01;
		
		protected var IS_HTML_TEXT:Boolean = false;
		
		private var realSelected:Boolean=false;
		
		public function FSRadioStandAlone()
		{
			this.addEventListener( MouseEvent.CLICK, mouseClick );
			
			super();
		}
		private function mouseClick(ev:MouseEvent):void
		{
			if (!this.selected) {
				if (stringId > -1)
					fSend(stringId);
				else
					fSend();
			}
		}
		override public function setName( _name:String ):void 
		{
			if (!tf) {
				tf = new SimpleTextField("");
				tf.setSimpleFormat("left",0,14);
				tf.x  = 15;
				tf.y = -10;
				addChild( tf );
				//this.width = tf.width+15;
				tf.height = 20;
			}
			if (IS_HTML_TEXT) {
				tf.htmlText = _name;
			} else
				tf.text = _name;
		}
		public function attune(value:int):void
		{
			var result:int;
			for(var i:int; i<value; ++i ) {
				result = value & (1 << i);
				if (result>0)
					applyParam(result);
			}
		}
		protected function applyParam(param:int):void
		{
			switch( param ) {
				case F_HTML_TEXT:
					IS_HTML_TEXT = true;
					break;
			}
		}
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
		}
		
		public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			switch(key) {
				case KEYS.Spacebar:
				case KEYS.Enter:
					mClick(null);
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
			return TabOperator.TYPE_NORMAL;
		}
		public function isPartOf(io:InteractiveObject):Boolean
		{
			return io == this;
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