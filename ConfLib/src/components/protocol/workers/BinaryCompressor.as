package components.protocol.workers
{
	import components.system.UTIL;

	public class BinaryCompressor
	{
		private static var inst:BinaryCompressor;
		public static function access():BinaryCompressor
		{
			if(!inst)
				inst = new BinaryCompressor;
			return inst;
		}
		public function BinaryCompressor()
		{
		}
		public function unpack(a:Array):Array
		{
		//	a = [4,10,-4,11,12,13,14,4,15,-5,14,13,12,11,10,6,9,-1,8];
		//	var b:Array = [10,10,10,10,11,12,13,14,15,15,15,15,14,13,12,11,10,9,9,9,9,9,9,8];
			
			var signa:Array = [];
			
			for (var k:int=0; k<a.length; k++) {
				signa.push( UTIL.toSigned(a[i],1) );
			}
			
			
			var result:Array = new Array;
			var len:int = a.length;
			var signed:int;
			for (var i:int=0; i<len; i++) {
				signed = UTIL.toSigned(a[i],1);
				if ( signed > 0 ) {
					for (var j:int=0; j<signed; j++) {
						result.push(a[i+1]);
					}
					i++;
				} else {
					result = result.concat( a.slice(i+1,(i+1)+UTIL.mod(signed) ));
					i+=UTIL.mod(signed);
				}
			}
			return result;
		}
	}
}