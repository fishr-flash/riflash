package components.abstract
{
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;

	public class Warning
	{
		public function Warning() {}
		
		public static const TYPE_ERROR:int=0x00;
		public static const TYPE_SUCCESS:int=0x01;

		public static const STATUS_CONNECTION:int=0x00;
		public static const STATUS_DEVICE:int=0x01;
		public static const STATUS_DEVICE_WRITING:int=0x02;
		
		public static function show( _text:String, _type:int, _status:int ):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( 
				SystemEvents.onStatusBarChanged, {getText:_text, getType:_type, getStatus:_status} );
		}
	}
}