package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class OptSensorOutput extends OptSensorRoot
	{
		public function OptSensorOutput(str:int, type:int)
		{
			super(str,type,CMD.CTRL_DOUT_SENSOR);
		}
		override protected function build():void
		{
			title = loc("rfd_output") + " " + structureID;
			
			addui( new FSSimple, operatingCMD, title, null, 1 );
			attuneElement( pos1, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			getLastElement().setAdapter( new OutputAdapter );
		}
		override public function putData(p:Package):void
		{
			if (p.cmd == operatingCMD)
				pdistribute(p);
		}
	}
}
import components.abstract.functions.loc;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.static.COLOR;

class OutputAdapter implements IDataAdapter
{
	private var color:uint;
	
	public function adapt(value:Object):Object
	{
		/**	Команда CTRL_DOUT_SENSOR - датчик состояния выходов, количество структур зависит от количества датчиков, описанных через параметр 1 структуры 5 команды CTRL_SENSOR_AVAILABLE
			Параметр 1 - 1-Включено, 2- Импульсы 1Гц, 3-Короткие импульсы, 4-Выключено, 5-Импульсы 7Гц.*/
		
		var n:int = int(value);
		switch(n) {
			case 1:
				color = COLOR.GREEN;
				return loc("g_enabled");
			case 2:
				color = COLOR.GREEN;
				return loc("out_impulse_1hz");
			case 3:
				color = COLOR.GREEN;
				return loc("out_impulse_short");
			case 4:
				color = COLOR.RED;
				return loc("g_disabled");
			case 5:
				color = COLOR.GREEN;
				return loc("out_7hz_pulse");
				
		}
		color = COLOR.BLACK;
		return loc("g_unknown");
	}
	public function change(value:Object):Object
	{
		return null;
	}
	public function perform(field:IFormString):void
	{
		(field as FSSimple).setTextColor( color );
	}
	public function recover(value:Object):Object
	{
		return null;
	}
}