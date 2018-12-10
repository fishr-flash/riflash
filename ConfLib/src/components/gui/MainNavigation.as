package components.gui
{
	/** ver 1.0 */
	
	import flash.events.Event;
	
	import mx.core.ScrollPolicy;
	
	import components.abstract.servants.TabOperator;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.triggers.ListButton;
	import components.interfaces.IFocusable;
	import components.static.MISC;
	import components.static.PAGE;

	public final class MainNavigation extends NavigationList
	{
		public static var shift:int = 0;
		
		private static var instance:MainNavigation;
		public static function getInst():MainNavigation
		{
			if ( instance == null )	instance = new MainNavigation( new Starter);
			return instance;
		}
		private var isOffline:Boolean=true;
		private var isBlocked:Boolean=false;
		private var menu:Array;
		
		public function getCurrent():IFocusable
		{
			var len:int = aButtonList.length;
			for (var i:int=0; i<len; ++i) {
				if ( (aButtonList[i] as ListButton).getId() == _selected)
					return aButtonList[i] as IFocusable;
			}
			return null;
		}
		public function getFirst():IFocusable
		{
			return aButtonList[0] as IFocusable;
		}
		public function getList():Array
		{
			return aButtonList;
		}
		public function getMenu():Array
		{
			return menu;
		}
		public function MainNavigation(s:Starter)
		{
			super();
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, eventOnline );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onBlockNavigation, blockNavigation);
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.MAINMENU_APPEARANCE, onAppearance);
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.width = PAGE.MAINMENU_WIDTH;
			
		}
		public function generate( menuInfo:Array ):void 
		{
			if (menu != menuInfo) {
				menu = menuInfo;
				if ( aButtonList.length > 0 )
					clear();
				buttonsAssembler( menuInfo );
				this.dispatchEvent( new Event( MISC.EVENT_RESIZE_IMPACT ));
				isBlocked = true;
				block( true );
			}
		}
		public function update(page:int):void
		{
			globalSelect( page );
		}
		protected function buttonsAssembler( _arr:Array ):void {
			var lb:ListButton;
			for( var key:String in _arr ) {
				lb = new ListButton;
				lb.focusgroup = TabOperator.GROUP_MAINMENU;
				lb.focusorder = int(key);
				lb.setFormat(false,14);
				lb.setUp( _arr[key].label, globalSelect, _arr[key].data );
				lb.y = 20*aButtonList.length;
				lb.x = shift;
				if (_arr[key].status)
					lb.statusCollection = _arr[key].status;
				if (_arr[key].off)
					lb.setColor( 0x9faebb, 0x666666 );
				addChild( lb );
				aButtonList.push( lb );
				lb.disabled = true;
			}
			//block( isOffline || isBlocked );
			block( isBlocked, true );
			
			height = _arr.length*20;
		}
		private function blockNavigation( ev:SystemEvents ):void
		{
			isBlocked = ev.isBlock();
			//block( isOffline || isBlocked );
			block( isBlocked );
		}
		private function eventOnline( ev:SystemEvents ):void
		{
			isOffline = !ev.isConneted();
			//block( isOffline || isBlocked );
			block( isBlocked );
		}
		private function onAppearance(e:GUIEvents):void
		{
			var len:int = aButtonList.length;
			for (var i:int=0; i<len; i++) {
				if( (aButtonList[i] as ListButton).getId() == e.getButtonId() )
					(aButtonList[i] as ListButton).status(e.getButtonStatus());
			}
		}
	}
}
class Starter {}