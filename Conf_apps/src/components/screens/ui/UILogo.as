package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.fields.FormString;
	import components.protocol.statics.CLIENT;
	import components.screens.page.LogoLoader;
	import components.static.NAVI;
	
	public class UILogo extends UI_BaseComponent
	{
		private var logoLoader:LogoLoader;
		private var g:GroupOperator;
		private var h:int;
		
		public function UILogo()
		{
			super();
			
			logoLoader = new LogoLoader;
			addChild( logoLoader );
			logoLoader.y = globalY;
			logoLoader.x = globalX;
			
			//g = logoLoader.height;
			
			g = new GroupOperator;
			
			g.add( "1", drawSeparator() );
			
			addui( new FormString, 0, loc("lcdkey_disable_usb_to_look_at_logo"), null, 1 );
			attuneElement( 400 );
			g.add( "1", getLastElement() );
		}
		override public function open():void
		{
			super.open();
			logoLoader.init();
			loadComplete();
			
			g.movey("1", 70);
			
			logoLoader.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			
			if (CLIENT.AUTOPAGE_WHILE_WRITING == NAVI.LOGO)
				onChangeHeight(null);
		}
		override public function close():void
		{
			logoLoader.removeEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
		}
		private function onChangeHeight(e:Event):void
		{
			g.movey("1", logoLoader.height + 60);
		}
	}
}