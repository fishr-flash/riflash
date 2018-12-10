package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.page.DeviceRestarter;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	
	public class UIEnergySave extends UI_BaseComponent
	{
		private var field1:IFormString;
		
		public function UIEnergySave()
		{
			super();
			FLAG_SAVABLE = false;
			createUIElement( new FSCheckBox, 0, loc("en_disable_hull_diods"), onBitParam, 1 );
			attuneElement( 520 );
			FLAG_SAVABLE = true;
			field1 = addui( new FSShadow, CMD.POWER_SAVE, "", null, 1 );
			createUIElement( new FSCheckBox, CMD.POWER_SAVE, 
				loc("en_disable_signal_receive"), null, 2 );
			attuneElement( 520, NaN, FSCheckBox.F_MULTYLINE );
			addui( new FSShadow, CMD.POWER_SAVE, "", null, 3 );
			FLAG_SAVABLE = false;
			createUIElement( new FSCheckBox, 0, 
				loc("en_always_on_when_got_power"), onBitParam, 2 );
			attuneElement( 520, NaN, FSCheckBox.F_MULTYLINE );
			if (DS.release < 6 && !MISC.COPY_DEBUG)
				getLastElement().visible = false;
			FLAG_SAVABLE = true;
			starterCMD = CMD.POWER_SAVE;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), CMD.POWER_SAVE );
			var bit:int = p.getStructure()[0];
			var bit1:int = (bit & 1);
			var bit2:int = (bit & 2);
			
			getField(0,1).setCellInfo( bit1 );
			getField(0,2).setCellInfo( bit2 > 1?1:0 );
			loadComplete();
		}
		private function onBitParam():void
		{
			var bit:int = getField(0,1).getCellInfo() == 1 ? 1:0;
			bit += getField(0,2).getCellInfo() == 1 ? 2:0;
			field1.setCellInfo(bit);
			remember(field1);
		}
	}
}