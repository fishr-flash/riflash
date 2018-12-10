package components.abstract
{
	import components.gui.DevConsole;
	import components.protocol.models.BinaryModel;
	import components.protocol.workers.BinaryParser;
	import components.static.MISC;

	public class ParsingBot
	{
		private static var log:Vector.<BinaryModel>;
		private static var binary:BinaryParser;
		
		public function ParsingBot()
		{
		}
		public static function parse(b:Array):void
		{
			if (MISC.DEBUG_SHOW_PARSING) {
				if(!log)
					log = new Vector.<BinaryModel>;
				
				if (!binary)
					binary = new BinaryParser;
				
				var bm:BinaryModel = binary.processResponse(b);
				if (bm) {
					DevConsole.write( "<a href=\"event:"+bm.uid+"\">bin ( "+bm.func+" ) ( "+bm.cmd+" )</a>", DevConsole.SIMPLE );
					log.unshift( bm );
					if (log.length < DevConsole.MAX_HISTORY_IN_LINE)
						log.length = DevConsole.MAX_HISTORY_IN_LINE;
				}
			}
		}
		public static function getData(uid:int):BinaryModel
		{
			if (log) {
				var len:int = log.length;
				for (var i:int=0; i<len; ++i) {
					if (log[i].uid == uid)
						return log[i];
				}
			}
			return null;
		}
	}
}