package components.screens.ui
{
	import components.basement.UI_BaseComponent;
	import components.interfaces.IResizeDependant;
	import components.static.PAGE;
	
	public class UIDebug extends UI_BaseComponent implements IResizeDependant
	{
		public function UIDebug()
		{
			super();
			
			initNavi();
			navi.setUp( openPage );
			navi.width = PAGE.SECONDMENU_WIDTH;
			navi.height = 200;
			navi.x = 200;
			navi.y = 200;
			
			var menu:Array = ["Параметры","Разделы","Зоны","Брелоки","Пользователи","Текст событий"];
			var len:int = menu.length;
			for(var i:int=0; i<len; ++i ) {
				navi.addButton( menu[i],i );
			}
			width = 500;
			height = 600
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
		private function openPage( num:Object ):void
		{
			
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			
			
		}
		
	}
}