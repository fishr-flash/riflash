package components.gui.fields.lowlevel.interfaces
{
	public interface IComboBoxItem
	{
		function set height(value:Number):void;
		function set width(value:Number):void;
		function set y(value:Number):void;
		function get width():Number;
		function set enabled(b:Boolean):void;
		function set data(obj:Object):void;
	}
}