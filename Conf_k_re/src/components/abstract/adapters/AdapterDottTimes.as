package components.abstract.adapters
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class AdapterDottTimes implements IDataAdapter
	{
		public function AdapterDottTimes()
		{
		}
		
		public function change(value:Object):Object
		{
			return value;
		}
		
		public function adapt(value:Object):Object
		{
			
			return int( value ) / 10;
		}
		
		public function recover(value:Object):Object
		{
			
			return Number( value ) * 10 ;
		}
		
		public function perform(field:IFormString):void
		{
		}
	}
}