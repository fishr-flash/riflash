package foundation.functions
{
	import components.system.CONST;

	public function getMenu():Array
	{
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
			for(var j:int; j<CONST.MENU_GROUP; ++j ) {
				result = CONST.MENU_GROUP & (1 << j);
				if (result==n)
					return true;
			}
			return false;
		}
	}
}