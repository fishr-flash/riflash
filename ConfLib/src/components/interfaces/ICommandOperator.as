package components.interfaces
{
	public interface ICommandOperator
	{	// используется в OfflineTaskManager для испольнения предусмотренных на приборе действий при загрузке комманды в прибор из файла
		function after(cmd:int, f:Function):Object	// выполнить функцию после посылки основной триггерной команды
	}
}