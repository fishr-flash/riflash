package components.screens.page
{
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	
	public class DeviceRestarter extends UIComponent implements IServiceFrame
	{
		private var button:TextButton;
		private var sep:Separator;
		private var diconnectFinal:Boolean;
		
		public function DeviceRestarter(final:Boolean=false)
		{
			super();
			
			diconnectFinal = final;
			
			button = new TextButton;
			addChild( button );
			button.setUp( loc("ui_service_do_device_restart"), onClick );
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 38;
		}
		private function onClick():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.REBOOT, onResponse, 1, [1]));
		}
		public function block(b:Boolean):void
		{
			button.disabled = b;
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
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			TaskManager.callLater( doRestart, 5000 );
		}
		private function doRestart():void
		{
			if (diconnectFinal) {
				PopUp.getInstance().composeOfflineMessage( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("sys_k5_final_disconnect") );
				SocketProcessor.getInstance().disconnectFinal();
			} else
				SocketProcessor.getInstance().disconnect();
		}
	}
}