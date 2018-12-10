package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class OptSysEvents extends OptionsBlock
	{
		public function OptSysEvents(txt:String,wid:int,struc:int, period:Boolean=false)
		{
			super();
			
			structureID = struc;
			var time_list:Array;
			var reg:String;
			
			if ( period ) {
				time_list = [ {label:loc("g_no"),data:"255:255"},
					{label:"04:00", data:"04:00"},
					{label:"08:00", data:"08:00"},
					{label:"12:00", data:"12:00"} ];
				reg = "^("+RegExpCollection.RE_0005to2359+"|255:255|"+loc("g_no")+")$";
			} else {
				time_list = [ {label:loc("g_no"),data:"255:255"},
					{label:"00:00", data:"00:00"},
					{label:"08:00", data:"08:00"},
					{label:"16:00", data:"16:00"} ];
				reg = "^("+RegExpCollection.RE_00to2359+"|255:255|"+loc("g_no")+")$";
			}
			
			operatingCMD = CMD.AUTOTEST;
			createUIElement( new FSShadow, operatingCMD, "", null, 1 );
			
			createUIElement( new FSComboBox, operatingCMD, txt,changeAutotest,2,time_list,"0-9:",5,
				new RegExp( reg ));
			attuneElement( wid,70, FSComboBox.F_COMBOBOX_TIME );
		}
		public function putRaw(re:Array):void
		{
			getField(operatingCMD,1).setCellInfo( String( re[0]) );
			if ( re[0] == 0 )
				getField(operatingCMD,2).setCellInfo( mergeIntoTime( 255,255 ) );
			else
				getField(operatingCMD,2).setCellInfo( mergeIntoTime( re[1], re[2] ) );
		}
		private function changeAutotest(target:IFormString):void
		{
			var info:String = String(getField(operatingCMD,2).getCellInfo());
			if( info == "255,255" ) {
				getField(operatingCMD,1).setCellInfo("0");
			} else
				getField(operatingCMD,1).setCellInfo("1");
			
			SavePerformer.remember(getStructure(),target);
		}
	}
}