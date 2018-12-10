package components.interfaces
{
	import components.protocol.Request;

	public interface IConfigLoaderBot
	{
		function checkImportant(navi:int):Boolean;	// проверяем, нет ли команд которые надо отправить в конец списка
		function addImportant(a:Array):Array;		// добавляем в конец списка все найденные важные сборки команд
		function doImportant(f:Function):void;		// выполнить какие либо действия после того как были отправлены команды на запись
		function doBeforeRead(a:Array):void;		// OfflineTaskManager.saveOnlineListToFile - произвести какие либо действия 
													// если была выбрана определенная страница, передается массив NAVI
		function fire(r:Request):void;				// при загрузки параметров запись в очеред команд производится через робота, чтобы была возможность управлять очередностью
		function doRefine(cmd:int, a:Array, str:int):void;
		function doActions(a:Array, f:Function, fcancel:Function):Boolean;
		function doSaveRefine(cmd:int):void;
		function doListIntegration(l:Array, selected:Array, f:IFormString):void;	// вызывается из управляющего UI, предназначен для изменения списка чекбокса налету
		function needRestart():Boolean;				// если по каким то причинам необходимо рестартнуть клиент после загрузки информации, функция возвращает true;
		function interrupt():void;					// если требуется полностью остановить работу конфиглоадера 
	}
}
