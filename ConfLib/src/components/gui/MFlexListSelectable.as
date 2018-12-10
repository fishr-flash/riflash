package components.gui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import components.abstract.functions.dtrace;
	import components.events.GUIEvents;
	import components.interfaces.IFlexListItem;
	import components.protocol.Package;

	public final class MFlexListSelectable extends MFlexList
	{
		public function MFlexListSelectable(c:Class)
		{
			super(c);
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
			//(e as IFlexListItem).getStructure();
			var len:int = list.length;
			for (var i:int=0; i<len; i++) {
				if (list[i]) {
					list[i].selectLine = e.currentTarget == list[i];
					if (e.currentTarget == list[i])
						this.dispatchEvent( new Event(GUIEvents.EVOKE_READY));
				}
			}
		}
		public function addpack(a:Array, forceStructureNumeration:Boolean=false):IEventDispatcher
		{
			if (!list)
				list = new Vector.<IFlexListItem>;
			var i:IFlexListItem;
			var p:Package = a[0];
			if( forceStructureNumeration )
				i = new cls(p.structure);
			else
				i = new cls(list.length);
			layer.addChild( i as DisplayObject );
			(i as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
			i.y = i.height*list.length;
			var len:int = a.length;
			for (var j:int=0; j<len; j++) {
				i.put(a[j]);
			}
			list.push(i);
			
			if (allowComponentControlItsHeight) {
				height = i.height*list.length;
				allowComponentControlItsHeight = true;
			}
			return i as IEventDispatcher;
		}
		public function putEvery(o:Object):void
		{
			if (list) {
				var len:int = list.length;
				for (var i:int=0; i<len; i++) {
					try {
						list[i].putRaw( o );
					} catch(error:Error) {
						dtrace("MFlexList error: putPack() outOfRange");
					}
				}
			} else
				dtrace("MFlexList error: putPack() list doesn't exist");
		}
	}
}