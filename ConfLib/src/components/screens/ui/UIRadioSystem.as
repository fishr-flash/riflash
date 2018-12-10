package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.RFSensorServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptRF_SYSTEM;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.MISC;
	import components.static.RF_STATE;
	import components.system.SavePerformer;
	import components.system.SysManager;
	
	public class UIRadioSystem extends UI_BaseComponent
	{
		private var optSystem:OptRF_SYSTEM;
		
		private var bCreateSystem:TextButton;
		private var blockScreen:ScreenBlock;
		
		private var MARK_LOST_COUNTER:int;
		
		public static function get sensortime_active():int
		{
			/*
			if (DEVICES.getCurrentDevice() == DEVICES.K14 )
				return 2;
			*/
			return 1;
		}
		
		public function UIRadioSystem()
		{
			super();
			
			optSystem = new OptRF_SYSTEM;
			addChild( optSystem );
			optSystem.y = globalY;
			
			globalY = optSystem.getHeight() + optSystem.y;
			globalX = 10;
			
			bCreateSystem = new TextButton;
			addChild( bCreateSystem );
			bCreateSystem.setFormat( true, 12 );
			bCreateSystem.setUp( loc("rf_system_new"), createNewSystem );
			bCreateSystem.x = globalX;
			bCreateSystem.y = globalY;
			
			blockScreen = new ScreenBlock(430,optSystem.getHeight()-40, ScreenBlock.MODE_ONLY_BLOCK,"",COLOR.BLUE );
			addChild( blockScreen );
			
			starterCMD = [CMD.RF_MESSAGE_TAMPER, CMD.RF_SENSOR_TIME, CMD.RF_SYSTEM];
			
			width = 440;
			height = 400;
		}
		override public function open():void
		{
			bCreateSystem.disabled = false;
			blockScreen.visible = false;
			super.open();
		}
		override public function put( p:Package):void 
		{
			if (p.cmd == CMD.RF_SYSTEM) {
				if ( p.getStructure()[0] != 1 ) {
					blockScreen.visible = true;
					blockScreen.text = loc("rf_nosystem");
					blockScreen.alphalevel = 0.7;
					blockScreen.mode( ScreenBlock.MODE_SIMPLE_TEXT );
				} else {
					if ( MISC.SYSTEM_INACCESSIBLE )
						GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onSystemChange, {"isSystemUp":true} );
				}
				MISC.SYSTEM_INACCESSIBLE = Boolean(p.getStructure()[0] == 0);
				optSystem.block(true);
				loadComplete();
			}
			optSystem.putData(p);
		}
		private function createNewSystem():void
		{
			var p:PopUp = PopUp.getInstance();
			p.construct( PopUp.wrapHeader( "sys_attention" ), 
				PopUp.wrapMessage("rf_system_sure_new"),
				PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doCreate] );
			p.open();
		}
		private function saveSystem():void
		{
			if ( optSystem.valid ) {
				SavePerformer.save();
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CODES, saveSystemSuccess, 1, generateCodeStructure() ));
				bCreateSystem.disabled = false;
				
			}
		}
		private function saveSystemSuccess( p:Package ):void
		{
			if ( p.success )
				doSuccessSave();
		}
		private function doSuccessSave():void 
		{
			bCreateSystem.disabled = false;
			SysManager.clearFocus(stage);
			blockScreen.mode( ScreenBlock.MODE_ONLY_BLOCK );
			optSystem.block(true);
			MISC.SYSTEM_INACCESSIBLE = false;
		}
		private function doCreate():void
		{
			bCreateSystem.disabled = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SYSTEM, null, 1, [0,0,0,0,0,0,0,0,0,0] ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_FUNCT, markSensorsLost, 1, [0,0,5,0] ));
			MARK_LOST_COUNTER = 0;
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			// Пометить все радиоустройства как потерянные
			MISC.SYSTEM_INACCESSIBLE = true;
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onSystemChange, {"isSystemUp":false} );
			SavePerformer.trigger({cmd:cmd});
		}
		private function cmd(value:Object):int
		{
			
			if (value is int) {
				if (int(value) == CMD.RF_SYSTEM) {
					saveSystem();
					//doSuccessSave();
					return SavePerformer.CMD_TRIGGER_TRUE;
				}
			} else if (value is Object && value.cmd == CMD.RF_SYSTEM) {
				RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM = value.array[4];
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function markSensorsLost(p:Package):void
		{
			RFSensorServant.systemRebuild();	// для сброса потерянных датчиков
			initSpamTimer( CMD.RF_STATE );
			blockScreen.visible = true;
			blockScreen.text = loc("rf_system_prepairing");
			blockScreen.mode( ScreenBlock.MODE_SIMPLE_TEXT );
		}
		override protected function processState(p:Package):void 
		{
			super.processState(p);
			if( p.getStructure()[2] == RF_STATE.ALL_DEVICES_LOST ) {
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBLock":false} );
				stateRequestTimer.stop();
				optSystem.setDefault();
				blockScreen.visible = false;
				optSystem.block(false);
			} else {
				if (MARK_LOST_COUNTER > 3) {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_FUNCT, markSensorsLost, 1, [0,0,5,0] ));
					MARK_LOST_COUNTER = 0;
				} else
					MARK_LOST_COUNTER++;
			}
		}
		private function generateCodeStructure():Array
		{
			/**	Команда RF_CODES
			 Параметр 1 - адрес прибора в радиосети, ( равно 0 );
			 Параметры 2,3,4,5 - ключи шифрования. */
			
			var aParams:Array = [0];
			for( var i:int=0; i < 4; ++i ) {
				var dec:int = (Math.random()*254+1);
				
				var isUnique:Boolean = false;
				while( isUnique == false ) {
					isUnique = true;
					for( var key:String in aParams ) {
						if ( aParams[key] == dec ) {
							dec = (Math.random()*254+1);
							isUnique = false;
							break;
						}
					}
				}
				aParams.push( dec );
			}
				
			return aParams;
		}
	}
}
// 203 до рефакторинга