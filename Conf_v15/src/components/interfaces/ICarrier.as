package components.interfaces
{
	public interface ICarrier
	{
		function set desired_x(n:int):void
		function set desired_y(n:int):void
		function get desired_x():int
		function get desired_y():int
		function start(dx:int, dy:int):void
		function slide():void
	}
}