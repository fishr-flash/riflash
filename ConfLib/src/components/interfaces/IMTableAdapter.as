package components.interfaces
{
	import mx.controls.dataGridClasses.DataGridColumn;

	public interface IMTableAdapter
	{
		function get isCellRenderer():Boolean;
		function get isAdapt():Boolean;
		function get isRowColor():Boolean;
		function adapt(a:Array, n:int):Array;	// distribute data to cells
		function getRowColor(rowIndex:int, sourceColor:uint):uint;
		function assignCellRenderer(c:DataGridColumn):void;
	}
}