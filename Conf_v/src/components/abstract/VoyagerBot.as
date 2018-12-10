package components.abstract
{
	import components.system.CONST;

	public final class VoyagerBot
	{
		public static var TIME_ZONE:int=4;
		/** меняет часы соответвенно выбранной часовой зоне */
		public static function changeTimeZone(tz:int):void
		{
			TIME_ZONE = tz;
		}
		
		private static var inst:VoyagerBot;
		public static function getInstance():VoyagerBot
		{
			if (!inst)
				inst = new VoyagerBot;
			return inst;
		}
		
		// Проверяет подключенную версию вояджера и возвраащет есть ли двигатель или нет
		public static function isEngine():Boolean
		{
			if ( CONST.PRESET_NUM == 1 
				|| CONST.PRESET_NUM == 2 
				|| CONST.PRESET_NUM == 4 
				|| CONST.PRESET_NUM == 7 
				|| CONST.PRESET_NUM == 8)
				return true;
			return false;
		}
		public static function getHistoryDeleteTimeOut():int
		{
			return 380000;
		}
	}
}