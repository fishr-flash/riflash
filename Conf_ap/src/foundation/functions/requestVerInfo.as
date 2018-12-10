package foundation.functions
{
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;

	public function requestVerInfo(p:Package=null):void
	{
		RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_v_VER_INFO, processVersion,0,null,Request.SYSTEM ));
	}	
}