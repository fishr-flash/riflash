package components.interfaces
{
	public interface IFormString
	{
		function setName( _name:String ):void;
		function getName():String;
		function setCellInfo( value:Object ):void;
		function getCellInfo():Object;
		function getId():int;
		function set visible(value:Boolean):void;
		function get visible():Boolean;
		function set cmd(value:int):void;
		function get cmd():int;
		function get param():int;
		function set param(value:int):void;
		function set disabled(value:Boolean):void;
		function get disabled():Boolean;
		function setUp( _fsend:Function, _id:int=-1 ):void;
		function set AUTOMATED_SAVE(value:Boolean):void;
		function isValid(_str:String=null):Boolean;
		function get valid():Boolean;
		function setAdapter(a:IDataAdapter):void;

		/// расширения добавлены 16.06.2017
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
		function get width():Number;
		function set width(value:Number):void;
		function get height():Number;
		function set height(value:Number):void;
		
	}
}