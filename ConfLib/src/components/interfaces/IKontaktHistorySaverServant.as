package components.interfaces
{
	public interface IKontaktHistorySaverServant
	{
		function start(value:int, page:int, maxWrittenStructures:int, hardMaxStructures:int, lastStructure:int):void;
		function halt():void;
		function getFieldData():Array;
		function get READING():Boolean;
	}
}