package components.interfaces
{
	public interface IListItem
	{
		function selectVertical(posx:int):void
		function select(value:Boolean):void
		function set setTestUniqueFunction(value:Function):void
		function getUniqueData(param:int):String
		function isRemovable():Boolean
	}
}