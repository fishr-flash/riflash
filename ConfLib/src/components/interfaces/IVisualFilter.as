package components.interfaces
{	// нужен для изменения отображения текстовой строки, например сокращение длины
	// содержит в себе так же оригинал строки
	public interface IVisualFilter
	{
		function filter(s:String):String;
		function get source():String;
	}
}