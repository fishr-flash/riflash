package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UITemperatureSensor extends UI_BaseComponent
	{

		private var fsCpu:FSSimple;
		private var fsOuter:FSSimple;
		private var fastScreen:VectorScreen;

		private var speedTask:ITask;

		private var hiLimit:FSSimple;

		private var lowLimit:FSSimple;
		
		public function UITemperatureSensor()
		{
			super();
			
			
			
			init();
		}
		
		private function init():void
		{
			
			const oneColWidth:int = 650;
			const thoColWidth:int = 80;
			
			fsCpu = addui( new FSSimple, CMD.GET_TEMPERATURE, loc("ui_temp_cpu"), null, 1  ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth, FSSimple.F_CELL_NOTSELECTABLE );
			fsCpu.setColoredBorder( COLOR.GREEN );
			addMeasure( getLastElement() as IFormString );
			
			drawSeparator( oneColWidth + thoColWidth + 100);
			
			fsOuter = addui( new FSSimple, CMD.GET_TEMPERATURE, loc("ui_temp_ext_sensor"), null, 2  ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth, FSSimple.F_CELL_NOTSELECTABLE );
			fsOuter.setColoredBorder( COLOR.RED );
			addMeasure( getLastElement() as IFormString );
			
			if( !DS.isVoyager() )
			{
				addui( new FSCheckBox, 0, loc( "save_changes_temperature" ), null, 1 );
				attuneElement( oneColWidth, thoColWidth );
			}
	
			
			
			var label:String = loc("g_event") + ' "' + loc( "vhis_179" ) + '" ';
			hiLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , null, 2, null, "0-9 \\-", 3  )  as FSSimple;
			
			attuneElement( oneColWidth, thoColWidth );
			addMeasure( getLastElement() as IFormString );
			
			
			label = loc("g_event") + ' "' + loc( "vhis_180" ) + '" ';
			lowLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , null, 1, null, "0-9 \\-", 3   ) as FSSimple;
			
			attuneElement( oneColWidth, thoColWidth );
			addMeasure( getLastElement() as IFormString );
			
			drawSeparator( oneColWidth + thoColWidth + 100);
			
			fastScreen = new VectorScreen(loc("ui_temp_update_5sec"), false);
			addChild( fastScreen );
			fastScreen.y = globalY + 10;
			fastScreen.x = ( ( oneColWidth + thoColWidth ) - fastScreen.width ) / 2;
			
			
			starterCMD = [ CMD.GET_TEMPERATURE, CMD.LIMITS_TEMP ];
			
			
			
			
			
		}
		
		
		override public function open():void
		{
			super.open();
			loadComplete();
			
			speedTask = TaskManager.callLater( onSpeedTick, TaskManager.DELAY_1SEC*5 );
			var d:Date = new Date;
			
			fastScreen.currentHour = d.hours + 1;
			if (fastScreen.currentHour > 23)
				fastScreen.currentHour -= 24;
			fastScreen.currentMinute = UTIL.fz(d.minutesUTC,2);
			fastScreen.open();
			
			
		}
		
		private function onSpeedTick():void
		{
			
			if (this.visible) 
			{
				speedTask.repeat();
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, put));
			}
			
		}
		
		override public function put(p:Package):void
		{
			var res:Number;
			switch( p.cmd ) 
			{
				case CMD.GET_TEMPERATURE:
					
					res = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(1))));
					
					if ( !isNaN(res) ) {
						fsCpu.setCellInfo(res);
					} else {
						fsCpu.setCellInfo(loc("g_nodata"));
					}
					if (fsOuter) {
						res = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(2))));
						if ( !isNaN(res) ) {
							fsOuter.setCellInfo(res);
						} else {
							fsOuter.setCellInfo(loc("g_nodata"));
						}
					}
					
					fastScreen.put( p );
					loadComplete();
					
					break;
				
				case CMD.LIMITS_TEMP:
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 1, 1 ) ])) );
					
					if ( !isNaN(res) ) {
						lowLimit.setCellInfo(res);
					} else {
						lowLimit.setCellInfo(loc("g_nodata"));
					}
					
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 2, 1 ) ])));
					
					if ( !isNaN(res) ) {
						hiLimit.setCellInfo(res);
					} else {
						hiLimit.setCellInfo(loc("g_nodata"));
					}
					
					break;
			

				default:
					pdistribute( p );		
					break;
			}
			//RequestAssembler.getInstance().fireEvent( new Request( CMD.ENGIN_NUMB, putEngineNum ) );
			
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
	}
}
