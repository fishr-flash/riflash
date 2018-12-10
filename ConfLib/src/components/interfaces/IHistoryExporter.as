package components.interfaces
{
	import flash.utils.ByteArray;

	public interface IHistoryExporter
	{
		function compile(header:Array, book:Object):ByteArray;
	}
}