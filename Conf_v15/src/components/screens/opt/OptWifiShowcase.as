package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.SpritePictureButton;
	import components.static.COLOR;
	import components.system.Library;
	
	public class OptWifiShowcase extends OptionsBlock
	{
		private var ttitle:SimpleTextField;
		
		public function OptWifiShowcase()
		{
			super();
			
			ttitle = new SimpleTextField("RITM_Industrial", 200, COLOR.MENU_ITEM_BLUE);
			ttitle.setSimpleFormat( "left", 0, 18, true );
			ttitle.y = 10;
			addChild( ttitle );
			
			globalY = 45;
			
			drawSeparator( 300 );
			
			var shift:int = 120;
			
			addui( new FSSimple, 0, loc("wifi_encryption"), null, 1 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE);
			
			drawSeparator( 300 );
			
			addui( new FSSimple, 1, loc("wifi_bssid"), null, 1 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE );
			addui( new FSSimple, 1, loc("wifi_speed"), null, 2 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE );
			
			drawSeparator( 300 );
			
			addui( new FSCheckBox, 2, loc("wifi_do_connect"), null, 1 );
			attuneElement( shift );
			addui( new FSSimple, 2, loc("g_pass"), null, 2 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE );
			
			var v:SpritePictureButton = new SpritePictureButton(Library.cButtonGear);
			addChild( v );
			v.setUp( "", onClick, 1 );
			v.y = globalY;
			
			v = new SpritePictureButton(Library.cButtonMinus);
			addChild( v );
			v.setUp( "", onClick, 2 );
			v.y = globalY;
			v.x = 34;
			
			globalY += 42;
			
			drawSeparator( 300 );
			
			addui( new FSSimple, 3, loc("lan_ipadr"), null, 1 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE );
			addui( new FSSimple, 3, loc("wifi_gate"), null, 2 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE );
			addui( new FSSimple, 3, loc("wifi_dns")+" 1", null, 3 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE );
			addui( new FSSimple, 3, loc("wifi_dns")+" 2", null, 4 );
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE );
		}
		private function onClick(value:int):void
		{
			if (value == 1) {
				
			} else {
				
			}
		}
	}
}