package components.interfaces
{
	public interface IPositioner
	{
		function getWidth():int;
		function getHeight():int;
		function set x(value:Number):void;
		function get x():Number;
		function set y(value:Number):void;
		function get y():Number;
	}
}