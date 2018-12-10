package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIEncryption extends UI_BaseComponent
	{
		public function UIEncryption()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			const wlabel:int = 470;
			const secw:int = 160;
			/*addui( new FSCheckBox, CMD.ENCRYPTION_KEY_128, loc( "ctrl_allow_cmd" ), null, 1 );
			attuneElement( wlabel  );
			*/
			const regexp:RegExp = /^\d{15}$/;
			addui( new FSSimple, CMD.ENCRYPTION_KEY_128, loc( "ctrl_allow_cmd" ), null, 1, null, "0-9", 15, regexp );
			attuneElement( wlabel, secw );
			//getLastElement().setAdapter( new AdaptCryptoKey );
			
			starterCMD = [ CMD.ENCRYPTION_KEY_128 ];
			
		}
		
		override public function put(p:Package):void
		{
			pdistribute( p );
			loadComplete();
		}
	}
	
	
	
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class AdaptCryptoKey implements IDataAdapter
{
	public function AdaptCryptoKey()
	{
	}
	
	public function change(value:Object):Object
	{
		return value;
	}
	
	public function adapt(value:Object):Object
	{
		return String( value ).slice( 0, -1 );
	}
	
	public function recover(value:Object):Object
	{
		return String( value )+ 0;
	}
	
	public function perform(field:IFormString):void
	{
	}
}
