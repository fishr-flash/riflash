package components.interfaces
{
	import flash.display.InteractiveObject;

	public interface IFocusable
	{
		function getFocusField():InteractiveObject;
		function getFocusables():Object;
		function isPartOf(io:InteractiveObject):Boolean;
		function getType():int;
		function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void;
		function focusSelect():void;
		function set focusgroup(value:Number):void;
		function set focusorder(value:Number):void;
		function get focusorder():Number;
		function set focusable(b:Boolean):void;
		function get focusable():Boolean;
	}
}