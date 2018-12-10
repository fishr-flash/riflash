package components.gui.limits
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import components.abstract.AccEngine;
	import components.abstract.functions.loc;
	import components.events.AccEvents;
	import components.gui.SimpleTextField;
	import components.screens.ui.UIAccLimits;
	import components.static.COLOR;
	
	public class LimitTimeline extends UIComponent
	{
		private var tStartTime:SimpleTextField;
		private var tEndTime:SimpleTextField;
		private var tNavigation:SimpleTextField;
		private var cursor:Sprite;
		private var rect:Rectangle;
		private var naviWidth:int
		private var dragging:Boolean;
		private var tCurrentTime:SimpleTextField;
		private var disableScreen:Sprite;
		
		public function LimitTimeline(w:int)
		{
			super();
			
			naviWidth = w-145;
			
			tStartTime = new SimpleTextField( "0"+loc("time_sec_3l")+".", 60, COLOR.BLACK );
			tStartTime.setSimpleFormat( "left", 0, 16,true );
			addChild( tStartTime );
			
			tEndTime = new SimpleTextField( AccEngine.TOTAL_TIME+loc("time_sec_3l")+".", 80, COLOR.BLACK );
			tEndTime.setSimpleFormat( "left", 0, 16,true );
			addChild( tEndTime );			
			tEndTime.x = w - 75;
			
			tNavigation = new SimpleTextField( loc("his_navi"),0, COLOR.BLACK );
			tNavigation.setSimpleFormat("center");
			addChild( tNavigation );		
			tNavigation.x = tStartTime.width + int( naviWidth*0.5 - tNavigation.width * 0.5);
			
			this.graphics.beginFill( COLOR.LIGHT_GREY );
			this.graphics.drawRect(59,0,naviWidth+1,20);
			this.graphics.endFill();
			this.graphics.lineStyle( 1, COLOR.BLACK );
			this.graphics.drawRect(59,0,naviWidth+1,20);
			this.graphics.endFill();
			
			cursor = new Sprite;
			addChild( cursor );
			cursor.graphics.beginFill( COLOR.SATANIC_GREY );
			cursor.graphics.drawRect(0,1,int(naviWidth*(AccEngine.MAX_PERIOD/AccEngine.TOTAL_TIME)),19);
			cursor.graphics.endFill();
			cursor.x = tStartTime.width;
			
			tCurrentTime = new SimpleTextField("0"+loc("time_sec_3l")+".", 50);
			tCurrentTime.setSimpleFormat("center");
			cursor.addChild( tCurrentTime );
			tCurrentTime.y = -17;
			tCurrentTime.x = -2;
			
			this.height = 20;
			this.width = w;
			
			rect = new Rectangle(tStartTime.width,0,naviWidth-int(naviWidth*(AccEngine.MAX_PERIOD/AccEngine.TOTAL_TIME)),0);
			
			cursor.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			
			disableScreen = new Sprite;
			addChild( disableScreen );
			disableScreen.graphics.beginFill( COLOR.WHITE, 0.8 );
			disableScreen.graphics.drawRect(0,-14, this.width, this.height+15 );
			disableScreen.visible = false;
		}
		public function reset():void
		{
			cursor.x = tStartTime.width;
			tCurrentTime.text = "0"+loc("time_sec_3l")+".";
		}
		public function colorize(c:int):void
		{
			cursor.graphics.clear();
			
			cursor.graphics.beginFill( c );
			cursor.graphics.drawRect(0,1,int(naviWidth*(AccEngine.MAX_PERIOD/AccEngine.TOTAL_TIME)),19);
			cursor.graphics.endFill();
			cursor.graphics.lineStyle(1, COLOR.SATANIC_GREY );
			cursor.graphics.drawRect(0,1,int(naviWidth*(AccEngine.MAX_PERIOD/AccEngine.TOTAL_TIME)-1),18);
			cursor.graphics.endFill();
			
			tCurrentTime.textColor = c;
		}
		public function open():void
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
		}
		public function close():void
		{
			stage.removeEventListener( MouseEvent.MOUSE_UP, mUp );
		}
		public function set disabled(b:Boolean):void
		{
			disableScreen.visible = b;
		}
		public function get disabled():Boolean
		{
			return disableScreen.visible;
		}
		private function mDown(ev:MouseEvent):void
		{
			dragging = true;
			cursor.startDrag(false, rect);
			//cursor.addEventListener(
		}
		private function mUp(ev:MouseEvent):void
		{
			cursor.stopDrag();
			if (dragging) {
				this.dispatchEvent( new AccEvents( AccEvents.onTimelineMove, (((cursor.x-tStartTime.width)/naviWidth)*AccEngine.TOTAL_TIME) ) );
				
				tCurrentTime.text = int(((cursor.x-tStartTime.width)/naviWidth)*AccEngine.TOTAL_TIME)+loc("time_sec_3l")+".";
				dragging = false;
			}
		}
	}
}