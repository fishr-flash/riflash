package components.gui.fields.lowlevel.parts
{
	import components.gui.fields.lowlevel.interfaces.IComboBoxItem;
	import components.static.COLOR;
	import components.static.GuiLib;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class MScrolling extends Sprite
	{
		private const NORMAL:int = 1;
		private const OVER:int = 3;
		private const DOWN:int = 5;
		
		public var pane:Sprite;
		public var background:Boolean=true;
		
		private var maskLayer:Shape;
		private var s_up:MovieClip;
		private var s_down:MovieClip;
		private var s_bar:MovieClip;
		private var s_bg:MovieClip;
		private var vRail:Rectangle;	// vertical rail рельсы для драга
		private var scrollBackFround:Shape;
		
		public function MScrolling(_h:int)
		{
			super();
			
			Engine.itemHeight = _h;
			
			scrollBackFround = new Shape;
			addChild( scrollBackFround );
			
			pane = new Sprite;
			addChild( pane );

			s_bg = new GuiLib.m_scroll_bg;
			addChild( s_bg );
			s_bg.gotoAndStop(NORMAL);
			s_bg.addEventListener( MouseEvent.CLICK, onClick );
			
			s_up = skinnAdd(new GuiLib.m_scroll_up);
			s_bar = skinnAdd(new GuiLib.m_scroll_bar, true);
			s_down = skinnAdd(new GuiLib.m_scroll_down);
			
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel );
			
			vRail = new Rectangle;
		}
		public function add(child:IComboBoxItem):void
		{
			pane.addChild(child as DisplayObject);
			Engine.contentMax = pane.height;
		}
		public function set active(b:Boolean):void
		{
			s_up.visible = b;
			s_down.visible = b;
			s_bar.visible = b;
			s_bg.visible = b;
		}
		public function get active():Boolean
		{
			return s_bg.visible;
		}
		override public function get width():Number
		{
			return s_bar.width;
		}
		public function scrollTo(n:int):void
		{
			Engine.jumpTo(n, s_bar);
			contentMove();
		}
		public function size(w:int, h:int):void
		{
			if (!maskLayer) {
				maskLayer = new Shape;
				addChild( maskLayer );
				pane.mask = maskLayer;
			}
			maskLayer.graphics.clear();
			maskLayer.graphics.beginFill( COLOR.BLACK );
			maskLayer.graphics.drawRect(0,0,w,h);
			maskLayer.graphics.endFill();
			
			if( background ) {
				scrollBackFround.graphics.clear();
				scrollBackFround.graphics.beginFill( COLOR.WHITE );
				scrollBackFround.graphics.drawRect(0,0,w-width,h);
				scrollBackFround.graphics.endFill();
			}
			s_up.x = w - s_up.width;
			s_down.x = w - s_up.width;
			s_down.y = h - s_down.height;
			s_bar.x = w - s_up.width;
			s_bar.y = s_up.height - 1;								// заступ в 1 пиксель для стыковки бара и стрелочки
			s_bg.x = w - s_up.width;
			s_bg.y = s_up.height;
			s_bg.height = h - s_up.height*2;
			
			vRail.x = w - s_up.width;
			vRail.y = s_up.height - 1;								// заступ в 1 пиксель для стыковки бара и стрелочки
			vRail.height = s_bg.height - (s_bar.height - 4); 		// 2 пикселя - тень которая должна заходить поднижнюю стрелочку + 2 пикселя заступ
			Engine.scrlMax = vRail.height;
			Engine.barMinPos = s_bar.y;
			Engine.contentVisibleHeight = maskLayer.height;
			
			active = pane.height > h;
		}
		public function reset():void
		{
			pane.y = 0;
			s_bar.y = s_up.height - 1;								// заступ в 1 пиксель для стыковки бара и стрелочки
			Engine.contentMax = 0;
		}
/**			MISC			***/
		private function skinnAdd(m:MovieClip, bar:Boolean=false):MovieClip
		{
			addChild(m);
			m.gotoAndStop(NORMAL);
			m.addEventListener( MouseEvent.ROLL_OVER, onOver );
			m.addEventListener( MouseEvent.ROLL_OUT, onOut );
			if (bar)
				m.addEventListener( MouseEvent.MOUSE_DOWN, onDown );
			else
				m.addEventListener( MouseEvent.CLICK, onClick );
			m.addEventListener( MouseEvent.MOUSE_UP, onUp );
			return m;
		}
		private function contentMove():void
		{
			pane.y = Engine.calc( s_bar.y-(s_up.height-1) );
		}
/**			EVENTS			***/		
		private function onOver(ev:Event):void
		{
			(ev.currentTarget as MovieClip).gotoAndStop(OVER);
		}
		private function onOut(ev:Event):void
		{
			(ev.currentTarget as MovieClip).gotoAndStop(NORMAL);
		}
		private function onDown(ev:Event):void
		{
			var m:MovieClip = (ev.currentTarget as MovieClip);
			m.gotoAndStop(DOWN);
			m.startDrag(false, vRail);
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageUp );
		}
		private function onClick(ev:Event):void
		{
			var m:MovieClip = (ev.currentTarget as MovieClip);
			m.gotoAndStop(DOWN);
			
			switch(m) {
				case s_up:
					Engine.movedown( s_bar.y-(s_up.height-1), s_bar );
					break;
				case s_down:
					Engine.moveup( s_bar.y-(s_up.height-1), s_bar );
					break;
				case s_bg:
					Engine.jump( s_bar.y < mouseY, s_bar );
					break;
			}
			contentMove();
		}
		private function onUp(ev:Event):void
		{
			var m:MovieClip = (ev.currentTarget as MovieClip);
			m.gotoAndStop(OVER);
			if (m == s_bar) {
				m.stopDrag();
				contentMove();
				stage.removeEventListener( MouseEvent.MOUSE_UP, onStageUp );
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMove );
			}
		}
		private function onWheel(ev:MouseEvent):void
		{
			if (active) {
				if( ev.delta < 0)
					Engine.moveup( s_bar.y-(s_up.height-1), s_bar );
				else
					Engine.movedown( s_bar.y-(s_up.height-1), s_bar );
				contentMove();
			}
		}
		private function onStageUp(ev:MouseEvent):void
		{
			s_bar.gotoAndStop(NORMAL);
			s_bar.stopDrag();
			
			contentMove();
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMove );
		}
		private function onStageMove(ev:MouseEvent):void
		{
			contentMove();
		}
	}
}
import flash.display.DisplayObject;

