package components.events
{
	import flash.events.Event;
	
	public class SystemEvents extends Event
	{
		public static const onChangeOnline:String = "onChangeOnlineStatus";
		public static const onCommandsLoaded:String = "onCommandsLoaded";
		public static const onBlockNavigation:String = "onBlockNavigation";
		public static const onBlockNavigationSilent:String = "onBlockNavigationSilent"; 	// блокируеются меню без визуального изменения
		public static const onNeedClearQueue:String = "onNeedClearQueue";
		public static const pageLoadLComplete:String = "pageLoadLComplete";			// когда страница прогрузилась и получила все свои запросы
		public static const menuReset:String = "menuReset";							// когда нужно сбросить выделение меню и привести его в рабочее состояние
		public static const onStatusBarChanged:String = "onStatusBarChanged";		// когда Warning получает изменения
		public static const onPageSavedOffline:String = "onPageSavedOffline";		// когда происходит изменение в оффлайне, 
															//	приходит номер страницы по Navi и есть ли эта страницы или удалена
		public static const onPageUpdated:String = "onPageUpdated";		// когда происходит обновление страницы
		
		public var serviceObject:Object;
		
		public function SystemEvents( type:String, eventObject:Object=null ) 
		{
			serviceObject = eventObject;
			super( type );
		}
		public function isBlock():Boolean 			//	onBlockNavigation, onBlockNavigationSilent
		{
			return serviceObject["isBlock"];
		}
		public function isConneted():Boolean 		//	onChangeOnlineStatus
		{
			return serviceObject["isConnected"];
		}
		public function getText():String 			//	onStatusBarChanged
		{
			return serviceObject["getText"];
		}
		public function getType():int 				//	onStatusBarChanged
		{
			return serviceObject["getType"];
		}
		public function getStatus():int 			//	onStatusBarChanged
		{	
			return serviceObject["getStatus"];
		}
		public function getPage():int 				//	onPageSavedOffline
		{	
			return serviceObject["getPage"];
		}
		public function exist():Boolean				//	onPageSavedOffline
		{	
			return serviceObject["exist"];
		}
	}
}