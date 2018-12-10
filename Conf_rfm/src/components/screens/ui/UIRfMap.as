package components.screens.ui
{
	import components.abstract.StateWidget;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.SensorHelp;
	import components.gui.visual.deviceMap.RadioDevicePanel;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.static.RF_STATE;
	
	public class UIRfMap extends UI_BaseComponent implements IWidget
	{
		private const MAPRF_SELECT_SEN:int = 0x01;
		
		private var sPanelSensor1:RadioDevicePanel;
		private var sPanelSensor2:RadioDevicePanel;
		private var sensorHelp:SensorHelp;
		private var bClear:TextButton;
		private var firstLoad:Boolean;
		private var blank:Array;
		
		public function UIRfMap()
		{
			super();
			
			sPanelSensor1 = new RadioDevicePanel( RadioDevicePanel.RADIOD_SENSORS_RDK );
			sPanelSensor1.x = globalX;
			addChild( sPanelSensor1 );
			
			sPanelSensor2 = new RadioDevicePanel( RadioDevicePanel.RADIOD_SENSORS_RDK );
			sPanelSensor2.x = sPanelSensor1.getWidth() + sPanelSensor1.x + 20;
			addChild( sPanelSensor2 );
			
			sensorHelp = new SensorHelp;
			addChild( sensorHelp );
			sensorHelp.x = globalX;
			sensorHelp.y = 420;
			
			bClear = new TextButton;
			addChild( bClear );
			bClear.setUp( loc("rfd_clearmap"), onClear );
			bClear.x = globalX;
			bClear.y = 380;
			
			blank = [];
			for (var i:int=0; i<16; i++) {
				blank.push( [0,0,0,0] );
			}
			firstLoad = true;
			
			width = 920;
			height = 930;
		}
		override public function open():void
		{
			super.open();
			
			bClear.disabled = false;
			cached(CMD.RF_SENSOR);
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.MAPRF_SELECT,null,1,[MAPRF_SELECT_SEN]));
			requestMap();
			
			WidgetMaster.access().registerWidget( CMD.MAPRF_SEN, this );
			WidgetMaster.access().registerWidget( CMD.RF_STATE, this );
			
			if (firstLoad) {
				sPanelSensor1.insertData( blank );
				sPanelSensor2.insertData( blank );
				firstLoad = false;
			}
			
			loadComplete();
			blockScreen(CLIENT.JUMPER_BLOCK);
		}
		override public function close():void
		{
			super.close();
			
			StateWidget.access().init();
			RequestAssembler.getInstance().fireEvent( new Request(CMD.MAPRF_GET,null,1,[0]));
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.RF_STATE:
					var state:int = p.getParamInt(3);
					switch(state) {
						case RF_STATE.JUMPER_ON:
							CLIENT.JUMPER_BLOCK = true;
							blockScreen(CLIENT.JUMPER_BLOCK);
							break;
						case RF_STATE.JUMPER_OFF:
							CLIENT.JUMPER_BLOCK = false;
							blockScreen(CLIENT.JUMPER_BLOCK);
							break;
					}
					break;
				default:
					if (!sensorHelp.visible)
						sensorHelp.visible = true;
					
					sPanelSensor1.insertData( p.data.splice(0, 16) );
					sPanelSensor2.insertData( p.data.splice(0), 17 );
					break;
			}
		}
		private function onClear():void
		{
			bClear.disabled = true;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.MAPRF_CLEAR,null,1,[1]));
			runTask(onRelease, TaskManager.DELAY_5SEC,1 );
		}
		private function onRelease():void
		{
			bClear.disabled = false;
		}
		private function requestMap():void
		{
			runTask(requestMap,TaskManager.DELAY_20SEC);
			RequestAssembler.getInstance().fireEvent( new Request(CMD.MAPRF_GET,null,1,[CLIENT.BIN2_RECEIVE_TIME]));
		}
		private function blockScreen(value:Boolean):void
		{
			if (this.visible) {
				if (value)
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, 
						{getScreenMode:ScreenBlock.MODE_SIMPLE_TEXT, getScreenMsg:loc("rfd_map_not_work_while_jumper")} );
				else
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
			}
		}
	}
}