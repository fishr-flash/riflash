package components.abstract.servants
{
	import flash.utils.ByteArray;

	public class TXTServant
	{
		private var s:String;
		
		public function compile(header:Array, book:Array):ByteArray
		{
			s = "";
			addarray(header);
			var len:int = book.length;
			for (var i:int=0; i<len; ++i) {
				addobject( book[i] );
			}
			
			var b:ByteArray = new ByteArray;
			b.writeUTFBytes(s);
			b.position = 0;
			return b;
		}
		private function addarray(a:Array):void
		{
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				s = s.concat( a[i] + "\t" ); 
			}
			s = s.concat( "\r\n" );
		}
		private function addobject(o:Object):void
		{
			var txt:String;
			for (var key:String in o) {
				if (o[key] is Array) {
					if (o[key][2] is String && o[key][2] == "cid") {
						txt = o[key][0];
					} else {
						txt = "";
						var len:int = (o[key][0] as String).length;
						for (var i:int=0; i<len; ++i) {
							if ( (o[key][1] as Vector.<String>)[i] == "009444" )
								txt += (o[key][0] as String).charAt(i);
						}
					}
					s = s.concat( txt + "\t" );
				} else
					s = s.concat( o[key] + "\t" ); 
			}
			s = s.concat( "\r\n" );
		}
	}
}