class Engine
{
	public static var itemHeight:int;		// высота одной строки
	public static var scrlMax:int;			// величина скроллинга
	public static var barMinPos:int;		// минимальное положение бара
	public static var contentVisibleHeight:int;	// величина видимой части контента
	public static var contentMax:int;			// величина контента
	
	/**scrlCurrent: значение скроллинга */
	public static function calc( scrlCurrent:Number ):int
	{
		var c:Number = ((contentMax+itemHeight*2)-contentVisibleHeight)/scrlMax;
		return int(( -(scrlCurrent*c) )/itemHeight)*itemHeight;
	}
	public static function moveup(scrlCurrent:Number, bar:DisplayObject ):void
	{
		/***/
		var c:Number = itemHeight/((contentMax+itemHeight*2)-contentVisibleHeight);
		var step:Number = c*scrlMax;
		if ( scrlCurrent + step <= scrlMax ) {
			bar.y += step;
			if (scrlCurrent + step*2 > scrlMax)
				bar.y = barMinPos + scrlMax;
		}
	}
	public static function movedown(scrlCurrent:Number, bar:DisplayObject ):void
	{
		var c:Number = itemHeight/((contentMax+itemHeight*2)-contentVisibleHeight);
		var step:Number = c*scrlMax; 
		if ( scrlCurrent - step >= 0 ) {
			bar.y -= step;
			if( scrlCurrent - step*2 < 0 ) {
				bar.y = barMinPos;
			}
		}
	}
	private static function jumpup(bar:DisplayObject ):void
	{
		if( bar.y/2 < barMinPos )
			bar.y = barMinPos;
		else
			bar.y /= 2;
	}
	private static function jumpdown(bar:DisplayObject ):void
	{
		if( bar.y + (scrlMax+barMinPos - bar.y)/2 > scrlMax+barMinPos )
			bar.y = scrlMax+barMinPos;
		else
			bar.y += (scrlMax+barMinPos - bar.y)/2;
		
		//дописать нажатие на bg и надо евенты добавить еще на них
	}
	public static function jump(clickedUnderBar:Boolean, bar:DisplayObject):void
	{
		if (clickedUnderBar)
			jumpdown(bar);
		else
			jumpup(bar);
	}
	public static function jumpTo(n:int, bar:DisplayObject):void
	{
		var c:Number = itemHeight/((contentMax+itemHeight*2)-contentVisibleHeight);
		var step:Number = c*scrlMax;
		bar.y = barMinPos + step*(n+2) - 1;
		if (bar.y > scrlMax+barMinPos)
			bar.y = scrlMax+barMinPos;
		if (bar.y < barMinPos)
			bar.y = barMinPos;
	}
}