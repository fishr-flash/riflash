package components.abstract.servants
{
	import components.gui.PopUp;
	import components.protocol.SocketProcessor;
	
	import flash.events.Event;

	public class OnlineObserver
	{	// Робот следит за онлайном и в случае дисконнекта,выводит мессадж
		public function OnlineObserver()
		{
			SocketProcessor.getInstance().addEventListener(Event.CLOSE, closeHandler);
		}
		private function closeHandler(e:Event):void
		{
			PopUp.getInstance().construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("sys_final_disconnect") );
			PopUp.getInstance().open();
			SocketProcessor.getInstance().removeEventListener(Event.CLOSE, closeHandler);
		}
	}
}