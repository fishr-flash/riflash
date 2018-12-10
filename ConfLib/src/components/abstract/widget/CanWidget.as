package components.abstract.widget
{
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class CanWidget implements IWidget
	{
		private var delegate:Function;
		private var task:ITask;
		
		public function CanWidget(f:Function)
		{
			delegate = f; 
		}
		public function active(b:Boolean):void
		{
			if (b) {
				if (!task)
				{
					task = TaskManager.callLater(proceed, 71500 );
					//RequestAssembler.getInstance().fireEvent( new Request(CMD.CAN_GET_PARAMS,null,1,[1]));
				}
				else
				{
					//
					task.repeat();
				}
					
				RequestAssembler.getInstance().fireEvent( new Request(CMD.CAN_GET_PARAMS,null,1,[1]));
				WidgetMaster.access().registerWidget( CMD.CAN_INPUTS, this );
				WidgetMaster.access().registerWidget( CMD.CAN_PARAMS_FUEL, this );
				WidgetMaster.access().registerWidget( CMD.CAN_PARAMS_ENGINE, this );
				WidgetMaster.access().registerWidget( CMD.CAN_PARAMS_EXPL, this );
				RequestAssembler.getInstance().doPing( false );
				
			} else {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.CAN_GET_PARAMS,null,1,[0]));
				
				if(task)
					task.stop();
				
				WidgetMaster.access().unregisterWidget( CMD.CAN_INPUTS );
				WidgetMaster.access().unregisterWidget( CMD.CAN_PARAMS_FUEL );
				WidgetMaster.access().unregisterWidget( CMD.CAN_PARAMS_ENGINE );
				WidgetMaster.access().unregisterWidget( CMD.CAN_PARAMS_EXPL );
				
				
				
			}
		}
		
		
		private function proceed():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CAN_GET_PARAMS,null,1,[1]));
			task.repeat();
		}
		public function put(p:Package):void
		{
			delegate(p);
		}
	}
}