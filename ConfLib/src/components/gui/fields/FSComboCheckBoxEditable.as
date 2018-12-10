package components.gui.fields
{
	import components.gui.fields.lowlevel.MComboBox;
	import components.interfaces.IFocusable;
	import components.system.UTIL;
	
	import flash.events.Event;
	
	import mx.collections.ArrayList;

	public class FSComboCheckBoxEditable extends FSComboCheckBox implements IFocusable
	{
		public static const F_RETURNS_ARRAY_OF_LABELDATA:int = 0x01;
		public static const F_RETURNS_FIRST_NIMBLE_FORWARD:int = 0x02;
		public static const F_RETURNS_BCD_FORMAT:int = 0x04;
		public static const F_FORMAT_PARTITION_OBJECT:int = 0x08;
		
		private var FORMAT_PARTITION_OBJECT:Boolean = false;
		private var loaded:Boolean = false;		// при первой загрузке должен отработать вызов selectItem из setList
		
		public var SELECT_ALL_KEY:int = 0xFFFF; 
		
		override public function set disabled(value:Boolean):void
		{
			
			
			
			if( super.disabled == value ) return;
			super.disabled = value;
			
		}
		
		public function FSComboCheckBoxEditable()
		{
			super();
		}
		override protected function construct():void
		{
			cell = new MComboBox(MComboBox.S_EditableCheckComboBox);
			addChild( cell );
			cell.width = 100;
			configureListeners();
			
			cell.addEventListener( MComboBox.CLOSE, onClose );
			cell.addEventListener( MComboBox.OPEN, onClose );
		}
		override protected function configureListeners():void
		{
			if(cell) {
				cell.addEventListener( MComboBox.DATA_CHANGED, change );
				cell.addEventListener( MComboBox.DATA_CHANGED_NON_MOUSE, noEventChange );
			}
		}
		
		// Change с onKey, onFocusOut
		private function noEventChange(ev:Event):void
		{
			selectItem(null);
			send();
			dispatchEvent(new Event(Event.CHANGE));
		}
		private function onClose(ev:Event=null):void
		{
			var txt:String = cell.text.toUpperCase();
			var allSelected:int = txt.toUpperCase() == LABEL_SELECT_ALL.toUpperCase() ? 1:0;
			var list:Array = [{label:LABEL_SELECT_ALL,data:allSelected,senddata:SELECT_ALL_KEY,trigger:FSComboCheckBox.TRIGGER_SELECT_ALL_INVERT}];
			
			if( txt.toUpperCase() != LABEL_SELECT_ALL.toUpperCase() ) {
				var changed:Boolean = true;
				
				if ( txt.toUpperCase() == lastValidInfo.toUpperCase() )
					changed = false;
				var source:Array = txt.split( new RegExp( REF_DELIM ));
				var arr:Array = new Array();
				var isNumber:Boolean = true;
				
				for each (var item:String in source)	{
					if (arr.indexOf(item)===-1) {
						if ( isNaN(Number(item)) )
							isNumber = false;
						arr.push(item);
					}
				}
				var len:int = arr.length;
				if (FORMAT_PARTITION_OBJECT) {
					for(var r:String in arr )
						arr[r] = (UTIL.formateZerosInFront(arr[r],4))
					arr.sort();
				} else if (isNumber) {
					arr.sort( Array.NUMERIC );
				} else
					arr.sort();
				
				for(var i:int=0; i<len; ++i ) {
					if ( testValidation( arr[i] ) ) {
						list.push( {label:arr[i],labeldata:arr[i], data:1} );
					}
				}
				this.setList( list );
				
				if (changed)
					send();
			} else
				this.setList( list, -1 );
		}
		override public function setList( _arr:Array, _selectedIndex:int=-1 ):void
		{
			var al:ArrayList = new ArrayList;
			al.source = _arr;
			cell.dataProvider = al;
			cell.selectedIndex = _selectedIndex;
			
			selectItem(null);
			
			
		/*	if( !loaded ) {
				if (_selectedIndex == -3) {
					cell.selectedIndex = 0;
					selectItem(new Event(""));
				} else
					selectItem(null);
				loaded = true;
			}*/
		}
		private function testValidation(txt:String):Boolean
		{
			if (!rule)
				return true;
			return Boolean( txt.search( rule ) == 0 )
		}
		override protected function applyParam(param:int):void
		{
			switch( param ) {
				case F_RETURNS_ARRAY_OF_LABELDATA:
					RETURNS_LABELDATA = true;
					break;
				case F_RETURNS_FIRST_NIMBLE_FORWARD:
					RETURNS_FIRST_NIMBLE_FORWARD = true;
					break;
				case F_RETURNS_BCD_FORMAT:
					RETURNS_BCD_FORMAT = true;
					break;
				case F_FORMAT_PARTITION_OBJECT:
					FORMAT_PARTITION_OBJECT = true;
					break;
			}
		}
	}
}