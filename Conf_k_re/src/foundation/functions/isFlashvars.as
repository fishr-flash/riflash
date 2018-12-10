package foundation.functions
{
	import components.abstract.functions.dtrace;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	
	import foundation.Founder;

	public function isFlashvars():Boolean
	{
		var a:Object =  Founder.app.stage.loaderInfo.parameters;
		
		/** FlashVars	*/
		SERVER.REMOTE_HOST =  Founder.app.stage.loaderInfo.parameters["HOST"];
		SERVER.REMOTE_PORT =  int(Founder.app.stage.loaderInfo.parameters["PORT"]);
		SERVER.REMOTE_TOKEN =  Founder.app.stage.loaderInfo.parameters["TOKEN"];
		var adr:int =  int(Founder.app.stage.loaderInfo.parameters["ADDRESS"]);
		CLIENT.LANGUAGE = Founder.app.stage.loaderInfo.parameters["LANG"];
		
		if (adr > 0)
			CLIENT.ADDRESS = adr;
		if (Founder.app.stage.loaderInfo.parameters["SRVUPD"] is String)
			SERVER.UPDATE_SERVER_ADR = Founder.app.stage.loaderInfo.parameters["SRVUPD"];
		
		if( SERVER.REMOTE_HOST != null ) {
			dtrace( "SERVER.REMOTE_HOST: "+SERVER.REMOTE_HOST );
			dtrace( "SERVER.REMOTE_PORT: "+SERVER.REMOTE_PORT );
			dtrace( "SERVER.REMOTE_TOKEN: "+SERVER.REMOTE_TOKEN );
			dtrace( "SERVER.UPDATE_SERVER_ADR: "+SERVER.UPDATE_SERVER_ADR );
			dtrace( "CLIENT.ADDRESS: "+CLIENT.ADDRESS );
		}
		return CLIENT.LANGUAGE is String;
	}
}