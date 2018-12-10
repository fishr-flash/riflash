package components.abstract.adapters
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class HexAdapter implements IDataAdapter
	{
		public function change(value:Object):Object
		{
			return value;
		}
		
		public function adapt(value:Object):Object
		{
			return int(value).toString(16).toUpperCase();
		}
		
		public function recover(value:Object):Object
		{
			return int("0x"+value);
		}
		
		public function perform(field:IFormString):void
		{
		}
	}
}