package components.abstract.servants
{
	import components.gui.PopUp;
	import components.interfaces.IConfigLoaderBot;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.page.OfflineDataLoader;
	import components.static.CMD;
	import components.static.NAVI;

	public class VConfigLoaderBot implements IConfigLoaderBot 
	{

		
		public function addImportant(a:Array):Array
		{
			return a;
		}
		public function checkImportant(n:int):Boolean
		{	// проверяем, нет ли команд которые надо отправить в конец списка
			return false;
		}
		public function doBeforeRead(a:Array):void	{}
		public function doImportant(f:Function):void	{}
		public function interrupt():void	{}
		public function doActions(a:Array,f:Function, fcancel:Function):Boolean
		{
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if (int(a[i]) == NAVI.HISTORY_STRUCTURE) {
					var p:PopUp = PopUp.getInstance();
					p.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("his_delete_after_load_hisstructure"),
						PopUp.BUTTON_YES | PopUp.BUTTON_NO, [f,fcancel]);
					p.open();			
					return true;
				}
			}
			return false;
		}
		
		public function doRefine(cmd:int, a:Array, str:int):void
		{
			
			
			switch(cmd) {
				case CMD.CONNECT_SERVER:
					if (str < 3)
						a[0] = OfflineDataLoader.CODE_OBJECT;
					else if( str == 3 )
					{
						a[ 0 ] = OfflineDataLoader.CODE_OBJECT_EGTS & 0xFFFF;
					}else{
					
						a[ 0 ] = OfflineDataLoader.CODE_OBJECT_EGTS >> 16;
					}
						
						
					break;
			}
		}
		public function doSaveRefine(cmd:int):void {}
		public function doListIntegration(l:Array, selected:Array, f:IFormString):void	{	}
		public function needRestart():Boolean
		{	// если по каким то причинам необходимо рестартнуть клиент после загрузки информации, функция возвращает true;
			return false;
		}
		public function fire(r:Request):void
		{
			
			RequestAssembler.getInstance().fireEvent(r);
		}
	}
}