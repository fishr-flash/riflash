package components.abstract.servants
{
	import components.interfaces.IConfigLoaderBot;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	
	public class K5ConfigLoaderBot implements IConfigLoaderBot
	{
		
		public function addImportant(a:Array):Array
		{
			return a;
		}
		
		public function checkImportant(navi:int):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function doActions(a:Array, f:Function, fcancel:Function):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function doBeforeRead(a:Array):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function doImportant(f:Function):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function doListIntegration(l:Array, selected:Array, f:IFormString):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function doRefine(cmd:int, a:Array, str:int):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function doSaveRefine(cmd:int):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function fire(r:Request):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function interrupt():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function needRestart():Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
	}
}