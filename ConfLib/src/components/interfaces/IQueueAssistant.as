package components.interfaces
{
	public interface IQueueAssistant
	{	// служит для отправки посылки из очереди по конкретному адресу с необходимым количеством аргументов
		function send(o:Object):void
	}
}