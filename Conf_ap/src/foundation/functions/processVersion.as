package foundation.functions
{
	import components.abstract.functions.dtrace;
	import components.abstract.servants.SensorLoader;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.CONST;
	
	import foundation.Founder;
	
	public function processVersion( p:Package ):void
	{
		var founder:Founder = Founder.app;
		MISC.VERSION_MISMATCH = false;

		if (p && CONST.PRESET_NUM == 1) { 	//	K1
			SERVER.VER_FULL = p.getStructure(1)[0];
			
			String(CONST.RELEASE)
			
			//if(p.getStructure(1)[0] == String(CONST.RELEASE) || CLIENT.SKIP_SOFTWARE_VERSION_CHECK ) {
			if( isValidVersion(p.getStructure(1)[0]) || CLIENT.SKIP_SOFTWARE_VERSION_CHECK ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_sp_STOP_PANEL, null,0,null,Request.SYSTEM ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_CA_PARTITION_ALARM_COUNT, null,0,["00"],Request.SYSTEM ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_T_WIRE_TYPE, null,0,[1],Request.SYSTEM ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_p_PARTITION, null,1,["111001000"],Request.SYSTEM ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_z_ZONES, loadSystemCommands,0,null,Request.SYSTEM ));
			} else
				SocketProcessor.getInstance().disconnectFinal();
			return;
		}
		
		if (p && CONST.PRESET_NUM == 2)	{	// Sensors
			if(String(p.getValidStructure()[0]).length < 9)
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_v_VER_INFO, processVersion,0,null,Request.SYSTEM ));
			else
				SensorLoader.access().start(p,founder);
			return;
		}
		
		dtrace( "SERVER.VER_FULL <b>" + SERVER.VER_FULL+"</b>"+ " CLIENT_TARGET_DEVICE <b>"+CONST.VERSION+"</b>" );
		
		founder.menu( getMenu() );
		founder.load();
		
		function isValidVersion(v:String):Boolean
		{
			var a:Array = CONST.RELEASE.split("_and_");
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if (v == a[i])
					return true;
			}
			return false;
		}
	}
}