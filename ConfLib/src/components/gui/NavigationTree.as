package components.gui
{
	import components.abstract.servants.TabOperator;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.triggers.ListButton;
	import components.gui.triggers.TextButton;
	import components.gui.triggers.TreeButton;
	import components.gui.triggers.VisualButton;
	import components.interfaces.IFocusable;
	import components.interfaces.INavigationItem;
	import components.static.GuiLib;
	import components.static.KEYS;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	public class NavigationTree extends UIComponent implements INavigationItem, IFocusable
	{
		private var buttons:Vector.<TextButton>;
		
		private const OFFEST_X:int = 22;
		private const OFFEST_Y:int = 18;
		private const OFFEST_Y_START:int = 21;
		private var MAX_HEIGHT:int = 0;
		
		private var _selected:int = -1;
		private var _closed:Boolean = false;
		private var _id:int;
		private var fClick:Function;
		private var fGetIsReady:Function;
		private var _disabled:Boolean;
		private var current_selected:Boolean;
		private var title:String;
		
		private var fillColor:int=0x287bbf;
		private var fillW:int=122;
		private var fillH:int=18;
		
		private var perm_selection:Sprite;
		
		private var bTitle:ListButton;
		private var bSwitch:VisualButton;
		
		public function NavigationTree(_title:String, items:Array)
		{
			super();
			buttons = new Vector.<TextButton>;
			
			title = _title;
			bTitle = new ListButton;
			addChild( bTitle );
			bTitle.setFormat(false,12);
			bTitle.setUp( title, click, 0 );
			bTitle.setUpFill( 0xcde0f2, fillW,fillH );
			bTitle.doubleClickEnabled = true;
			bTitle.addEventListener( MouseEvent.DOUBLE_CLICK, tree_action );
			
			bSwitch = new VisualButton(GuiLib.cIcon);
			addChild( bSwitch );
			bSwitch.setUp( "", tree_action );
			bSwitch.x = 2;
			
			buttons.push( bTitle );
			
			var but:TextButton;
			var len:int = items.length;
			for(var i:int=0; i<len; ++i) {
				but = new TreeButton;
				addChild( but );
				but.setUp(items[i], click, i+1 );
				but.x = OFFEST_X;
				but.y = i*OFFEST_Y+OFFEST_Y_START;
				buttons.push( but );
			}
			this.height = i*OFFEST_Y+OFFEST_Y_START;
			MAX_HEIGHT = this.height;
			
		}
		private function click( _num:int ):void 
		{
			if (fGetIsReady() == true ) {
				procesList(_num);
				fClick( {num:_id, sub:selected});
			}
		}
		private function procesList(_num:int):void
		{
			var len:int = buttons.length;
			_selected = -1;
			for( var i:int; i<len; ++i  ) {
				if ( buttons[i] is TextButton ) {
					if ( (buttons[i] as TextButton).getId() == _num ) {
						(buttons[i] as TextButton).select( true );
						_selected = _num;
					} else (buttons[i] as TextButton).select( false ); 
				}
			}
		}
		private function tree_action(ev:MouseEvent=null):void
		{
			closed = !closed;
		}
		public function set closed(value:Boolean):void
		{
			var len:int = buttons.length;
			for(var i:int=1; i<len; ++i ) {
				(buttons[i] as TextButton).visible = !value;
			}
			_closed = value;
			if (value) {
				bSwitch.frame = 5;
				this.height = OFFEST_Y_START;
			} else {
				bSwitch.frame = 1;
				this.height = MAX_HEIGHT;
			}
			
			if(perm_selection)
				drawPermanent();
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onResize );
		}
		public function get closed():Boolean
		{
			return _closed;
		}
		public function setUp(_clickFunc:Function, _idnum:int=-1, f:Function=null ):void
		{
			_id = _idnum;
			fGetIsReady = f;
			fClick = _clickFunc;
		}
		public function get selected():int
		{
			return _selected;
		}
		public function getId():int
		{
			return _id;
		}
		public function select(value:Boolean):void
		{
			if(current_selected == value)
				return;
			
			graphics.clear();
			if(value) {
				graphics.lineStyle(1,fillColor);
				graphics.drawRect( 0,0,fillW,fillH );
				graphics.endFill();
			} else {
				procesList(-1);
			}
			
			current_selected = value;
		}
		public function undraw():void
		{
			bTitle.removeEventListener( MouseEvent.DOUBLE_CLICK, tree_action );
		}
		public function set disabled(value:Boolean):void {}
		public function get disabled():Boolean { return false }
		public function getHeight():int 
		{
			//if(closed)
			//	return OFFEST_Y_START;
			return this.height; 
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
				perm_selection.graphics.drawRect( 0,0,fillW+1,getHeight() );
				perm_selection.graphics.endFill();
				setChildIndex( perm_selection, 0 );
			} else {
				if(perm_selection) {
					addChild( perm_selection );
					perm_selection = null;
				}
			}
		}
		
		public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			switch(key) {
				case KEYS.Spacebar:
				case KEYS.Enter:
					(getFocusField() as TextButton).doAction(key);
					break;
				case KEYS.RightArrow:
					closed = false;
					break;
				case KEYS.DownArrow:
					doNavigate(true);
					break;
				case KEYS.LeftArrow:
					closed = true;
					click(0);
					TabOperator.getInst().iNeedFocus(this);
					break;
				case KEYS.UpArrow:
					doNavigate(false);
					break;
			}
			
		}
		private function doNavigate(forward:Boolean):void
		{
			if (closed)
				click(0);
				else {
					var len:int = buttons.length;
					for (var i:int=0; i<len; ++i) {
						if (TabOperator.getInst().currentFocus() == buttons[i] ) {
							
							if (forward) {
								if( i+1 < len )
									click(i+1);
								else
									click(0);
							} else {
								if( i > 0 )
									click(i-1);
								else
									click(len-1);
							}
							break;
						}
					}
				}
			TabOperator.getInst().iNeedFocus(this);
		}
		public function focusSelect():void
		{
			// TODO Auto Generated method stub
			
		}
		public function getFocusField():InteractiveObject
		{
			if (closed)
				return buttons[0];
			var len:int = buttons.length;
			for (var i:int=0; i<len; ++i) {
				if( _selected == buttons[i].getId() ) {
					return buttons[i];
				}
			}
			return buttons[0];
		}
		
		private var aButtons:Array;
		public function getFocusables():Object
		{
			if (!aButtons) {
				aButtons = [];
				var len:int = buttons.length;
				for (var i:int=0; i<len; ++i) {
					aButtons.push( buttons[i] );
				}
			}
			return aButtons;
		}
		
		public function getType():int
		{
			// TODO Auto Generated method stub
			return TabOperator.TYPE_ACTION;
		}
		
		public function isPartOf(io:InteractiveObject):Boolean
		{
			var len:int = buttons.length;
			for (var i:int=0; i<len; ++i) {
				if( buttons[i] == io )
					return true;
			}
			return false;
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
	}
}