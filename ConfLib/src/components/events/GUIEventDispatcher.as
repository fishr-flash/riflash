package components.events
{
	import flash.events.EventDispatcher;
	
	public class GUIEventDispatcher extends EventDispatcher
	{
		private static var instance:GUIEventDispatcher;

		public static function getInstance():GUIEventDispatcher 
		{
			if ( instance == null )
				instance = new GUIEventDispatcher( new Initiator );
			return instance;
		}
		public function GUIEventDispatcher(initiator:Initiator)
		{
			super();
		}
		public function fireEvent( _cls:Class, _type:String, obj:Object=null ):void 
		{
			dispatchEvent( new _cls( _type, obj ));
		}
		public function fireSystemEvent(_type:String, obj:Object=null ):void 
		{
			dispatchEvent( new SystemEvents( _type, obj ));
		}
	}
}
class Initiator {public function Initiator()}