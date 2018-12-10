package components.gui.visual.out
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSShadow;
	import components.interfaces.IOutServant;
	import components.static.CMD;

	public class LevelPanelWire extends LevelPanel
	{
		public function LevelPanelWire(srv:IOutServant)
		{
			super();
			
			fields = new Array;
			for(var i:int; i<5; ++i) {
				fields.push( new FSShadow() );				
			}
			operationCMD = CMD.K5_ADC_TRESH;
			servant = srv;
			measure_unit = loc("measure_resist_sk");
			
		}
	}
}