package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.UTIL;
	
	public class UISensTermWTSOfFourParam extends UI_BaseComponent
	{
		public static const TOP_LEVEL:int = 2;
		public static const TOP_LEVEL_LEFT:int = 4;
		public static const DOWN_LEVEL:int = 1;
		public static const DOWN_LEVEL_LEFT:int = 3;
		
		private var fsCpu:FSShadow;
		private var fsOuter:FSSimple;
		private var firstScreen:VectorScreen;
		private var hiLimit:FSSimple;
		private var lowLimit:FSSimple;
		private var speedTask:ITask;
		
		public function UISensTermWTSOfFourParam( group:int=0 )
		{
			super();
			
			toplevel = false;
			globalY += 10;
			globalFocusGroup = group;
			
			
			init();
			
			
		}
		
		private function init():void
		{
			const oneColWidth:int = 650;
			const thoColWidth:int = 80;
			
			fsOuter= addui( new FSSimple, CMD.GET_TEMPERATURE, loc("temp_sonsor"), null, 2  ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth, FSSimple.F_CELL_NOTSELECTABLE );
			fsOuter.setColoredBorder( COLOR.GREEN );
			addMeasure( getLastElement() as IFormString );
			fsCpu = addui( new FSShadow, CMD.GET_TEMPERATURE, null, null, 1  ) as FSShadow;
			
			drawSeparator( oneColWidth + thoColWidth + 100);
			
			
		
			var list:Array = UTIL.comboBoxNumericDataGenerator( -30, 90 ).reverse();
			
			var label:String = loc("on_exit_higth_temperature");
			hiLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , delegateTermoLevel, TOP_LEVEL, null, "0-9 \\-", 3, new RegExp( RegExpCollection.REF_000to127 )  )  as FSSimple;
			attuneElement( oneColWidth, thoColWidth );
			hiLimit.setColoredBorder( 0xed1c24 );
			addMeasure( getLastElement() as IFormString );
			
			label = loc("off_exit_higth_temperature");
			lowLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , delegateTermoLevel, TOP_LEVEL_LEFT, null, "0-9 \\-", 3, new RegExp( RegExpCollection.REF_000to127 )   ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth  );
			lowLimit.setColoredBorder( 0xe88e91 );
			addMeasure( getLastElement() as IFormString );
			
			
			drawSeparator( oneColWidth + thoColWidth + 100);
			
			label = loc("on_exit_low_temperature");
			lowLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , delegateTermoLevel, DOWN_LEVEL, null, "0-9 \\-", 3, new RegExp( RegExpCollection.REF_000to127 )   ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth  );
			lowLimit.setColoredBorder( 0x1f59cf );
			addMeasure( getLastElement() as IFormString );
			
			label = loc("off_exit_low_temperature");
			lowLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , delegateTermoLevel, DOWN_LEVEL_LEFT, null, "0-9 \\-", 3, new RegExp( RegExpCollection.REF_000to127 )   ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth  );
			lowLimit.setColoredBorder( 0x8ebde8 );
			
			addMeasure( getLastElement() as IFormString );
			
			drawSeparator( oneColWidth + thoColWidth + 100);
			
			
			starterCMD = [ CMD.GET_TEMPERATURE, CMD.LIMITS_TEMP];
		}
		
		override public function open():void
		{
			super.open();
			
			
			speedTask = TaskManager.callLater( onSpeedTick, TaskManager.DELAY_1SEC*5 );
			
			
		}
		
		override public function close():void
		{
			super.close();
			
			speedTask.kill();
			speedTask = null;
			
			
		}
		
		
		
		private function addMeasure( elt:IFormString ):void
		{
			const yy:int = globalY;
			const xx:int = globalX;
			const space:int = 10;
			
			const measure:IFormString = addui( new FormString, 0, loc( "measure_degree_m" ), null, 1 );
			measure.y = elt.y;
			measure.x = elt.x + elt.width + space;
			
			globalY = yy;
			globalX = xx;
			
			
		}
		
		override public function put(p:Package):void
		{
			var res:Number;
			
			switch( p.cmd ) {
				case CMD.GET_TEMPERATURE:
					
					getField( p.cmd, 1 ).setCellInfo( p.getParam( 1,1 ) );
					
					
					if (fsOuter) {
						res = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(2))));
						if ( !isNaN(res) ) {
							fsOuter.setCellInfo(res);
						} else {
							fsOuter.setCellInfo(loc("g_nodata"));
						}
					}
					break;
				case CMD.LIMITS_TEMP:
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 1 ) ])));
					getField( p.cmd, 1 ).setCellInfo( res );
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 2 ) ])));
					getField( p.cmd, 2 ).setCellInfo( res );
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 3 ) ])));
					getField( p.cmd, 3 ).setCellInfo( res );
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 4 ) ])));
					getField( p.cmd, 4 ).setCellInfo( res );
					
					
					loadComplete();
					break;
				default:
					break;
			}

			
			function comb(value:int):Number
			{
				if (UTIL.mod(value) == 128)
					return NaN;
				if(value > 90)
				return 90;
				if (value < -30)
				return -30;
				return value;
			}
		}
		
		private function delegateTermoLevel( t:IFormString ):void
		{
			var opponent:FormEmpty;
			var subopponent:FormEmpty;
			var sidekick:FormEmpty; 
			( t as FormEmpty ).forceValid = 0;
			
			
			switch( t.param ) {
				case TOP_LEVEL:
					opponent = getField( CMD.LIMITS_TEMP, DOWN_LEVEL ) as FormEmpty;
					subopponent = getField( CMD.LIMITS_TEMP, DOWN_LEVEL_LEFT ) as FormEmpty;
					sidekick = getField( CMD.LIMITS_TEMP, TOP_LEVEL_LEFT ) as FormEmpty;
					if( ( int( t.getCellInfo() ) <= int( subopponent.getCellInfo() ) ) || 
						( int( t.getCellInfo() ) <= int( sidekick.getCellInfo() ) ) ){
						opponent.disabled = subopponent.disabled = sidekick.disabled = true; 
						( t as FormEmpty ).forceValid = 2;
					}
					else {
						opponent.disabled = subopponent.disabled = sidekick.disabled = false; 
						( t as FormEmpty ).forceValid = 0;
					}
					break;
				case DOWN_LEVEL:
					opponent = getField( CMD.LIMITS_TEMP, TOP_LEVEL ) as FormEmpty;
					subopponent = getField( CMD.LIMITS_TEMP, TOP_LEVEL_LEFT ) as FormEmpty;
					sidekick = getField( CMD.LIMITS_TEMP, DOWN_LEVEL_LEFT ) as FormEmpty;
					
					if( ( int( t.getCellInfo() ) >= int( subopponent.getCellInfo() ) ) || 
						( int( t.getCellInfo() ) >= int( sidekick.getCellInfo() ) ) ){
						opponent.disabled = subopponent.disabled = sidekick.disabled = true; 
						( t as FormEmpty ).forceValid = 2;
					}
					else {
						opponent.disabled = subopponent.disabled = sidekick.disabled = false; 
						( t as FormEmpty ).forceValid = 0;
					}
						
					break;
				
				case TOP_LEVEL_LEFT:
					opponent = getField( CMD.LIMITS_TEMP, DOWN_LEVEL ) as FormEmpty;
					subopponent = getField( CMD.LIMITS_TEMP, DOWN_LEVEL_LEFT ) as FormEmpty;
					sidekick = getField( CMD.LIMITS_TEMP, TOP_LEVEL ) as FormEmpty;
					
					
					if( ( int( t.getCellInfo() ) <= int( subopponent.getCellInfo() ) ) || 
						( int( t.getCellInfo() ) >= int( sidekick.getCellInfo() ) ) ){
						opponent.disabled = subopponent.disabled = sidekick.disabled = true; 
						( t as FormEmpty ).forceValid = 2;
					}
					else {
						opponent.disabled = subopponent.disabled = sidekick.disabled = false; 
						( t as FormEmpty ).forceValid = 0;
					}
						
					break;
				case DOWN_LEVEL_LEFT:
					opponent = getField( CMD.LIMITS_TEMP, TOP_LEVEL ) as FormEmpty;
					subopponent = getField( CMD.LIMITS_TEMP, TOP_LEVEL_LEFT ) as FormEmpty;
					sidekick = getField( CMD.LIMITS_TEMP, DOWN_LEVEL ) as FormEmpty;
					
					
					if( ( int( t.getCellInfo() ) >= int( subopponent.getCellInfo() ) ) || 
						( int( t.getCellInfo() ) <= int( sidekick.getCellInfo() ) ) ){
						opponent.disabled = subopponent.disabled = sidekick.disabled = true; 
						( t as FormEmpty ).forceValid = 2;
					}
					else {
						opponent.disabled = subopponent.disabled = sidekick.disabled = false; 
						( t as FormEmpty ).forceValid = 0;
					}
						
					break;
				
				
			}
			
			
			remember( t );
			
			
			
			
		}
		
		private function onSpeedTick():void
		{
			if (this.visible) {
				speedTask.repeat();
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, put));
			}
		}
		
		
	}
}