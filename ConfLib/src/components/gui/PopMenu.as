package components.gui
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import mx.core.UIComponent;
	
	import components.gui.triggers.TextButtonAdv;
	import components.static.COLOR;
	
	public class PopMenu extends UIComponent
	{
		private static var inst:PopMenu;
		public static function access():PopMenu
		{
			if(!inst)
				inst = new PopMenu;
			return inst;
		}
		
		private var bg:Shape;
		private var buttons:Vector.<TextButtonAdv>;
		
		public function PopMenu()
		{
			super();
			
			bg = new Shape;
			addChild( bg );
			visible = false;
			this.addEventListener(MouseEvent.ROLL_OUT,close);
			this.addEventListener(MouseEvent.CLICK,close);
		}
		public function open(a:Array):void
		{
			if (a && a.length > 0) {
				var len:int = a.length;
				clear();
				var w:int, currentw:int;
				var _y:int;
				
				
				for (var i:int=0; i<len; i++) {
					if (a[i] is TextButtonAdv) {
						addChild( a[i] );
						a[i].y = _y;
						_y += 25;
						buttons.push( a[i] );
						
						currentw = (a[i] as TextButtonAdv).getWidth();
						if (w < currentw)
							w = currentw;
					}
				}
			
				draw(25*buttons.length,w);
				visible = true;
			}
		}
		private function close(e:Event):void
		{
			visible = false;
		}
		private function draw(h:int, w:int):void
		{
			bg.graphics.clear();
			bg.graphics.beginFill( COLOR.NAVI_MENU_LIGHT_BLUE_BG );
			bg.graphics.drawRoundRect(-5,0, w, h, 5,5);
			bg.filters = [new DropShadowFilter(0,0,COLOR.BLACK,1,2,2,1,1,false)];
			
			//bg.y = -h;
			
			width = w;
			height = h+17;
			
			this.x = parent.mouseX-10;
			this.y = parent.mouseY-5;
		}
		private function clear():void
		{
			if (buttons) {
				var len:int = buttons.length;
				for (var i:int=0; i<len; i++) {
					removeChild( buttons[i] );
				}
			}
			buttons = new Vector.<TextButtonAdv>; 
		}
	}
}