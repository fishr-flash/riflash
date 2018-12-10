package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.resources.SensorMenuMeasures;
	import components.static.CMD;
	
	public class UISensorCrash extends UI_BaseComponent
	{
		public function UISensorCrash(group:int)
		{
			super();
			
			globalY += 10;
			toplevel = false;
			globalFocusGroup = group;
			
			createUIElement( new FSCheckBox, CMD.VR_SENSOR_SC, loc("ui_acc_evoke_crash"), null, 1 );
			attuneElement( SensorMenuMeasures.MEASURE_SHIFT_CHECKBOX );
			
			//createUIElement( new FSCheckBox, CMD.VR_SENSOR_SC, "Использовать для поиска аварии ASI15", null, 2 );
			createUIElement( new FSShadow, CMD.VR_SENSOR_SC, loc("ui_acc_asi15"), null, 2 );
			attuneElement(SensorMenuMeasures.MEASURE_SHIFT_CHECKBOX );
			
			createUIElement( new FSSimple, CMD.VR_SENSOR_SC, loc("ui_acc_acceleration_exceed"), null, 3, null,
				"0-9.", 4,new RegExp(RegExpCollection.COMPLETE_0dot1to24dot0) );
			attuneElement( 620-68, 40);
			getLastElement().setAdapter( new SensorFloatAdapter );
			
			starterCMD = CMD.VR_SENSOR_SC;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			loadComplete();
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class SensorFloatAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return (int(value)/10).toString(10);
	}
	
	public function perform(field:IFormString):void	{	}
	public function change(value:Object):Object 	{ return value	}
	public function recover(value:Object):Object
	{
		return Number(value)*10;
	}
}