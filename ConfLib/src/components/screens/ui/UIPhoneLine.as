package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIPhoneLine extends UI_BaseComponent
	{
		public function UIPhoneLine()
		{
			super();
			
			createUIElement( new FSCheckBox, CMD.TELCO_CONTROL_LINE, loc("ui_phone_control"), callSwitcher, 1 );
			attuneElement( 210 );
			globalY += 36;
			
			var txt:String = loc("ui_phone_note");
			var list:Array = [{data:"00:05",label:"00:05"},{data:"00:10",label:"00:10"},
					{data:"00:30",label:"00:30"},{data:"01:00",label:"01:00"}];
			
			createUIElement( new FSComboBox, CMD.TELCO_CONTROL_LINE, txt, null, 2, 
				list, "0-9:", 5, new RegExp(RegExpCollection.REF_TIME_0000to9959) );
			attuneElement( 400,NaN,FSComboBox.F_COMBOBOX_TIME );
			
			height = 150;
			
			starterCMD = CMD.TELCO_CONTROL_LINE;
		}
		override public function put(p:Package):void
		{
			getField( p.cmd, 1 ).setCellInfo( String( p.getStructure()[0] ) );
			getField( p.cmd, 2 ).setCellInfo( mergeIntoTime( p.getStructure()[1], p.getStructure()[2] ) );
			getField( p.cmd, 2 ).disabled = Boolean( p.getStructure()[0] == 0 );
			loadComplete();
		}
		private function callSwitcher(t:IFormString):void
		{
			var b:Boolean = Boolean( int(t.getCellInfo()) == 1 );
			getField(CMD.TELCO_CONTROL_LINE, 2).disabled = !b;
			remember( t );
		}
	}
}