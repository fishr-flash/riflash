package components.resources
{
	import flash.utils.ByteArray;

	public class Resources
	{
		public function Resources()
		{
		}
		
		[Embed(source="assets/can_car_id.txt",mimeType="application/octet-stream")]
		private static var can_car_id:Class;
		
		
		
		public static function CanCars():String
		{           
			var txt:ByteArray = new can_car_id() as ByteArray;
			trace(txt.toString());
			return txt.toString();
		}
		
		[Embed(source="assets/utc_times.json",mimeType="application/octet-stream")]
		private static var UTCTimesClass:Class;
		
		public static function getUTCTimes( lng:String ):Array
		{
			const jsnObject:Object = JSON.parse( new UTCTimesClass() );
			
			/**
			 * 
			 * Структура
			 * 
			 * utc_times:Object (3): 
				ru_RU:Array(25):
					[0] => Object (2): 
						shift_time:(int,3) -11
						label:(str,12) Мидуэй, о-ва
			 */
			
			const arr:Array = jsnObject[ lng ];
			const len:int = arr.length;
			var sign:String;
			for (var i:int=0; i<len; i++) 
			{
				sign = arr[ i ][ "data" ] < 0?"":"+";
				arr[ i ][ "label" ] += " (UTC" +  sign + arr[ i ][ "data" ] + ")";	
			}
			
			 
			
			
			return arr;
		}
		
		[Embed(source='../../assets/egts_vehicles_ru.json', mimeType="application/octet-stream")]
		public static var EgtsVehicles_ru:Class;
		
		[Embed(source='../../assets/egts_vehicles_en.json', mimeType="application/octet-stream")]
		public static var EgtsVehicles_en:Class;
		
		[Embed(source='../../assets/egts_vehicles_it.json', mimeType="application/octet-stream")]
		public static var EgtsVehicles_it:Class;
	}
}