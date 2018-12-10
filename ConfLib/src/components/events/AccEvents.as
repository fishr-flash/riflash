package components.events
{
	import flash.events.Event;
	
	public class AccEvents extends Event
	{
		public static const onSharedGuideLineMove:String = "onSharedGuideLineMove";		// Когда меняется местоположение LimitGuide
		public static const onTimelineMove:String = "onTimelineMove";					// Когда двигают LimitTimeLine
		public static const onExpand:String = "onExpand";								// Когда нажимают подробнее на графике
		public static const onSelectTriangle:String = "onSelectTriangle";				// Когда нажимают на треугольничек на графике (выделен может быть только 1)
		
		public var serviceObject:Object;
		
		public function AccEvents( type:String, eventObject:Object=null, params:Object=null ) 
		{
			switch(type) {
				case "onTimelineMove":
					serviceObject = {getTime:int(eventObject)};
					break;
				case "onExpand":
				case "onSelectTriangle":	
					serviceObject = {getNum:int(eventObject)};
					break;
				default:
					serviceObject = eventObject;
			}
			super( type );
		}
		public function getTime():int			//	onTimelineMove
		{
			return serviceObject["getTime"];
		}
		public function getNum():int			//	onExpand
		{
			return serviceObject["getNum"];
		}
	}
}