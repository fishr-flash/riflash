package components.abstract.adapters
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSSimple;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.static.COLOR;

	public class SwitchAdapter implements IDataAdapter
	{
		private var v:int;
		private var c:int;
		
		public function adapt(value:Object):Object
		{
			/**	Команда CTRL_DOUT_SENSOR - датчик состояния выходов, количество структур зависит от количества датчиков, описанных через параметр 1 структуры 5 команды CTRL_SENSOR_AVAILABLE
				Параметр 1 - 1-Включено, 2- Импульсы 1Гц, 3-Короткие импульсы, 4-Выключено, 5-Импульсы 7Гц. */
			
			v = int(value);
			
			c = COLOR.GREEN_DARK;
			switch(v) {
				case 1:
					return loc("g_enabled");
				case 2:
					return loc("out_impulse_1hz");
				case 3:
					return loc("out_impulse_short");
				case 4:
					c = COLOR.RED;
					return loc("g_disabled");
				case 5:
					return loc("out_7hz_pulse");
			}
			c = COLOR.RED;
			return loc("g_unknown");
		}
		public function change(value:Object):Object	{		return null;	}
		public function perform(field:IFormString):void
		{	
			(field as FSSimple).setTextColor( c );
		}
		public function recover(value:Object):Object	{		return null;	}
	}
}