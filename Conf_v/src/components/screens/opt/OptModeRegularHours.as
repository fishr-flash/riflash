package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.static.CMD;

	public class OptModeRegularHours extends OptModeRoot
	{
		public function OptModeRegularHours(s:int)
		{
			super(s);
			
			var xplace:int = 610;
			var fieldShift:int = 600;
			
			/*var xplace:int = 500;
			var fieldShift:int = 180;*/
			
			FLAG_VERTICAL_PLACEMENT = false;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("vem_update_ger_with_interval")+":", null, 1 );
			attuneElement( fieldShift );
			FLAG_SAVABLE = true;
			
			createUIElement( new FSShadow, CMD.VR_WORKMODE_REGULAR, "", null, 1 );
			
			createUIElement( new FSShadow, CMD.VR_WORKMODE_REGULAR, "", null, 2 );
			//createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 2, null, "0-9", 2 ).x = xplace - 63;
			//attuneElement( 30, NaN, FormString.F_EDITABLE );
			//createUIElement( new FormString, 0, "сут.", null, CMD.VR_WORKMODE_REGULAR ).x = xplace - 32;
			//attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 3, null, "0-9", 2, re_hours ).x = xplace;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			createUIElement( new FormString, 0, loc("time_hour_s"), null, CMD.VR_WORKMODE_REGULAR+1 ).x = xplace + 32;
			attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 4, null, "0-9", 2, re_minutes  ).x = xplace + 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			FLAG_VERTICAL_PLACEMENT = true;
			createUIElement( new FormString, 0, loc("time_min_s"), null, CMD.VR_WORKMODE_REGULAR+2 ).x = xplace + 96;
			attuneElement( 30 );
			
			this.complexHeight = globalY;
		}
		override public function rename(arg:Object):void
		{
			getField( 0,1 ).setName( String(arg) );
		}
		override public function putAssemblege(a:Array):void
		{
			LOADING = true;
			
			compare(CMD.VR_WORKMODE_SET, a);
			
			compare(CMD.VR_WORKMODE_ENGINE_START, a);
			compare(CMD.VR_WORKMODE_ENGINE_RUNS, a );
			compare(CMD.VR_WORKMODE_ENGINE_STOP, a );
			
			compare(CMD.VR_WORKMODE_START, a );
			compare(CMD.VR_WORKMODE_MOVE, a );
			compare(CMD.VR_WORKMODE_STOP, a );
			compare(CMD.VR_WORKMODE_PARK, a );
			// Подменяет дефол и в исходном массиве и отсылает на прибор
			compareSoft(CMD.VR_WORKMODE_REGULAR, a, [ new RegExp(/3/),new RegExp(/0/),re_hours,re_minutes]);
			
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID);
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID+12);
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID+24);
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID+36);
			
			distribute( a[CMD.VR_WORKMODE_REGULAR][structureID-1], CMD.VR_WORKMODE_REGULAR );
			
			LOADING = false;
		}
	}
}