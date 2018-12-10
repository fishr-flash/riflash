package components.abstract.adapters
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class DigitalCallAdapter implements IDataAdapter
	{
		public function adapt(value:Object):Object
		{
			return int(value)/2;
		}
		public function change(value:Object):Object
		{
			return value;
		}
		public function perform(field:IFormString):void	{	}
		public function recover(value:Object):Object
		{
			return int(int(value)*2);
		}
	}
}