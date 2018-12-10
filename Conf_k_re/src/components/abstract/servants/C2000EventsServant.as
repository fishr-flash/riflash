package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.abstract.LOC;
	import components.static.DS;
	import components.system.Library;

	/**
	 * Содержит только статические поля и методы, создавать
	 * его экземпляр не нужно.
	 * 
	 *  Обеспечивает формирование набора смс-сообщений
	 * для компонентов экрана СМС-сообщения для семейства приборов V2-V6  
	 * 
	 */
	public class C2000EventsServant
	{
		/**
		 *  В дальнейшем поиск старшего индекса
		 * в списке смс может стать не тривиальной задачей.
		 * Поэтому один раз печатаем самый страший индекс последовательности,
		 * в хексе, и десятичном представлении, а также хекс следующего индекса
		 */
		private static var printLastIndex:Boolean;
		
		/**
		 *  Сохраняем сюда идентификаторы смсок поддерживаемых
		 * данным прибором, вычисленных по маске полученной по 746 
		 * команде.
		 */
		public static var listEvents:Array = new Array();
		
		public function C2000EventsServant()
		{
			throw( new Error( "The class has only static members. To create an instance of it is not necessary!" ) );
		}
		
		/**
		 *  Создает и возвращает выборку сообщений
		 * в зависимости от типа, прошивки и релиза 
		 * прибора.
		 * 
		 */
		public static function getSetMessages():Array
		{
			
			
			if( listEvents.length ) return listEvents;
			
			const cls:Class = Library[ "c2000evt" + "_" + LOC.language ];
			
			
			
			const ba:ByteArray = new cls() as ByteArray;
			
			const jsonObj:Object = JSON.parse( ba.readUTFBytes( ba.bytesAvailable ) );
			
			
			
			/// Позже, если понадобится, можно организовать фильтрацию по самым разным критериям
			switch( DS.alias ) {
				default:
					listEvents =  jsonObj.apps[ "1" ].releases[ "1" ];
					break;
			}
			
			const events:Array = CIDServant.getEvent();
			
			
			
			
			
			var len:int = events.length;
			var len1:int = listEvents.length;
			for (var j:int=0; j<len1; j++) 
			{
				listEvents[ j ].cid = "";
				
				for (var i:int=0; i<len; i++)
				{
					if( listEvents[ j ].info ) 
					{
						listEvents[ j ].cid = addDota( listEvents[ j ].alias as String ) + listEvents[ j ].info;
						break;
					}
					else if( listEvents[ j ].alias == events[ i ].data )
					{
						listEvents[ j ].cid = events[ i ].label;
						break;
					}
				}
				
			}
			
			
			return listEvents;
			
			function addDota( str:String ):String
			{
				
				return str.substr( 0, str.length - 1 ) + "." + str.substr(  str.length - 1, 1 ) + " ";
				
			}
		}
		
		
		
		
	}
}