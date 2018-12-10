package components.screens.opt
{
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.IListItem;
	
	public class OptSms_line extends OptionListBlock implements IListItem
	{
		protected var title:String;
		protected var num_len:int;
		protected var groupset:Number;
		
		public function OptSms_line(_struct:int)
		{
			super();
			
			structureID = _struct;
			FLAG_VERTICAL_PLACEMENT = false;
			
			globalFocusGroup = getGroup();
			
			createUIElement( new FormString,operatingCMD , "",onChange,1,null,"0-9",num_len);
			attuneElement(50,NaN, FormString.F_ALIGN_CENTER | FormString.F_EDITABLE );
			(getLastElement() as FormString).fillBlank( getStructure().toString() );
			
			createUIElement( new FormString,operatingCMD , "",null,2,null,"",15).x = 55;
			attuneElement(250,NaN, FormString.F_EDITABLE | FormString.F_TRIM_SPACES );
		//	(getLastElement() as FormString).fillBlank( title + " "+ getStructure() );
		}
		override public function putRawData(re:Array):void
		{
			getField( operatingCMD, 1).setCellInfo( String(re[0]) );
			getField( operatingCMD, 2).setCellInfo( (re[1]).toString() );
			(getField(operatingCMD,2) as FormString).fillBlank(title + " "+ re[0]);
		}
		protected function getGroup():Number
		{
			return 0.1;
		}
		private function onChange(t:IFormString):void
		{
			(getField(operatingCMD,2) as FormString).fillBlank(title + " "+t.getCellInfo() as String);
			remember(t);
		}
		override public function call(value:Object, param:int):Boolean
		{
			getField(operatingCMD,1).setCellInfo(structureID);
			getField(operatingCMD,2).setCellInfo(title + " " + structureID);
			remember( getField(operatingCMD,1) );
			return true;
		}
	}
}