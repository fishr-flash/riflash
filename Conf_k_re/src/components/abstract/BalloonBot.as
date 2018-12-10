package components.abstract
{
	import components.gui.Balloon;
	import components.interfaces.ISaveListener;
	import components.system.SavePerformer;

	public class BalloonBot implements ISaveListener
	{
		private static var inst:BalloonBot;
		public static function access():BalloonBot
		{
			if(!inst)
				inst = new BalloonBot;
			return inst;
		}
		
		private var sleep:Boolean=true;
		
		public function BalloonBot() 
		{
			
		}
		public function open():void
		{
			if (!sleep)
				show();
			else {
				SavePerformer.addObserver(this);				
			}
		}
		public function saveEvent(e:int):void
		{
			if (e == SavePerformer.EVENT_COMPLETE) {
				sleep = false;
				show();
			}
		}
		private function show():void
		{
			Balloon.access().show( "sys_attention","misc_need_restart_to_apply" );
		}
	}
}