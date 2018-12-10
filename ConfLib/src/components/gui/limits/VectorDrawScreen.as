package components.gui.limits
{
	import components.abstract.AccEngine;
	
	import flash.display.Shape;
	
	import mx.core.UIComponent;
	
	public class VectorDrawScreen extends UIComponent
	{
		protected var vectorScreen:Shape;
		private var PAINTING:Boolean = false;
		protected var xShift:Number;
		protected var timeShift:Number;
		protected var color:int;
		private var lastNaviTime:int;
		
		public var history:Vector.<Number>;
		protected var online:Vector.<Number>;
		protected var vectorMask:Shape;
		
		public function VectorDrawScreen(c:int)
		{
			super();
			
			color = c;
			
			vectorScreen = new Shape;
			addChild( vectorScreen );
			
			vectorMask = new Shape;
			addChild( vectorMask );
			vectorMask.graphics.beginFill(0);
			vectorMask.graphics.drawRect(0,0, AccEngine.BOX_CURRENT_WIDTH, AccEngine.BOX_CURRENT_HEIGHT);
			vectorScreen.mask = vectorMask;
		}
		public function clear():void
		{
			history = null;
			online = null;
		}
		public function installHistory(v:Vector.<Number>):void
		{
			history = v;
			online = null;
			
			xShift = timeShift;
			vectorScreen.x = 0;
			vectorScreen.graphics.clear();
			vectorScreen.graphics.lineStyle(2, color );
			vectorScreen.graphics.moveTo(0,0);
			var len:int = history.length;
			for ( var i:int=0; i<len; ++i) {
				vectorScreen.graphics.lineTo(timeShift*i, AccEngine.getYByAcp(history[i]));
			}
		}
		public function setup(tshift:Number ):void
		{
			timeShift = tshift;
		}
		public function navigate(t:int):void
		{
			lastNaviTime = t;
			var currentTimeCoef:Number = t/(AccEngine.TOTAL_TIME-AccEngine.MAX_PERIOD);
			var totalMoveSpace:int = (AccEngine.TOTAL_TIME*AccEngine.SIGNAL_RESOLUTION)*timeShift-AccEngine.BOX_CURRENT_WIDTH;
			vectorScreen.x = -totalMoveSpace*currentTimeCoef; 
		}
		public function resize():void
		{
			vectorMask.graphics.clear();
			vectorMask.graphics.beginFill(0);
			vectorMask.graphics.drawRect(0,0, AccEngine.BOX_CURRENT_WIDTH, AccEngine.BOX_CURRENT_HEIGHT);

			var current:Vector.<Number>;
			if (online)
				current = online;
			else
				current = history;
			
			if (current) {
				vectorScreen.graphics.clear();
				vectorScreen.graphics.lineStyle(2, color );
				var len:int = current.length;
				xShift = timeShift*len;
				for (var i:int=0; i<len; ++i) {
					vectorScreen.graphics.lineTo(timeShift*i,AccEngine.getYByAcp(current[i]));
				}
			}
			if (!AccEngine.LIVE)
				navigate(lastNaviTime);
		}
		private var vs:int = 0;
		public function paint(n:Number):void
		{
			var i:int;
			var len:int;
			if (AccEngine.LIVE && !AccEngine.RECORDING) {
				lastNaviTime = 0;
				history = null;
				if (!online) {
					online = new Vector.<Number>;
					vectorScreen.graphics.clear();
					vectorScreen.graphics.lineStyle(2, color );
					vectorScreen.graphics.moveTo(0,AccEngine.getYByAcp(n) );
					online.push( n );
					xShift = timeShift;
					vectorScreen.x = 0;
				} else {
					online.push( n );
					if (online.length < (AccEngine.MAX_PERIOD*AccEngine.SIGNAL_RESOLUTION) ) {
						var nu:Number = AccEngine.getYByAcp(n);
						vectorScreen.graphics.lineTo(xShift, AccEngine.getYByAcp(n) );
						xShift += timeShift;
					} else {
						online.shift();
						vectorScreen.graphics.clear();
						vectorScreen.graphics.lineStyle(2, color );
						vectorScreen.graphics.moveTo(0,AccEngine.getYByAcp(n) );
						len = online.length;
						for (i=0; i<len; ++i) {
							vectorScreen.graphics.lineTo(timeShift*i,AccEngine.getYByAcp(online[i]));
						}
					}
				}
				if(vectorScreen.width>AccEngine.BOX_CURRENT_WIDTH)
					vectorScreen.x = -(vectorScreen.width-AccEngine.BOX_CURRENT_WIDTH);
			} else {
				online = null;
				if (!history) {
					history = new Vector.<Number>;
					vectorScreen.graphics.clear();
					vectorScreen.graphics.lineStyle(2, color );
					vectorScreen.graphics.moveTo(0,AccEngine.getYByAcp(n) );
					history.push(n);
					xShift = timeShift;
					vectorScreen.x = 0;
				} else {
					history.push( n );
					if (history.length < (AccEngine.TOTAL_TIME*AccEngine.SIGNAL_RESOLUTION) ) {
						vectorScreen.graphics.lineTo(timeShift*history.length,AccEngine.getYByAcp(n) );
					} else {
						history.shift();
						vectorScreen.graphics.clear();
						vectorScreen.graphics.lineStyle(2, color );
						vectorScreen.graphics.moveTo(0,AccEngine.getYByAcp(n) );
						len = history.length;
						for (i=0; i<len; ++i) {
							vectorScreen.graphics.lineTo(timeShift*i,AccEngine.getYByAcp(history[i]));
						}
					}
					if (AccEngine.LIVE) {
						lastNaviTime = 0;
						if(vectorScreen.width>AccEngine.BOX_CURRENT_WIDTH)
							vectorScreen.x = -(vectorScreen.width-AccEngine.BOX_CURRENT_WIDTH);
					}
				}
			}
		}
	}
}