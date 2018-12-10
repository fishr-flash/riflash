package components.interfaces
{
	import components.protocol.Package;

	public interface IRfDevice
	{
		function setState(n:int, p:Package=null):void;
		function isAddable():Boolean;
		function isRemovable():Boolean;
		function getStructure():int;
	}
}