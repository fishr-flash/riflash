package components.basement
{
	public class SourceProtocol
	{
		protected var packetNum:int=0;
		protected var aStack:Array = new Array;
		//protected var isConnected:Boolean;
		
		protected var fRequeue:Function;
		protected var fComplete:Function;
		
		public function SourceProtocol()
		{
		//	GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onlineStatus );
		}
		/*protected function onlineStatus( ev:SystemEvents ):void
		{
			isConnected = ev.isConneted();
		}*/
	}
}