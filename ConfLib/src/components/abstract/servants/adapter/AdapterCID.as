package components.abstract.servants.adapter
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;

	public class AdapterCID implements IDataAdapter
	{
		public function adapt(value:Object):Object
		{
			return (value as int).toString(16);
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
			return "0x"+String(value);
		}
	}
}