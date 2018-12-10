package components.screens.opt
{
	import components.abstract.ClientArrays;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.IListItem;
	import components.static.CMD;
	
	public class OptSms_text extends OptionListBlock implements IListItem
	{
		private var field1:FSComboBox;
		private var field2:FormString;
		public function OptSms_text(_struct:int)
		{
			super();
			
			structureID = _struct;
			FLAG_VERTICAL_PLACEMENT = false;
			operatingCMD = CMD.SMS_TEXT;
			
			globalFocusGroup = 3050;
			
			field1 = createUIElement( new FSComboBox,operatingCMD , "",change,1, CIDServant.getEvent() ) as FSComboBox;
			attuneElement(300,NaN,  FSComboBox.F_RETURNS_HEXDATA | FSComboBox.F_COMBOBOX_NOTEDITABLE);
			field1.disabled = true;
			
			field2 = createUIElement( new FormString,operatingCMD , "",null,2,null,"",50) as FormString;
			attuneElement(300,NaN, FormString.F_EDITABLE );
			field2.x = 305;
			field2.fillBlank(loc("g_no"));
		}
		override public function putRawData(a:Array):void
		{
			field1.setCellInfo( (a[0]).toString(16) );
			field2.setCellInfo( (a[1]).toString() );
			setFill();
		}
		private function setFill():void
		{
			var txt:String = String( field1.getLabel() );
			if (txt != loc("g_no"))
				field2.fillBlank( txt.slice(6,56)); 
			else
				field2.fillBlank(txt);
		}
		private function change(target:IFormString):void
		{
			setFill();
			remember( field1 );
		}
		override public function call(value:Object, param:int):Boolean
		{
			if (!value)
				return false;
			if (int(value) < 0) {
				
				if ( field1.getCellInfo() != "0" &&
					field2.getCellInfo() != ""	) {
					remember( field2 );
				}
			//	field1.setCellInfo( "0" );
				field2.setCellInfo( "" );
				return true;
			}
			
			if( int(value) != int(field1.getCellInfo()) )
				field1.setCellInfo( value.toString(16) );

			var txt:String = String( field1.getLabel() );
			var fill:String;
			
			if (txt != loc("g_no"))
				fill = txt.slice(6,56); 
			else
				fill = txt;
				
			if( field2.getCellInfo().toString() != fill ) {
				field2.setCellInfo( fill );
				remember( field2 );
			}
			
			setFill();
			
			return true;
		}
	}
}