package components.screens.opt
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.basement.OptionsBlock;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.screens.ui.UIOutput;
	import components.static.CMD;
	
	import flash.events.Event;
	
	public class OptInputSpeedExcess extends OptionsBlock
	{
		private var zoomer:Boolean;
		private var bEnable:TextButton;
		private var go:GroupOperator;
		
		public function OptInputSpeedExcess(str:int)
		{
			super();
			
			operatingCMD = CMD.VR_SPEED_ALARM;
			structureID = str;
			globalX = 0;
			globalY = 0;
			
			var cellwidth:int = 60;
			
			addui( new FormString, 0, "Превышение " + str, null, 1 );
			
			globalX = 18;
			
			addui( new FormString, operatingCMD, "", null, 1 , null, "0-9", 5, new RegExp(RegExpCollection.REF_0to65535));
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			go = new GroupOperator;
			go.add("1", addui( new FormString, operatingCMD, "", null, 3, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			go.add("1", addui( new FormString, operatingCMD, "", null, 4, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			go.add("1", addui( new FormString, operatingCMD, "", null, 5, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			go.add("1", addui( new FormString, operatingCMD, "", null, 2, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			go.add("1", addui( new FormString, operatingCMD, "", null, 6 , null, "0-9", 5, new RegExp(RegExpCollection.REF_0to65535) ) );
			attuneElement( cellwidth, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			
			bEnable = new TextButton;
			addChild( bEnable );
			bEnable.setUp("Включить", onClick );
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
			bEnable.setName( zoomer ? "Выключить" : "Включить" );
		}
		public function get enableZoomer():Boolean
		{
			return zoomer;
		}
		private function onClick():void
		{
			zoomer = !zoomer;
			bEnable.setName( zoomer ? "Выключить" : "Включить" );
			this.dispatchEvent( new Event(UIOutput.EVENT_SPEED_EXCESS_TEST));
		}
	}
}