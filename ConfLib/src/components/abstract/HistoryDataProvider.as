package components.abstract
{
	import components.abstract.servants.VoyagerHistoryServant;
	import components.protocol.Package;

	public class HistoryDataProvider
	{
		public static var TOTAL_MEMORY:Number = 0;
		public static var HIS_COLLAPSED_PARAMS:Vector.<int> = new Vector.<int>(256);
		public static var HIS_ORDER_PARAMS:Vector.<int> = new Vector.<int>(256);
		public static var HIS_PERBLOCK_PARAMS:Vector.<Vector.<int>>;
		private static var HIS_VISIBLE_PARAMS:Vector.<int> = new Vector.<int>(256);
		
		public static function isVisible(value:int):Boolean
		{
			return HIS_VISIBLE_PARAMS[value];
		}
		public static function isAtleast1Invisible():Boolean
		{
			for (var i:int=0; i<256; ++i) {
				if( HIS_VISIBLE_PARAMS[i] == 0 )
					return true;
			}
			return false;
		}
		public static function resetOrder():void
		{
			var counter:int=2;
			HIS_ORDER_PARAMS = new Vector.<int>(256);
			for (var i:int=0; i<256; ++i) {
				if (HIS_COLLAPSED_PARAMS[i] > 0) {
					HIS_ORDER_PARAMS[counter-2] = counter++;
				}
			}
			SharedObjectBot.write(SharedObjectBot.HISTORY_ORDER_PARAMS, HIS_ORDER_PARAMS );
		}
		public static function installParams(v:Vector.<int>):void
		{
			if (v)
				HIS_VISIBLE_PARAMS = v;
			else {
				for (var i:int=0; i<256; ++i) {
					HIS_VISIBLE_PARAMS[i] = 1;
				}
			}
		}
		public static function changeParam(param:int, value:int):void
		{
			HIS_VISIBLE_PARAMS[param] = value;
		}
		public static function applyVisibleParams():void
		{
			SharedObjectBot.write(SharedObjectBot.HISTORY_VISIBLE_PARAMS, HIS_VISIBLE_PARAMS);
		}
		public static function caclHistoryBlockSize(p:Package):Array
		{
			var arr:Array = p.getStructure();
			var table_params:Array = new Array;
			var mask:int = 0xF;
			
			HIS_COLLAPSED_PARAMS = new Vector.<int>(256);
			HIS_PERBLOCK_PARAMS = new Vector.<Vector.<int>>(4);
			
			var block_size:uint = 0;
			var temp_size:int = 0;
			var total_blocks:uint = 0;
			var bytesize:int;
			var byteparams:int;
			
			var bitgroup:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(4);
			
			var compiled:Array= new Array;
			for(var l:int=0; l<4; ++l) {
				arr = p.getStructure(l+1);
				temp_size = 0;
				compiled[l] = [];
				HIS_PERBLOCK_PARAMS[l] = new Vector.<int>(256);
				for( var i:int=0; i<32; ++i) {
					for(var k:int=0; k<8; ++k) {
						if( (arr[i] & (1 << k)) > 0 ) {
							if (i*8+k == 0)
								continue;
							byteparams = VoyagerHistoryServant.PARAMS[i*8+k] == null ? 0 : VoyagerHistoryServant.PARAMS[i*8+k].byte;
							bytesize = getByteSize(l,i*8+k);
							HIS_COLLAPSED_PARAMS[i*8+k] = byteparams;
							
							HIS_PERBLOCK_PARAMS[l][i*8+k] = byteparams;
							compiled[l][i*8+k] = bytesize;
							temp_size += bytesize;
						}
					}
				}
				if ( block_size < temp_size )
					block_size = temp_size;
			}
			
			total_blocks = Math.floor(TOTAL_MEMORY/block_size);
			return [block_size,total_blocks, compiled];
			
			function getByteSize(c:int, num:int):int
			{
				var p:Object = VoyagerHistoryServant.PARAMS[num];
				if (!p)
					return 0;
				if ( p.bit is int) {
					if( !bitgroup[c] )
						bitgroup[c] = new Vector.<int>;
					else {
						var len:int = bitgroup[c].length;
						for (var i:int=0; i<len; ++i) {
							if (bitgroup[c][i] == p.bit)
								return 0;
						}
					}
					bitgroup[c].push( p.bit );
				}
				return p.byte;
			}
		}
	}
}