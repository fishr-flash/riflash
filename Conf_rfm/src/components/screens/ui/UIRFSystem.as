package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.RFSensorServant;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptRfSystem;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.MISC;
	import components.static.RF_STATE;
	import components.system.SavePerformer;
	import components.system.SysManager;
	
	public class UIRFSystem extends UI_BaseComponent implements IWidget
	{
		private var bCreateSystem:TextButton;
		private var opt:OptRfSystem;
		private var blockScreen:ScreenBlock;
		private var task:ITask;
		
		public function UIRFSystem()
		{
			super();
			
			opt = new OptRfSystem;
			addChild( opt );
			opt.x = globalX;
			opt.y = globalY;
			
			globalY += opt.complexHeight;
			
			drawSeparator();

			bCreateSystem = new TextButton;
			addChild( bCreateSystem );
			bCreateSystem.x = globalX;
			bCreateSystem.y = globalY;
			bCreateSystem.setUp(loc("rf_system_new"), onCreate );
			
			blockScreen = new ScreenBlock(430,opt.getHeight(), ScreenBlock.MODE_ONLY_BLOCK,"",COLOR.BLUE );
			addChild( blockScreen );
			blockScreen.visible = false;
			
			starterCMD = CMD.RF_SYSTEM;
		}
		override public function put( p:Package):void 
		{
			switch(p.cmd) {
				case CMD.RF_SYSTEM:
					if ( p.getStructure()[0] != 1 ) {
						blockScreen.visible = true;
						blockScreen.text = loc("rf_nosystem");
						blockScreen.alphalevel = 0.7;
						blockScreen.mode( ScreenBlock.MODE_SIMPLE_TEXT );
					} else {
						if ( MISC.SYSTEM_INACCESSIBLE )
							GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onSystemChange, {"isSystemUp":true} );
					}
					MISC.SYSTEM_INACCESSIBLE = Boolean(p.getParamInt(1) == 0);
					opt.block(true);
					loadComplete();
					opt.putRawData(p.data[0]);
					break;
				case CMD.RF_STATE:
					//super.processState(p);
					if( p.getParamInt(3) == RF_STATE.ALL_DEVICES_LOST ) {
						blockNavi = false;
						opt.setDefault();
						blockScreen.visible = false;
						opt.block(false);
						task.stop();
					}
					break;
			}
		}
		private function onCreate():void
		{
			var p:PopUp = PopUp.getInstance();
			p.construct( PopUp.wrapHeader( "sys_attention" ), 
				PopUp.wrapMessage("rf_system_sure_new"),
				PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doCreate] );
			p.open();
		}
		private function doCreate():void
		{
			bCreateSystem.disabled = true;
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SYSTEM, markSensorsLost, 1, [0,0,0,0,0,0,0,0,0,0] ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_FUNCT, markSensorsLost, 1, [0,0,5,0] ));
			blockNavi = true;
			// Пометить все радиоустройства как потерянные
			MISC.SYSTEM_INACCESSIBLE = true;
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onSystemChange, {"isSystemUp":false} );
			SavePerformer.trigger({cmd:cmd});
		}
		private function doSuccessSave():void 
		{
			bCreateSystem.disabled = false;
			SysManager.clearFocus(stage);
			blockScreen.mode( ScreenBlock.MODE_ONLY_BLOCK );
			opt.block(true);
			MISC.SYSTEM_INACCESSIBLE = false;
		}
		private function cmd(value:Object):int
		{
			if (value is int) {
				if (int(value) == CMD.RF_SYSTEM) {
					doSuccessSave();
					return SavePerformer.CMD_TRIGGER_TRUE;
				}
			} else if (value is Object && value.cmd == CMD.RF_SYSTEM) {
				RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM = value.array[4];
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function markSensorsLost(p:Package=null):void
		{
			RFSensorServant.systemRebuild();	// для сброса потерянных датчиков
			WidgetMaster.access().registerWidget(CMD.RF_STATE,this);
			blockScreen.visible = true;
			blockScreen.text = loc("rf_system_prepairing");
			blockScreen.mode( ScreenBlock.MODE_SIMPLE_TEXT );
		
			if (!task)	// для подстраховки, если прибор ничего не ответит
				task = TaskManager.callLater( markSensorsLost, TaskManager.DELAY_10SEC );
			else
				task.repeat();
		}
	}
}