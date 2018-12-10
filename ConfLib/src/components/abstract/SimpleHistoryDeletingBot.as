package components.abstract
{
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.gui.visual.ScreenBlock;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class SimpleHistoryDeletingBot
	{
		private var timer:Timer;
		private var complete:Function;
		
		public function SimpleHistoryDeletingBot(_complete:Function=null)
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, init, 1 ,[HistoryDeletingBot.HIS_DELETE] ));
			complete = _complete;
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
		}
		private function init(p:Package):void
		{
			if (p.success ) {
				var popup:PopUp = PopUp.getInstance();
				popup.construct( PopUp.wrapHeader("his_wait_for_delete"),PopUp.wrapMessage("his_sometime_deleting") );
				popup.open();
				
				timer = new Timer( 3000, 1 );
				timer.addEventListener( TimerEvent.TIMER_COMPLETE, onComplete );
				timer.reset();
				timer.start();
			}
		}
		private function onComplete(ev:TimerEvent):void
		{
			timer.removeEventListener( TimerEvent.TIMER_COMPLETE, onComplete );
			PopUp.getInstance().close();
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			if (complete is Function)
				complete();
		}
	}
}