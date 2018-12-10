package components.events
{
	import flash.events.Event;
	
	public class RFSensorEvents extends Event
	{
		public static const REQUEST:String = "REQUEST";
		private var serviceObject:Object;
		
		public function RFSensorEvents(stype:int, ftype:int, struct:int )
		{
			serviceObject = {"stype":stype, "ftype":ftype, "struct":struct};
			super( REQUEST );
		}
		public function getStructure():int
		{
			return int(serviceObject["struct"]);
		}
		public function getFunctType():int
		{
			return int(serviceObject["ftype"]);
		}
		public function getSensorType():int
		{
			return int(serviceObject["stype"]);
		}
	}
}