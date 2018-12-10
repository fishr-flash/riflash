package components.abstract.servants
{
	import components.system.UTIL;

	public class UTCDateAdapter
	{
		private var date:Date;
		public function UTCDateAdapter(year:Object, mon:Object, day:Object, hour:Object, min:Object, sec:Object )
		{
			date = new Date;
			var ayear:int = int(year) < 70 ? 2000+int(year) : 1900+int(year) 
			date.setUTCFullYear( ayear, int(mon)-1, int(day) );
			date.setUTCHours( hour, min, sec );
		}
		public function get year():int
		{
			return date.getFullYear();
		}
		public function get mon():int
		{
			return date.getMonth()+1;
		}
		public function get day():int
		{
			return date.getDate();
		}
		public function get hour():int
		{
			return date.getHours();
		}
		public function get min():int
		{
			return date.getMinutes();
		}
		public function get sec():int
		{
			return date.getSeconds();
		}
		public function getFullHistoryDate():String
		{
			return UTIL.fz(day,2)+"."+ UTIL.fz(mon,2)+ "." +UTIL.fz(year,2)
				+ " " + UTIL.fz(hour,2) + ":"+UTIL.fz(min,2) + ":"+UTIL.fz(sec,2);
		}
	}
}