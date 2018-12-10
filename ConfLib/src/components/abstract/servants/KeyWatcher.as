package components.abstract.servants
{
	import flash.events.KeyboardEvent;
	
	import components.interfaces.IKeyDownUser;
	import components.interfaces.IKeyUser;

	public class KeyWatcher
	{
		private static var users:Vector.<IKeyUser>;
		private static var usersdwn:Vector.<IKeyDownUser>;

		private static var keyPressed:int;
		
		public static function add( u:IKeyUser ):void
		{
			if (!users) {
				users = new Vector.<IKeyUser>;
			} else {
				var len:int = users.length;
				for (var i:int=0; i<len; ++i) {
					if ( users[i] == u ) {
						return;
					}
				}
			}
			users.push( u );
		}
		public static function remove( u:IKeyUser ):void
		{
			if (users) {
				var len:int = users.length;
				for (var i:int=0; i<len; ++i) {
					if ( users[i] == u ) {
						users.splice(i,1);
						break;
					}
				}
				if (users.length == 0)
					users = null;
			}
		}
		public function onKeyUp(ev:KeyboardEvent):void
		{
			if (users) {
				var len:int = users.length;
				for (var i:int=0; i<len; ++i) {
					users[i].onKeyUp(ev);
				}
			}
			keyPressed = 0;
		}
		public static function addDwnUser( u:IKeyUser ):void
		{
			if (!usersdwn) {
				usersdwn = new Vector.<IKeyDownUser>;
			} else {
				var len:int = usersdwn.length;
				for (var i:int=0; i<len; ++i) {
					if ( usersdwn[i] == u ) {
						return;
					}
				}
			}
			usersdwn.push( u );
		}
		public function onKeyDown(ev:KeyboardEvent):void
		{
			if (usersdwn) {
				var len:int = usersdwn.length;
				for (var i:int=0; i<len; ++i) {
					usersdwn[i].onKeyDown(ev);
				}
			}
			keyPressed = ev.keyCode
		}
		public static function isPressed(key:int):Boolean
		{
			return keyPressed == key;
		}
	}
}