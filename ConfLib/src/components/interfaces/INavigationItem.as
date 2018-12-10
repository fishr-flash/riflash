package components.interfaces
{
	public interface INavigationItem
	{
		function getId():int;
		function select(value:Boolean):void;
		function undraw():void;
		function set disabled(value:Boolean):void;
		function get disabled():Boolean;
		function getHeight():int;
		function drawPermanent(b:Boolean=true):void;
	}
}