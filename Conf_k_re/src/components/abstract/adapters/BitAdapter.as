package components.abstract.adapters
{
	import components.abstract.functions.loc;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	import su.fishr.utils.Dumper;
	
	public class BitAdapter implements IDataAdapter
	{
		public function adapt(value:Object):Object
		{

			
			if (value == loc("g_all") || !value )
				return value;
			var a:Array =  (value as String).split(",");
			var len:int = a.length;
			var n:int = 0;
			for (var i:int=0; i<len; i++) {
				n |= int(a[i]);
			}
			var s:String = "";
			for (i=0; i<16; i++) {
				if( (n & 1 << i) > 0 ) {
					if( s.length > 0 )
						s += ",";
					s += (i+1);
				}
			}
			return s;
		}
		
		public function change(value:Object):Object
		{
			return null;
		}
		
		public function perform(field:IFormString):void
		{
			
		}
		
		public function recover(value:Object):Object
		{
			return null;
		}
	}
}