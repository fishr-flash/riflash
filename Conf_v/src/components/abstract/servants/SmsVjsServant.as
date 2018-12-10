package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.abstract.LOC;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.static.DS;
	import components.system.Library;
	
	import su.fishr.utils.Dumper;
	import su.fishr.utils.searcPropValueInArr;

	/**
	 * Содержит только статические поля и методы, не создавать
	 * его экземпляр.
	 * 
	 *  Обеспечивает формирование набора смс-сообщений
	 * для компонентов экрана СМС-сообщения для семейства приборов V2-V6  
	 * 
	 */
	public class SmsVjsServant
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
		 * данным прибором, вычисленных по маске полученной по 746 VR_SMS_NOTIF_LIST
		 * команде.
		 */
		public static var listIdsSmss:Array = new Array();
		
		public static var busyIdsSmss:Array;

		private static var groups:Array;

		private static var setFields:Array;
		
		public function SmsVjsServant()
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
			
			if( setFields ) return setFields;
			
			var lastNm:int = 0;
			var lastLabel:String;
			
			setFields = new Array();
			/// специальное сообщение 0 никогда не присылается прибором, поэтому создаем его
			setFields.push( {label:loc("g_no"), data:0} );
			
			const cls:Class = selectLanguageFile();
			
			const ba:ByteArray = new cls() as ByteArray;
			
			const jsonObj:Object = JSON.parse( ba.readUTFBytes( ba.bytesAvailable ) );
			var groups:Array = new Array();
			
			/// Позже, если понадобится, можно организовать фильтрацию по самым разным критериям
			switch( DS.alias ) {
				case DS.V2:
				default:
					groups.push( jsonObj.devices.default.apps[ "1" ].releases[ "1" ].groups );
					break;
			}
			
			
			
			var id:int;
			const len:int = groups.length;
			var sublen:int;
			for (var i:int=0; i<len; i++) {
				// раскрываем группы
				for each ( var grp:Array in groups[ i ] )
				{
					
					sublen = grp.length;
					
					for (var j:int=0; j<sublen; j++) 
					{
						id = int( grp[ j ].id ); 
						if(  id > lastNm )
						{
							lastNm = id;
							lastLabel = grp[ j ].label;
						}
					
						if( listIdsSmss.indexOf( id )> -1 )setFields.push( {label: grp[ j ].label, data:id  } );
					}
					
					
					
					
				}
				
			}
			
			if( !printLastIndex )
			{
				dtrace( "старший индекс смс " + lastNm + ", label: " + lastLabel );
				
				printLastIndex = true;
			}
			
			
			
			return setFields;
		}
		
		
		/**
		 * Сюда сообщаются текущие выбранные значения в комбобоксах идентификаторов
		 * СМС сообщений, для формирования списка занятых идентификаторов и затем
		 * формирования листа незанятых для дополнения опциями тех же комбобоксов.
		 * 
		 * @param1: value - Строка служащая текстовым идентификатором для пользователя смс-сообщения 
		 */
		public static function registerBusySMS( value:Object ):void
		{
			
			
			busyIdsSmss.push( searcPropValueInArr( "data", value.toString() , setFields ) );

		}
		
		/**
		 *  Собираем лист опций для каждого комбобокса
		 */
		public static function getFreeSMS( selectItem:Object, options:Array ):Array
		{
			
			
			/// Если список свободных смс еще не составлен
			/// исключаем из копии исходного массива смс-ок
			/// выбранные в комбобоксах 
			
			if( !options.length )
			{
				
				options = new Array;
				var len:int = setFields.length;
				
				
				for (var i:int= 1; i<len; i++) 
					if( busyIdsSmss.indexOf( i ) == -1 ) options.push( setFields[ i ] );
					
			}
			
			
			const meId:int = searcPropValueInArr( "data", selectItem.toString() , setFields );
			
			
			options.unshift( setFields.slice( meId, meId + 1 )[ 0 ] );
			
			
			
			return options;
		}
		
		private static function selectLanguageFile():Class
		{
			
			
			switch( LOC.language ) {
				
				case LOC.EN:
					return Library.v2SmsEn;
					break;
				
				case LOC.IT:
					return Library.v2SmsIt;
					break;
				
				default:
					return Library.v2SmsRu;
					break;
			}
			
			
		}
		
		
	}
}