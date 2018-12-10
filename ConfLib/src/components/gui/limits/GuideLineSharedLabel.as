package components.gui.limits
{
	import flash.display.DisplayObject;
	
	import components.abstract.AccEngine;
	import components.abstract.functions.loc;
	import components.events.AccEvents;
	import components.gui.SimpleTextField;
	
	public class GuideLineSharedLabel extends SimpleTextField
	{
		private var objs:Array;
		public var time:Number;
		
		public function GuideLineSharedLabel( ... args )
		{
			super("-",75,(args[0] as LimitGuideLine).color);
			setSimpleFormat("center");
			
			objs = new Array;
			
			var len:int = args.length;
			for (var i:int=0; i<len; ++i) {
				if (args[i] is DisplayObject) {
					args[i].addEventListener( AccEvents.onSharedGuideLineMove, updatePos );
					objs[i] = (args[i] as DisplayObject);
				}
			}
		}
		
		public function updatePos(ev:AccEvents=null):void
		{
			var pos:Number = 0;
			var len:int = objs.length;
			var min:Number = 0xffff;
			var max:Number = 0;
			for (var i:int=0; i<len; ++i) {
				pos += objs[i].x;
				if (min > objs[i].x)
					min = objs[i].x;
				if (max < objs[i].x)
					max = objs[i].x;
			}
			this.x = int(pos/len-this.width/2+2);
			this.y = (objs[0] as LimitGuideLine).height;
			
			var totalw:int = AccEngine.BOX_CURRENT_WIDTH;
			var period:int = AccEngine.BOX_TIME_PERIOD;
			
			time = (max-min)/totalw * period;
			
			if (time > 0) {
				if (AccEngine.EXPAND)
					this.text = (time).toFixed(2) + loc("time_sec_1l");
				else
					this.text = (time).toFixed(1) + loc("time_sec_1l");
			} else
				this.text = loc("time_instant");
		}
	}
}