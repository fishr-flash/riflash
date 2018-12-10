package components.abstract
{
	import components.gui.fields.FSComboBox;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	
	public class SecondCalculateAdapter implements IDataAdapter
	{
		
		private var _field:FSComboBox;
		public function SecondCalculateAdapter()
		{
		}
		
		public function change(value:Object):Object
		{
			return value;
		}
		
		public function adapt(value:Object):Object
		{
			const res:String = Number( int( value ) * .1 ).toFixed( 1 ) ; 
			return res;
		}
		
		public function recover(value:Object):Object
		{
			
			const res:int = Number( value ) / .1 ; 
			
			return res;
		}
		
		public function perform(field:IFormString):void
		{
			_field = field as FSComboBox;
		}
	}
}