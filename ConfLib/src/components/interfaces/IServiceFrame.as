package components.interfaces
{
	import components.protocol.Package;

	public interface IServiceFrame
	{
		function close():void;
		function init():void;
		function block(b:Boolean):void;
		function put(p:Package):void;
		function set visible(value:Boolean):void;
		function set y(value:Number):void;
		function getLoadSequence():Array;
		function get height():Number;
		function get width():Number;
		function isLast():void;
	}
}