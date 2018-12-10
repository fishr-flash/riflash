package foundation.functions
{
	import components.protocol.statics.SERVER;
	import components.static.MISC;
	import components.system.CONST;

	public function getMenu():Array
	{
		if ( SERVER.HARDWARE_VER == null && CONST.DEBUG )	// null обычно значит эмулятор
			CONST.MENU = CONST.MENU_TOP;
		if (SERVER.HARDWARE_VER.charAt(0) == "1")
			CONST.MENU = CONST.MENU_DOWN;
		else
			CONST.MENU = CONST.MENU_TOP;
		
		MISC.COPY_MENU = CONST.MENU;
		
		if (!CONST.DEBUG) {
			var m:Array = [];
			var len:int = CONST.MENU.length;
			var a:Array = CONST.MENU;
			for (var i:int=0; i<len; i++) {
				if (CONST.MENU[i].debug)
					continue;
				if (CONST.MENU_GROUP < 0 || CONST.MENU[i].group is int && !isPartOf(CONST.MENU[i].group))
					continue;
				m.push( CONST.MENU[i] );
			}
			return m;
		}
		return CONST.MENU;
		
		function isPartOf(n:int):Boolean
		{
			var result:int;
			for(var i:int; i<CONST.MENU_GROUP; ++i ) {
				result = CONST.MENU_GROUP & (1 << i);
				if (result==n)
					return true;
			}
			return false;
		}
	}
}
