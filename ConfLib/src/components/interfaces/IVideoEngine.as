package components.interfaces
{
	import flash.utils.ByteArray;

	public interface IVideoEngine
	{
		function read(b:ByteArray):Boolean;
		function resize(w:int, h:int):void;
		function reset():void;
		function set visible(b:Boolean):void;
	}
}