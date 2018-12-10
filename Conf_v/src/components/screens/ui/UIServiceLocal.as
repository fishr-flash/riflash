package components.screens.ui
{
	import components.static.DS;
	import components.static.MISC;

	public class UIServiceLocal extends UIServiceAdv
	{
		public static const SEPARATOR_WIDTH:int = 370;
		
		public function UIServiceLocal()
		{
			super();
		}
		override protected function getModuls():Array 
		{
			
			var a:Array = [addConfig];
			
			
			
			if (MISC.COPY_DEBUG)
				a = a.concat( [ addFirmware ] );
			if (DS.release >= 20)
				a = a.concat( [addNmeaReader] );
			if (DS.release >= 25)
				a = a.concat( [addHistoryRetranslator] );
			if (DS.release >= 29)
				a = a.concat( [addMasterCodeWriter] );
			if( DS.release != 46 )
				a = a.concat( [ addPhoneRequester ] );
			
			a = a.concat( [ addRestarter] );
			return a;
			//return [addFirmware,addConfig,addMasterCodeWriter,addPhoneRequester,addNmeaReader,addRestarter,addHistoryRetranslator];
		}
	}
}