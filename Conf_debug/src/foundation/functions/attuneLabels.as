package foundation.functions
{
	import components.gui.SimpleTextField;
	import components.static.PAGE;
	
	import foundation.Founder;

	public function attuneLabels(limited:Boolean):void
	{
		var founder:Founder = Founder.app;
		
		var label:SimpleTextField = founder.pageLabel;
			
		if (limited) {
			label.setSimpleFormat("center", 0, 17 );
			label.x = PAGE.MAINMENU_WIDTH;
			label.width = PAGE.SECONDMENU_WIDTH;
			label.height = 50;
			if( label.numLines == 1 ) {
				label.y = 17;
				label.height = 43;
			} else {
				label.y = 10;
				label.height = 50;
			}		
		} else {
			label.setSimpleFormat("left", 0, 17 );
			label.x = PAGE.MAINMENU_WIDTH + PAGE.CONTENT_LEFT_SHIFT;
			label.width = 600;
			label.height = 50;
			label.y = 17;
			label.height = 43;
		}
	}
}