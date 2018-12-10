package components.abstract.servants.adapter
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.system.UTIL;
	
	// GMT adapter for FSComboBox Time
	
	public class AdapterGMT implements IDataAdapter
	{
		public function AdapterGMT()
		{
		}
		
		public function change(value:Object):Object
		{
			return value;
		}
		
		public function adapt(value:Object):Object
		{
			var date:Date = new Date;
			var gmtshift:int = UTIL.mod(date.getTimezoneOffset()/60);
			var time:String = String(value);
			date.setUTCHours( time.slice(0,2), time.slice(3,5) ); 
			//var res:String = date.getHours()+time.slice(2,5);
			return date.getHours()+time.slice(2,5);
		}
		
		public function recover(value:Object):Object
		{
			var date:Date = new Date;
			var gmtshift:int = UTIL.mod(date.getTimezoneOffset()/60);
			var time:String = String(value);
			date.setHours( time.slice(0,2), time.slice(3,5) ); 
			//var res:String = date.getUTCHours()+time.slice(2,5);
			
			return date.getUTCHours()+time.slice(2,5);
		}
		
		public function perform(field:IFormString):void
		{
		}
	}
}