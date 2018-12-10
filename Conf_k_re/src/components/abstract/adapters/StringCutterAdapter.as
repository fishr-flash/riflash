package components.abstract.adapters
{
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class StringCutterAdapter implements IDataAdapter
	{
		private var f:IFormString;
		
		public function StringCutterAdapter(f:IFormString):void
		{
			this.f = f;
		}
		
		public function adapt(value:Object):Object
		{
			var len:int = int(f.getCellInfo());
			return String(value).slice(0,len);
		/*	var len:int = (value as String).length;
			f.setCellInfo(len);
			return String(value).slice(0,len);*/
		}
		public function change(value:Object):Object
		{
			f.setCellInfo( String(value).length );
			var s:Object = f.getCellInfo();
			return value;
		}
		public function perform(field:IFormString):void	{	}
		public function recover(value:Object):Object
		{
			return value;
		}
	}
}