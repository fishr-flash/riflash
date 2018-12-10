package components.screens.page
{
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.gui.Balloon;
	import components.gui.PopUp;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	
	public class HistoryRetranslator extends UIComponent implements IServiceFrame
	{
		private var button:TextButton;
		private var sep:Separator;
		private var working:Boolean = false;
		
		public function HistoryRetranslator()
		{
			super();
			
			button = new TextButton;
			addChild( button );
			button.setUp( loc("service_do_history_retranslate"), onClick );
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 38;
		}
		private function onClick():void
		{
			PopUp.getInstance().construct(PopUp.wrapHeader("sys_attention"),
				PopUp.wrapMessage("service_sure_do_history_retranslate"), 
				PopUp.BUTTON_YES | PopUp.BUTTON_NO, [onConfirm] );
			PopUp.getInstance().open();
		}
		private function onConfirm():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.HISTORY_RETRANSMISSION, onResponse, 1, [0xff]));
		}
		public function block(b:Boolean):void
		{
			button.disabled = b || working;
		}
		override public function get height():Number
		{
			return 50;
		}
		
		public function close():void {	}
		public function getLoadSequence():Array
		{
			return null;
		}
		public function init():void	{	}
		public function put(p:Package):void	{	}
		public function isLast():void
		{
			sep.visible = false;
		}
		
		private function onResponse(p:Package):void
		{	// до ухода в оффлайн кнопка должна быть потушена
			working = true;
			button.disabled = true;
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onChangeOnline );
			Balloon.access().show( loc("sys_attention"), loc("service_cmd_processing") );
		}
		private function onChangeOnline(e:SystemEvents):void
		{
			working = false;
			button.disabled = false;
			GUIEventDispatcher.getInstance().removeEventListener( SystemEvents.onChangeOnline, onChangeOnline );
		}
		private function doRestart():void
		{
			SocketProcessor.getInstance().disconnect();
		}
	}
}