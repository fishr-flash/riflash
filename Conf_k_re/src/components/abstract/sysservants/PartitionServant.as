package components.abstract.sysservants
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSComboCheckBox;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;

	public class PartitionServant
	{
		public function PartitionServant()
		{
		}
		
		public static function getPartitionList():Array 
		{
			var sectionList:Array = new Array;
			var bit:int=0;
			for (var i:int=0; i<16; i++) {
				bit = 0;
				bit |= 1 << i;
				sectionList.push( {label:(i+1), data:bit } );
			}
			
			/// Модификация прибора К-5А допускает работу с 8-ью разделами
			if( DS.isfam( DS.K5,  DS.K5, DS.K53G  )) sectionList = truncateList( sectionList, 8 );
			
			return sectionList;
		}
		public static function getPartitionCCBList(bit:int):Array
		{
			var list:Array = new Array;
			list.push( {"label":loc("part_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL } );
			var selected:int;
			for (var j:int=0; j<16; j++) {
				var _bit:int = bit;
				selected = 0;
				for( var i:int=0; i<16; ++i ) {
					if ( (_bit & int(1<<i)) > 0 && i == j ) {
						selected = 1;
						break;
					}
				}
				list.push( {"labeldata":(j+1), 
					"label":(j+1), 
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
			}
			
			
			
			/// Модификация прибора К-5А допускает работу с 8-ью разделами
			if( DS.isfam( DS.K5, DS.K5, DS.K53G  ) ) list = truncateList( list );
			
			
			
			return list;
			
			
			
			
		}
		
		private static function truncateList( list:Array, tlen:int = 9 ):Array
		{
			
			if( list.length <= tlen ) return list;
			
			list.splice( tlen, list.length - tlen );
			
			return list;
		}
		
		public static function turnToPartitionBitfield( arr:Array ):int
		{
			var len:int = arr.length;
			var bf:int;
			for(var i:int=0; i<len; ++i) {
				bf |= 1 << (int(arr[i]) - 1);
			}
			return bf;
		}
		public static function getPartitionBySection(bf:int):int
		{
			for (var i:int=0; i<16; i++) {
				if ( 1 << i == bf )
					return i+1;
			}
			return 0;
		}
		public static function isPartitionAssigned(n:int):Boolean
		{
			var a:Array;
			var len:int, i:int;
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					a = OPERATOR.getData(CMD.K5_AWIRE_PART_CODE)[0];
					len = a.length;
					for (i=0; i<len; i++) {
						if ( int(a[i])+1 == n )
							return true;
					}
					
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
					a = OPERATOR.getData(CMD.K9_AWIRE_TYPE);
					
					const dryWire:Boolean = UTIL.isBit( 1, OPERATOR.getData(CMD.K9_BIT_SWITCHES )[ 0 ][ 0 ] );
					
					len = a.length;
					/// если шлейфы сухие проверяем только первую половину шлейфов, остальные дизаблим
					if( dryWire ) len /= 2;
					for (i=0; i<len; i++) {
						if ( int(a[i][1])+1 == n )
							return true;
					}
					break;
			}
			return false;
		}
		public static function isSystemPartition(struct:int):Boolean
		{
			var a:Array = OPERATOR.getData(CMD.K9_PART_PARAMS);
			if ( int(a[struct-1][4]) == 1 || int(a[struct-1][5]) == 1)
				return true;
			return false;
		}
	}
}