package foundation.functions
{
	import components.abstract.Warning;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;

	public function requestVerInfo(p:Package=null):void
	{
		if (p)
			Warning.show("Токен получен, запрашивается версия прибора...",Warning.TYPE_SUCCESS,Warning.STATUS_DEVICE);
		else
			Warning.show("Запрашивается версия прибора...",Warning.TYPE_SUCCESS,Warning.STATUS_DEVICE);
		RequestAssembler.getInstance().fireEvent( new Request( CMD.VER_INFO, processVersion,0,null,Request.SYSTEM ));
	}	
}