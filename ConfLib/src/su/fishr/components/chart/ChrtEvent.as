package su.fishr.components.chart 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author fishr
	 */
	public class ChrtEvent extends Event 
	{
		static public const SELECT_SERIES:String = "selectSeries";
		static public const OVER_PUNCT:String = "overPunct";
		public var data:Object;
		
		public function ChrtEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, datas:Object = null) 
		{ 
			
			super(type, bubbles, cancelable );
			data = datas;
		} 
		
		public override function clone():Event 
		{ 
			return new ChrtEvent(type, bubbles, cancelable, data);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ChartEvent", "type", "bubbles", "cancelable", "data", "eventPhase"); 
		}
		
	}
	
}