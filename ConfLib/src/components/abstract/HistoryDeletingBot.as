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

	public final class HistoryDeletingBot
	{
		public static const HIS_DELETE:int = 0x01;
		public static const HIS_DELETE_SUCCESS:int = 0x02;
		
		public static const HISTORY:int = 0x01;
		public static const SELECT_PAR:int = 0x02;
		private static const DONT_CHANGE:int = 0x03;
		public static const LINKCHANNELS:int = 0x04;
		
		private var timer:Timer;
		private var timerIncomplete:Timer;
		private var complete:Function;
		private var incomplete:Function;
		private var context:int;
		
		public function HistoryDeletingBot( requestDelay:int, incompleteDelay:int, _complete:Function, _context:int)
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, init, 1, [HIS_DELETE] ));
			timer = new Timer(requestDelay,1);
			timerIncomplete = new Timer( incompleteDelay, 1);
			complete = _complete;
			context = _context;
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
		}
		private function init(p:Package):void
		{
			if (p.success) {
				
				var popup:PopUp = PopUp.getInstance();
				popup.construct( PopUp.wrapHeader("his_wait_for_delete"),PopUp.wrapMessage("his_sometime_deleting") );
				popup.open();
				
				GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onChangeOnline );
				
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer );
				timer.reset();
				timer.start();
				timerIncomplete.addEventListener( TimerEvent.TIMER_COMPLETE, onIncomplete );
				timerIncomplete.reset();
				timerIncomplete.start();
			} else {
				incomplete();
				terminate();
			}
		}
		private function onChangeOnline(e:SystemEvents):void
		{
			if (!e.isConneted()) {
				context = DONT_CHANGE;
				terminate();
			}
		}
		private function onTimer(e:TimerEvent):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, onHistory ));
		}
		private function onHistory(p:Package):void
		{
			if (p.getStructure()[0] == HIS_DELETE_SUCCESS ) {
				
				PopUp.getInstance().close();
				
				if( complete is Function )
					complete();
				terminate();
			} else {
				timer.reset();
				timer.start();
			}
		}
		private function onIncomplete(e:TimerEvent):void
		{
			var popup:PopUp = PopUp.getInstance();
			popup.construct( PopUp.wrapHeader("sys_error"), PopUp.wrapMessage("his_not_deleted"), PopUp.BUTTON_OK, [popup.close] );
			popup.open();
			
			terminate();
		}
		private function terminate():void
		{
			switch(context) {
				case HISTORY:
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
					break;
				case SELECT_PAR:
				case DONT_CHANGE:
					break;
				default:
					GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
					break;
			}
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimer );
			timerIncomplete.stop();
			timerIncomplete.removeEventListener( TimerEvent.TIMER_COMPLETE, onIncomplete );
		}
	}
}