package components.interfaces
{
	public interface ITask
	{
		function kill():void;
		function repeat():void;
		function stop():void;
		function running():Boolean;
		function set delay(value:Number):void;
	}
}