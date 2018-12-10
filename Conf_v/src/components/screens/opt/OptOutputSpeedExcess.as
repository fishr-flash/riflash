package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.adapter.Float1Adapter;
	import components.basement.OptionsBlock;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IOutputSpeed;
	import components.screens.ui.UIOutput;
	import components.static.CMD;
	
	public class OptOutputSpeedExcess extends OptionsBlock implements IOutputSpeed
	{
		private var zoomer:Boolean;
		private var bEnable:TextButton;
		private var go:GroupOperator;
		
		public function OptOutputSpeedExcess(str:int, needtitle:Boolean)
		{
			super();
			
			operatingCMD = CMD.VR_SPEED_ALARM;
			structureID = str;
			globalX = 0;
			globalY = 0;
			
			var cellwidth:int = 60;

			if( needtitle ) // название
				addui( new FormString, 0, loc("output_speed_km"), null, 1 );
			else // отбивка
				addui( new FormString, 0, "", null, 1 );
			//addui( new FormString, 0, loc("input_exceed")+" " + str, null, 1 );
			
			globalX = 18;
			
			addui( new FormString, operatingCMD, "", null, 1 , null, "0-9", 5, new RegExp(RegExpCollection.REF_0to65535));
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			
			//addui( new FormString, 0, "", null, 1 );
			
			
			go = new GroupOperator;
			go.add("1", drawSeparator(85+14) );
			
			go.add("1", addui( new FormString, operatingCMD, "", null, 3, null, "0-9.", 4, new RegExp(RegExpCollection.REF_0to255_FLOAT1) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			getLastElement().setAdapter(new Float1Adapter );
			go.add("1", addui( new FormString, operatingCMD, "", null, 4, null, "0-9.", 4, new RegExp(RegExpCollection.REF_0to255_FLOAT1) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			getLastElement().setAdapter(new Float1Adapter );
			go.add("1", addui( new FormString, operatingCMD, "", null, 5, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			
			go.add("1", addui( new FormString, operatingCMD, "", null, 2, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			go.add("1", addui( new FormString, operatingCMD, "", null, 6 , null, "0-9", 5, new RegExp(RegExpCollection.REF_0to65535) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			
			bEnable = new TextButton;
			addChild( bEnable );
			bEnable.setUp(loc("g_switchon"), onClick );
			go.add( "1", bEnable );
			bEnable.y = globalY;
			bEnable.x = 15;
			
		}
		override public function putRawData(a:Array):void
		{
			refreshCells( operatingCMD, false, structureID );
			distribute( a, operatingCMD );
		}
		public function set extend(value:Boolean):void
		{
			go.visible( "1", value );
		}
		public function set enableZoomer(value:Boolean):void
		{
			zoomer = value;
			bEnable.setName( zoomer ? loc("g_switchoff") : loc("g_switchon") );
		}
		public function get enableZoomer():Boolean
		{
			return zoomer;
		}
		public function get type():int 
		{
			return OptOutput.OPT_TYPE_NORMAL;
		}
		private function onClick():void
		{
			zoomer = !zoomer;
			bEnable.setName( zoomer ? loc("g_switchoff") : loc("g_switchon") );
			this.dispatchEvent( new Event(UIOutput.EVENT_SPEED_EXCESS_TEST));
		}
	}
}