package components.interfaces
{
	public interface IDataEngine
	{ // интерфейм перевода команд в текстовый вид, разных форматы
		function save(navi:Array):String;
		function getExtension():String;
	}
}