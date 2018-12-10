package components.gui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import components.events.GUIEvents;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IRfManager;
	import components.protocol.Package;

	public final class MflexListSensor extends MFlexList
	{
		private var manager:IRfManager;
		
		public function MflexListSensor(c:Class, m:IRfManager)
		{
			super(c);
			
			manager = m;
		}
		override public function put(p:Package, clear:Boolean=true, evokeSave:Boolean=false):void
		{
			var len:int = p.length;
			var i:int;
			if (clear || !list) {
				clearlist();
				
				list = new Vector.<IFlexListItem>(len);
				for (i=0; i<len; i++) {
					list[i] = (new cls(i+1, manager) as IFlexListItem);
					(list[i] as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					layer.addChild( list[i] as DisplayObject );
					list[i].y = list[i].height*i;
					if (evokeSave)
						list[i].change(p);
					else
						list[i].put(p);
				}
			} else {
				len = list.length; // может быть 1 структура но положена во все строки листа
				for (i=0; i<len; i++) {
					if (evokeSave)
						list[i].change(p);
					else
						list[i].put(p);
				}
			}
		}
		/*override protected function onSelect(e:Event):void
		{
			var len:int = list.length;
			for (var i:int=0; i<len; i++) {
				if (list[i])
					list[i].selectLine = e.currentTarget == list[i];
			}
		}*/
		public function isSelected():Boolean
		{
			return selected >= 0;
		}
		public function get selected():int
		{
			if (list) {
				var len:int = list.length;
				for (var i:int=0; i<len; i++) {
					if( list[i].isSelected() )
						return i;
				}
			}
			return -1;
		}
		public function getSelected():IFlexListItem
		{
			if (list) {
				var len:int = list.length;
				for (var i:int=0; i<len; i++) {
					if( list[i].isSelected() )
						return list[i];
				}
			}
			return null;
		}
		override protected function onSelect(e:Event):void
		{
			var len:int = list.length;
			for (var i:int=0; i<len; i++) {
				if (list[i]) {
					list[i].selectLine = e.currentTarget == list[i];
					if (e.currentTarget == list[i])
						this.dispatchEvent( new Event(GUIEvents.EVOKE_READY));
				}
			}
		}
		
		
	}
}