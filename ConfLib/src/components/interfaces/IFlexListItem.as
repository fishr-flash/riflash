package components.interfaces
{
	import components.protocol.Package;

	public interface IFlexListItem
	{
		function put(p:Package):void;		// loads data
		function change(p:Package):void;	// loads data and evoke save
		function putRaw(value:Object):void;
		function kill():void;
		function set y(value:Number):void;
		function get height():Number;
		function extract():Array;			// get data from target
		function getStructure():int;
		function set selectLine(b:Boolean):void;
		function isSelected():Boolean;
		function get disabled():Boolean;
		function set disabled( value:Boolean ):void;
	}
}