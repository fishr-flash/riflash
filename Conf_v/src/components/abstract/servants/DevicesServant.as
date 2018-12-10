package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.abstract.functions.loc;
	import components.system.Library;
	
	import su.fishr.utils.searcPropValueInArr;

	public class DevicesServant
	{
		private static var self:DevicesServant;

		private static var data:Object;
		
		public function DevicesServant()
		{
			
			init();
		}
		
		public static function get instance():DevicesServant
		{
			if( !self )
				self = new DevicesServant;
			
			return self;
		}
		
		public function getLabel( id:int ):String
		{
			
			const index:int = searcPropValueInArr( "id", id, data.devices );
			const loc_label:String = data.devices[ index ].loc_label;
			
			// сохраняем обратную совместимость, чтобы при отправке была возможность найти нужный индекс
			const name:String = data.devices[ index ][ "loc_name" ] = loc( loc_label ); 
			return name;
		}
		
		public function getId( name:String ):String
		{
			
			const index:int = searcPropValueInArr( "loc_name", name, data.devices );
			return data.devices[ index ].id;
		}
		
		private function init():void
		{
			const cls:Class =  Library.RdkDevices;
				
			const ba:ByteArray = new cls as ByteArray; 
			ba.position  = 0;
			
			data = JSON.parse( ba.readUTFBytes( ba.bytesAvailable ) );
			
			
		}
	}
}