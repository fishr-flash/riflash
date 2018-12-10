package components.abstract.adapters
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class CidAdapter implements IDataAdapter
	{
		/** Адаптер переставляет 1/3 в начало при загрузке 654.1=0х1654=5716
		 * 	Пересатвляет 1/3 в конец и переводит в хекс при сохранении 5716=0х1654=654.1	*/
		
		public function change(value:Object):Object
		{
			return value;
		}
		
		public function adapt(value:Object):Object
		{
			//5716
			var s:String = int(value).toString(16);
			return int(s.slice(1,4) + s.slice(0,1));
		}
		
		public function recover(value:Object):Object
		{
			// 1654
			var s:String = String(value).slice(3,4) + String(value).slice(0,3);
			return int("0x"+s);
		}
		
		public function perform(field:IFormString):void
		{
		}
	}
}