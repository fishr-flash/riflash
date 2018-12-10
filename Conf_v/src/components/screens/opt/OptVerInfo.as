package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FormString;
	import components.screens.ui.UIVerInfo;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	import components.static.COLOR;
	
	/** Версия для Вояджеров	*/
	
	public class OptVerInfo extends OptionsBlock
	{
		public function OptVerInfo(_struc:int)
		{
			super();
			operatingCMD = CMD.VER_INFO1;
			
			drawSeparator(UIVersion.sepwidth);
			var a:int = globalY;
			
			yshift = 5;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("ui_gprs_simcard")+ (UIVerInfo.OnlyOneSim == true ? "" : " "+_struc),null,1);
			createUIElement( new FormString, 0, loc("ui_gprs_simcard_id"),null,2);
			createUIElement( new FormString, 0, loc("ui_gprs_operator"),null,3);
			
			globalX = UIVersion.shift;
			globalY = a;
			var clr:uint = COLOR.GREEN_DARK;
			globalY += 27; 
			createUIElement( new FormString, operatingCMD, "",null,5);
			(getLastElement() as FormString).setTextColor( clr );
			createUIElement( new FormString, operatingCMD, "",null,6);
			(getLastElement() as FormString).setTextColor( clr );
			attuneElement(250);
			
			complexHeight = globalY;
		}
		override public function putRawData(a:Array):void
		{
			getField( operatingCMD, 5 ).setCellInfo( String( a[4]));
			var param6:String = String( a[5] );
			var field:FormString = getField( operatingCMD, 6 ) as FormString; 
			if ( param6 == "" ) {
				param6 = loc("ui_gprs_no_gsm");
				field.setTextColor( COLOR.RED );
			} else
				field.setTextColor( COLOR.GREEN_DARK );
			
			field.setCellInfo( param6 );
		}
	}
}