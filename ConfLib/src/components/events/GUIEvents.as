package components.events
{
	import flash.events.Event;
	
	public class GUIEvents extends Event
	{
		public static const onNeedScreenBlock:String = "onNeedScreenBlock"; // требуется поставить блок на экран и выстреливается этот эвент
		public static const onNeedChangeLabel:String = "onNeedChangeLabel" // компоненту требуется сменить его лейбл формат {labelnum:1-2, label:"name" или 3 + процент загрузки}
// События для каналов связи
		public static const onGPRSOnline:String = "onGPRSOnline";		// когда меняется GPRS онлайн/оффлайн
		public static const onChangeObject:String = "onChangeObject";	// кода меняется объект (7 параметр)
// События для OptList
		public static const onNeedPage:String = "onNeedPage";	// запрос отсутствующей страницы
// События для Tree когда происходит ресайз дерева внешний компонент его ловит и отрисовывает правильную высоту
		public static const onResize:String = "onResize";
// fires OptList when add remove or canel lines success
		public static const onEventFiredSuccess:String = "onEventFiredSuccess";
// флаг активируется когда на сервер ушла команда RF_FUNCT		
		public static const onFlag_WAIT_FOR_STATE:String = "onFlag_WAIT_FOR_STATE";
// сенсор получает некорректную информацию и стартует ивент чтобы ее обновили		
		public static const onSensorGotIncorrectInfo:String = "onSensorGotIncorrectInfo"; 
// Радиосистема, когда создается		
		public static const onSystemChange:String = "onSystemChange";
// Когда видео разворачивается в полный или нормальный размер оно скидыввает свой айди
		public static const onHDsize:String = "onHDsize";
		public static const onCIFsize:String = "onCIFsize";
// Когда меняется обьект на вояджерах		
		public static const onVoyagerObjectChange:String = "onVoyagerObjectChange";
		/* Abstract Events	*/
		public static var ON_RESIZE:String = "onResize";
		
		public static const EVOKE_BLOCK:String = "EVOKE_BLOCK";
		public static const EVOKE_FREE:String = "EVOKE_FREE";
		public static const EVOKE_READY:String = "EVOKE_READY";
		public static const EVOKE_CONNECTION_ERROR:String = "EVOKE_CONNECTION_ERROR";
		public static const EVOKE_CHANGE_HEIGHT:String = "EVOKE_CHANGE_HEIGHT";
		public static const EVOKE_TOGLE:String = "EVOKE_TOGLE";
		public static const EVOKE_CHANGE:String = "EVOKE_CHANGE";
		public static const EVOKE_ERROR:String = "EVOKE_ERROR";
		public static const EVOKE_CHANGE_PARAM:String = "EVOKE_CHANGE_PARAM";
//		public static const EVOKE_CHANGE_HEIGHT:String = "EVOKE_NEED_STATE";
//		public static const EVOKE_CHANGE_HEIGHT:String = "EVOKE_NO_STATE";
		public static const MAINMENU_APPEARANCE:String = "MAINMENU_APPEARANCE";
		// когда на странице настройки смс-оповещений Вояджеров в комбобоксе выбирается другой тип оповещения
		public static const CHANGE_SMS_TYPE:String = "changeSmsType";  
		
		public static const CLICK_GET_PHOTO_SHOT:String = "clickGetPhotoShot";
		public static const RECEPTION_PHOTO_COMPLETE:String = "receptionPhotoComplete";
		public static const CHANGE_RFMODULE_TEMPLATE:String = "changeRfmoduleTemplate";
		public static const SWITCH_GPRS_ADD:String = "switchGprsAdd";
		public static const SELECT_ZONE_AS_KEY:String = "selectZoneAsKey";
		
		public var serviceObject:Object;
		

		public function GUIEvents( type:String, eventObject:Object=null ) 
		{
			serviceObject = eventObject;
			super( type );
		}
		public function getFlagStatus():Boolean 		//	onFlag_WAIT_FOR_STATE
		{
			return serviceObject["getFlagStatus"];		
		}
		public function isLoaded():Boolean
		{
			return serviceObject["isLoaded"];
		}
		public function getScreenMode():int
		{
			if ( !serviceObject )
				return -1;
			return serviceObject["getScreenMode"];
		}
		public function getScreenMsg():String
		{
			return serviceObject["getScreenMsg"];
		}
		public function isGPRSOnline():Boolean
		{
			return serviceObject["isGPRSOnline"];
		}
		public function isCall():Boolean
		{
			return serviceObject["isCall"];
		}
		public function getData():Object
		{
			return serviceObject["getData"];
		}
		public function getActionCode():int				//	onEventFiredSuccess
		{
			return serviceObject["getActionCode"];
		}
		public function getStructure():int				//	onEventFiredSuccess
		{
			return serviceObject["getStructure"];
		}
		public function isSystemUp():Boolean 			// onSystemChange
		{
			return serviceObject["isSystemUp"];
		}
		public function getSensorInfo():Array			// onSensorGotIncorrectInfo 
		{
			return serviceObject["getSensorInfo"];
		}
		public function getSensorId():int 				// onSensorGotIncorrectInfo
		{
			return serviceObject["getSensorId"];
		}
		public function getLink():Function				// onNeedScreenBlock
		{
			return serviceObject["getLink"];
		}
		public function getButtonId():int				// MAINMENU_APPEARANCE
		{
			return serviceObject["getButtonId"];
		}
		public function getButtonStatus():int			// MAINMENU_APPEARANCE
		{
			return serviceObject["getButtonStatus"];
		}
		public function getButtonArgs():Object				// onNeedScreenBlock
		{
			return serviceObject["getButtonArgs"];
		}
	}
}