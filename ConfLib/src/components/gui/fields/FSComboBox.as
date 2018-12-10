package components.gui.fields
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mx.collections.ArrayList;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.gui.fields.lowlevel.MComboBox;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.interfaces.IPositioner;
	
	public class FSComboBox extends FormString implements IFormString, IPositioner, IFocusable
	{
		protected var cell:MComboBox;
		private var tSecond:TextField;
		
		protected var EDITABLE:Boolean = true;
		private var LABEL_EXIST:Boolean=false;		// переменная смотрит включен ли у комбобокса текстовое поле впереди, сделано для совместимости.
		
		public static var F_RETURNS_HEXDATA:int = 0x01;
		public static var F_COMBOBOX_NOTEDITABLE:int = 0x02;
		public static var F_MULTYLINE:int = 0x04;
		public static var F_COMBOBOX_BOOLEAN:int = 0x08;
		public static var F_COMBOBOX_TIME:int = 0x10;
		public static var F_COMBOBOX_NOTCLICKABLE:int = 0x20;
		public static var F_COMBOBOX_CLICKABLE:int = 0x40;
		public static var F_ADAPTER_OVERRIDES_RECOVERY:int = 0x80;
		public static var F_ALIGN_CENTER:int = 0x100;
		public static var F_CLEAR_BOX_WHEN_DISABLED:int = 0x200;
		
		protected var COMBOBOX_IS_BOOLEAN:Boolean=false;
		protected var COMBOBOX_IS_TIME:Boolean=false;
		
		private var COMBOBOX_CLEAR_WHEN_DISABLED:Boolean = false;
		private var storeDataWhileDisabled:String;
		private var adapterOverridesRecovery:Boolean=false;
		
		public function FSComboBox()
		{
			super();
			construct();
		}
		protected function construct():void 
		{
			cell = new MComboBox;
			addChild( cell );
			cell.width = 100;
			cell.tabEnabled = false;
			cell.editable = true;			
			
			configureListeners();
		}
		override protected function configureListeners():void
		{
			if(cell) {
				cell.addEventListener( MComboBox.DATA_CHANGED, change );
				cell.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			}
		}
		override protected function change(ev:Event):void
		{
			// не принимать изменения если по факту изменений не было
			if (cell.data != null && cellInfo != cell.data) {
				if (adapter) {
					cellInfo = adapter.change( cell.data ).toString();
					// если после изменения адаптера результат помеялся, его надо вписать и в источник
					if (cellInfo != cell.data)
						cell.data = cellInfo;
				} else
					cellInfo = cell.data;
				validate(cellInfo);
				send();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		protected function mDown(e:MouseEvent):void
		{
			callLater( TabOperator.getInst().iNeedFocus, [this] );
		}
		override public function setList( _arr:Array, _selectedIndex:int=-1 ):void
		{
			
			var al:ArrayList = new ArrayList;
			al.source = _arr;
			cell.dataProvider = al;
			cell.selectedIndex = _selectedIndex;
			if (!EDITABLE)
				installDefaultRegExp();
		}
		public function getList():Array
		{
			return cell.dataProvider.toArray();
		}
		override public function getWidth():int 
		{
			return cell.width;
		}
		override public function setWidth(_num:int):void
		{
			if (LABEL_EXIST) {
				tName.width = _num;
				cell.x = tName.width;
			} else
				cell.width = _num;
		}
		override public function setCellWidth( _num:int ):void
		{
			cell.width = _num;
		}
		override public function getHeight():int
		{
			return cell.height;
		}
		override public function setCellInfo( value:Object ):void
		{
			if (adapter) {
				cellInfo = String( adapter.adapt(value) );
				adapter.perform(this);
			} else
				cellInfo = String(value);
			
			if (COMBOBOX_CLEAR_WHEN_DISABLED && _disabled)
				storeDataWhileDisabled = cellInfo;
			else
				cell.data = cellInfo;
			validate(cellInfo);
		}
		override public function getCellInfo():Object
		{
			if( RETURNS_HEXDATA )
				return "0x"+cellInfo;
			if ( COMBOBOX_IS_TIME ) {
				if (adapterOverridesRecovery)
					return adapter.recover(getName());
				return getTime();
			}
			if (adapter)
				return adapter.recover(getName());
			return cellInfo;
		}
		public function getLabel():String
		{
			return cell.label;
		}
		public function close():void
		{
			cell.close();
		}
		public function setNameAfter(s:String):void
		{ 
			if (!tSecond) {
				tSecond = new TextField;
				addChild( tSecond );
				tSecond.border = false;
				tSecond.selectable = false;
				tSecond.height = 22;
				tSecond.width = 100;
				tSecond.defaultTextFormat = textFormat;
			}
			tSecond.x = cell.x + cell.width + 5;
			tSecond.text = s;
		}
/**		FORMSTRING OVERRIDE			***/
		override public function setName( _name:String ):void 
		{
			if (_name != "") {
				LABEL_EXIST = true;
				cell.x = 200;
				cell.width = 100;
				
				attune( F_MULTYLINE );
				
				super.setName(_name);
			}
		}
/**		TIME COMBOBOX OVERRIDE			***/
		private function getTime():Array 
		{
			var result:String="";
			if ( cell.selectedIndex > -1 )
				result = cell.data;
			else
				result = cellInfo;
			
			if (!result)
				result = "";
			
			if (adapter) {
				result = adapter.recover( result ) as String;
			}
			return [ getFirst(result), getSecond(result) ];
		}
		private function getFirst( _str:String ):int
		{
			var digit:String = _str.slice( 0, _str.search(":") );
			return int(digit)
		}
		private function getSecond( _str:String ):int
		{
			var digit:String = _str.substr( _str.search(":")+1 );
			return int(digit);
		}
		override public function getName():String 
		{
			return cellInfo;
		}
		
/*********************/
		override public function restrict( _restrict:String, _maxChars:int=0 ):void
		{
			if (_restrict!="")
				cell.restrict = _restrict;
			if(_maxChars>0)
				cell.maxChars = _maxChars;
		}
		override protected function drawValid( value:Boolean ):void
		{
			cell.valid = value;
		}
		override public function set disabled(value:Boolean):void
		{
			
			if (_disabled != value) {
				super.disabled = value;
				cell.enabled = !value;
				if (value) {	// если информация загружена раньше чем поле стало выключенным - невалидная информация будет отображаться красным
					cell.valid = true;
					if( COMBOBOX_CLEAR_WHEN_DISABLED ) {
						storeDataWhileDisabled = cell.data;
						cell.data = "";
					}
				} else
					if( COMBOBOX_CLEAR_WHEN_DISABLED )
						cell.data = storeDataWhileDisabled;
					/// для комбобоксов нуль не является недопустимым значением, его не должно быть просто в этом эл-те
					/// поэтому подменяем на валидации отсутствующие данные
					isValid( cellInfo?cellInfo:"1" );	// после разблокировки надо опять проверить валидность поля
				if (tSecond) {
					if ( value )
						tSecond.textColor = disable_color;
					else
						tSecond.textColor = color;
				}
			}
		}
		override protected function applyParam(param:int):void
		{
			switch( param ) {
				case F_RETURNS_HEXDATA:
					RETURNS_HEXDATA = true;
					break;
				case F_COMBOBOX_NOTEDITABLE:
					EDITABLE = false;
					cell.editable = false;
					
					installDefaultRegExp();
					break;
				case F_MULTYLINE:
					tName.multiline = true;
					//textFormat.leading = -7;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					tName.height = tName.textHeight+5;
					tName.y = -int((tName.height - 22)/2);
					break;
				case F_COMBOBOX_BOOLEAN:
					COMBOBOX_IS_BOOLEAN = true;
					setList( [ {label:loc("g_disabled"), data:0}, {label:loc("g_enabled"), data:1} ] );
					break;
				case F_COMBOBOX_TIME:
					COMBOBOX_IS_TIME = true;
					cell.isTime = true;
					break;
				case F_COMBOBOX_NOTCLICKABLE:
					cell.CLICKABLE = false;
					break;
				case F_COMBOBOX_CLICKABLE:
					cell.CLICKABLE = true;
					break;
				case F_ADAPTER_OVERRIDES_RECOVERY:
					adapterOverridesRecovery = true;
					break;
				case F_ALIGN_CENTER:
					cell.configure(MComboBox.OPTION_ALIGN_CENTER);
					break;
				case F_CLEAR_BOX_WHEN_DISABLED:
					COMBOBOX_CLEAR_WHEN_DISABLED = true;					
					break;
			}
		}
		override public function get width():Number
		{
			return cell.x + cell.width;
		}
		protected function installDefaultRegExp():void
		{
			var re:String = "^(";
			var len:int = cell.dataProvider.length;
			if (len > 0) {
				for (var i:int=0; i<len; ++i) {
					if (i>0)
						re += "|("+getValue()+")";
					else
						re += "("+getValue()+")";
				}
				re += ")$";
				rule = new RegExp(re);
			}
			function getValue():String
			{
				return cell.dataProvider.getItemAt(i).data;
			}
		}
		
		override public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void		
		{
			cell.transferKey(key);
		}
		
		override public function getFocusField():InteractiveObject
		{
			return cell.getFocusable();
		}
		override public function getFocusables():Object
		{
			return cell;
		}
		override public function getType():int
		{
			if (disabled)
				return TabOperator.TYPE_DISABLED;  
			return TabOperator.TYPE_ACTION;
		}
		override public function isPartOf(io:InteractiveObject):Boolean
		{
			return cell.getFocusable() == io;
		}
		
		
	}
}