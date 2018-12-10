package components.gui.fields
{
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.interfaces.IPositioner;
	
	public class FSSimpleConnectServerEGTS extends FSSimple implements IFormString, IPositioner, IFocusable
	{
		
		
		public function FSSimpleConnectServerEGTS()
		{
			super();
			
		}
		override protected function validate( str:String, ignorSave:Boolean=false ):Boolean
		{
			
			var isvalid:Boolean  = Number( str ) > 4294967295 /* uint32 */?false:super.validate( str, ignorSave );
			super.drawValid( isvalid );
			
			return isvalid;
			
			
		}
	}
}