package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSSimple;
	import components.static.CMD;
	
	public class OptSensorButton extends OptSensorRoot
	{
		public function OptSensorButton(str:int, type:int)
		{
			super(str,type,CMD.CTRL_KEY_SENSOR);
		}
		override protected function build():void
		{
			switch(type) {
				case TYPE_A:
					title = loc("sensor_button_ctrl");
					break;
			}
			
			addui( new FSSimple, operatingCMD, title, null, 1 );
			attuneElement( pos1, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			getLastElement().setAdapter( new ButtonAdapter );
		}
	}
}
import components.abstract.functions.loc;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.static.COLOR;

class ButtonAdapter implements IDataAdapter
{
	private var color:uint;
	
	public function adapt(value:Object):Object
	{
		var n:int = int(value);
		switch(n) {
			case 0:
				color = COLOR.RED;
				return loc("sensor_btn_released");
			case 1:
				color = COLOR.GREEN;
				return loc("sensor_btn_pressed");
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