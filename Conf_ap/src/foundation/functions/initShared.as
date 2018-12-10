package foundation.functions
{
	import components.abstract.SharedObjectBot;
	import components.abstract.functions.dtrace;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import foundation.Founder;

	public function initShared(v:String):void
	{
		SharedObjectBot.register(v);
		
		/** FlashVars	*/
		SERVER.REMOTE_HOST = Founder.app.stage.loaderInfo.parameters["HOST"];
		SERVER.REMOTE_PORT = int(Founder.app.stage.loaderInfo.parameters["PORT"]);
		SERVER.REMOTE_TOKEN = Founder.app.stage.loaderInfo.parameters["TOKEN"];
		var adr:int = int(Founder.app.stage.loaderInfo.parameters["ADDRESS"]);
		if (adr > 0)
			CLIENT.ADDRESS = adr;
		
		if( SERVER.REMOTE_HOST != null ) {
			dtrace( "SERVER.REMOTE_HOST: "+SERVER.REMOTE_HOST );
			dtrace( "SERVER.REMOTE_PORT: "+SERVER.REMOTE_PORT );
			dtrace( "SERVER.REMOTE_TOKEN: "+SERVER.REMOTE_TOKEN );
			dtrace( "CLIENT.ADDRESS: "+CLIENT.ADDRESS );
		}
	}
}