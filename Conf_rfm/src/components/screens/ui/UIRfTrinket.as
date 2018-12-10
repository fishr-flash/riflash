package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.gui.Header;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.abstract.UIRfDevices;
	import components.static.CMD;
	
	public class UIRfTrinket extends UIRfDevices
	{
		public function UIRfTrinket()
		{
			super();
			
			addButton( ADD, loc("rf_add_trinket"));
			addButton( REMOVE, loc("rf_remove_trinket"));
			
			listCmd = CMD.RF_RCTRL;
			addValue = 5;
			
			manager.titles = {"add":loc("rctrl_adding"),"notfound":loc("rf_trinket_notfound"),
				"exist":loc("rf_trinket_alreadyexist"),"deleted":loc("rf_trinket_deleted"),"cancelled":loc("rfd_add_cancel")};
			
			starterCMD = CMD.RF_RCTRL;
		}
		override protected function listUpdate():void
		{
			RequestAssembler.getInstance().fireEvent(new Request(CMD.RF_RCTRL,put));
		}
		override protected function getHeader():Header
		{
			return new Header( [{label:loc("his_exp_index"),xpos:10, width:100, align:"center"},
				{label:loc("out_title"), xpos:globalX + 95, width:100} ], {size:11, border:false, align:"left"} );
		}
	}
}