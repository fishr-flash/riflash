package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.CmdBot;
	import components.abstract.DEVICESB;
	import components.abstract.offline.DataEngine;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.screens.page.FirmWareSimpleLoader;
	import components.screens.page.OfflineDataLoader;
	import components.screens.page.PhoneRequester;
	import components.static.MISC;
	import components.static.PAGE;
	
	public class UIServiceHybrid extends UI_BaseComponent
	{
		private var prequester:PhoneRequester;
		private var dataLoader:OfflineDataLoader;
		
		private var fwloader:FirmWareSimpleLoader;
		private var fwloaderb:FirmWareSimpleLoader;
		
		public function UIServiceHybrid()
		{
			super();
			
			dataLoader =  new OfflineDataLoader(new CmdBot, new DataEngine);
			addChild( dataLoader );
			dataLoader.x = globalX;
			dataLoader.addEventListener( OfflineDataLoader.LOADER_EVOKE_HIDE, onHide );
			dataLoader.addEventListener( OfflineDataLoader.LOADER_EVOKE_SHOW, onShow );
			dataLoader.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			dataLoader.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			dataLoader.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			
			if (MISC.COPY_DEBUG) {
				fwloader = new FirmWareSimpleLoader;
				addChild( fwloader );
				fwloader.x = globalX;
				if (SERVER.DUAL_DEVICE) {
					fwloaderb = new FirmWareSimpleLoader;
					addChild( fwloaderb );
					fwloaderb.x = globalX;
					fwloaderb.ADDRESS = SERVER.ADDRESS_BOTTOM;
					fwloaderb.deviceLabel = DEVICESB.fullver + " "+DEVICESB.commit;
				}
			}
			
			prequester = new PhoneRequester;
			addChild( prequester );
			prequester.x = globalX;
			prequester.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			prequester.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			prequester.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			prequester.isLast();
			
		}
		override public function put(p:Package):void
		{
			var a:Array = SERVER.BOTTOM_VER_INFO;
			var v:Array = (a[1][0] as String).split(".");
			loadComplete();
		}
		override public function open():void
		{
			super.open();
			
			//dataLoader.visible = !SERVER.BOTTOM_VERSION_MISMATCH;
			
			dataLoader.init();
			dataLoader.setMenu(MISC.COPY_MENU);
			dataLoader.block(CLIENT.IS_WRITING_FIRMWARE);
			
			prequester.init();
			
			onChangeHeight(null);
			loadComplete();
		}
		override public function close():void
		{
			super.close();
			dataLoader.close();
			RequestAssembler.getInstance().clearStackLater();
		}
		private function onHide(e:Event):void
		{
			prequester.visible = false;
		}
		private function onShow(e:Event):void
		{
			prequester.visible = true;
		}
		private function onChangeHeight(e:Event):void
		{
			dataLoader.y = PAGE.CONTENT_TOP_SHIFT;
			
			var gy:int = dataLoader.y + dataLoader.height;
			if (fwloader) {
				fwloader.y = gy;
				gy += fwloader.height;
				
				if( fwloaderb ) {
					fwloaderb.y = gy;
					gy += fwloader.height;					
				}
			}
			
			prequester.y = gy;
		}
		private function onBlock(e:Event):void
		{
			prequester.block(true);
			blockNaviSilent = true;
			dataLoader.block(true);
		}
		private function onFree(e:Event):void
		{
			prequester.block(false);
			blockNaviSilent = false;
			dataLoader.block(false);
		}
	}
}