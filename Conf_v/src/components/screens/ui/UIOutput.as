package components.screens.ui
{
	import flash.events.Event;
	
	import mx.events.ResizeEvent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.PopUp;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptOutput;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.SavePerformer;
	
	public class UIOutput extends UI_BaseComponent
	{
		public static const EVENT_ASK_STATE:String="EVENT_ASK_STATE";
		public static const EVENT_SPEED_EXCESS_TEST:String="EVENT_SPEED_EXCESS_TEST";
		
		private var TOTAL_IN:int;
		
		private var opts:Vector.<OptOutput>;
		private var task:ITask;
		
		public function UIOutput()
		{
			super();
			
			if ( DS.isDevice( DS.VL1 ) 
				|| DS.isDevice( DS.VL2 ) 
				|| DS.isfam( DS.F_VL_3G ) 
				|| DS.isDevice( DS.VL3 )   
			)
				starterCMD = [  CMD.VR_SPEED_ALARM, CMD.VR_OUT_COUNT, CMD.VR_OUT,  CMD.VR_OUT_STATE];
			else
				starterCMD = [ CMD.VR_OUT_COUNT, CMD.VR_ACC_ALARM,  CMD.VR_SPEED_ALARM,  CMD.VR_OUT, CMD.VR_OUT_STATE];
			
			
		}
		override public function open():void
		{
			super.open();
			SavePerformer.trigger( {cmd:cmd} );
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.stop();
		}
		override public function put(p:Package):void
		{
			var i:int;
			switch(p.cmd) {
				case CMD.VR_OUT_COUNT:
					TOTAL_IN = p.getStructure()[0];
					if (!navi && TOTAL_IN > 0) {
						// меняем стартер, чтобы не запрашивать лишнее
						if ( DS.isDevice( DS.VL1 ) 
							|| DS.isDevice( DS.VL2 ) 
							|| DS.isfam( DS.F_VL_3G ) 
							   )
							starterCMD = [ CMD.VR_SPEED_ALARM, CMD.VR_OUT_COUNT, CMD.VR_OUT,  CMD.VR_OUT_STATE];
						else if (DS.isDevice(DS.VL0))
							starterCMD = [CMD.VR_SPEED_ALARM, CMD.VR_OUT, CMD.VR_OUT_STATE];
						else
							starterCMD = [CMD.VR_SPEED_ALARM, CMD.VR_ACC_ALARM, CMD.VR_OUT, CMD.VR_OUT_STATE];
						
						OPERATOR.getSchema(CMD.VR_OUT).StructCount = TOTAL_IN;
						OPERATOR.getSchema(CMD.VR_OUT_MANUAL_CONTROL).StructCount = TOTAL_IN;
						OPERATOR.getSchema(CMD.VR_OUT_STATE).StructCount = TOTAL_IN;
						
						globalX = PAGE.CONTENT_LEFT_SHIFT;
						initNavi();
						navi.setUp( openOut, 50 );
						navi.width = PAGE.SECONDMENU_WIDTH;
						navi.height = 200;
						
						for (i=0; i<TOTAL_IN; ++i) {
							navi.addButton( loc("rfd_output")+" "+(i+1), i+1 );
						}
						globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT + 10;
						opts = new Vector.<OptOutput>(TOTAL_IN+1);	// потому что 0 выхода нет
					}
					if (TOTAL_IN == 0) {
						popup = PopUp.getInstance();
						popup.construct( PopUp.wrapHeader("sys_error"), PopUp.wrapMessage( "device_no_outputs" ) );
						popup.open();
					}
					break;
				case CMD.VR_OUT:
					loadComplete();
					if (TOTAL_IN > 0) {
						openOut(1);
						navi.selection = 1;
					}
					break;
				case CMD.VR_OUT_STATE:
					if (TOTAL_IN > 0) {
						for (i=0; i<TOTAL_IN; ++i) {
							if( opts[i+1] && opts[i+1].visible ) {
								opts[i+1].putState(p.getStructure(i+1));
								break;
							}
						}
					}
					break;
			}
		}
		private function openOut( value:int ):void
		{
			if (!opts[value]) {
				opts[value] = new OptOutput(value);
				addChild( opts[value] );
				opts[value].x = globalX;
				opts[value].y = PAGE.CONTENT_TOP_SHIFT;
				opts[value].addEventListener( ResizeEvent.RESIZE, onResize );
				opts[value].addEventListener( EVENT_ASK_STATE, onInit );
			}
			opts[value].putRawData( [
				{cmd:CMD.VR_OUT, data:OPERATOR.dataModel.getData(CMD.VR_OUT)[value-1] }
			] );
			changeSecondLabel( loc("rfd_output")+" " + value );
			visibleOnlyOne(value);			
		}
		private function visibleOnlyOne(value:int):void
		{
			var len:int = opts.length;
			for (var i:int=0; i<len; ++i) {
				if (opts[i] )
					opts[i].visible = i == value;
			}
		}
		private function onTask():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_OUT_STATE, put));
			task.repeat();
		}
		private function cmd(value:Object):int
		{
			if (value is int) {
				if ( int(value) == CMD.VR_OUT )
					opts[navi.selection].updateOutType();
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function onInit(e:Event):void
		{
			if( (e.currentTarget as OptOutput).needState ) {
				if (!task)
					task = TaskManager.callLater( onTask, CLIENT.TIMER_EVENT_SPAM );
				else
					task.repeat();
			} else
				if (task)
					task.stop();
		}
		private function onResize(e:Event):void
		{
			width = (e.currentTarget as OptOutput).width;
			height = (e.currentTarget as OptOutput).height;
		}
	}
}