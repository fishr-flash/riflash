package components.abstract.sysservants
{
	import components.abstract.LOC;
	import components.gui.fields.FSComboCheckBox;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;
	
	import su.fishr.utils.Dumper;

	public class PartitionServant
	{
		public static var PARTITION:Object = null;
		public static var MAX_PARTITIONS:int;
		
		public function PartitionServant()
		{
		}
		public static function getFirstPartition():int
		{
			var len:int = MAX_PARTITIONS+1;
			for( var i:int=0; i<len; ++i ) {
				if( PARTITION[i] is Object) {
					return 1<<(i-1);
				}
			}
			return 0;
		}
		
		public static function getExistParts():Array
		{
			var p:Array = OPERATOR.dataModel.getData(CMD.PARTITION);
			
			var sectionList:Array = new Array;
			
			var len:int = p.length;
			for (var i:int=0; i<len; ++i) {
				if (p[i][0] == 0)
					delete PARTITION[i+1];
				else {
					PARTITION[i+1] = {code:p[i][1], section:p[i][0]};
					sectionList.push( { label: p[i][0], data:p[i][0] } );
				}
			}
			
			return sectionList;
			
		}
		
		public static function getPartitionList():Array 
		{
			var p:Array = OPERATOR.dataModel.getData(CMD.PARTITION);
			
			
			var len:int = p.length;
			for (var i:int=0; i<len; ++i) {
				if (p[i][0] == 0)
					delete PARTITION[i+1];
				else {
					PARTITION[i+1] = {code:p[i][1], section:p[i][0]};
				}
			}
			
			var sectionList:Array = new Array;
			for(var key:String in PARTITION ) {
				var bit:int=0;
				bit |= 1 << int(int(key)-1);
				sectionList.push( {label:PARTITION[key].section, data:bit } );
			}
			
			
			return sectionList;
		}
		
		
		public static function getPartShortCCBList(bit:int):Array
		{
			var list:Array = new Array;
			list.push( {"label":LOC.loc("part_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL } );
			var selected:int;
			for( var key:String in PARTITION ) {
				var _bit:int = bit;
				selected = 0;
				for( var i:int=0; i<16; ++i ) {
					if ( (_bit & int(1<<i)) > 0 && i+1 == int(key) ) {
						selected = 1;
						break;
					}
				}
				
				list.push( {"labeldata":PARTITION[key].section, 
					"label":PARTITION[key].section , 
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
			}
			
			
			return list;
		}
		
		public static function getPartitionCCBList(bit:int):Array
		{
			var list:Array = new Array;
			list.push( {"label":LOC.loc("part_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL } );
			var selected:int;
			for( var key:String in PARTITION ) {
				var _bit:int = bit;
				selected = 0;
				for( var i:int=0; i<16; ++i ) {
					if ( (_bit & int(1<<i)) > 0 && i+1 == int(key) ) {
						selected = 1;
						break;
					}
				}
				var codeX16:String = UTIL.formateZerosInFront( int(PARTITION[key].code ).toString(16), 4).toUpperCase();
				list.push( {"labeldata":PARTITION[key].section, 
					"label":PARTITION[key].section + "   " + "("+LOC.loc("g_object")+" "+codeX16+")", 
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
			}
			
			
			return list;
		}
		public static function getAllPartitionCCBList(bit:int):Array
		{	// для приборов, где все разделы есть всегда
			var list:Array = new Array;
			list.push( {"label":LOC.loc("part_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL } );
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
				//var codeX16:String = UTIL.formateZerosInFront( (PARTITION[key].code as int).toString(16), 4).toUpperCase();
				
				list.push( {"labeldata":1<<j, 
					"label":(j+1), 
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
			}
			
				
			return list;
		}
		public static function insertNewPartition(num:int, code:int, section:int):void
		{
			if( PARTITION[num] == null )
				PARTITION[num] = {"code":code, "section":section };
		}
		public static function removePartition(num:int):void
		{
			if( PARTITION[num] != null )
				delete PARTITION[num];
		}
		public static function getPartiton(num:int):Object
		{
			for(var p:String in PARTITION) {
				if( int(p) == num )
					return PARTITION[p];
			}
			return null;
		}
		public static function getPartitonByBitshift(num:int):Object
		{	// для 16го контакта
			for(var p:String in PARTITION) {
				if( 1<<(int(p)-1) == num )
					return PARTITION[p];
			}
			return null;
		}
		public static function getAllPartitionBitmask():int
		{
			var bit:int=0;
			for(var key:String in PARTITION ) {
				bit |= 1 << int(int(key)-1);
			}
			return bit;
		}
		/*public static function isPartitionAssigned(n:int):Boolean
		{
			var a:Array;
			var len:int, i:int;
			switch(DEVICES.alias) {
				case DEVICES.K5:
		case DEVICES.K5A:
					a = OPERATOR.getData(CMD.K5_AWIRE_PART_CODE)[0];
					len = a.length;
					for (i=0; i<len; i++) {
						if ( int(a[i])+1 == n )
							return true;
					}
					
					break;
				case DEVICES.K9:
					a = OPERATOR.getData(CMD.K9_AWIRE_TYPE);
					len = a.length;
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
		}*/
		/** UTILITY SECTION *********************************/
		
		public static function turnToPartitionBitfield( arr:Array ):int
		{
			var aBitfield:Array = new Array;
			var len:int = arr.length;
			var i:int;
			for( i=0; i<len; ++i ) {
				var bf:int = getPartitionBySection( arr[i] );
				if ( bf > 0 )
					aBitfield.push( bf );
			}
			len = aBitfield.length;
			var num:int = 0;
			
			for(i = 0 ;i < len; ++i) {
				num |= 1 << (int(aBitfield[i]) - 1);
			}
			
			
			return num;
		}
		public static function getPartitionBySection( _section:int):int
		{
			
			for( var key:String in PARTITION ) {
				if ( _section == PARTITION[key].section )
					return int(key)
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
					
					len = a.length;
					for (i=0; i<len; i++) {
						if ( int(a[i][1])+1 == n )
							return true;
					}
					break;
			}
			return false;
		}
		
		public static function partitionGeneratorFromK14( a:Array ):Array
		{
			var list:Array = new Array;
			var selected:int;
			const exitsPart:Array = getExistParts();
			
			
			var len:int = exitsPart.length;
			
			for (var i:int=0; i<len; i++) {
				
				selected = containsNum(exitsPart[ i ].data, a);
				
				list.push( {"labeldata":( exitsPart[ i ].data), 
					"label":(exitsPart[ i ].data),
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
			}
			
			function containsNum(n:int, a:Array):int
			{
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					if (n == a[i])
						return 1;
				}
				return 0;
			}
			
			return list;
		}
		
		
		public static function partitionGenerator( a:Array ):Array
		{
			
			
			var list:Array = new Array;
			var selected:int;
			const existParts:Array = getExistParts();
			
			//var len:int = OPERATOR.dataModel.getData(CMD.PARTITION).length;
			var len:int = existParts.length;
			for (var i:int=0; i<len; i++) {
				
				selected = containsNum( int( existParts[ i ][ "label" ] ), a);
				
				list.push( {"labeldata":( existParts[ i ][ "label" ]), 
					"label":(  existParts[ i ][ "label" ]),
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
			}
			
			function containsNum(n:int, a:Array):int
			{
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					if (n == a[i])
						return 1;
				}
				return 0;
			}
			
			return list;
		}
		
	}
}