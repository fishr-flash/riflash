package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class OptLinkTime extends OptionsBlock
	{
		public function OptLinkTime(n:int)
		{
			super();
			
			structureID = n;
			

			var ttl:String = "";
			switch(n) {
				case 1:
					ttl = "linkch_k9_network_time_reg";
					break;
				case 2:
					ttl = "linkch_k9_gprs_time_reg";
					break;
				case 3:
					ttl = "linkch_k9_gprs_time_csd";
					break;
				default:
					ttl = "not defined"
			}
			
			addui( new FSShadow, CMD.CH_COM_TIME_PARAM, "", null, 1 );
			addui( new FSSimple, CMD.CH_COM_TIME_PARAM, loc(ttl), null, 2, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to254) );
			attuneElement( 650, 60 );
		}
		
		override public function putData(p:Package):void
		{
			pdistribute(p);
		}
	}
}