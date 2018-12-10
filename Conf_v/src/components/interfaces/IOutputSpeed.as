package components.interfaces
{
	public interface IOutputSpeed
	{
		function get type():int;
		function putRawData(a:Array):void;
		function set enableZoomer(value:Boolean):void;
		function get enableZoomer():Boolean;
		function set extend(value:Boolean):void;
		function getStructure():int;
	}
}