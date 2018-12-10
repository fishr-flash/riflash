package components.screens.ui
{
	import components.events.GUIEvents;
	import components.interfaces.IServiceFrame;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.screens.page.FirmWareAutoLoader;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIUpdate extends UIServiceAdv
	{
		private var autoloader:FirmWareAutoLoader;
		
		public function UIUpdate()
		{
			super();
		}
		override public function open():void
		{
			super.open();
			
		//	if (DEVICES.isDevice(DEVICES.C15)
			SERVER.ADDRESS_BOTTOM = FirmWareWatchDogLoader.WATCHDOG_ADDRESS; 
			
			if (!DS.isDevice(DS.C15) && !DS.isDevice(DS.R15) &&  !DS.isDevice(DS.R15IP)) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO, autoloader.put,0,null,0,0,SERVER.ADDRESS_BOTTOM));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_BUF_SIZE, autoloader.put,0,null,0,0,SERVER.ADDRESS_BOTTOM));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_MAX_IND_CMDS, autoloader.put,0,null,0,0,SERVER.ADDRESS_BOTTOM));
			}
		}
		override protected function getModuls():Array 
		{
			if (DS.isDevice(DS.C15) || DS.isDevice(DS.R15)  || DS.isDevice(DS.R15IP))
				return [addAutoFirmware];
			return [addAutoFirmware,addFirmware];
		}
		
		private function addAutoFirmware():IServiceFrame
		{
			var target:FirmWareAutoLoader = new FirmWareAutoLoader();
			addChild( target );
			target.x = globalX;
			target.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			autoloader = target;
			return target;
		}
		override protected function addFirmware():IServiceFrame
		{
			var target:FirmWareWatchDogLoader = new FirmWareWatchDogLoader;
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
	}
}
import components.abstract.functions.loc;
import components.gui.SimpleTextField;
import components.screens.page.FirmWareSimpleLoader;

class FirmWareWatchDogLoader extends FirmWareSimpleLoader
{
	public static const WATCHDOG_ADDRESS:int = 0xfc;
	
	public function FirmWareWatchDogLoader()
	{
		super();
		
		var t:SimpleTextField = new SimpleTextField(loc("update_watchdog"), 600 );
		addChild( t );
		t.height = 20;
		
		group.movey("1",33);
		
		ADDRESS = WATCHDOG_ADDRESS;
	}
	override protected function getLabel(key:int):String
	{
		switch(key) {
			case LABEL_LOAD_FROM_FILE:
				return loc("update_load_from_file");
			case LABEL_DO_UPDATE:
				return loc("update_ver");
			case LABEL_UPDATE_COMPLETE:
				return loc("update_complete");
			case LABEL_DO_UPDATE:
				return loc("update_fail");
			case LABEL_CANCEL_UPLOAD:
				return loc("service_cancel_load_update");
		}
		return "-"
	}
	override protected function createTitle(label:String):void
	{
	}
}