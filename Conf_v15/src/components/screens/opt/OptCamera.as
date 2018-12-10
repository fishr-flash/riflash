package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.static.CMD;
	
	public class OptCamera extends OptionsBlock
	{
		public function OptCamera(s:int)
		{
			super();
			
			structureID = s;
			operatingCMD = CMD.VIDEO_CAMS;
			
			createUIElement( new FSCheckBox, operatingCMD, loc("cam_cam")+" "+structureID, null, 1 );
			attuneElement( 80 );
			
			createUIElement( new FSShadow, operatingCMD, "", null, 2 );
		}
		override public function putRawData(data:Array):void
		{
			distribute( data, operatingCMD );
		}
		public function set disabled(b:Boolean):void
		{
			getField(operatingCMD,1).disabled = b;
		}
	}
}