package components.gui
{
	import flash.display.InteractiveObject;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import components.abstract.servants.TabOperator;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.triggers.ListButton;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFocusable;
	import components.interfaces.INavigationItem;
	import components.static.COLOR;
	
	public class NavigationList extends Canvas
	{
		protected var g:int; 
		
		protected var aButtonList:Array = new Array;
		protected var fMenu:Function;
		protected var buttonsXoffest:int=30;
		protected var menuAddon:UIComponent;
		protected var lastBlock:Boolean = false;
		public var isReady:Boolean = true;
		protected var _selected:int=-1;
		private var isResizeAdded:Boolean = false;
		
		public function NavigationList()
		{
			super();
			this.width = 155;
		}
		protected function block( _value:Boolean, force:Boolean=false ):void
		{
			if (lastBlock != _value || force ) {
				
				lastBlock = _value;
				var i:int;
				var len:int = aButtonList.length;
				for( i=0; i < len; ++i ) {
					if (aButtonList[i] is INavigationItem)
						(aButtonList[i] as INavigationItem).disabled = _value;
				}
			}
		}
		public function addButton( _name:String, _num:int, group:int=-1 ):void
		{
			var lb:ListButton = new ListButton(buttonsXoffest);
			addChild( lb );
			lb.setFormat( true );
			lb.setUp( _name ,globalSelect, _num );
			lb.setFormat( false, 12 );
			lb.setUpFill( COLOR.NAVI_MENU_BLUE, 170 );
			TabOperator.getInst().add(lb);
			if (group>=0)
				lb.focusgroup = group;
			if (aButtonList[_num] != null) {
				var rb:ListButton = aButtonList[_num];
				rb.undraw();
				removeChild(rb);
				aButtonList[_num] = null;
			}
			aButtonList[_num] = lb;
			
			localResize();
		}
		public function getButtonNameByIndex(value:int):String
		{
			if( aButtonList[value] is ListButton )
				return (aButtonList[value] as ListButton).getName();
			return "";
		}
		
		public function getButtonIndexByName(value:String):int
		{
			var len:int = aButtonList.length;
			for (var i:int = 0; i < len; i++) {
				if (aButtonList[i] is TextButton && (aButtonList[i] as TextButton).getName() == value) {
					return i;
				}
			}
			return -1;
		}
		
		public function addTree( _name:String, _num:int, _menu:Array):void
		{
			if (!isResizeAdded)
				GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onResize, catchResize );
			var tree:NavigationTree = new NavigationTree(_name,_menu);
			addChild( tree );
			tree.x = buttonsXoffest;
			tree.setUp( globalSelect, _num, getIsReady );
			if (aButtonList[_num] != null) {
				var rb:NavigationTree = aButtonList[_num];
				rb.undraw();
				removeChild(rb);
				aButtonList[_num] = null;
			}
			aButtonList[_num] = tree;
			TabOperator.getInst().add(tree);
			localResize();
		}
		public function addCustom(_ni:INavigationItem, _name:String, _num:int, group:int=-1 ):void
		{
			var ni:INavigationItem = _ni
			addChild( ni as InteractiveObject );
			if (ni is TextButton)
				(ni as TextButton).setUp( _name, globalSelect, _num );
			TabOperator.getInst().add(ni as IFocusable);
			if (group>=0)
				(ni as IFocusable).focusgroup = group;
			if (aButtonList[_num] != null) {
				var rb:INavigationItem = aButtonList[_num];
				rb.undraw();
				removeChild(rb as InteractiveObject);
				aButtonList[_num] = null;
			}
			aButtonList[_num] = ni;
			
			localResize();
		}
		private function getIsReady():Boolean
		{
			return isReady;
		}
		public function removeButton( _num:int ):void
		{
			(aButtonList[_num] as INavigationItem).undraw();
			removeChild( aButtonList[_num] );
			aButtonList[_num] = null;
			
			if ( _num == _selected ) {
				_selected = -1;
			}
			
			localResize();
		}
		public function scrollTo(num:int):void
		{
			var value:int = 0;
			var len:int = aButtonList.length;
			for( var i:int; i<len; ++i ) {
				if ( aButtonList[i] is INavigationItem ) {
					if (i==num )
						break;
					value += (aButtonList[i] as INavigationItem).getHeight();
				}
			}
			this.verticalScrollPosition = value;
		}
		public function getScrollTo(num:int):int
		{
			var value:int = 0;
			var len:int = aButtonList.length;
			for( var i:int; i<len; ++i ) {
				if ( aButtonList[i] is INavigationItem ) {
					if (i==num )
						break;
					value += (aButtonList[i] as INavigationItem).getHeight();
				}
			}
			return value;
		}
		protected function localResize():void
		{
			//this.height = 0;
			var h:int = 0;
			var len:int = aButtonList.length;
			for( var i:int; i<len; ++i ) {
				if ( aButtonList[i] is INavigationItem) {
					//aButtonList[i].y = this.height;
					aButtonList[i].y = h;
					//this.height += (aButtonList[i] as INavigationItem).getHeight();
					h += (aButtonList[i] as INavigationItem).getHeight();
				}
			}
			if( menuAddon ) {
				height = h + menuAddon.height + 10;
				menuAddon.y = h + 10;
			} else
				height = h;
		}
		protected function globalSelect( value:Object ):void 
		{
			if ( !isReady )
				return;
			
			var _num:int
			if (value is int)
				_num = int(value);
			else
				_num = value.num;
			
			var len:int = aButtonList.length;
			_selected = -1;
			for( var i:int; i<len; ++i  ) {
				if ( aButtonList[i] is INavigationItem ) {
					if ( (aButtonList[i] as INavigationItem).getId() == _num ) {
						(aButtonList[i] as INavigationItem).select( true );
						_selected = _num;
						fMenu( value );
						//trace( _num );
					} else (aButtonList[i] as INavigationItem).select( false ); 
				}
			}
		}
		protected function visualSelect( _num:int ):void 
		{
			var len:int = aButtonList.length;
			_selected = -1;
			for( var i:int; i<len; ++i  ) {
				if ( aButtonList[i] is INavigationItem ) {
					if ( (aButtonList[i] as INavigationItem).getId() == _num ) {
						(aButtonList[i] as INavigationItem).select( true );
						_selected = _num;
					} else (aButtonList[i] as INavigationItem).select( false ); 
				}
			}
		}	
		public function set tree_selection(value:Object):void
		{
			globalSelect( value );
		}
		public function set selection( _value:int ):void
		{
			visualSelect( _value );
		}
		public function get selection():int
		{
			return _selected;
		}
		/*public function set namedSelection(value:String):void
		{
			var s:int = -1;
			var len:int = aButtonList.length;
			for (var i:int = 0; i < len; i++) {
				if( aButtonList[i] && (aButtonList[i] as TextButton).getName() == value ) {
					s = i; 
					break;
				}
			}
			visualSelect(s);
		}
		public function get namedSelection():String
		{
			return (aButtonList[_selected] as TextButton).getName();
		}*/
		public function setUp( _funcMenu:Function, _buttonsXoffset:int=30 ):void {
			fMenu = _funcMenu;
			buttonsXoffest = _buttonsXoffset;
		}
		public function reset():void
		{
			var len:int = aButtonList.length;
			for( var i:int=0; i<len; ++i  ) {
				if ( aButtonList[i] is INavigationItem )
					( aButtonList[i] as INavigationItem ).select(false);
			}
		}
		public function clear():void
		{
			var len:int = aButtonList.length;
			for( var i:int=0; i<len; ++i  ) {
				if ( aButtonList[i] is INavigationItem ) {
					( aButtonList[i] as INavigationItem ).undraw();
					removeChild( aButtonList[i] );
				} 
			}
			aButtonList.length = 0;
			if( menuAddon ) {
				height = menuAddon.height + 10;
				menuAddon.y = 0;
			} else
				height = 0;
		}
		public function isKeeperOf(f:IFocusable):Boolean
		{	// проверка принадлежит ли данный объект этому классу
			var len:int = aButtonList.length;
			for (var i:int=0; i<len; ++i) {
				if ( aButtonList[i] == f)
					return true;
			}
			return false;
		}
		private function catchResize(ev:GUIEvents):void
		{
			localResize();
			this.dispatchEvent( new GUIEvents(GUIEvents.onResize) );
		}
	}
}