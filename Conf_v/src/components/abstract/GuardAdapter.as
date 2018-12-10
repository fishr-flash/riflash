package components.abstract
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSSimple;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.static.COLOR;
	
	public class GuardAdapter implements IDataAdapter
	{
		private var color:uint;
		private var label:String;
		
		private var fSimple:FSSimple;
		
		public function adapt(value:Object):Object
		{
			if ( int(value) == 0 ) {
				color = COLOR.RED;
				return loc("g_disabled_m");
			}
			color = COLOR.GREEN_DARK;
			return loc("g_enabled_m");
			
			
		}
		
		public function change(value:Object):Object
		{
			return value;
		}
		
		public function perform(field:IFormString):void
		{
			fSimple = field as FSSimple;
			fSimple.setTextColor( color );
		}
		
		public function recover(value:Object):Object
		{
			if( value == loc( "g_disabled_m" ) )
			{
				color = COLOR.GREEN_DARK;
				label = loc("g_enabled_m");
			}
			else
			{
				color = COLOR.RED;
				label = loc("g_disabled_m");
			}
			
			fSimple.setTextColor( color );
			fSimple.setCellInfo( label );
			return value;
		}
	}
}