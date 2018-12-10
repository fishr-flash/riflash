package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.protocol.statics.CLIENT;
	import components.abstract.IconLoader;
	import components.static.NAVI;
	
	public class UIRedrawIcons extends UI_BaseComponent
	{
		
		private var iconLoader:IconLoader;
		private var g:GroupOperator;
		private var h:int;
		
		public function UIRedrawIcons()
		{
			super();
			
			iconLoader = new IconLoader;
			addChild( iconLoader );
			iconLoader.y = globalY;
			iconLoader.x = globalX;
			iconLoader.setNewId( 3 );
			
			
			//g = logoLoader.height;
			
			g = new GroupOperator;
			
			///FIXME: Отладочный метод. Временный.
			addui( new FSSimple, 0, loc("options_objnum"), changeNum, 1, null, "0-9", 4 );
			attuneElement( 400 );
			getLastElement().y += 20;
			getLastElement().setCellInfo( "3" );
			g.add( "1", getLastElement() );
			
			g.add( "1", drawSeparator() );
			
			addui( new FormString, 0, loc("lcdkey_disable_usb_to_look_at_logo"), null, 1 );
			attuneElement( 400 );
			
			
			
			g.add( "1", getLastElement() );
		}
		
		///FIXME: Отладочный метод. Временный.
		private function changeNum( me:FormEmpty ):void
		{
			
			
			iconLoader.setNewId( int( me.getCellInfo() ) );
		}
		override public function open():void
		{
			super.open();
			iconLoader.init();
			loadComplete();
			
			g.movey("1", 70);
			
			iconLoader.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			
			if (CLIENT.AUTOPAGE_WHILE_WRITING == NAVI.LOGO)
				onChangeHeight(null);
		}
		override public function close():void
		{
			iconLoader.removeEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
		}
		private function onChangeHeight(e:Event):void
		{
			g.movey("1", iconLoader.height + 60);
		}
	}
}