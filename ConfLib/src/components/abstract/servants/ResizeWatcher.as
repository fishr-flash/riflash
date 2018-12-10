package components.abstract.servants
{
	import components.interfaces.IResizeDependant;
	import components.static.MISC;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class ResizeWatcher
	{
		private static var f:Function;
		private static var fpuppet:Function;
		
		private static var dependers:Vector.<IResizeDependant>;
		public static var lastHeight:int;
		public static var lastWidth:int;
		
		public function ResizeWatcher(delegate:Function, puppet:Function)
		{
			f = delegate;
			fpuppet = puppet;
		}
		public function add( r:IEventDispatcher ):void
		{
			r.addEventListener( MISC.EVENT_RESIZE_IMPACT, impact );
		}
		public static function addDependent( d:IResizeDependant, update:Boolean=true ):void
		{
			if (!dependers) {
				dependers = new Vector.<IResizeDependant>;
			} else {
				var len:int = dependers.length;
				for (var i:int=0; i<len; ++i) {
					if ( dependers[i] == d ) {
						if (update)	// если обновление вызывает уже присутствующий на сцене компонент
							d.localResize(lastWidth,lastHeight,false);
						return;
					}
				}
			}
			dependers.push( d );
			if (update)
				d.localResize(lastWidth,lastHeight,false);
		}
		public static function removeDependent( d:IResizeDependant ):void
		{
			if (dependers) {
				var len:int = dependers.length;
				for (var i:int=0; i<len; ++i) {
					if ( dependers[i] == d ) {
						dependers.splice(i,1);
						break;
					}
				}
				if (dependers.length == 0)
					dependers = null;
			}
		}
		public static function doResizeMe(me:IResizeDependant):void
		{
			me.localResize(lastWidth,lastHeight,false);
		}
		public static function doResize(w:int, h:int):void
		{
			fpuppet(w,h);
		}
		public static function doReturn():void
		{
			f();
		}
		public function resize(w:int, h:int):void
		{
			var real:Boolean = Boolean( lastWidth != w || lastHeight != h );
			if (real)
				trace("w"+w + " h" +h);
			
			lastWidth = w;
			lastHeight = h;
			if (dependers) {
				var len:int = dependers.length;
				for (var i:int=0; i<len; ++i) {
					dependers[i].localResize(w,h,real);
				}
			}
		}
		private function impact(ev:Event):void
		{
			f();
		}
	}
}