package components.protocol.statics
{
	public class CLIENT				// Version 1.0
	{
		public static var ADDRESS:int = 0xFE;	// может менять для серверов
		public static const OLD_ADDRESS:int = 0xFE;	// может менять для серверов, const, dont delete
		public static const MESSAGE_TERMINAL_ADDRESS:int = 0xFB;
		
		public static var NO_DELAY_PROGRESSION:Boolean = false;		// если требуется отключить прогрессию задержки перезапроса
		public static var FIRST_DELAY:int = 1000; // Это и задержка срабатывания таймера и делитель кол-ва раз срабатывания таймера проверки наличия ответа от сервера
		public static var TIMER_IDLE:int = 20000;	// const, dont delete
		public static var TIMER_IDLE_INCOMPLETE:int = 4000;
		public static const BIN2_RECEIVE_TIME:int = 30;
		public static const TIMER_PING:int = 20000;
		public static const TOTAL_RECONNECT_WHILE_INVALID_DATA:int= 5;
		public static const ENSURE_TRY_TIMES:int = 5;				// Если ALWAYS_TRY = false сколько раз пытаться переконнектиться
		public static var ALWAYS_TRY:Boolean = false;				// Если true будет всегда пытаться переконнектиться при уходе прибора в оффлайн
		
		public static var NOT_REQUEST_WHILE_IDLE:Boolean = false;	// Если требуется остановить запросы, пока прибор не отвечает
		
		public static function get DELAY_IDLE():int 
		{
			if (SERVER.REMOTE_TOKEN_PASSED || SERVER.isSlowConnection() || NO_DELAY_PROGRESSION ) // при работе по GPRS прогресивный таймер дает много сбоев
				return TIMER_IDLE;
			
			if (delay_idle < idle_connection*4) {
				delay_idle += idle_connection;
				return delay_idle;
			}
			
			return delay_idle;
		}
		public static function get DELAY_RESET():int
		{
			if (SERVER.REMOTE_TOKEN_PASSED || SERVER.isSlowConnection() || NO_DELAY_PROGRESSION) // при работе по GPRS прогресивный таймер дает много сбоев 
				return TIMER_IDLE_INCOMPLETE;
				
			delay_idle = 0;
			return idle_connection;
		}
		private static var delay_idle:int;
		private static const idle_connection:int = 5000;
		
		public static var TIMER_EVENT_SPAM:int = 2000;
		public static const TIMER_EVENT_DATE_SPAM:int = 1000;
		public static const HIS_DELETE_TIMEOUT:int = 50000;
		
		public static var PROTOCOL_BINARY:Boolean = true;
		public static var CONNECT_IP:String = "localhost";
		public static var CONNECT_PORT:int= 53462;
		
		public static var IS_WRITING_FIRMWARE:Boolean = false;
		public static var AUTOPAGE_WHILE_WRITING:int = 0;	//	Если загружается прошивка (или любая другая инофрмация, которая при реконнекте должна возобновиться)
			// выставляется каждый раз при старте и возобновлении, дабы не перепутать с реальной прошивкой
		public static var NO_CLONE_HUNT:Boolean = false; // true - протокол перестает проверять очередь на клоны, требуется при особо больших объемах отсылаемых команд (вычитывание всей истории) 
		public static var IS_WRITING_VIP_DATA:Boolean = false;
		public static var PROTOCOL_BlOCK_BINARY:Boolean = false;
		public static var JUMPER_BLOCK:Boolean = false;
		public static var HISTORY_LINES_PER_PAGE:int = 20;
		public static var AUTO_SELECT_PAGE:int = -1;
		public static var SKIP_HARDWARE_VERSION_CHECK:int = 0;
		//public static var USE_HTTP_FIFO_SERVANT:Boolean = true;		// использовать стандартную очеред запросов (если не используется паук от К7)
		
		public static var SYSTEM_LOADED:Boolean=false; 				// становится true при загрузке все системных переменных (GET_BUF_SIZE etc)
		public static var SKIP_SOFTWARE_VERSION_CHECK:int = 0;
		public static var SKIP_LEVEL_CHECK:int = 0;
		public static var DELETE_HISTORY:int = 1;
		public static var PREVENT_RESIZE:Boolean = false;
		public static var LANGUAGE:String;
		
		public static var AFTERUPDATE:Boolean = false;	// для К9, чтобы знать при дисконнекте - было ли это от прошивки или просто дискнуло
		public static var SIM_SLOT_COUNT:int; /// кол-во симкарт устанавливаемое по команда CMD.SIM_SLOT_COUNT
	}
}