package components.abstract.servants.adapter
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class VoltageAdapter implements IDataAdapter
	{
		public function adapt(value:Object):Object
		{
			return (Number(value)/1000).toFixed(1);
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
			return int(Number(value)*1000);
		}
	}
}