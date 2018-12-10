package components.abstract.servants
{
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import components.abstract.LOC;
	import components.abstract.functions.dtrace;
	import components.resources.Resources;
	import components.system.UTIL;
	
	import su.fishr.utils.Dumper;
	import su.fishr.utils.searcPropValueInArr;

	public class EgtsVehiclesServant
	{
		
		
		private static var self:EgtsVehiclesServant;
		private static var data:Object;
		private var haveIndexes:Array = new Array;
		
		public function EgtsVehiclesServant()
		{
			init();
		}
		
		public static function get instance():EgtsVehiclesServant
		{
			if( !self )
				self = new EgtsVehiclesServant;
			
			return self;
		}
		
		private function init():void
		{
			
			var cls:Class;
			switch( LOC.language )
			{
				case LOC.EN:
					cls = Resources.EgtsVehicles_en;
					break;
				case LOC.IT:
					cls = Resources.EgtsVehicles_it;
					break;
				case LOC.RU:
					cls = Resources.EgtsVehicles_ru;
					break;
			}
			
			
			const ba:ByteArray = new cls as ByteArray; 
			ba.position  = 0;
			
			data = JSON.parse( ba.readUTFBytes( ba.bytesAvailable ) );
			
			
		}
		
		public function getVehiclesType():Array
		{
			
			
			return getCBoxList( data["vehicles"] as Array );
		}
		public function getPowersType():Array
		{
			
			return getBitsCBoxList( data["powers"] as Array );
		}
		
		private function getCBoxList( inarr:Array ):Array
		{
			var outarr:Array = [];
			var ob:Object;
			var len:int = inarr.length;
			for (var i:int=0; i<len; i++) 
			{
					outarr.push( {data:i, label:inarr[ i ] } );
			}
			
			return outarr;
		}
		private function getBitsCBoxList( inarr:Array ):Array
		{
			var outarr:Array = [];
			var ob:Object;
			var len:int = inarr.length;
			outarr.push( {data: 0, label:inarr[ 0 ] } );
			for (var i:int=1; i<len; i++) 
			{
					outarr.push( {data: 1<<( i-1 ), label:inarr[ i ] } );
			}
			
			return outarr;
		}
		
	}
}