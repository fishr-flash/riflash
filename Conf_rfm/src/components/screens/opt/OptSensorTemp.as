package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSSimple;
	import components.static.CMD;
	
	public class OptSensorTemp extends OptSensorRoot
	{
		public function OptSensorTemp(str:int, type:int)
		{
			super(str,type,CMD.CTRL_TEMPERATURE_SENSOR);
		}
		override protected function build():void
		{
			switch(type) {
				case TYPE_A:
					title = loc("sensor_temperature_cpu");
					break;
				case TYPE_I:
					title = loc("vhis_25");
					break;
			}
			
			addui( new FSSimple, operatingCMD, title, null, 1 );
			attuneElement( pos2, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setAdapter( new TempAdapter );
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;

class TempAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return UTIL.toSigned(int(value),1).toString();
	}
	public function change(value:Object):Object
	{
		return null;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		return null;
	}
}