package foundation.functions
{
	import components.abstract.functions.dtrace;
	import components.abstract.servants.PartitionServant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.MISC;
	import components.static.PART_FUNCT;

	function addPartitionSuccess( p:Package ):void
	{
		if ( p.success ) {
			PartitionServant.PARTITION[1] = {"code":0x50, "section":1 }
			dtrace( "SERVER_PARTITION " + PartitionServant.PARTITION.toString() )
			RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT, null, 1, [1,PART_FUNCT.TAKEOFFGUARD,MISC.PARTITION_CREATE_DELAY] ));
		}
	}
}