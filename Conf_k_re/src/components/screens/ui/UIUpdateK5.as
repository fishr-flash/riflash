package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.gui.Balloon;

	public class UIUpdateK5 extends UIUpdate
	{
		public function UIUpdateK5()
		{
			super();
		}
		override public function open():void
		{
			super.open();
			
			Balloon.access().showResizable("sys_attention",loc("update_k5_note1")+"\r"+ loc("update_k5_note2") +"\r"+loc("update_k5_note3"),14);
		}
	}
}