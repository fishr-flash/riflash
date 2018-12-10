package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSRadioGroup;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIDisplay extends UI_BaseComponent
	{
		public function UIDisplay()
		{
			super();
			
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("g_disabled_m"), selected:false, id:0 },
				{label:loc("g_always_on_m"), selected:false, id:1 },
				{label:loc("lcdkey_on_when_powered"), selected:false, id:2 }
				], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = globalX;
			fsRgroup.width = 530;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.LCD_BACKLIGHT, 1	);
			
			starterCMD = CMD.LCD_BACKLIGHT;
		}
		
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			loadComplete();
		}
	}
}