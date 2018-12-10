package components.gui.triggers
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import components.abstract.functions.dtrace;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.TaskManager;
	import components.gui.Balloon;
	import components.interfaces.INavigationItem;
	import components.protocol.statics.CLIENT;
	import components.static.COLOR;
	import components.static.KEYS;
	import components.static.MISC;
	
	public class ListButton extends TextButton implements INavigationItem
	{
		protected var fillColor:int=0xcde0f2;
		protected var fillW:int=247;
		protected var fillH:int=20;
		protected var selected:Boolean;
		
		private var perm_selection:Sprite;
		public var _statusCollection:Object;

		public function set statusCollection(value:Object):void
		{	// при задании разных статусов, нулевым статусом присваивается дефолтное состояние автоматически
			_statusCollection = value;
			_statusCollection[0] = {title:tName.text, color:0x287bbf};
		}
		public function get statusCollection():Object 
		{
			return _statusCollection;
		}
		public function ListButton( _offset:int=30)
		{
			super();
			tName.x = _offset;
			defaultPlaceX = _offset;
			shiftPlaceX = _offset + 1;
		}
		public function status(n:int):void
		{
			if( statusCollection[n] is Object ) {
				setName( statusCollection[n].title );
				if (disabled)
					normalColor = statusCollection[n].color;
				else
					setColor(statusCollection[n].color, COLOR.BLACK ); 
			}
		}
		override protected function rollOut( ev:MouseEvent ):void 
		{
			if ( !selected ) 
				tName.textColor = normalColor;
			Mouse.cursor = MouseCursor.AUTO;
		}
		override protected function click( ev:MouseEvent ):void {
			if ( !selected ) { 
				if ( idNum > -1 ) {
					fClick( idNum );
				} else {
					fClick();
				}
			}
			Mouse.cursor = MouseCursor.ARROW;
		}
		override public function select( _select:Boolean ):void {
			selected = _select;
			graphics.clear();
			if ( _select ) {
				tName.textColor = overColor;
				graphics.beginFill( fillColor );
				graphics.drawRect( 0,0,fillW,fillH );
				graphics.endFill();
				
				// автоматическая установка pages
				if (MISC.COPY_DEBUG && KeyWatcher.isPressed(KEYS.Key_Z) ) {
					var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
					so.data["auto_select_page"] = int(idNum);
					CLIENT.AUTO_SELECT_PAGE = so.data["auto_select_page"];
					
					TaskManager.callLater( Balloon.access().show, 500, ["Автозагрузка", tName.text] );  
					try {
						so.flush();
					} catch(error:Error) {
						dtrace("Error: flush shared object  at DevConsole");
					}
				}
			} else
				tName.textColor = normalColor; 
			
			
		}
		public function drawPermanent(b:Boolean=true):void
		{
			if (b) {
				if(!perm_selection) {
					perm_selection = new Sprite;
					addChild( perm_selection );
				}
				perm_selection.graphics.clear();
				perm_selection.graphics.beginFill( 0xff0000, 0.2 );
				perm_selection.graphics.drawRect( 0,0,fillW,fillH );
				perm_selection.graphics.endFill();
				setChildIndex( perm_selection, 0 );
			} else {
				if(perm_selection) {
					removeChild( perm_selection );
					perm_selection = null;
				}
			}
		}
		public function setUpFill( _color:int=0xcde0f2, _w:int=247, _h:int=20 ):void {
			fillColor = _color;
			fillW = _w;
			fillH = _h;
		}
		override public function getHeight():int 
		{
			return 20;
		}
		override public function getFocusables():Object
		{
			if (tName.text == "Точка доступа")
				transform
			return tName;
		}
		
	}
}