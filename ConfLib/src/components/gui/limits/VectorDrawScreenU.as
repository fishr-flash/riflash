package components.gui.limits
{
	public final class VectorDrawScreenU extends VectorDrawScreen
	{
		public var getFunction:Function;
		public var fGetGlobalXShift:Function;
		private var gear:Object = {w:600, h:200, max_period:300, signal_resolution:1};
		private var painting:Boolean = true;	// чтобы движок понимал, что нужно сдвинуть рисующую полоску на то место, откуда он начинает рисовать
		
		public function VectorDrawScreenU(c:int, g:Object=null )
		{
			super(c);
			
			if (g)
				gear = g;
			
			vectorMask.graphics.clear();
			vectorMask.graphics.beginFill(0);
			vectorMask.graphics.drawRect(0,0, gear.w, gear.h);
			vectorMask.graphics.endFill();
		}
		override public function paint(n:Number):void
		{
			var i:int;
			var len:int;
			if (!online) {
				online = new Vector.<Number>;
				vectorScreen.graphics.clear();
				vectorScreen.graphics.lineStyle(2, color );
				vectorScreen.graphics.moveTo(0,getFunction(n) );
				online.push( n );
				//xShift = fGetGlobalXShift();//timeShift;
				xShift = fGetGlobalXShift is Function ? fGetGlobalXShift() : timeShift;
				vectorScreen.x = 0;
			} else {
				online.push( n );
				if (online.length < (gear.max_period*gear.signal_resolution) ) {
					var nu:Number = getFunction(n);
					if (!painting) {
						if( fGetGlobalXShift is Function )
							xShift = fGetGlobalXShift();
						vectorScreen.graphics.moveTo(xShift, getFunction(n) );
						vectorScreen.graphics.lineStyle(2, color );
						painting = true;
					}
					vectorScreen.graphics.lineTo(xShift, getFunction(n) );
					if( fGetGlobalXShift is Function )
						xShift = fGetGlobalXShift();
					else
						xShift += timeShift;
				} else {
					online.shift();
					vectorScreen.graphics.clear();
					vectorScreen.graphics.lineStyle(2, color );
					vectorScreen.graphics.moveTo(0,getFunction(n) );
					len = online.length;
					for (i=0; i<len; ++i) {
						vectorScreen.graphics.lineTo(timeShift*i,getFunction(online[i]));
					}
				}
			}
		}
		public function isFull():Boolean
		{
			var fully:Boolean = online != null;
			if( fully ) fully = online.length+1 >= (gear.max_period*gear.signal_resolution);
			return fully;
		}
		public function endFill():void
		{
			if( painting ) {
				vectorScreen.graphics.endFill();
				painting = false;
			}
		}
	}
}