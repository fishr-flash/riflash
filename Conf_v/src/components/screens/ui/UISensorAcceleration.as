package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.resources.SensorMenuMeasures;
	import components.static.CMD;
	
	public class UISensorAcceleration extends UI_BaseComponent
	{
		public function UISensorAcceleration(group:int)
		{
			super();
			
			toplevel = false;
			globalY += 10;
			globalFocusGroup = group;
			
			createUIElement( new FSCheckBox, CMD.VR_SENSOR_SA, loc("ui_acc_evoke_acceleration"), null, 1 );
			attuneElement( SensorMenuMeasures.MEASURE_SHIFT_CHECKBOX );
			
			createUIElement( new FSSimple, CMD.VR_SENSOR_SA, loc("ui_acc_evoke_acceleration_higher"), null, 2, null,
				"0-9", 2,new RegExp(RegExpCollection.REF_1to10) );
			attuneElement( 620-68, 40);
			
			starterCMD = CMD.VR_SENSOR_SA;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			loadComplete();
		}
	}
}