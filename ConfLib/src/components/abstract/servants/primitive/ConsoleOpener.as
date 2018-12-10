package components.abstract.servants.primitive
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.core.FlexGlobals;
	
	import components.abstract.servants.KeyWatcher;
	import components.gui.DevConsole;
	import components.interfaces.IKeyDownUser;
	import components.interfaces.IKeyUser;
	import components.static.KEYS;

	public class ConsoleOpener implements IKeyUser, IKeyDownUser
	{
		private var zpressed:Boolean=false;
		private var xpressed:Boolean=false;
		private var anykey:Boolean=false;
		private var stage:Stage;
		
		public function ConsoleOpener()
		{
			KeyWatcher.add(this);
			KeyWatcher.addDwnUser(this);
			
			stage = FlexGlobals.topLevelApplication.stage as Stage;
			stage.addEventListener( Event.DEACTIVATE, onDeactivate );
		}
		
		public function onKeyDown(ev:KeyboardEvent):void
		{
			switch(ev.keyCode) {
				case KEYS.KEY_X:
					xpressed = true;
					break;
				case KEYS.Key_Z:
					zpressed = true;
					break;
				case KEYS.Alt:
				case KEYS.AltReal:
				case KEYS.Shift:
				case KEYS.Control:
					break;
				default:
					anykey = true;
					break;
			}
		}
		
		public function onKeyUp(ev:KeyboardEvent):void
		{
			if (ev.altKey && ev.shiftKey && ev.ctrlKey && xpressed && zpressed && !anykey) {
				DevConsole.inst.visible = !DevConsole.inst.visible;
				xpressed = false;
				zpressed = false;
			}
			
			switch(ev.keyCode) {
				case KEYS.KEY_X:
					xpressed = false;
					break;
				case KEYS.Key_Z:
					zpressed = false;
					break;
				default:
					anykey = false;
					break;
			}
		}
		
		private function onDeactivate(e:Event):void
		{
			zpressed = false;
			xpressed = false;
			anykey = false;
		}
	}
}