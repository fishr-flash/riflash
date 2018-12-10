package components.abstract.servants.adapter
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.system.UTIL;
	
	public class FFAdapter implements IDataAdapter
	{
		public function change(value:Object):Object
		{
			return value;
		}
		public function adapt(value:Object):Object
		{
			
			if (value != 0)
				return 1;
			return 0;
		}
		public function recover(value:Object):Object
		{
			return value;
		}
		public function perform(field:IFormString):void		
		{
			
		}
	}
}