package components.abstract.servants
{
	import mx.core.UIComponent;
	
	import components.gui.Widget;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.static.CMD;

	public class WidgetMaster
	{
		private static var instance:WidgetMaster;
		public static function access():WidgetMaster 
		{
			if ( instance == null )	instance = new WidgetMaster;
			return instance;
		}
		
		private var widgets:Object;
		private var area:UIComponent;
		
		public function WidgetMaster()
		{
			widgets = new Object;
		}
		public function registerArea(ui:UIComponent):void
		{
			area = ui;
		}
		public function registerWidget(cmd:int, w:IWidget):void
		{
			widgets[cmd] = w;
		}
		public function unregisterWidget(cmd:int):void
		{
			delete widgets[cmd];
		}
		//Надо дописать скины виджетов вывод информации в них и плейсмент на экране.
		public function process(p:Package):void
		{
			
			switch(p.cmd) {
				case CMD.V2D_MESSAGE_DRIVER:	// подтверждение от водителя
					if ( widgets[p.cmd] ) {
						(widgets[p.cmd] as IWidget).put(p);						
					}
					break;
				case CMD.CONNECT_SERVER:
					if ( !widgets[p.cmd] ) {
						var w:Widget = construct(p.cmd);
						widgets[p.cmd] = w;
						// чтобы сработало позиционирование по верхнему правому краю
						w.x = 10000;
						w.y = 0;
						area.addChild( w );
					}
					(widgets[p.cmd] as Widget).put(p);
					break;
				default:
					if (widgets[p.cmd] is IWidget)
						(widgets[p.cmd] as IWidget).put(p);
			//		dtrace( "Пришел необрабатываемая команда по протоколу 2: " + OPERATOR.getSchema(p.cmd).Name + " ("+p.cmd+")" );
					break;
			}
		}
/**	MISC		***/
		private function construct(cmd:int):Widget
		{	// сборка нужного виджета по команде
			return new Widget(cmd);
		}
	}
}