package components.abstract
{
	import flash.net.SharedObject;
	
	import components.abstract.functions.dtrace;
	import components.protocol.statics.CLIENT;
	import components.static.DS;
	import components.static.MISC;

	public class SharedObjectBot
	{
		public static const HISTORY_VISIBLE_PARAMS:String  = "history_visible_params";
		public static const HISTORY_ORDER_PARAMS:String  = "history_order_params";
		
		public function SharedObjectBot()
		{
		}
		public static function register(v:String):void
		{
			var so:SharedObject = SharedObject.getLocal( "RITM_"+v, "/" );
			
			if ( so.data["ip"] != null )
				CLIENT.CONNECT_IP = so.data["ip"];
			
			if ( so.data["port"] != null )
				CLIENT.CONNECT_PORT = so.data["port"];
			
			if ( so.data["history_line_per_page"] != null )
				CLIENT.HISTORY_LINES_PER_PAGE = so.data["history_line_per_page"];
			
			if ( so.data["global_spam_timer"] != null )
				CLIENT.TIMER_EVENT_SPAM = int(so.data["global_spam_timer"])*100;
			
			if ( so.data["auto_select_page"] != null )
				CLIENT.AUTO_SELECT_PAGE = so.data["auto_select_page"];
			
			if ( so.data["skip_hardware_version_check"] != null )
				CLIENT.SKIP_HARDWARE_VERSION_CHECK= so.data["skip_hardware_version_check"];
			if ( so.data["skip_software_version_check"] != null )
				CLIENT.SKIP_SOFTWARE_VERSION_CHECK = so.data["skip_software_version_check"];
			if ( so.data["skip_level_check"] != null )
				CLIENT.SKIP_LEVEL_CHECK = so.data["skip_level_check"];
			
			if ( so.data["delete_history"] != null )
				CLIENT.DELETE_HISTORY = so.data["delete_history"];
			
			/** RELEASE CLIENT SHARED OBJECTS */
			if (DS.isVoyager() ) {
				HistoryDataProvider.installParams(so.data[HISTORY_VISIBLE_PARAMS]);
			}
		}
		public static function write(key:String, value:Object):void
		{
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data[key] = value;
			try {
				so.flush();
			} catch(error:Error) {
				dtrace("Error: flush shared object  at SharedObjectBot");
			}
		}
		public static function get(key:String):Object
		{
			var op:Object = "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH;
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			return so.data[key];
		}
	}
}