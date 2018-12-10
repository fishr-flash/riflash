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
	
	public class UIVSensorsShort extends UI_BaseComponent
	{
		public function UIVSensorsShort()
		{
			super();
			
			globalY += 10;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSComboBox, 0, loc("sensor_move"), callLogic, 1, [{label:loc("g_enabled_m"),data:1},{label:loc("g_disabled_m"),data:0}] );
			attuneElement(580, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			FLAG_SAVABLE = true;
			
			createUIElement( new FSSimple, CMD.VR_VIBRO_SENSOR, loc("sensor_detect_move"), null, 1, null,
				"0-9", 3,new RegExp(RegExpCollection.REF_1to120) );
			attuneElement( 620, 60);
			
			createUIElement( new FSSimple, CMD.VR_VIBRO_SENSOR, 
				loc("sensor_detect_stop"), 
				null, 2,null, "0-9",3,new RegExp(RegExpCollection.REF_1to600) );
			attuneElement( 620, 60, FSSimple.F_MULTYLINE );
			
			starterCMD = CMD.VR_VIBRO_SENSOR;
		}
		override public function put(p:Package):void
		{
			LOADING = true;
			distribute( p.getStructure(), p.cmd );
			callLogic();
			LOADING = false;
			loadComplete();
		}
		private function callLogic():void
		{
			var f:IFormString = getField(CMD.VR_VIBRO_SENSOR,1);
			var cb:IFormString = getField(0,1);
			
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
					getField(0,1).setCellInfo(0);
			} else {
				f.disabled = false;
				(f as FSSimple).rule = new RegExp(RegExpCollection.REF_1to120);
				getField(CMD.VR_VIBRO_SENSOR,2).disabled = false;
				if (!LOADING)
					f.setCellInfo(5);
				else
					getField(0,1).setCellInfo(1);
			}
			if (!LOADING)
				SavePerformer.remember(1,f);
		}
	}
}