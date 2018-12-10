package components.gui.fields
{
	import components.abstract.servants.TabOperator;
	import components.gui.fields.lowlevel.MCheckBox;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.KEYS;
	
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	public dynamic class FSCheckBoxSimple extends FormEmpty implements IFormString, IFocusable
	{
		private var checkBox:MCheckBox;
		
		public static const F_SEND_DATA:int = 0x01;
		private var SEND_DATA:Boolean=false;
		
		public function FSCheckBoxSimple()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			checkBox = new MCheckBox;
			addChild( checkBox );
			
			checkBox.y = 9;
			checkBox.addEventListener( MouseEvent.CLICK, boxClick );
			checkBox.tabEnabled = false;
			this.valid = true;
		}
		private function boxClick( ev:MouseEvent ):void
		{
			if( !disabled ) {
				callLater(send);
				callLater( TabOperator.getInst().iNeedFocus, [this] );
			}
		}
		override public function setCellInfo( value:Object ):void
		{
			var _name:String = String(value);
			if ( _name == "1" || _name == "true" )
				checkBox.selected = true;
			else
				checkBox.selected = false;
			
			
			
		}
		override public function getCellInfo():Object
		{
			if ( checkBox.selected )
				return 1;
			return 0;
		}
		public function switchCheck():void
		{
			checkBox.selected = !checkBox.selected;
		}
		override protected function send():void
		{
			if ( SEND_DATA )
				fSend( this );
			else if ( AUTOMATED_SAVE )
				fSend( this );
			else {
				if ( fSend != null ) {
					if ( stringId > -1 )
						fSend( stringId );
					else
						fSend();
				}
			}
		}
		override protected function applyParam(param:int):void
		{
			switch( param ) {
				case F_SEND_DATA:
					SEND_DATA = true;
					break;
			}
		}
		override public function get width():Number
		{
			return checkBox.x + checkBox.width;
		}
		override public function set disabled(value:Boolean):void
		{
			checkBox.enabled = !value;
		}
		override public function get disabled():Boolean
		{
			return !checkBox.enabled;
		}
		override public function undraw():void
		{
			checkBox.removeEventListener( MouseEvent.CLICK, boxClick );
		}
		override public function getFocusField():InteractiveObject
		{
			return checkBox;
		}
		override public function getFocusables():Object
		{
			return checkBox;
		}
		
		override public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			switch(key) {
				case KEYS.Spacebar:
				case KEYS.Enter:
					switchCheck();
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
			return checkBox == io;
		}
	}
}