package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Label;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.deviceMap.RadioDevicePanel;
	import components.gui.visual.deviceMap.Sensor_help;
	import components.gui.visual.deviceMap.Sensor_helpM;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.static.RF_STATE;
	
	// Версия без Реле
	
	public class UIRadiodeviceMap extends UI_BaseComponent
	{
		public static const MAPRF_SELECT_NONE:int = 0x00;
		public static const MAPRF_SELECT_SEN:int = 0x01;
		public static const MAPRF_SELECT_KEY:int = 0x02;
		//public static const MAPRF_SELECT_REL:int = 0x03;
		public static const MAPRF_SELECT_REL:int = 0xFF;
		public static const MAPRF_SELECT_MOD:int = 0x03;
		public static const MAPRF_SELECT_LOG:int = 0x04;
		
		private var pageLabel:Label;
		
		private var sensorHelp:Sensor_help;
		
		private var sPanelSensor1:RadioDevicePanel;
		private var sPanelSensor2:RadioDevicePanel;
		private var sPanelKeyboard:RadioDevicePanel;
		private var sPanelRele:RadioDevicePanel;
		private var sPanelModule:RadioDevicePanel;
		
		private var lastOpened:int;
		private var UID:int = 12301;
		private var sensorHelpM:Sensor_helpM;

		private var cleanButton:TextButton;
		
		public function UIRadiodeviceMap()
		{
			super();
			construct();
		}
		private function construct():void
		{
			initNavi();
			navi.setUp( openMap );
			navi.addButton( loc("rfd_sensors"), 1 );
			navi.addButton( loc("rfd_keys"), 2 );
		
			if( !DS.isfam( DS.K16 ) || SERVER.BOTTOM_RELEASE > 17 )
				navi.addButton( loc("navi_rf_modules_much"), 4 );
				
			pageLabel = new Label;
			addChild( pageLabel );
			
			cleanButton = addbutton( loc( "rfd_clearmap_II" ), 1 );
			cleanButton.visible = false;
			
			
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onChangeOffline );
			
			starterCMD = CMD.RF_SENSOR;
			
			
			
			
			
			function addbutton(title:String, n:int):TextButton
			{
				var b:TextButton = new TextButton;
				addChild( b );
				b.setUp( title, onClick, n );
				b.y = globalY + 380;
				b.x = globalX - 7;
				
				return b;
			}
			
			height = 730;
			
			
			
		}
		
		private function onClick( id:int ):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_CLEAR, null, 1, [ 1 ] ) ); 
			
			
		}
		override public function put(p:Package):void
		{
			if ( lastOpened == 0 )
				openMap(1);
			else
				openMap(lastOpened);
			
			//	blockScreen(CLIENT.JUMPER_BLOCK);
			navi.selection = lastOpened;	
			LOADING = false;
		}
		override public function open():void
		{
			stateRequestTimer = new Timer( CLIENT.TIMER_EVENT_SPAM, 1 );
			super.open();
			LOADING = true;
		}
		override public function close():void
		{
			if ( !this.visible ) return;
			timerOn( false );
			hideAll();
			RequestAssembler.getInstance().clearStackLater();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_SELECT, null, 1, [MAPRF_SELECT_NONE]) );
			lastOpened = 0;
			super.close();
		}
		private function createButton( _but:TextButton ):void 
		{
			addChild( _but );
			_but.y = globalY;
			_but.setFormat( true, 12 );
			globalY += _but.getHeight() + 5;
		}
		private function createHelp( _name:String ):void {
			
			if( _name == loc( "rfd_module_lost" ) )
			{
				if( !sensorHelpM )
				{
					sensorHelpM = new Sensor_helpM;
					addChild( sensorHelpM );
					
					sensorHelpM.x = 10;
					sensorHelpM.y = 450;
					
				}
				else 
				{
					sensorHelpM.visible = true;
				}
				
				if( sensorHelp ) sensorHelp.visible = false;
				
				
			}
			else
			{
				if ( !sensorHelp ) 
				{
					
					
					sensorHelp = new Sensor_help;
					addChild( sensorHelp );
					
					sensorHelp.x = 10;
					sensorHelp.y = 450;
				}
				else 
				{
					sensorHelp.visible = true;
				}
				
				sensorHelp.title = _name;
				
				
				if( sensorHelpM ) sensorHelpM.visible = false;
			}
			
			
			
		}
		private function openMap(num:int):void
		{
			
			
			
			
			doReady( false );
			hideAll();
			if (stateRequestTimer.running)
				TaskManager.callOnDemand( UID, select, num, true );
			else
				select(num);
			
			loadStart();
		}
		private function select(num:int):void
		{
			cleanButton.visible = false;
			
			switch(num) {
				case 1:
					openPageRadioSensor();
					break;
				case 2:
					openPageRadioKeyBoard();
					break;
				case 3:
					openPageRadioRele();
					break;
				case 4:
					
					openPageRModule();
					cleanButton.visible = true;		
					break;
			}
		}
		
		/************************************** SENSOR ***************************************************/
		
		private function openPageRadioSensor():void
		{
			if ( !sPanelSensor1 ) {
				sPanelSensor1 = new RadioDevicePanel( RadioDevicePanel.RADIOD_SENSORS );
				sPanelSensor1.x = 10;
				addChild( sPanelSensor1 );
				
				sPanelSensor2 = new RadioDevicePanel( RadioDevicePanel.RADIOD_SENSORS );
				sPanelSensor2.x = sPanelSensor1.getWidth() + sPanelSensor1.x + 20;
				addChild( sPanelSensor2 );
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_SELECT, openPageRadioSensorSuccess, 1, [MAPRF_SELECT_SEN]));
			lastOpened = MAPRF_SELECT_SEN;
			width = 830;
		}
		private function openPageRadioSensorSuccess( p:Package ):void
		{
			if ( p.success && this.visible ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_SEN, processSensor ));
				timerOn( true );
			//	doReady(true);
			}
		}
		private function processSensor( p:Package ):void
		{
			if ( !p.error && sPanelSensor1 && this.visible ) {
				
			/*	if (navi.selection != 1)
					navi.selection = 1;*/
				
				globalVisible(MAPRF_SELECT_SEN);
				
				sPanelSensor1.insertData( p.data.splice(0, 16) );
				sPanelSensor2.insertData( p.data.splice(0), 17 );
				
				createHelp( loc("rfd_lost"));
				doReady(true);
				loadComplete();
			}
		}
		
		/************************************** KEYBOARD ***************************************************/
		
		private function openPageRadioKeyBoard():void
		{
			if ( !sPanelKeyboard ) {
				sPanelKeyboard= new RadioDevicePanel( RadioDevicePanel.RADIOD_KEYBOARD );
				sPanelKeyboard.x = 10;
				addChild( sPanelKeyboard );
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_SELECT, openPageRadioKeyBoardSuccess, 1, [MAPRF_SELECT_KEY] ));
			lastOpened = MAPRF_SELECT_KEY;
			width = 335;
		}
		private function openPageRadioKeyBoardSuccess( p:Package ):void
		{
			if ( p.success && this.visible ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_KEY, processKeyboard ));
				timerOn( true );
		//		doReady(true);
			}
		}
		private function processKeyboard( p:Package ):void
		{
			if ( !p.error && sPanelKeyboard && this.visible) {
			/*	if (navi.selection != 2)
					navi.selection = 2;*/
				globalVisible(MAPRF_SELECT_KEY);
				//sPanelKeyboard.visible = true;
				sPanelKeyboard.insertData( p.data.splice(0, 16) );
				
				createHelp(loc("rfd_key_lost"));
				doReady(true);
				loadComplete();
			}
		}
		
		/************************************** RELE ***************************************************/
		
		private function openPageRadioRele():void
		{
			if ( !sPanelRele ) {
				sPanelRele= new RadioDevicePanel( RadioDevicePanel.RADIOD_RELE );
				sPanelRele.x = 10;
				addChild( sPanelRele );
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_SELECT, openPageRadioReleSuccess, 1, [MAPRF_SELECT_REL] ));
			lastOpened = MAPRF_SELECT_REL;
			width = 750;
		}
		
		
		private function openPageRadioReleSuccess( p:Package ):void
		{
			if ( p.success && this.visible ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_REL, processRele ));
				timerOn( true );
		//		doReady(true);
			}
		}
		
		
		private function processRele( p:Package ):void
		{
			if ( !p.error && sPanelRele && this.visible ) {
				if (navi.selection != 3)
					navi.selection = 3;
				globalVisible(MAPRF_SELECT_REL);
				sPanelRele.insertData( p.data.splice(0, 16) );
				
				createHelp(loc("rfd_relay_lost"));
				doReady(true);
				loadComplete();
			}
		}
		
		/************************************** MODULE ***************************************************/
		
		
		private function openPageRModule():void
		{
			if ( !sPanelModule ) {
				sPanelModule= new RadioDevicePanel( RadioDevicePanel.RADIOD_MODULE );
				sPanelModule.x = 10;
				addChild( sPanelModule );
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_SELECT, openPageRadioModuleSuccess, 1, [MAPRF_SELECT_MOD] ));
			lastOpened = MAPRF_SELECT_MOD;
			
			width = 750;
		}
		
		private function openPageRadioModuleSuccess( p:Package ):void
		{
			if ( p.success && this.visible ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_MOD, processModule ));
				timerOn( true );
				
			}
		}
		
		private function processModule( p:Package ):void
		{
			if ( !p.error && sPanelModule && this.visible ) {
				if (navi.selection != MAPRF_SELECT_MOD)
					navi.selection = MAPRF_SELECT_MOD;
				globalVisible(MAPRF_SELECT_MOD);
				sPanelModule.insertData( p.data.splice(0, 16) );
				
				createHelp(loc("rfd_module_lost"));
				doReady(true);
				loadComplete();
				
				
			}
		}
		
		/************************************** OVER ***************************************************/
		
		
		
		
		private function globalVisible(value:int):void 
		{
			if ( sPanelSensor1 ) {
				sPanelSensor1.visible = Boolean(MAPRF_SELECT_SEN == lastOpened);
				sPanelSensor2.visible = Boolean(MAPRF_SELECT_SEN == lastOpened);
			}
			if ( sPanelKeyboard )
				sPanelKeyboard.visible = Boolean(MAPRF_SELECT_KEY == lastOpened);
			if ( sPanelRele )
				sPanelRele.visible = Boolean(MAPRF_SELECT_REL == lastOpened);
			if ( sPanelModule )
				sPanelModule.visible = Boolean(MAPRF_SELECT_MOD == lastOpened);
			
			
		}
		private function hideAll():void 
		{
			RequestAssembler.getInstance().clearStackLater();
			
			if ( sPanelSensor1 ) {
				sPanelSensor1.visible = false;
				sPanelSensor2.visible = false;
			}
			if ( sPanelKeyboard )
				sPanelKeyboard.visible = false;
			
			if ( sPanelRele )
				sPanelRele.visible = false;
		}
		private function timerOn( _value:Boolean ):void
		{
			if ( !stateRequestTimer )
				return;
			if ( _value ) {
				stateRequestTimer.reset();
				stateRequestTimer.start();
			} else
				stateRequestTimer.stop();
		}
		
		override protected function processState(p:Package):void
		{
			super.processState(p);
			switch( p.getStructure()[2] ) {
				case RF_STATE.JUMPER_ON:
				case RF_STATE.JUMPERBLOCK:
					CLIENT.JUMPER_BLOCK = true;
					break;
				case RF_STATE.JUMPER_OFF:
					CLIENT.JUMPER_BLOCK = false;
					break;
			}
			blockScreen(CLIENT.JUMPER_BLOCK);
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
		override protected function timerComplete( ev:TimerEvent ):void 
		{
			if (!this.visible) 
				return;
			
			if (TaskManager.exist(UID) ) {
				TaskManager.demand(UID);
			} else if (navi.isReady) {
				if (!CLIENT.JUMPER_BLOCK) {
					switch(lastOpened) {
						case MAPRF_SELECT_SEN:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_SEN, processSensor ));
							break;
						case MAPRF_SELECT_KEY:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_KEY, processKeyboard ));
							break;
						case MAPRF_SELECT_REL:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_REL, processRele ));
							break;
						case MAPRF_SELECT_MOD:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.MAPRF_MOD, processModule ) );
							break;
					}
				}
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_STATE, processState ));
			}
			stateRequestTimer.reset();
			stateRequestTimer.start();
		}
		private function doReady(b:Boolean):void
		{
			navi.isReady = b;
			if (!LOADING && this.visible)
				blockNaviSilent = !b;
			
			
			
		}
		private function onChangeOffline(ev:SystemEvents):void		// очистка всех панелей при уходе в офф
		{
			if (!ev.isConneted()) {
				if (sPanelSensor1) {
					sPanelSensor1.reset();
					sPanelSensor2.reset();
				}
				if (sPanelRele)
					sPanelRele.reset();
				if (sPanelKeyboard)
					sPanelKeyboard.reset();
			}
		}
	}
}