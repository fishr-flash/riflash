package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.static.DEVICES;
	
	public class UISensorMenu extends UI_BaseComponent
	{
		public static const MEASURE_SHIFT_CHECKBOX:int = 580;
		public static const MEASURE_SEPARATOR_SIZE:int = 633;
		
		private const S_NAKLONA:int=3;
		private const S_HIT:int=6;
		private const S_TEMP:int=7;
		
		private var ui:UI_BaseComponent;
		
		private var uiSensorIncline:UISensorIncline;
		private var uiSensorTemperature:UISensorTemperature;
		private var uiSensorHit:UISensorHit;
		
		public function UISensorMenu()
		{
			super();
			
			initNavi();
			navi.setUp( openSensor, 10 );
			
			if ( DEVICES.isDevice(DEVICES.ACC2) ) {
				navi.addButton( loc("sensor_incline"), S_NAKLONA, TabOperator.GROUP_BUTTONS + S_NAKLONA*1000 );
				navi.addButton( loc("sensor_crash"), S_HIT, TabOperator.GROUP_BUTTONS + (S_HIT)*1000 );
			}
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
				case S_NAKLONA:
					if (!uiSensorIncline) {
						uiSensorIncline = new UISensorIncline(TabOperator.GROUP_BUTTONS+num*1000);
					//	if ( DEVICES.isDevice(DEVICES.ACC2) )
							uiSensorIncline.addEventListener( Event.CHANGE, onBlockNavi );
					}
					ui = uiSensorIncline;
					break;
				case S_TEMP:
					if (!uiSensorTemperature)
						uiSensorTemperature = new UISensorTemperature(TabOperator.GROUP_BUTTONS+num*1000);
					ui = uiSensorTemperature;
					break;
				case S_HIT:
					if (!uiSensorHit)
						uiSensorHit = new UISensorHit(TabOperator.GROUP_BUTTONS+num*1000);
					ui = uiSensorHit;
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