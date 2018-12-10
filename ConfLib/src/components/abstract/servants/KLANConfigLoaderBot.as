package components.abstract.servants
{
	import components.interfaces.IConfigLoaderBot;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class KLANConfigLoaderBot implements IConfigLoaderBot
	{
		private var counterIncrease:Function;
		
		public function KLANConfigLoaderBot(fCounterIncrease:Function)
		{
			counterIncrease = fCounterIncrease;
		}
		public function addImportant(a:Array):Array
		{
			return a;
		}
		public function checkImportant(navi:int):Boolean
		{
			return false;
		}
		public function doActions(a:Array, f:Function, fcancel:Function):Boolean
		{
			return false;
		}
		public function doBeforeRead(a:Array):void
		{
		}
		public function doImportant(f:Function):void
		{
			counterIncrease();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.LAN_SET_UP, f, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
		}
		public function doListIntegration(l:Array, selected:Array, f:IFormString):void
		{
		}
		public function doRefine(cmd:int, a:Array, str:int):void
		{
		}
		public function doSaveRefine(cmd:int):void
		{
		}
		public function fire(r:Request):void
		{
			RequestAssembler.getInstance().fireEvent(r);
		}
		public function interrupt():void
		{
		}
		public function needRestart():Boolean
		{
			return false;
		}
	}
}