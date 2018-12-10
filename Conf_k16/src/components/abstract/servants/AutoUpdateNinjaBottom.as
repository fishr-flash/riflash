package components.abstract.servants
{
	import mx.utils.URLUtil;
	
	import components.abstract.DEVICESB;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.protocol.statics.SERVER;
	import components.static.NAVI;

	public class AutoUpdateNinjaBottom extends AutoUpdateNinja
	{
		private static var inst:AutoUpdateNinjaBottom;
		public static function access():AutoUpdateNinjaBottom
		{
			if(!inst)
				inst = new AutoUpdateNinjaBottom;
			return inst;
		}
		
		override public function getList():void
		{
			GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.MAINMENU_APPEARANCE, 
				{getButtonId:getButtonId(), getButtonStatus:0} ));

			connecterror = false;
			
			adr = URLUtil.getServerName(SERVER.UPDATE_SERVER_ADR);
			port = URLUtil.getPort(SERVER.UPDATE_SERVER_ADR);
			if (port == 0)
				port = 80;
			
			// создание GrabNinja для выкачивания ртмки нижней платы
			init();
			// запрос device.json у основного апдейтера
			AutoUpdateNinja.access().askDevice(onDevice);
		}
		override public function askTableList(f:Function):void
		{
			if (connecterror)
				f(null);
			else if (fb) {
				f(fb.getTableList());
			} else
				fwDelegate = f;
		}
		private function onDevice(d:Object):void
		{
			/*var keyword:String 
			if (int(DEVICESB.bootloader)>0)
				keyword = DEVICESB.fullver+"."+DEVICESB.bootloader;
			else
				keyword = DEVICESB.fullver;*/
			
			
			var keyword:String = DEVICESB.fullver+"."+DEVICESB.bootloader;
			
			createBot(keyword, DEVICESB.app, DEVICESB.alias);
			
			var isupdate:Boolean = fb.isUpdate(d);
			
			if (isupdate) {
				GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.MAINMENU_APPEARANCE, 
					{getButtonId:getButtonId(), getButtonStatus:1} ));
			} 
			if (fwDelegate is Function)
				fwDelegate(fb.getTableList());
			fwDelegate = null;
		}
		override protected function getButtonId():int
		{
			return NAVI.UPDATE_SECOND;
		}
	}
}