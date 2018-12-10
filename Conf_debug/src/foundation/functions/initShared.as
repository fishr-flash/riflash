package foundation.functions
{
	import components.abstract.functions.dtrace;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	
	import flash.net.SharedObject;
	
	import foundation.Founder;

	public function initShared(v:String):void
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
		
		/** FlashVars	*/
		SERVER.REMOTE_HOST = Founder.app.stage.loaderInfo.parameters["HOST"];
		SERVER.REMOTE_PORT = int(Founder.app.stage.loaderInfo.parameters["PORT"]);
		SERVER.REMOTE_TOKEN = Founder.app.stage.loaderInfo.parameters["TOKEN"];
		
		if( SERVER.REMOTE_HOST != null ) {
			dtrace( "SERVER.REMOTE_HOST: "+SERVER.REMOTE_HOST );
			dtrace( "SERVER.REMOTE_PORT: "+SERVER.REMOTE_PORT );
			dtrace( "SERVER.REMOTE_TOKEN: "+SERVER.REMOTE_TOKEN );
		}
	}
}