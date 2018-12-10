package components.gui.limits
{
	import components.screens.ui.UIVSensors;

	public final class VectorDrawScreenU extends VectorDrawScreen
	{
		public var getFunction:Function;
		
		public function VectorDrawScreenU(c:int)
		{
			super(c);
			
			vectorMask.graphics.clear();
			vectorMask.graphics.beginFill(0);
			vectorMask.graphics.drawRect(0,0, UIVSensors.GRAPH_WIDTH, UIVSensors.GRAPH_HEIGHT);
			vectorMask.graphics.endFill();
		//	vectorScreen.mask = null;
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
				xShift = timeShift;
				vectorScreen.x = 0;
			} else {
				online.push( n );
				//if (online.length < ((UIAccLimits.MAX_PERIOD*UIAccLimits.SIGNAL_RESOLUTION)/UIAccLimits.REQUEST_DELAY) ) {
				if (online.length < (UIVSensors.MAX_PERIOD*UIVSensors.SIGNAL_RESOLUTION) ) {
					var nu:Number = getFunction(n);
					vectorScreen.graphics.lineTo(xShift, getFunction(n) );
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
		/*	if(vectorScreen.width>UIVSensors.GRAPH_WIDTH)
				vectorScreen.x = -(vectorScreen.width-UIVSensors.GRAPH_WIDTH);*/
		}
	}
}