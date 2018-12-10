package components.gui.visual.out
{
	import components.abstract.OutServantOn;
	import components.gui.fields.FSShadow;
	import components.static.CMD;

	public class LevelPanelOn extends LevelPanel
	{
		public function LevelPanelOn()
		{
			super();
			
			fields = new Array;
			for(var i:int; i<4; ++i) {
				fields.push( new FSShadow() );				
			}
			operationCMD = CMD.OUT_ON_LEVEL;
			
			servant = new OutServantOn;
		}
	}
}