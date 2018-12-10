package components.interfaces
{
	import components.protocol.Package;
	
	import flash.utils.ByteArray;

	public interface IRequestAssembler
	{
		function initSocket( _request:ByteArray ):void;
		function delegateAssembler(post:Vector.<Package>, packetNumber:int=0):void;
		function onError(err:int):void;
		function activeHandler(h:IActiveErrorHandler=null):void;
		function online():Boolean;
		function getClientAddress():int;
	}
}