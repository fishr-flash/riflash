package components.gui.visual.charsGraphic 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author me
	 */
	public class ChartEvent extends Event 
	{
		static public const DRAG_LINE:String = "dragLine";
		
		private var _data:Object;
		public function get data():Object 
		{
			return _data;
		}
		
		public function ChartEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object = null) 
		{
			_data = data;
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ChartEvent(type, bubbles, cancelable, _data);
		} 
		
		
		
		public override function toString():String 
		{ 
			return formatToString("ChartEvent", "type", "bubbles", "cancelable", "eventPhase", "data"); 
		}
		
	}
	
}