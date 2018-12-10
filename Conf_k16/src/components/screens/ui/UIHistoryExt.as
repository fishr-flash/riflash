package components.screens.ui
{
	import components.abstract.DEVICESB;
	import components.abstract.functions.loc;
	import components.abstract.servants.HistorySaverServant;
	import components.gui.Header;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptHistoryLine;
	import components.static.DS;

	public class UIHistoryExt extends UIHistory
	{
		public function UIHistoryExt()
		{
			super();
			
			tAmount.restrict("0-9",5);
			
			if (DEVICESB.release < 7)
				list.width = 996;
			else
				list.width = 1070;
			
			servant = new HistorySaverServant([bXLSpageAll, bTXTpageAll],21,OptHistoryLine.getEmulatedvisualizeBitfield,OptHistoryLine.calcCIDCRC);
		}
		override protected function getClass():Class 
		{
			return OptHistoryLine;
		}
		override protected function getHeader():Header
		{
			if ( passBottomRelease(7) ) {
				return new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
					{label:loc("his_object_num"), align:"center", xpos:195}, {label:loc("his_alarm_code"), align:"center", xpos:230+49-9}, {label:loc("his_event"), xpos:350-4},
					{label:loc("his_partition"), xpos:420+173+13+1},{label:loc("his_zone_user"), align:"center", xpos:480+183},{label:loc("his_direction"), xpos:535+190},
					{label:loc("his_cid"), xpos:650+212+2-20},{label:loc("his_power_supply"), width:150, align:"center", xpos:650+212+2+61} ], {size:11} );
			} else {
				return new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
					{label:loc("his_object_num"), align:"center", xpos:195}, {label:loc("his_alarm_code"), align:"center", xpos:230+49-9}, {label:loc("his_event"), xpos:350-4},
					{label:loc("his_partition"), xpos:420+173+13+1},{label:loc("his_zone_user"), align:"center", xpos:480+183},{label:loc("his_direction"), xpos:535+190},
					{label:loc("his_cid"), xpos:650+212+2} ], {size:11} );
			}
		}
		override protected function getHistoryExportHeader():Array
		{
			if ( passBottomRelease(7) ) {
				return [loc("his_exp_index"),loc("his_exp_date"),loc("his_exp_object"),loc("his_exp_alarm_code"),
					loc("his_exp_event"), loc("his_exp_part"), loc("his_exp_zone_user"), loc("his_exp_direction"),loc("his_exp_cid"),loc("his_power_supply")];
			} else {
				return [loc("his_exp_index"),loc("his_exp_date"),loc("his_exp_object"),loc("his_exp_alarm_code"),
					loc("his_exp_event"), loc("his_exp_part"), loc("his_exp_zone_user"), loc("his_exp_direction"),loc("his_exp_cid")];
			}
		}
		private function passBottomRelease(num:int):Boolean
		{	// проверка нижней платы
			if (SERVER.DUAL_DEVICE) {
				return DEVICESB.release >= num;
			}
			return DS.release >= num;
		}
	}
}