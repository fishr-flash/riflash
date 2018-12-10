package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.static.DS;
	
	public class UISensorMenu extends UI_BaseComponent
	{
		private const S_MOVE:int=1;
		private const S_VOLTAGE:int=2;
		private const S_NAKLONA:int=3;
		private const S_ACCELERATION:int=4;
		private const S_CRASH:int=5;
		private const S_TEMP:int=7;
		
		private var ui:UI_BaseComponent;
		
		private var uiSensorMove:UISensorMove;
		private var uiSensorVoltage:UISensorVoltage;
		private var uiSensorAcceleration:UISensorAcceleration;
		private var uiSensorCrash:UISensorCrash;
		private var uiSensorIncline:UISensorIncline;
		private var uiSensorTemperature:UI_BaseComponent;
		
		public function UISensorMenu()
		{
			super();
			
			initNavi();
			navi.setUp( openSensor, 10 );
			
			navi.addButton( loc("sensor_move"), S_MOVE, TabOperator.GROUP_BUTTONS + S_MOVE*1000 );
			if (DS.isfam(DS.V2) 
				|| DS.isfam( DS.F_VL, DS.VL1_3G, DS.VL2_3G ) 
				|| ( DS.isfam( DS.F_VL_3G, DS.V3L_3G ))
				|| ( DS.isDevice( DS.V_BRPM ))
				|| DS.isDevice(DS.V4) ) {
				navi.addButton( loc("sensor_voltage"), S_VOLTAGE, TabOperator.GROUP_BUTTONS + S_VOLTAGE*1000 );
			}
			if (DS.isfam(DS.V2) ) {
				navi.addButton( loc("sensor_incline"), S_NAKLONA, TabOperator.GROUP_BUTTONS + S_NAKLONA*1000 );
				navi.addButton( loc("sensor_acc"), S_ACCELERATION, TabOperator.GROUP_BUTTONS + S_ACCELERATION*1000 );
				navi.addButton( loc("sensor_crash"), S_CRASH, TabOperator.GROUP_BUTTONS + S_CRASH*1000 );
			}
			if (DS.release >= 25)
			navi.addButton( loc("sensor_temp"), S_TEMP, TabOperator.GROUP_BUTTONS + S_TEMP*1000 );
			width = 700;
		}
		override public function open():void
		{
			super.open();
			navi.isReady = true;
			if (ui) 
				ui.open();
			else
				loadComplete();
		}
		override public function close():void
		{
			if (ui)
				ui.close();
			super.close();
		}
		private function openSensor(num:int):void
		{
			loadStart();
			if (ui) {
				ui.close();
				removeChild(ui);
				ui = null;
			}
			switch(num) {
				case S_MOVE:
					if (!uiSensorMove)
						uiSensorMove = new UISensorMove(TabOperator.GROUP_BUTTONS+num*1000);
					ui = uiSensorMove;
					break;
				case S_VOLTAGE:
					if (!uiSensorVoltage)
						uiSensorVoltage = new UISensorVoltage(TabOperator.GROUP_BUTTONS+num*1000);
					ui = uiSensorVoltage;
					break;
				case S_NAKLONA:
					if (!uiSensorIncline) {
						uiSensorIncline = new UISensorIncline(TabOperator.GROUP_BUTTONS+num*1000);
					//	if ( DEVICES.isDevice(DEVICES.ACC2) )
							uiSensorIncline.addEventListener( Event.CHANGE, onBlockNavi );
					}
					ui = uiSensorIncline;
					break;
				case S_CRASH:
					if (!uiSensorCrash)
						uiSensorCrash = new UISensorCrash(TabOperator.GROUP_BUTTONS+num*1000);
					ui = uiSensorCrash;
					break;
				case S_ACCELERATION:
					if (!uiSensorAcceleration)
						uiSensorAcceleration = new UISensorAcceleration(TabOperator.GROUP_BUTTONS+num*1000);
					ui = uiSensorAcceleration;
					break;
				case S_TEMP:
					if (!ui)
					{
						if( DS.isfam( DS.V2 )  )
							ui = new UISensorTemperatureV2(TabOperator.GROUP_BUTTONS+num*1000);
						else 
							ui = new UISensorTemperature(TabOperator.GROUP_BUTTONS+num*1000);
					}
						
							
					
					break;
			}
			if (ui) {
				width = ui.width;
				height = ui.height;
				addChild( ui );
				ui.open();
			}
		}
		public function hideUIexcept(ui:UI_BaseComponent):void 
		{
			var comp:UI_BaseComponent;
			var len:int = numChildren;
			for (var i:int=0; i<len; ++i) {
				comp = getChildAt(i) as UI_BaseComponent;
				if (comp && ui != comp) {
					comp.close();
					removeChild(comp);
					i--;
					len--;
				}
			}
		}
		private function onBlockNavi(e:Event):void
		{
			navi.disable( uiSensorIncline.blocked );
		}
	}
}