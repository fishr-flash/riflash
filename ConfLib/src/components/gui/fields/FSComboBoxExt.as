package components.gui.fields
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.gui.fields.lowlevel.MComboBox;
	import components.interfaces.IFocusable;

	public class FSComboBoxExt extends FSComboBox implements IFocusable
	{
		private var extendedList:Array;
		private var shortList:Array;
		private var isExtended:Boolean =false;
		
		public function FSComboBoxExt()
		{
			super();
		}
		override public function setList( _arr:Array, _selectedIndex:int=-1 ):void
		{
			
			var al:ArrayList = new ArrayList;
			var a:Array = _arr.slice();
			if (_selectedIndex >= -1 || _selectedIndex == -3 ) {
				a.push({label:loc("g_further"), data:-1, cls:MComboBox.S_CheckComboBox});
				shortList = _arr;
			} else
				a.push({label:loc("g_rollup"), data:-1, cls:MComboBox.S_CheckComboBox});
			al.source = a;
			cell.dataProvider = al;
			cell.selectedIndex = _selectedIndex;
			if (!EDITABLE)
				installDefaultRegExp();
			if (_selectedIndex < -1)
				callLater( cell.open )
		}
		override public function setCellInfo( value:Object ):void
		{
			if (adapter) {
				cellInfo = String( adapter.adapt(value) );
				adapter.perform(this);
			} else
				cellInfo = String(value);
			cell.data = cellInfo;
			if( !validate(cellInfo,true) && !isExtended ) {
				var len:int = extendedList.length;
				var found:Boolean=false;
				for (var i:int=0; i<len; ++i) {
					if( extendedList[i].data == int(cellInfo) ) {
						cell.dataProvider.source.push( extendedList[i] );
						found = true;
						break;
					}
				}
				if (found) {
					if (!EDITABLE)
						installDefaultRegExp();
					setCellInfo( int(value) );	// нужно отсылать начальное значение а не измененное, к примеру адаптером
				} else	// блок нужен для повторной валидации чтобы выскочила сохранялка
					validate(cellInfo);
			}
		}
		public function setListExt(a:Array):void
		{
			extendedList = a;
		}
		override protected function configureListeners():void
		{
			if(cell) {
				cell.addEventListener( MComboBox.DATA_CHANGED, change );
				cell.addEventListener( MComboBox.MBUTTON_CLICK, onMButton);
				cell.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			}
		}
		private function onMButton(e:Event):void
		{
			if (extendedList) {
				if (isExtended) {
					isExtended = !isExtended;
					setList( shortList, -3 );
					setCellInfo(cellInfo);
				} else {
					isExtended = !isExtended;
					setList( extendedList, -2 );
				}
			} else
				dtrace( "Нет расширенного списка для FSComboBoxExt" );
		}
	}
}