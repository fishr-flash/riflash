package components.gui.limits
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.events.AccEvents;
	import components.gui.limits.LimitGuideLineH;
	import components.interfaces.IFocusable;
	
	public class LimitGuideLineHU extends LimitGuideLineH implements IFocusable
	{
		public var getFunction:Function;
		
		public function LimitGuideLineHU(_w:int, c:int)
		{
			super(_w, c);
			value.width = 80;
			
			this.addEventListener( FocusEvent.FOCUS_IN, focusIn );
			this.addEventListener( FocusEvent.FOCUS_OUT, focusOut );
		}
		override public function updateCoords(ev:Event=null):void
		{
			var result:Number = getFunction( this.y )/100;
			this.text = result +" "+loc("measure_volt_1l");
			this.dispatchEvent( new AccEvents( AccEvents.onSharedGuideLineMove, this.y));
		}
		
		override public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void		
		{
			this.dispatchEvent( new Event( Event.SELECT));
			trace("LIMIT "+key);
		}
		override public function getFocusField():InteractiveObject
		{
			return this;
		}
		override public function getFocusables():Object
		{
			return this;
		}
		override public function getType():int
		{
			return TabOperator.TYPE_NORMAL;
		}
		override public function isPartOf(io:InteractiveObject):Boolean
		{
			return io == this;
		}
		private function focusIn(e:Event):void
		{
			this.select = true;
		}
		private function focusOut(e:Event):void
		{
			this.select = false;
		}
		override public function focusSelect():void		{		}
		//protected var _focusgroup:Number = 0;
		//protected var _focusorder:Number = NaN;
		override public function set focusgroup(value:Number):void
		{
			_focusgroup = value;
		}
		override public function set focusorder(value:Number):void
		{
			if ( isNaN(_focusorder) )
				_focusorder = value;
		}
		override public function get focusorder():Number
		{
			return _focusorder + _focusgroup;
		}
		//protected var _focusable:Boolean=true;
		override public function set focusable(value:Boolean):void
		{
			_focusable = value;
		}
		override public function get focusable():Boolean
		{
			return _focusable;
		}
	}
}