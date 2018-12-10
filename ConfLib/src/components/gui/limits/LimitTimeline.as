package components.gui.limits
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import components.abstract.AccEngine;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.events.AccEvents;
	import components.gui.SimpleTextField;
	import components.interfaces.IFocusable;
	import components.static.COLOR;
	import components.static.KEYS;
	
	public class LimitTimeline extends UIComponent implements IFocusable
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
			TabOperator.getInst().iNeedFocus(this);
			dragging = true;
			cursor.startDrag(false, rect);
			//cursor.addEventListener(
		}
		private function mUp(ev:MouseEvent):void
		{
			cursor.stopDrag();
			if (dragging) {
				place();
				dragging = false;
			}
		}
		private function place():void
		{
			this.dispatchEvent( new AccEvents( AccEvents.onTimelineMove, (((cursor.x-tStartTime.width)/naviWidth)*AccEngine.TOTAL_TIME) ) );
			
			tCurrentTime.text = int(((cursor.x-tStartTime.width)/naviWidth)*AccEngine.TOTAL_TIME)+ loc("time_sec_3l")+ ".";
		}
		
		/** IFocusable	*/
		
		public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			switch(key) {
				case KEYS.LeftArrow:
					cursor.x -=	(naviWidth/100);
					if (cursor.x < tStartTime.width)
						cursor.x = tStartTime.width;
					place();
					break;
				case KEYS.RightArrow:
					cursor.x +=	(naviWidth/100);
					if (cursor.x > naviWidth-int(naviWidth*(AccEngine.MAX_PERIOD/AccEngine.TOTAL_TIME))+tStartTime.width )
						cursor.x = naviWidth-int(naviWidth*(AccEngine.MAX_PERIOD/AccEngine.TOTAL_TIME))+tStartTime.width;
					place();
					break;
			}
		}
		public function focusSelect():void		{	}
		public function getFocusField():InteractiveObject
		{
			return this;
		}
		public function getFocusables():Object
		{
			return this;
		}
		public function getType():int
		{
			if (disabled)
				return TabOperator.TYPE_DISABLED;
			return TabOperator.TYPE_NORMAL;
		}
		public function isPartOf(io:InteractiveObject):Boolean
		{
			return this == io;;
		}
		protected var _focusgroup:Number = 0;
		protected var _focusorder:Number = NaN;
		public function set focusgroup(value:Number):void
		{
			_focusgroup = value;
		}
		public function set focusorder(value:Number):void
		{
			//	if ( isNaN(_focusorder) )
			_focusorder = value;
		}
		public function get focusorder():Number
		{
			return _focusorder + _focusgroup;
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
	}
}