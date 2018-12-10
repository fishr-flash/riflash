package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.CmdBot;
	import components.abstract.offline.DataEngine;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.visual.Separator;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.screens.page.DeviceRestarter;
	import components.screens.page.FirmWareAdvLoader;
	import components.screens.page.OfflineDataLoader;
	import components.static.DS;
	import components.static.MISC;
	
	public class UIService extends UI_BaseComponent
	{
		public static const SEPARATOR_WIDTH:int = 370;
		
		protected var firmwareFrame:FirmWareAdvLoader;
		protected var offlineFrame:OfflineDataLoader;
		private var restarter:DeviceRestarter;
		protected var sep:Separator;
		
		public function UIService()
		{
			super();
			
			firmwareFrame = new FirmWareAdvLoader;
			addChild( firmwareFrame );
			firmwareFrame.y = globalY;
			firmwareFrame.x = globalX;
			firmwareFrame.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			firmwareFrame.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			firmwareFrame.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			
			globalY += firmwareFrame.height + 10;

			sep = drawSeparator(SEPARATOR_WIDTH);
			
			createOfflineFrame();
			addChild( offlineFrame );
			offlineFrame.y = globalY;
			offlineFrame.x = globalX;
			offlineFrame.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			offlineFrame.addEventListener( OfflineDataLoader.LOADER_EVOKE_HIDE, onHide );
			offlineFrame.addEventListener( OfflineDataLoader.LOADER_EVOKE_SHOW, onShow );
			offlineFrame.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			offlineFrame.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			globalY = 350;
			
			restarter = new DeviceRestarter;
			if ( DS.isDevice(DS.V2) ) {
				globalY = 258;
				addChild( restarter );
				restarter.y = globalY;
				restarter.x = globalX;
				restarter.addEventListener( OfflineDataLoader.LOADER_EVOKE_HIDE, onHide );
				restarter.addEventListener( OfflineDataLoader.LOADER_EVOKE_SHOW, onShow );
				restarter.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
				restarter.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			//	globalY = 362;
			}
			//height = 200;
			starterCMD = firmwareFrame.getLoadSequence();
		}
		
		/***********************************/
		override public function open():void
		{
			//CLIENT.NO_DELAY_PROGRESSION = true;
			SocketProcessor.getInstance().progressiveRequest = false;
			
			super.open();
			
			firmwareFrame.init();
			offlineFrame.setMenu(MISC.COPY_MENU);
			offlineFrame.block(CLIENT.IS_WRITING_FIRMWARE);
			restarter.block(CLIENT.IS_WRITING_FIRMWARE);
			
			onChangeHeight(null);
			
			offlineFrame.visible = !MISC.VERSION_MISMATCH;
			restarter.visible = !MISC.VERSION_MISMATCH;
			sep.visible = !MISC.VERSION_MISMATCH;
			
			if (!starterCMD)
				loadComplete();
		}
		override public function put(p:Package):void 
		{
			firmwareFrame.put(p);
			loadComplete();
		}
		override public function close():void
		{
			super.close();
			offlineFrame.close();
			RequestAssembler.getInstance().clearStackLater();
			
			//CLIENT.NO_DELAY_PROGRESSION = false;
			SocketProcessor.getInstance().progressiveRequest = true;
		}
		private function onHide(e:Event):void
		{
			firmwareFrame.visible = false;
			sep.visible = false;
			restarter.visible = false;
		}
		protected function onShow(e:Event):void
		{
			firmwareFrame.visible = true;
			sep.visible = !MISC.VERSION_MISMATCH;
			restarter.visible = true;
		}
		protected function onChangeHeight(e:Event):void
		{
			var firmh:int = firmwareFrame.height;
			sep.y = firmh;
			offlineFrame.y = firmh + 20;
			restarter.y = offlineFrame.y + offlineFrame.height;
		}
		private function onBlock(e:Event):void
		{
			if (e.currentTarget is OfflineDataLoader ) {
				firmwareFrame.block(true);
				blockNaviSilent = true;
			} else
				offlineFrame.block(true);
			restarter.block(true);
		}
		private function onFree(e:Event):void
		{
			if (e.currentTarget is OfflineDataLoader ) {
				firmwareFrame.block(false);
				blockNaviSilent = false;
				RequestAssembler.getInstance().clearStackLater();
			} else {
				offlineFrame.block(false);
				if (!SocketProcessor.getInstance().connected)
					firmwareFrame.resetAndDisable();
			}
			restarter.block(false);
		}
		
		protected function createOfflineFrame():void
		{
			offlineFrame = new OfflineDataLoader(new CmdBot, new DataEngine);
		}
	}
}