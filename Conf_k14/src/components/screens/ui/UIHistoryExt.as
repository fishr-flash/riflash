package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.HistorySaverServant;
	import components.gui.Header;
	import components.screens.opt.OptHistoryLine;
	import components.static.DS;
	import components.static.MISC;

	public class UIHistoryExt extends UIHistory
	{
		public function UIHistoryExt()
		{
			super();
			
			tAmount.restrict("0-9",4);
			
			if (DS.release >= 9 || MISC.COPY_DEBUG)
				list.width = 1070;
			else
				list.width = 996;
			
			servant = new HistorySaverServant([bXLSpageAll, bTXTpageAll],0,OptHistoryLine.getEmulatedvisualizeBitfield,OptHistoryLine.calcCIDCRC);
		}
		override protected function getClass():Class 
		{
			return OptHistoryLine;
		}
		override protected function getHeader():Header
		{
			if ( (DS.release >= 9 && int(DS.app) != 4) || MISC.COPY_DEBUG) {
				return new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
					{label:loc("his_object_num"), align:"center", xpos:195}, {label:loc("his_alarm_code"), align:"center", xpos:230+49-9}, {label:loc("his_event"), xpos:350-4},
					{label:loc("his_partition"), xpos:420+173+13+1},{label:loc("his_zone_user"), align:"center", xpos:480+183},{label:loc("his_power_supply"), xpos:525+200},
					{label:loc("his_direction"), xpos:535+210+90}, {label:loc("his_cid"), xpos:660+212+2+90} ], {size:11} );
			}
			return new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
				{label:loc("his_object_num"), align:"center", xpos:195}, {label:loc("his_alarm_code"), align:"center", xpos:230+49-9}, {label:loc("his_event"), xpos:350-4},
				{label:loc("his_partition"), xpos:420+173+13+1},{label:loc("his_zone_user"), align:"center", xpos:480+183},	{label:loc("his_direction"), xpos:535+190},
				{label:loc("his_cid"), xpos:650+212+2} ], {size:11} );
						
		}
		override protected function getHistoryExportHeader():Array
		{
			if ( ( DS.release >= 9 && int(DS.app) != 4 ) || MISC.COPY_DEBUG) {
				return [loc("his_exp_index"),loc("his_exp_date"),loc("his_exp_object"),loc("his_exp_alarm_code"),
					loc("his_exp_event"), loc("his_exp_part"), loc("his_exp_zone_user"), loc("his_power_supply"), loc("his_exp_direction"),loc("his_exp_cid")];
			}
			return [loc("his_exp_index"),loc("his_exp_date"),loc("his_exp_object"),loc("his_exp_alarm_code"),
				loc("his_exp_event"), loc("his_exp_part"), loc("his_exp_zone_user"), loc("his_exp_direction"),loc("his_exp_cid")];
		}
	}
}