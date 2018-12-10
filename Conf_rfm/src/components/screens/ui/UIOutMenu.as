package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.interfaces.IBaseComponent;
	import components.screens.opt.OptOut;
	import components.screens.ui.abstract.UIDeviceOutput;
	import components.static.CMD;
	import components.static.DS;
	
	public final class UIOutMenu extends UIDeviceOutput
	{
		private var titles:Array;
		private var names:Array;
		
		public function UIOutMenu()
		{
			if (DS.isDevice(DS.MS1) || DS.isDevice(DS.MT1)) {
				names = [loc("out_ind_light"),loc("out_ind_sound")];
				titles = [loc("out_ind_light_title"),loc("out_ind_sound_title")];
			}
			
			super();
			
			lastcmd = CMD.CTRL_TEMPLATE_OUT;
			
			starterCMD = [CMD.CTRL_INIT_OUT
				, CMD.CTRL_NAME_OUT
				, CMD.CTRL_TEMPLATE_AL_PART
				, CMD.CTRL_TEMPLATE_ST_PART
				, CMD.CTRL_TEMPLATE_AL_LST_PART
				, CMD.CTRL_TEMPLATE_UNSENT_MESS
				, CMD.CTRL_TEMPLATE_MANUAL_CNT
				, CMD.CTRL_TEMPLATE_MANUAL_TIME
				, CMD.CTRL_TEMPLATE_FAULT
				, CMD.CTRL_TEMPLATE_OUT];
		}
		override protected function getTitle():String
		{
			return loc("rfd_output");
		}
		override protected function getClass(str:int):IBaseComponent
		{
			return new OptOut(str);
		}
		override protected function getSecondLabel(str:int):String
		{
			if (titles && titles[str-1])
				return titles[str-1];
			return getTitle()+" "+ str;
		}
		override protected function getButtonTitle(str:int):String
		{
			if (names && names[str-1])
				return names[str-1];
			return getTitle()+" "+str;
		}
	}
}