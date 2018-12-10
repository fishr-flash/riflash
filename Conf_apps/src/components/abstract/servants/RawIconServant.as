package components.abstract.servants
{
	import components.abstract.BMPDecoder;

	public class RawIconServant
	{
		[Embed(source = "../../../assets/icons/03.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass03:Class;
		
		[Embed(source = "../../../assets/icons/04.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass04:Class;
		
		[Embed(source = "../../../assets/icons/05.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass05:Class;
		
		[Embed(source = "../../../assets/icons/06.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass06:Class;
		
		[Embed(source = "../../../assets/icons/07.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass07:Class;
		
		[Embed(source = "../../../assets/icons/08.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass08:Class;
		
		[Embed(source = "../../../assets/icons/09.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass09:Class;
		
		[Embed(source = "../../../assets/icons/10.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass10:Class;
		
		[Embed(source = "../../../assets/icons/11.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass11:Class;
		
		[Embed(source = "../../../assets/icons/12.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass12:Class;
		
		[Embed(source = "../../../assets/icons/13.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass13:Class;
		
		
		[Embed(source = "../../../assets/icons/14.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass14:Class;
		
		
		[Embed(source = "../../../assets/icons/15.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass15:Class;
		
		
		[Embed(source = "../../../assets/icons/16.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass16:Class;
		
		
		[Embed(source = "../../../assets/icons/17.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass17:Class;
		
		
		[Embed(source = "../../../assets/icons/18.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass18:Class;
		
		
		[Embed(source = "../../../assets/icons/19.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass19:Class;
		
		
		[Embed(source = "../../../assets/icons/20.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass20:Class;
		
		
		[Embed(source = "../../../assets/icons/21.bmp", mimeType = "application/octet-stream" )] 
		public var bmpClass21:Class;
		
		
		
		private static const MAX_COUNT_ICONS:int = 100;
		
		private static var _inst:RawIconServant;

		private var bmpDecoder:BMPDecoder;
		
		
		public static function get inst():RawIconServant
		{
			if( !_inst ) 
				_inst = new RawIconServant();
			return _inst;
		}
		
		public function RawIconServant()
		{
			init();
		}
		
		private function init():void
		{
			bmpDecoder = new BMPDecoder;
		}
		
		public function getMaterials():Array
		{
			var data:Array = new Array;
			var nmf:String;
			for (var i:int=0; i< RawIconServant.MAX_COUNT_ICONS; i++) 
			{
				nmf = "bmpClass" + addZerro( i ) + "";
				
				if( !this.hasOwnProperty( nmf )  ) continue;
				
				
				
				
				data.push
				(
					{
						id:i,
						bmdata: bmpDecoder.decode( new this[ nmf ]()  ),
						b16data: bmpDecoder.b16data
					}
				);
			}
			
			function addZerro( n:int ):String
			{
				if( n < 10 ) 
					return "0" + n;
				return n + "";
				
				
			}
			
			
			return data;
			
		}
	}
}