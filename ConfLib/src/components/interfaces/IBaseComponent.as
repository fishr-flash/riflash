package components.interfaces
{
	import components.protocol.Package;

	public interface IBaseComponent
	{
		function put(p:Package):void;
		function open():void;
		function close():void;
		function set visible(value:Boolean):void;
		function get visible():Boolean;
	}
}