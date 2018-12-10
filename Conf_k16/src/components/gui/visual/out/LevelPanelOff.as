package components.gui.visual.out
{
	import components.abstract.OutServantOff;
	import components.gui.fields.FSShadow;
	import components.static.CMD;
	
	public class LevelPanelOff extends LevelPanel
	{
		public function LevelPanelOff()
		{
			super();
			
			fields = new Array;
			for(var i:int; i<4; ++i) {
				fields.push( new FSShadow() );				
			}
			operationCMD = CMD.OUT_OFF_LEVEL;
			servant = new OutServantOff;
		}
	}
}