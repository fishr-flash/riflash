package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.abstract.servants.adapter.BooleanColorInvertAdapter;
	import components.gui.fields.FSSimple;
	import components.static.CMD;
	
	public class OptSensorTamper extends OptSensorRoot
	{
		public function OptSensorTamper(str:int, type:int)
		{
			super(str,type,CMD.CTRL_TAMPER_SENSOR);
		}
		override protected function build():void
		{
			switch(type) {
				case TYPE_A:
					title = loc("sensor_tamper_hull");
					break;
				case TYPE_B:
					title = loc("sensor_tamper_wall");
					break;
			}
			
			addui( new FSSimple, operatingCMD, title, null, 1 );
			attuneElement( pos1, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			//getLastElement().setAdapter( new TamperAdapter );
			getLastElement().setAdapter( new BooleanColorInvertAdapter([loc("sensor_norm"),loc("sensor_alarm")]) );
		}
	}
}