package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.abstract.servants.adapter.VoltageAdapter;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.visual.Battery;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class OptSensorVoltage extends OptSensorRoot
	{
		private var battery:Battery;
		
		public function OptSensorVoltage(str:int, type:int)
		{
			super(str,type,CMD.CTRL_VOLTAGE_SENSOR);
		}
		override protected function build():void
		{
			battery = new Battery;
			addChild( battery );
			battery.x = pos1+3;
			battery.y = globalY+3; 
			
			switch(type) {
				case TYPE_A:
					battery.visible = false;
					title = loc("sensor_ext_power");
					break;
				case TYPE_B:
					title = loc("sensor_battery_main");
					break;
				case TYPE_C:
					title = loc("sensor_battery_reserve");
					break;
			}
			
			addui( new FSShadow, CMD.CTRL_VOLTAGE_SENSOR, "", null, 1 );
			addui( new FSSimple, CMD.CTRL_VOLTAGE_SENSOR, title, null, 2 );
			attuneElement( pos2, 60, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setAdapter( new VoltageAdapter );
		}
		override public function putData(p:Package):void
		{
			if (p.cmd == operatingCMD) {
				pdistribute(p);
				battery.putSimple( int(p.getParam(1,structureID)) );
			}
		}
	}
}