package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class UISensorMove extends UI_BaseComponent
	{
		public function UISensorMove(group:int)
		{
			super();

			toplevel = false;
			globalY += 10;
			globalFocusGroup = group;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSComboBox, 1, loc("sensor_move"), callLogicSensor, 1, [{label:loc("g_enabled_m"),data:1},{label:loc("g_disabled_m"),data:0}] );
			attuneElement(580, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			FLAG_SAVABLE = true;
			
			createUIElement( new FSSimple, CMD.VR_VIBRO_SENSOR, loc("sensor_detect_move"), null, 1, null,
				"0-9", 3,new RegExp(RegExpCollection.REF_1to120) );
			attuneElement( 620, 60);
			
			createUIElement( new FSSimple, CMD.VR_VIBRO_SENSOR, 
				loc("sensor_detect_stop"), 
				null, 2,null, "0-9",5,new RegExp(RegExpCollection.REF_1to600) );
			attuneElement( 620, 60, FSSimple.F_MULTYLINE );
			
			starterCMD = CMD.VR_VIBRO_SENSOR;
		}
		override public function open():void
		{
			super.open();
			
			getField(CMD.VR_VIBRO_SENSOR,1).disabled = true;
			getField(CMD.VR_VIBRO_SENSOR,2).disabled = true;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			
			LOADING = true;
			callLogicSensor();
			LOADING = false;
			loadComplete();
		}
		private function callLogicSensor():void
		{
			var f:IFormString = getField(CMD.VR_VIBRO_SENSOR,1);
			var cb:IFormString = getField(1,1);
			
			var off:Boolean = false;
			if (LOADING)
				off = Boolean(int(f.getCellInfo()) == 0);
			else
				off = Boolean(int(cb.getCellInfo()) == 0);
			
			if ( off ) {
				(f as FSSimple).rule = null;
				f.setCellInfo( "" );
				f.disabled = true;
				getField(CMD.VR_VIBRO_SENSOR,2).disabled = true;
				if (LOADING)
					cb.setCellInfo(0);
			} else {
				f.disabled = false;
				(f as FSSimple).rule = new RegExp(RegExpCollection.REF_1to120);
				getField(CMD.VR_VIBRO_SENSOR,2).disabled = false;
				if (!LOADING)
					f.setCellInfo(5);
				else
					cb.setCellInfo(1);
			}
			if (!LOADING)
				SavePerformer.remember(1,f);
		}
	}
}