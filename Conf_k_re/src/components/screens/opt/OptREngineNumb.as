package components.screens.opt
{
	import components.abstract.adapters.StringCutterAdapter;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.static.CMD;
	
	public class OptREngineNumb extends OptionsBlock
	{
		public function OptREngineNumb(_struc:int)
		{
			super();
			
			yshift = 5;
			structureID = _struc;
			operatingCMD = CMD.K5_EPHONE;
			addui( new FSShadow, operatingCMD, "", null, 1 );
			addui( new FSSimple, operatingCMD, loc("g_number")+" "+_struc,null,2,null,"0-9+", 20 );
			getLastElement().setAdapter( new StringCutterAdapter( getField(operatingCMD,1) ));
			attuneElement( 70, 200 );
			
			complexHeight = globalY;
		}
		override public function putRawData(a:Array):void
		{
			getField( operatingCMD,1).setCellInfo( String( a[0] ) );
			getField( operatingCMD,2).setCellInfo( String( a[1] ) );
		}
		public function set disabled(b:Boolean):void
		{
			getField(operatingCMD,2).disabled = b;
		}
	}
}