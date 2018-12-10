package components.abstract.adapters
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.static.DS;
	import components.system.UTIL;
	
	public class DecimalToHHMMAdapter implements IDataAdapter
	{
		public function adapt(value:Object):Object
		{
			
			var n:int = int(value);
			var h:int = Math.floor(n/60);
			var m:int = n - h*60;
			return UTIL.fz(h,2)+":"+UTIL.fz(m,2);
		}
		public function change(value:Object):Object
		{
			return value;
		}
		public function perform(field:IFormString):void
		{
			
		}
		public function recover(value:Object):Object
		{
			var res:int = 0;
			
			var h:int = int(String(value).slice(0,2));
			var m:int = int(String(value).slice(3,5));
			res = h*60+m;
			
			return res; 
		}
	}
}