package components.interfaces
{
	import components.gui.fields.FormEmpty;

	public interface IValidator
	{
		function isValid(f:FormEmpty):Boolean;
		function added():void;		// вызывается при setCellInfo для узнавания момента когда добавится информация во все поля
		function reset():void;		// сбррос собранной информации, при выходе с страницы
	}
}