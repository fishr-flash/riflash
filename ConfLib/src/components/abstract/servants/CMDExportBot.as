package components.abstract.servants
{
	import components.static.MISC;

	public class CMDExportBot
	{
		public function CMDExportBot()
		{
		}
		public static function getList():Array
		{
			var a:Array = MISC.COPY_MENU;
			var list:Array = [];
			var len:int = a.length;
			
			for (var i:int=0; i<len; ++i) {
				if (a[i].cmds)
					list.push( a[i].data );
			}
			return list;
		}
	}
}