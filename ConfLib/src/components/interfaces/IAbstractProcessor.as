package components.interfaces
{
	public interface IAbstractProcessor
	{
		function process():void;
		function get solved():Boolean;
		function set callback(f:Function):void; 
	}
}