package components.abstract.servants.adapter
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class Float1Adapter implements IDataAdapter
	{
		public function change(value:Object):Object
		{
			return value;
		}
		
		public function adapt(value:Object):Object
		{
			return Number(value)/10;
		}
		
		public function recover(value:Object):Object
		{
			return Number(value)*10;
		}
		
		public function perform(field:IFormString):void
		{
		}
	}
}