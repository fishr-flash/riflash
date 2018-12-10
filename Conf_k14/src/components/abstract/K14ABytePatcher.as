package components.abstract
{
	import components.gui.PopUp;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;

	public class K14ABytePatcher
	{
		public function K14ABytePatcher()
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.SET_DEV_HARD_VER, null, 2,[0xff]));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.REBOOT, null, 1,[1]));
			PopUp.getInstance().construct(PopUp.wrapHeader(LOC.loc("sys_attention")),PopUp.wrapMessage(LOC.loc("version_updated_restart_client")));
			PopUp.getInstance().open();
		}
	}
}