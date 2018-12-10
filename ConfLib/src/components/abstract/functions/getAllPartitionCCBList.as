package components.abstract.functions
{
	import components.abstract.sysservants.PartitionServant;
	import components.gui.fields.FSComboCheckBox;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	
	public function getAllPartitionCCBList(bit:int, onlyexisting:Boolean=false):Array
	{	// для приборов, где все разделы есть всегда
		var list:Array = new Array;
		list.push( {"label":loc("part_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL } );
		var selected:int;
		
		var a:Array;
		if ( DS.isfam( DS.K5 ))
			a = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
		else if (DS.isfam(DS.K9))
			a = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
		
		var add:String;
		var g:int;
		var d:Boolean;
		var i:int;
		var len:int = a.length;
		for (var j:int=0; j<len; j++) {
			var _bit:int = bit;
			selected = 0;
			for( i=0; i<len; ++i ) {
				if ( (_bit & int(1<<i)) > 0 && i == j ) {
					selected = 1;
					break;
				}
			}
			d = (a[j] && a[j][4] > 0) ? true : false;
			if (d)
				g = 3;
			else
				g = (a[j] && a[j][5] > 0) ? 3 : 2;
			
			
			// добавляем в список только существующие разделы
			/*if (onlyexisting && !PartitionServant.isPartitionAssigned(j+1))
				continue;*/
			add = "";
			
			if (DS.isfam(DS.K9) && !PartitionServant.isPartitionAssigned(j+1)) {
				g = 3;	// неактивные разделы заносятся в группу 3 которая всегда блокирована в FSComboCheckBoxGroupDisabler
				
				
			}
			
			if (a[j] && a[j][4] > 0)
				add = " ( "+loc("zone_24") + " ) ";
			else if (a[j] && a[j][5] > 0)
				add = " ( "+loc("wire_type_fire").toLowerCase() + " ) ";
			else if( g == 3 ) 
				add = " ( "+loc("can_engine_notinuse").toLowerCase() + " ) ";
			
			if( d || g == 3 ) selected = 0;
			
			list.push( {"labeldata":1<<j, 
				"label":(j+1) + add,
				"disabled": d,
				"group":g,
				"data":selected, 
				"block":0 } ); // param = partition (45,65,99 etc)
		}
		
		
		
		if(  DS.isfam( DS.K5,  DS.K5, DS.K53G  )) list = truncateList( list );
		
		
		
		return list;
		
		function truncateList( list:Array, tlen:int = 9 ):Array
		{
			
			if( list.length <= tlen ) return list;
			
			list.splice( tlen, list.length - tlen );
			
			return list;
		}
	}
	
	
}