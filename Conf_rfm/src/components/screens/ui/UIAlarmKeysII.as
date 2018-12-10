package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.gui.Header;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.abstract.UIRfDevicesLr;
	import components.static.CMD;
	
	public class UIAlarmKeysII extends UIRfDevicesLr
	{
		public function UIAlarmKeysII()
		{
			super();
			
			addButton( ADD, loc("rf_add_trinket"));
			addButton( REMOVE, loc("rf_remove_trinket"));
			
			listCmd = CMD.LR_DEVICE_LIST_RF_SYSTEM;
			addValue = 5;
			
			manager.titles = {"add":loc("rctrl_adding"),"notfound":loc("rf_trinket_notfound"),
				"exist":loc("rf_trinket_alreadyexist"),"deleted":loc("rf_trinket_deleted"),"cancelled":loc("rfd_add_cancel")};
			
			starterCMD = CMD.LR_DEVICE_LIST_RF_SYSTEM;
		}
		override protected function listUpdate():void
		{
			RequestAssembler.getInstance().fireEvent(new Request(CMD.LR_RF_STATE,put));
		}
		override protected function getHeader():Header
		{
			const widthNN:int = 80;
			const margin:int = 20;
			const widthAdrr:int = 120;
			const widthType:int = 250;
			
			return  new Header
				(
					[
						{ label: loc("rf_sen_h_num"), align: Header.ALIGN_CENTER, xpos:0, width:widthNN },
						{ label: loc("navi_adress"), align: Header.ALIGN_CENTER, xpos:widthNN + margin, width:widthAdrr },
						{ label: loc("rf_sen_h_type"), align: Header.ALIGN_CENTER, xpos:widthNN + margin +  widthAdrr + margin, width:widthType }
					]
				);
		}
	}
}