package components.abstract
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class TimeZoneAdapter implements IDataAdapter
	{
		public function change(value:Object):Object 	{ return value	}
		public function adapt(value:Object):Object
		{
			var n:int = int(value) + VoyagerBot.TIME_ZONE;
			if (n > 23)
				n-=24;
			if (n < 0)
				n+=24;
			return n;
		}
		public function recover(value:Object):Object
		{
			var n:int = int(value) - VoyagerBot.TIME_ZONE;
			if (n > 23)
				n-=24;
			if (n < 0)
				n+=24;
			return n;
		}
		public function perform(value:IFormString):void
		{
		}
	}
}