package components.gui.visual
{
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.protocol.SocketProcessor;
	import components.static.GuiLib;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	public class OnlineStatus extends UIComponent
	{
		private var picOnline:Bitmap;
		private var picOffline:Bitmap;
		
		public function OnlineStatus()
		{
			super();
			
			this.width = 25;
			this.height = 25;

			picOnline = new GuiLib.cOnline;
			addChild( picOnline );
			picOnline.visible = false;
			
			picOffline = new GuiLib.cOffline;
			addChild( picOffline );
			
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, changeOnline );
			
			this.addEventListener( MouseEvent.CLICK, disconnect );
		}
		private function changeOnline( ev:SystemEvents ):void {
			picOnline.visible = ev.isConneted();
			picOffline.visible = !ev.isConneted();
		}
		private function disconnect(ev:MouseEvent):void
		{
			if ( SocketProcessor.getInstance().connected )
				SocketProcessor.getInstance().disconnectFinal();
			else
				SocketProcessor.getInstance().reConnect();
		}
	}
}