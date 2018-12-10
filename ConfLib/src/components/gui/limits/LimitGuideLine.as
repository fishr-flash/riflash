package components.gui.limits
{
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import components.abstract.servants.TabOperator;
	import components.interfaces.IFocusable;
	
	public class LimitGuideLine extends Sprite implements IFocusable
	{
		public const EVENT_UNSELECT:String = "UNSELECT";
		
		public var rect:Rectangle;
		public var lowLimit:LimitGuideLineH;
		public var hiLimit:LimitGuideLineH;
		public var limit:int;
		
		protected var triangle:Sprite;
		protected var ring:Shape;
		protected var _color:uint;
		protected var _selected:Boolean=false;
		
		public function LimitGuideLine()
		{
			this.addEventListener( FocusEvent.FOCUS_IN, focusIn );
			this.addEventListener( FocusEvent.FOCUS_OUT, focusOut );
		}
		
		public function set text(s:String):void	{}
		public function set dragging(b:Boolean):void {}
		
		public function set color(c:uint):void 
		{
			_color = c;
		}
		public function get color():uint 
		{
			return _color;
		}
		public function updateCoords(ev:Event=null):void	{}
		protected function mOver(ev:MouseEvent):void
		{
			if(ring)
				ring.visible = true;
		}
		protected function mOut(ev:MouseEvent):void
		{
			if(ring && !_selected)
				ring.visible = false;
		}
		public function set select(b:Boolean):void
		{
			_selected = b;
			if(ring)
				ring.visible = b;
		}
		
		private function focusIn(e:Event):void
		{
			this.select = true;
		}
		private function focusOut(e:Event):void
		{
			this.select = false;
			this.dispatchEvent( new Event( EVENT_UNSELECT ));
		}
		
		
		public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void		
		{
			this.dispatchEvent( new Event( Event.SELECT));
		//	trace("LIMIT "+key);
		}
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
			return TabOperator.TYPE_NORMAL;
		}
		public function isPartOf(io:InteractiveObject):Boolean
		{
			return io == this;
		}
		public function focusSelect():void		{		}
		protected var _focusgroup:Number = 0;
		protected var _focusorder:Number = NaN;
		public function set focusgroup(value:Number):void
		{
			_focusgroup = value;
		}
		public function set focusorder(value:Number):void
		{
			if ( isNaN(_focusorder) )
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