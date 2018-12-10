package components.interfaces
{
	public interface IOutServant
	{
		function edges(min:int, max:int):void
		function getMaxACP():int;
		function getMinACP():int;
		function getXlength():int;
		function getDefaults():Array;
		function calcAPCtoX(acp:int):int;
		function calcXtoACP(x:int):int;
		function getLabelXtoI(x:int):String;
	}
}