package components.gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import components.gui.SimpleTextField;
	import components.gui.fields.lowlevel.MCheckBox;
	import components.gui.triggers.TextButton;
	import components.gui.triggers.VisualButton;
	import components.static.GuiLib;
	import components.system.UTIL;
	
	public class MCheckBoxTree extends UIComponent
	{
		public static const EVENT_SELECT:String = "EVENT_SELECT";
		
		public var itemId:Number;
		public var groupId:Number;
		
		private const EVENT_RESIZE:String = "EVENT_RESIZE";
		private const MIN_HEIGHT:int = 20;
		private var MAX_HEIGHT:int = 0;
		
		private var slave:Boolean;
		private var bridge:Sprite;
		private var text:SimpleTextField;
		private var cb:MCheckBox;
		private var tree:Array;
		private var bSwitch:VisualButton;
		private var _closed:Boolean;
		private var toplevel:MCheckBoxTree;
		
		/** Если title == null, значит это верхняя часть дерева	*/
		public function MCheckBoxTree(title:String=null)
		{
			super();
			
			slave = title is String;
			
			if (slave) {
				bridge = new GuiLib.cTreeBridgeShort;
				addChild( bridge );
				bridge.y = -3;
			} else
				toplevel = this;
			
			cb = new MCheckBox;
			addChild( cb );
			cb.x = 14;
			cb.y = 8;
			cb.addEventListener( MouseEvent.CLICK, onClick );
			
			text = new SimpleTextField(title is String ? title : "root", 100);
			addChild( text );
			text.x = 30;
			height = MIN_HEIGHT;
		}
		public function closeChildren():void
		{
			if(tree) {
				var len:int = tree.length;
				for (var i:int=0; i<len; i++) {
					tree[i].closeChildren();
				}
				if (slave)
					closed = true;
			}
		}
		public function set items(a:Array):void
		{
			if (a) {
				tree = new Array;
				var t:MCheckBoxTree;
				var h:int = height;
				
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					t = new MCheckBoxTree(a[i].name);
					t.itemId = a[i].id;
					t.groupId = isNaN(a[i].groupId) ? NaN : a[i].groupId;
					t.toplevel = toplevel;
					addChild( t );
					t.items = a[i].items;
					tree.push( t );
					t.y = h;
					t.x = 20;
					t.addEventListener( EVENT_RESIZE, resize );
					h += t.height;
				}
				height = h;
				MAX_HEIGHT = h;
				
				if (slave) {
					bSwitch = new VisualButton(GuiLib.cIcon);
					addChild( bSwitch );
					bSwitch.setUp( "", tree_action );
					bSwitch.x = -4;
					bSwitch.y = -1;
				}
			}
		}
		public function getSelected():Array
		{
			var a:Array = [];
			if (selected && slave) {
				if (tree)
					a.push([itemId]);
				else
					a.push(itemId);
			}
			if (tree) {
				var len:int = tree.length;
				for (var i:int=0; i<len; i++) {
					a = a.concat( tree[i].getSelected() );
				}
			}
			return a;
		}
		/*public function getTree():Object
		{
			var a:Array;
			if (tree) {
				a = [];
				var t:Object;
				var len:int = tree.length;
				for (var i:int=0; i<len; i++) {
					t = tree[i].getTree();
					if (t)
						a[i] = {selected:tree[i].selected, tree:tree[i].getTree()};
					else
						a[i] = {selected:tree[i].selected};
				}
			}
			return {selected:selected, items:a};
		}*/
		public var auto:Boolean = false;
		public function initSelector():int
		{
			// 1 - all deselectd
			// 2 - all selected
			// 3 - some some
			if (!slave)
				auto = true;

			if (tree) {
				var len:int = tree.length;
				var bit:int;
				var num:int;
				for (var i:int=0; i<len; i++) {
					
					num = tree[i].initSelector();
					switch(num) {
						case 1:
							bit = UTIL.changeBit(bit,0,true);
							break;
						case 2:
							bit = UTIL.changeBit(bit,1,true);
							break;
						case 3:
							selected = false;
							break; 
					}
					if (num==3)
						break;
				}
				switch(bit) {
					case 1:
						selected = true; 
						break;
					case 2:
					case 3:
						selected = false;
						break;
				}
				if (!slave) 
					auto = false;				
				return bit;
			}
			if (!slave)
				auto = false;
			return selected ? 1 : 2;
		}
		
		public function set selected(value:Boolean):void
		{
			cb.selected = value;
			if (!toplevel.auto)	// если не включена автоматическая расстановка галочек
				onClick();
		}
		public function get selected():Boolean 
		{
			return cb.selected;
		}
		public function set closed(value:Boolean):void
		{
			_closed = value;
			if (value) {
				bSwitch.frame = 5;
				this.height = MIN_HEIGHT;
			} else {
				bSwitch.frame = 1;
				this.height = MAX_HEIGHT;
			}
			resize();
		}
		public function get closed():Boolean
		{
			return _closed;
		}
		public function destroy():void
		{
			if (slave) {
				toplevel = null;
				cb.removeEventListener( MouseEvent.CLICK, onClick );
			} else
				this.height = MIN_HEIGHT;
			if (tree) {
				var len:int = tree.length;
				for (var i:int=0; i<len; i++) {
					tree[i].removeEventListener( EVENT_RESIZE, resize );
					removeChild(tree[i]);
					tree[i].destroy();
				}
				tree = null;
			}
		}
		private function tree_action(ev:MouseEvent=null):void
		{
			closed = !closed;
		}
		private function resize(e:Event=null):void
		{
			var h:int = MIN_HEIGHT;
			if (tree) {
				var len:int = tree.length;
				for (var i:int=0; i<len; i++) {
					tree[i].visible = !closed;
					if (!closed) {
						tree[i].y = h;
						h += tree[i].height;
					}
				}
				this.height = h;
			}
			this.dispatchEvent( new Event( EVENT_RESIZE ));
		}
		private function onClick(e:Event=null):void
		{
			if (tree) {
				var len:int = tree.length;
				for (var i:int=0; i<len; i++) {
					tree[i].selected = selected;
				}
			}
			if (e)
				callLater( dispatchSelected );
		}
		private function deselectParent(cb:MCheckBoxTree):void
		{
			cb.selected=false
		}
		private function dispatchSelected():void
		{
			toplevel.dispatchEvent( new Event( EVENT_SELECT ));
		}
	}
}	