package foundation.functions
{
	import flash.display.DisplayObjectContainer;
	
	import components.abstract.HoldConnectBot;
	import components.abstract.functions.dtrace;
	import components.abstract.servants.RFSensorServant;
	import components.abstract.sysservants.PartitionServant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.CONST;
	
	import foundation.Founder;

	public function processSystem( p:Package ):void
	{
		var founder:Founder = Founder.app;
		
		if ( !p.error ) {
			switch( p.cmd )	{
				case CMD.GET_BUF_SIZE:
					SERVER.BUF_SIZE_SEND = p.getStructure(1)[1];
					SERVER.BUF_SIZE_RECEIVE = p.getStructure(1)[0];
					dtrace( "SERVER_BUF_SIZE_SEND " + SERVER.BUF_SIZE_SEND ) 
					dtrace( "SERVER_BUF_SIZE_RECEIVE " + SERVER.BUF_SIZE_RECEIVE )
					break;
				case CMD.GET_MAX_IND_CMDS:
					if ( int(p.getStructure(1)) > 0 ) {
						SERVER.MAX_IND_CMDS = int(p.getStructure(1));
					} else SERVER.MAX_IND_CMDS = 0xFF;
					dtrace( "SERVER_MAX_IND_CMDS " + SERVER.MAX_IND_CMDS )
					
					if(CONST.NEED_PARTITION)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.PARTITION,processSystem,0,null,Request.SYSTEM ));
					if(CONST.NEED_SYSTEM)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SYSTEM,processSystem,0,null,Request.SYSTEM ));
					if(CONST.NEED_VER_INFO1)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.VER_INFO1,processSystem,0,null,Request.SYSTEM ));
					
					if (!CONST.NEED_PARTITION && !CONST.NEED_SYSTEM && !CONST.NEED_VER_INFO1)
						founder.initMenuSelection();
					
					break;
				case CMD.PARTITION:
					var len:int = p.length;
					PartitionServant.PARTITION = new Object;
					PartitionServant.MAX_PARTITIONS = len;
					var noPartitions:Boolean=true;
					for(var i:int; i<len+1; ++i) {
						if ( p.getStructure(i) is Array && p.getStructure(i)[0] != 0 && p.getStructure(i)[0] != undefined ) {
							PartitionServant.PARTITION[i] = {"code":p.getStructure(i)[1], "section":p.getStructure(i)[0] };
							noPartitions = false;
						}
					}
					if ( noPartitions )
						RequestAssembler.getInstance().fireEvent( new Request( CMD.PARTITION, addPartitionSuccess, 1, [1,0x50,MISC.PARTITION_CREATE_DELAY], Request.SYSTEM ));
					
					var txt:String = "SERVER_PARTITION:";
					for(var key:String in PartitionServant.PARTITION) {
						txt += "\r    part num: "+PartitionServant.PARTITION[key]["section"] + ", code: 0x" + int(PartitionServant.PARTITION[key]["code"]).toString(16); 
					}
					
					dtrace( txt )
					
					if ( !CONST.NEED_SYSTEM && !CONST.NEED_VER_INFO1 )
						founder.initMenuSelection();
					break;
				case CMD.RF_SYSTEM:
					MISC.SYSTEM_INACCESSIBLE = Boolean( p.getStructure()[0] != 1 );
					dtrace( "CLIENT_SYSTEM_INACCESSIBLE " + MISC.SYSTEM_INACCESSIBLE )
					RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM = p.getStructure()[4];
					dtrace( "CLIENT_SYSTEM_PERIOD_OF_TRANSMISSION_ALARM " + RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM )
					
					if ( !CONST.NEED_VER_INFO1 )
						founder.initMenuSelection();
					
					
					break;
				case CMD.VER_INFO1:
					
					SERVER.CONNECTION_TYPE = p.getStructure()[0]; 
					founder.initMenuSelection();
					break;
			}
		}
	}
}