package foundation.functions
{
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	import components.static.PAGE;
	
	import foundation.Founder;

	public function addLabels(container:UIComponent):void
	{
		var founder:Founder = Founder.app;

		var main:SimpleTextField = new SimpleTextField("", PAGE.MAINMENU_WIDTH, COLOR.MENU_BLUE);
		container.addChild( main );
		main.setSimpleFormat("center", 0, 17 );
		main.x = 0;
		main.y = 17;
		main.height = 30;
		main.text = loc("g_settings")
		founder.mainLabel = main;
		
		var page:SimpleTextField = new SimpleTextField("", 800, COLOR.MENU_BLUE);
		container.addChild( page );
		page.setSimpleFormat("center", 0, 17 );
		page.x = PAGE.MAINMENU_WIDTH;
		page.y = 10;
		page.width = PAGE.SECONDMENU_WIDTH;
		page.height = 50;
		//page.border = true;
		page.text = "";
		founder.pageLabel = page;
		
		
		var second:SimpleTextField = new SimpleTextField("", 800, COLOR.MENU_BLUE);
		container.addChild( second );
		second.setSimpleFormat("left", 0, 17 );
		second.x = PAGE.MAINMENU_WIDTH + PAGE.SECONDMENU_WIDTH + 10;
		second.y = 17;
		second.height = 30;
		second.text = "";
		founder.pageLabelSecond = second;
	}
}