package components.gui.visual
{
	import components.abstract.servants.TaskManager;
	import components.interfaces.ILoadAni;
	import components.static.GuiLib;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class GUILoading extends Sprite implements ILoadAni
	{
		private var progress:MovieClip;
		private const length:int = 36;
		private var percent:int=0;
		private var goingto:int;
		private var executeOnFinish:Function;
		private var callback:Function;
		
		public function GUILoading()
		{
			super();
			
			progress = new GuiLib.load_numeric;
			progress.stop();
			addChild( progress );
		}
		public function goto(p:int):void
		{
			goingto = p;
		}
		public function execWhenFinish(f:Function):void
		{
			executeOnFinish = f;
		}
		public function halt():void
		{
			progress.removeEventListener(Event.ENTER_FRAME, onFrame );
			visible = false;
		}
		public function link(f:Function):void
		{
			callback = f;
			f(this);
		}
		private function onFrame(e:Event):void
		{
			var result:int;
			if( percent >= goingto ) {
				percent = goingto;
				result = int(percent/100*length);
			} else {
				result = int(++percent/100*length);
				if (percent>100)
					percent=100;
			}
			progress.gotoAndStop( result );
			progress.txt.text = percent+"/100%";
			if (percent == 100 ) {
				progress.removeEventListener(Event.ENTER_FRAME, onFrame );
				TaskManager.callLater( close, 250 );
			}
		}
		private function close():void
		{
			visible = false;
			callback(this);
			if (executeOnFinish != null)
				executeOnFinish();
		}
		override public function set visible(value:Boolean):void
		{
			if (!visible && value)
				progress.addEventListener(Event.ENTER_FRAME, onFrame );
			if (visible && !value)
				progress.removeEventListener(Event.ENTER_FRAME, onFrame );
			super.visible = value;
		}
	}
}