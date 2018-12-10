package components.screens.ui
{
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
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
			var a:Array = [];
			if (MISC.COPY_DEBUG)
				a = [addFirmware];
			
			
			
			switch(DS.alias) {
				case DS.K5RT1:
				case DS.K5RT13G:
				case DS.K5RT1L:
				case DS.K5RT3:
				case DS.K5RT3L:
				case DS.K5RT33G:
					if (SERVER.isGeoritm())
						a = a.concat( [addConfig,addPhoneRequester] ); 
					else
						a = a.concat( [addConfig] );
					break;
				case DS.isfam( DS.K5 ):
					if (SERVER.isGeoritm())
						a = a.concat( [addConfigSimple,addPhoneRequester] );
					else
						a = a.concat( [addConfigSimple] );
					OPERATOR.getSchema( CMD.K5_ADC_TRESH).StructCount = 8;
					OPERATOR.getSchema( CMD.K5_OUT_DRIVE ).StructCount = 2;
					
					break;
				case DS.K1:
				case DS.K1M:
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
					if (SERVER.isGeoritm())

						a = a.concat( [addConfigSimple,addPhoneRequester] );
					else
						a = a.concat( [addConfigSimple] );
					
					OPERATOR.getSchema( CMD.K5_ADC_TRESH).StructCount = 3;
					OPERATOR.getSchema( CMD.K5_TM_KEY).StructCount = 16;
					OPERATOR.getSchema( CMD.K5_KBD_KEY ).StructCount = 10;
					OPERATOR.getSchema( CMD.K5_OUT_DRIVE ).StructCount = 2;
					break;
				
				case DS.KLAN:
				case DS.A_ETH:
					a = a.concat( [addConfigSimple,addK5DisabledTime,addRestarterFinal] );
					break;
			}
			return a;
		}
	}
}