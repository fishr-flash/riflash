package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.interfaces.IBaseComponent;
	import components.interfaces.ITask;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptOutLoRa;
	import components.screens.ui.abstract.UIDeviceOutput;
	import components.static.CMD;
	import components.static.DS;
	
	public final class UIOutMenuLoRa extends UIDeviceOutput
	{
		private var titles:Array;
		private var names:Array;
		private var task:ITask;
		public function UIOutMenuLoRa()
		{
			if (DS.isDevice(DS.MS1) || DS.isDevice(DS.MT1)) {
				names = [loc("out_ind_light"),loc("out_ind_sound")];
				titles = [loc("out_ind_light_title"),loc("out_ind_sound_title")];
			}
			
			super();
			
			lastcmd = CMD.CTRL_TEMPLATE_OUT;
			
			starterCMD = [CMD.CTRL_INIT_OUT, 
							CMD.CTRL_NAME_OUT,
							CMD.CTRL_TEMPLATE_RF_ALARM_BUTTON,
							CMD.LR_DEVICE_LIST_RF_SYSTEM,
							//CMD.CTRL_TEMPLATE_AL_PART, 
							//CMD.CTRL_TEMPLATE_ST_PART,
							//CMD.CTRL_TEMPLATE_AL_LST_PART,
							//CMD.CTRL_TEMPLATE_UNSENT_MESS,
							//CMD.CTRL_TEMPLATE_MANUAL_CNT, 
							//CMD.CTRL_TEMPLATE_MANUAL_TIME,
							//CMD.CTRL_TEMPLATE_FAULT,
							CMD.CTRL_TEMPLATE_OUT];
			
		
			
			this.height = 600;
		}
		
		
		override public function open():void
		{
			super.open();
			isOn(  TaskManager.DELAY_30SEC );
			RequestAssembler.getInstance().doPing( false );
		}
		
		override public function close():void
		{
			super.close();
			if( task )
			{
				task.stop();
				task.kill();
				task = null;
			}
			RequestAssembler.getInstance().doPing( true );
		}
		
		private function isOn( delay:int ):void
		{
			
			
			if (!task)
				task = TaskManager.callLater( isOn, TaskManager.DELAY_30SEC + 10,  [ TaskManager.DELAY_30SEC ]  );
			else
				task.repeat();
			
			
		}
		override protected function getTitle():String
		{
			return loc("rfd_output");
		}
		override protected function getClass(str:int):IBaseComponent
		{
			return new OptOutLoRa(str);
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