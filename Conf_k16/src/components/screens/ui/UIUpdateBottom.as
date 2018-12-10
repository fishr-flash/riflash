package components.screens.ui
{
	import components.abstract.DEVICESB;
	import components.abstract.functions.loc;
	import components.abstract.servants.AutoUpdateNinjaBottom;
	import components.abstract.servants.FirmwareServant;
	import components.abstract.servants.ResizeWatcher;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.NAVI;

	public class UIUpdateBottom extends UIUpdate
	{
		public function UIUpdateBottom()
		{
			ninja = AutoUpdateNinjaBottom.access();
			super();
			
			
		}
		override public function open():void
		{
			super.open();
			
			ResizeWatcher.addDependent(this);
			
			
			
			
			if( CLIENT.AUTOPAGE_WHILE_WRITING == 0 ) {
				
				bReconnect.visible = false;
				go.show("nofw");
				if (int(DEVICESB.bootloader) == 0)
					getField(0,1).setCellInfo(  loc("sys_device_ver")+": "+ DEVICESB.fullver );
				else
					getField(0,1).setCellInfo( loc("sys_device_ver")+": "+ DEVICESB.fullver + "." + DEVICESB.bootloader );
				bUpload.disabled = false;
				ninja.askTableList(onGetList);
				loadComplete();
			} else {
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
					null );
			}
		}
		override protected function createFirmwareServant():void
		{
			fwservant = new FirmwareServant;
			fwservant.sendAddress = SERVER.ADDRESS_BOTTOM;
		}
		override protected function sertAutopage():void
		{
			
			CLIENT.AUTOPAGE_WHILE_WRITING = NAVI.UPDATE_SECOND;
			
		}
	}
}