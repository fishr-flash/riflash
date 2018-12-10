package components.abstract.servants
{
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.MISC;

	public class SystemCheckServant
	{
		private var fChooseMenuItem:Function;
		private var upId:int;
		private var failId:int;
		public function SystemCheckServant(chooseMenuItem:Function)
		{
			fChooseMenuItem = chooseMenuItem;
		}
		/** up - номер страницы в случае если система поднята, 
		 * 	fail - переход на страницу если системы нет */
		public function check(up:int, fail:int):void
		{
			upId = up; 
			failId = fail;
			if (SERVER.DUAL_DEVICE)	// если подключен двойной девайс, надо отправлять rf_system на нижний
				RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_SYSTEM, onSystem, 0, null, Request.NORMAL, Request.PARAM_NONE, SERVER.ADDRESS_BOTTOM));
			else
				RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_SYSTEM, onSystem ));
		}
		private function onSystem(p:Package):void
		{
			if (p.getStructure()[0] == 0)
				fChooseMenuItem(failId);
			else {
				MISC.SYSTEM_INACCESSIBLE = false;
				fChooseMenuItem(upId);
			}
		}
	}
}