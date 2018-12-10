package components.abstract.offline
{
	import components.protocol.models.DataModel;
	import components.protocol.models.OfflineConfigParser;
	import components.protocol.statics.SERVER;
	import components.static.MISC;
	
	public class OfflineProcessor
	{
		private static var parser:OfflineConfigParser;
		public static function init():void
		{
			parser = new OfflineConfigParser;
		}
		public static function getSaveList(a:Array):Array
		{
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if (a[i].cmds is Array) {
					if ( parser.dm.getData(a[i].cmds[0]) == null )
						a[i].disabled = true;
				}
			}
			return a;
		}
		public static function getSaveListOnline(a:Array):Array
		{
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if ( !(a[i].cmds is Array) )
					a[i].disabled = true;
			}
			return a;
		}
		
/* получить список загруженных из XML страниц		*/
		public static function getLoadedPages(xml:XML):Array
		{
			return parser.assembleMenuStructure( xml );
		}
/* добавить страницы к существующей датамодели		*/
		public static function mergeSelectedPages(a:Array):void
		{
			parser.mergeData(a);
		}
		public static function isPageExist(navi:int):Boolean
		{
			var a:CMDArray = getCMDsetByPage( navi );
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if( !parser.dm.getData( a[i] ) )
					return false;
			}
			return true;
		}
/**** DATA MODEL		*********************/
		
		public static function get dataModel():DataModel
		{
			return parser.dm;
		}
		public static function getData( cmd:int ):Array
		{
			return parser.dm.getData(cmd);
		}
	/*	public static function updateData( o:Object):void
		{
			if (parser)
				parser.dm.update(o);
		}*/
		public static function updateOnlineData( o:Object):void
		{
			parser.dm.update(o);
		}
		public static function clearOnlineDataModel():void
		{
			parser.dm = new DataModel;
		}

/* получить объект меню по команде содержащийся в нем. 
		Внимание! возрвращает первый найденный объект, а команда может содержаться в несколких		*/
		/*private static function getCMDset(cmd:int):Object
		{
			var item:Object;
			for (var key:String in MISC.COPY_MENU) {
				item = MISC.COPY_MENU[key];
				for (var c:String in item.cmds ) {
					if ( item.cmds[c] == cmd )
						return item;
				}
			}
			return null;
		}*/
		public static function getAddress(cmd:int):int
		{
			var item:Object;
			for (var key:String in MISC.COPY_MENU) {
				item = MISC.COPY_MENU[key];
				for (var c:String in item.cmds ) {
					if ( item.cmds[c] == cmd )
						return item.bottom==true?SERVER.ADDRESS_BOTTOM:SERVER.ADDRESS_TOP;
				}
			}
			return SERVER.ADDRESS_TOP;
		}
/* получить объект меню по номеру NAVI	*/
		public static function getCMDsetByPage(page:int):CMDArray
		{
			var o:Object = MISC.COPY_MENU;
			var item:Object;
			var cmda:CMDArray;
			for (var key:String in MISC.COPY_MENU) {
				item = MISC.COPY_MENU[key];
				if ( item.data == page && item.cmds is Array ) {
					cmda = new CMDArray(item.bottom==true?SERVER.ADDRESS_BOTTOM:SERVER.ADDRESS_TOP);
					var len:int = item.cmds.length;
					for (var i:int=0; i<len; ++i) {
						cmda.push( item.cmds[i] )
					}
					var sf:Object = cmda[0];
					return cmda;
				}
			}
			return null;
		}
	}
}