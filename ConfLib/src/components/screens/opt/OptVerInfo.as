package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FormString;
	import components.gui.visual.Battery;
	import components.gui.visual.SIMSignal;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class OptVerInfo extends OptionsBlock
	{
		private var signal:SIMSignal;
		
		
		public function OptVerInfo(_struc:int)
		{
			super();
			operatingCMD = CMD.VER_INFO1;
			
			globalXSep -= 20;
			drawSeparator(600);
			var a:int = globalY;
			
			yshift = 0;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("ui_gprs_simcard")+" "+_struc,null,1);
			createUIElement( new FormString, 0, loc("ui_gprs_simcard_id"),null,2);
			createUIElement( new FormString, 0, loc("ui_gprs_operator"),null,3);
			createUIElement( new FormString, 0, loc("ui_gprs_signal_level"),null,4);
			
			globalX = UIVersion.shift;
			globalY = a;
			var clr:uint = COLOR.GREEN_DARK;
			globalY += 23; 
			createUIElement( new FormString, operatingCMD, "",null,5);
			(getLastElement() as FormString).setTextColor( clr );
			createUIElement( new FormString, operatingCMD, "",null,6);
			(getLastElement() as FormString).setTextColor( clr );
			
			signal = new SIMSignal;
			addChild( signal );
			signal.x = UIVersion.shift;
			signal.y = a + 87 - 15;
			
			
			complexHeight = globalY+27+7;
		}
		override public function putRawData(a:Array):void
		{
			getField( operatingCMD, 5 ).setCellInfo( loc(a[4]) );
			var param6:String = String( loc(a[5]) );
			var field:FormString = getField( operatingCMD, 6 ) as FormString; 
			if ( param6 == "" ) {
				param6 = loc("g_unidentified");
				field.setTextColor( COLOR.RED );
			} else
				field.setTextColor( COLOR.GREEN_DARK );
			
			field.setCellInfo( param6 );
		}
		override public function putState(re:Array):void
		{
			signal.put(re[0]);
		}
	}
}