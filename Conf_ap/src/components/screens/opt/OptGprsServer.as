package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class OptGprsServer extends OptionsBlock
	{
		public function OptGprsServer(s:int)
		{
			super();
			
			structureID = s;
			
			addui( new FSSimple, CMD.OP_GS_SERVER_ADR, loc("g_ipdomen"), null, 1, null, "", 64, new RegExp("^"+ RegExpCollection.RE_IP_ADDRESS+"|"+RegExpCollection.RE_DOMEN+"$") );
			attuneElement( 250, 250 );
			addui( new FSSimple, CMD.OP_GG_SERVER_PORT, loc("g_port"), null, 1,null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT) );
			attuneElement( 250, 250 );
			addui( new FSSimple, CMD.OP_GI_SERVER_PASS, loc("ui_gprs_pass_gprs"), null, 1, null, "a-zA-Z0-9", 8, new RegExp(/[a-zA-Z0-9]{8}/g) );
			attuneElement( 250, 250, FSSimple.F_MULTYLINE );
			
			complexHeight = globalY;
		}
		override public function putData(p:Package):void
		{
			distribute( p.getStructure(structureID), p.cmd );
		}
	}
}