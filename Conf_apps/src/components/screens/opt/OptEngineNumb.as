package components.screens.opt
{
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.static.CMD;
	
	public class OptEngineNumb extends OptionsBlock
	{
		public function OptEngineNumb(_struc:int)
		{
			super();
			
			yshift = 5;
			structureID = _struc;
			operatingCMD = CMD.ENGIN_NUMB;
			createUIElement( new FSSimple, operatingCMD, "Номер "+_struc,null,1,null,"0-9+", 20 );
			attuneElement( 70, 200 );
			
			complexHeight = globalY;
		}
		override public function putRawData(a:Array):void
		{
			getField( operatingCMD,1).setCellInfo( String( a[0] ) );
		}
	}
}