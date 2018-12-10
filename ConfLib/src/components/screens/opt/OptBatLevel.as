package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	
	public class OptBatLevel extends OptionsBlock
	{

		private var stateLabel:FormString;
		public function OptBatLevel()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			operatingCMD = CMD.BATTERY_LEVEL;
			structureID = 1;
			const padding:int = 20;
			
			drawSeparator();
			
			globalY += 20;
			
			const comment:String = DS.isfam( DS.K5AA, DS.K5A )?"control_builtreserve_bettery":"control_builtin_bettery";
			
			addui( new FormString, 0, loc( comment ), null, 1 );
			attuneElement( 280 );
			
			const ancoreY:int = globalY;
			
			stateLabel = addui( new FormString, 0, loc( "g_lack" ), null, 2 ) as FormString; //g_lack
			
			stateLabel.y = getField( 0, 1 ).y - 16;
			stateLabel.x = getField( 0, 1 ).x + getField( 0, 1 ).width + padding;
			stateLabel.setTextColor( COLOR.RED );
			
			globalY = ancoreY + padding;
			
			const comment_i:String = DS.isfam( DS.K5AA, DS.K5A )?"voltage_builtreserve_bettery":"voltage_builtin_bettery";
			addui( new FSSimple, 0, loc( comment_i ), null, 3 );
			attuneElement( 300, NaN, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setCellInfo( "-" );
			
		}
		
		override public function putData(p:Package):void 
		{
			if( p.getParam( 1, structureID ) > 0 )
			{
				stateLabel.setCellInfo( loc( "his_exist" ) );
				stateLabel.setTextColor( COLOR.GREEN_SIGNAL );
				getField( 0, 3 ).setCellInfo( Number( int( p.getParam( 2, structureID ) ) / 1000 ).toFixed( 2 ) + "" );
			}
			else
			{
				stateLabel.setCellInfo( loc( "g_lack" ) );
				stateLabel.setTextColor( COLOR.RED );
				getField( 0, 3 ).setCellInfo( "-" );
			}
			
			
			
			
		}
	}
}