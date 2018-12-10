package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.abstract.LOC;
	import components.system.Library;
	import components.system.UTIL;
	
	import su.fishr.utils.searcPropValueInArr;

	public class VjrEventsServant
	{
		private static var self:VjrEventsServant;
		private static var data:Object;
		private var haveIndexes:Array = new Array;
		
		public function VjrEventsServant()
		{
			init();
		}
		
		public static function get instance():VjrEventsServant
		{
			if( !self )
				self = new VjrEventsServant;
			
			return self;
		}
		
		private function init():void
		{
			
			var cls:Class;
			switch( LOC.language )
			{
				case LOC.EN:
					cls = Library.VjrEventsList_en;
					break;
				case LOC.IT:
					cls = Library.VjrEventsList_it;
					break;
				case LOC.RU:
					cls = Library.VjrEventsList_ru;
					break;
			}
			
			
			const ba:ByteArray = new cls as ByteArray; 
			ba.position  = 0;
			
			data = JSON.parse( ba.readUTFBytes( ba.bytesAvailable ) );
			
			
			
		}
		
		public function getList():Array
		{
			return data as Array;
		}
		
		public function setList(onevents:Array):void
		{
			
			var counter:int = 0;
			var len:int = onevents.length;
			
			/// 0-вой бит в первом байте незначащий,  делаем его равным единице, чтобы не пытаться удалить нулевой пункт в списке
			onevents[ 0 ] |= 1;
			
			
			
			for (var i:int=0; i<len; i++) {
				
				for (var j:int=0; j<8; j++) {
					
					
					/// удаляем события ( и тематические группы в которых не осталось событий ) которые в приборе не поддержаны
					if( UTIL.isBit( j, onevents[ i ] ) == false ) deleteItem( counter );
					/// счетчик равен нулю если это первый самый бит из всех байтов, он не значащий
					else if( counter ) haveIndexes.push( counter );
					counter++;
					
				}
				
			}
			/// обнуляем нулевой бит, чтобы потом не возникли какие то сложности
			onevents[ 0 ]--;
			
			
			 
		}
		
		
		
		
		public function getSettingsIndex():int
		{
			
			return haveIndexes.shift();
		}
		
		public function setSettings(structure:int, settings:Array):void
		{
			
			var len:int = data.length;
			var foundIndex:int = -1;
			var eventEnt:Object;
			for (var i:int=0; i<len; i++) {
				
				foundIndex = searcPropValueInArr( "MSG_ID", structure, data[ i ].Messages );
				if( foundIndex == -1 ) continue;
				
				
				
				data[ i ].Messages[ foundIndex ].settings = settings;
				
				

			}
		}
		
		private function searchIndex( nm:int ):int
		{
			var len:int = data.length;
			var foundIndex:int = -1;
			for (var i:int=0; i<len; i++) {
				
				foundIndex = searcPropValueInArr( "MSG_ID", nm, data[ i ].Messages );
				if( foundIndex == -1 ) continue;
				
				
				
				return foundIndex;
				
			}
			
			return foundIndex;
		}
		
		private function deleteItem( nm:int ):void
		{
			var len:int = data.length;
			var foundIndex:int = -1;
			for (var i:int=0; i<len; i++) {
				
				foundIndex = searcPropValueInArr( "MSG_ID", nm, data[ i ].Messages );
				if( foundIndex == -1 ) continue;
				
				
				( data[ i ].Messages as Array ).splice( foundIndex, 1 );
				
				if( ( data[ i ].Messages as Array ).length == 0 ) 
				{
					( data as Array ).splice( i, 1 );
					--i;
				}
				return;
				
			}
			
		}
	}
}