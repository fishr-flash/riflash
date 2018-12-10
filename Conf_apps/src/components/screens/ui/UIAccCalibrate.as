package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.akc.AkcBox;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	
	public class UIAccCalibrate extends UI_BaseComponent
	{
		private var bRemember:TextButton;
		private var taskstates:ITask;
		private var task:ITask;
		private var box:AkcBox;

		private const SPAM_TIMER:int = 100;
		
		private const STATES:Array = [
			loc("ui_acc_unknown_state"),
			"",
			"",
			loc("ui_acc_no_rest"),
			loc("ui_acc_position_incorrect"),
			loc("ui_acc_calib_success") ];
		
		public function UIAccCalibrate()
		{
			super();
			
			bRemember = new TextButton;
			addChild( bRemember );
			bRemember.x = PAGE.CONTENT_LEFT_SHIFT;
			bRemember.y = globalY;
			bRemember.setUp(loc("ui_acc_rem_start_pos"), onRemember );
			
			FLAG_SAVABLE = false;
			addui( new FormString, 2, "", null, 1 ).x = 300;
			attuneElement(400);
			
			box = new AkcBox(50,50,50);
			addChild( box );
			box.x = -60;
			box.y = globalY - 100;
			
			starterCMD = CMD.VR_SENSOR_SI_XY;
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			if(taskstates)
				taskstates.kill();
			taskstates = null;
		}
		override public function put(p:Package):void
		{
			switch (p.cmd) {
				case CMD.VR_SENSOR_SI_XY:
					box.rotate(p.getStructure()[0],p.getStructure(2)[0],0);
					if (!task)
						task = TaskManager.callLater( onTask, SPAM_TIMER );
					else
						task.repeat();
					break;
				case CMD.VR_SENSOR_SI_REMEMBER:
					if (p.getStructure()[0] == 1 || p.getStructure()[0] == 2)
						taskstates.repeat();
					else {
						var f:FormString = getField(2,1) as FormString;
						if (STATES.length > p.getStructure()[0] ) {
							if (p.getStructure()[0] == 3 || p.getStructure()[0] == 4)
								f.setTextColor( COLOR.RED );
							else if (p.getStructure()[0] == 5 )
								f.setTextColor( COLOR.GREEN );
							else
								f.setTextColor( COLOR.BLACK );
							f.setCellInfo( STATES[p.getStructure()[0]] );
						} else {
							f.setTextColor( COLOR.RED );
							f.setCellInfo( loc("ui_acc_cal_not_success") );
						}
						blockNavi = false;
						bRemember.disabled = false;
					}
					break;
			}
		}
		private function onTask():void
		{
			if (this.visible)
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SENSOR_SI_XY, put));
		}
		private function onRequestStates():void
		{
			if (this.visible)
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SENSOR_SI_REMEMBER, put));
		}
		private function onRemember():void
		{	// Параметр 1 - запомнить начальное положение (0x01)
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SENSOR_SI_REMEMBER, null, 1, [1]));
			if(!taskstates)
				taskstates = TaskManager.callLater(onRequestStates, CLIENT.TIMER_EVENT_DATE_SPAM);
			else
				taskstates.repeat();
			bRemember.disabled = true;
			blockNavi = true;
			this.dispatchEvent( new Event( Event.CHANGE ) );
			(getField(2,1) as FormString).setTextColor( COLOR.BLACK );
			getField(2,1).setCellInfo(loc("ui_acc_cal_inprogress"));
		}
	}
}