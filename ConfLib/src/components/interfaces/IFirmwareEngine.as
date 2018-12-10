package components.interfaces
{
	import flash.utils.ByteArray;

	public interface IFirmwareEngine
	{
		function put(b:ByteArray):void;
		function write():void;
		function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void;
		function get percload():int;
		function set sendAddress(adr:int):void;
	}
}