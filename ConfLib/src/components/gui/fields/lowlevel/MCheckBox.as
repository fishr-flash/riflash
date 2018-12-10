package components.gui.fields.lowlevel
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import components.static.GuiLib;
	
	public class MCheckBox extends Sprite
	{
		protected var layer:MovieClip;
		
		protected const NORMAL:int = 1;
		protected const OVER:int = 3;
		protected const DOWN:int = 5;
		
		public static const ICON_WIDTH:int=15;
		
		protected var _selected:Boolean;
		protected var _over:Boolean;
		protected var _enabled:Boolean=true;
		
		private var processMouseClick:Boolean;
		
		public function MCheckBox(processMouseClick:Boolean=true)
		{
			super();
			this.processMouseClick = processMouseClick; 
			construct();
		}
		protected function construct():void
		{
			layer = new GuiLib.m_checkbox;
			addChild( layer );
			layer.gotoAndStop(1);
			layer.check.visible = _selected;
			
			enabled =_enabled;
		}
		public function set selected(b:Boolean):void
		{
			_selected = b;
			layer.check.visible = b;
		}
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set enabled(b:Boolean):void
		{
			_enabled = b;
			if (b) {
				layer.alpha = 1;
				if (processMouseClick)
					this.addEventListener(MouseEvent.CLICK, mClick);
				this.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
				this.addEventListener(MouseEvent.MOUSE_UP, mUp );
				this.addEventListener(MouseEvent.ROLL_OVER, mOver);
				this.addEventListener(MouseEvent.ROLL_OUT, mOut );
				
			} else {
				layer.alpha = 0.5;
				this.removeEventListener(MouseEvent.CLICK, mClick);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
				this.removeEventListener(MouseEvent.MOUSE_UP, mUp );
				this.removeEventListener(MouseEvent.ROLL_OVER, mOver);
				this.removeEventListener(MouseEvent.ROLL_OUT, mOut );
				
			}
			
			this.tabEnabled = this.mouseEnabled = _enabled;
		}
		public function get enabled():Boolean
		{
			return _enabled;
		}
/** EVENTS			*/
		private function mDown(ev:MouseEvent):void
		{
			layer.gotoAndStop( DOWN );
		}
		protected function mClick(ev:MouseEvent):void
		{
			selected = !selected;
		}
		private function mUp(ev:MouseEvent):void
		{
			if (_over)
				layer.gotoAndStop( OVER );
			else
				layer.gotoAndStop( NORMAL );
		}
		private function mOver(ev:MouseEvent):void
		{
			_over = true;
			layer.gotoAndStop( OVER );
		}
		private function mOut(ev:MouseEvent):void
		{
			_over = false;
			layer.gotoAndStop( NORMAL );
		}
	}
}