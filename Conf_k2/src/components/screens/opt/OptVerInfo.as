package components.screens.opt
{
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.Battery;
	import components.gui.visual.SIMSignal;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	
	public class OptVerInfo extends OptionsBlock
	{
		private var signal:SIMSignal;
		private var battery:Battery;
		
		public function OptVerInfo(_struc:int)
		{
			super();
			operatingCMD = CMD.VER_INFO1;
			var clr:uint = COLOR.GREEN_DARK;
			
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_simcard_id"),null,5);
			attuneElement(250,250, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE);
			(getLastElement() as FSSimple).setTextColor( clr );
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_operator"),null,6);
			attuneElement(250,250, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE);
			(getLastElement() as FSSimple).setTextColor( clr );
			
			if (LOC.language == LOC.RU && DS.alias != DS.K2M ) {
				createUIElement( new FSSimple, CMD.USSD_STRING, loc("sim_balance"),null,1);
				attuneElement(250,250, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE);
			} else
				createUIElement( new FSShadow, CMD.USSD_STRING, loc("sim_balance"),null,1);
				
			var sy:int = globalY;
			createUIElement( new FormString, 0, loc("ui_gprs_signal_level"),null,5);
			var by:int = globalY;
			createUIElement( new FormString, 0, loc("battery_level"),null,6);
			
			signal = new SIMSignal;
			addChild( signal );
			signal.x = 250;
			signal.y = sy;
			
			battery = new Battery;
			addChild( battery );
			battery.x = 250;
			battery.y = by;
			
			complexHeight = globalY+27;
		}
		public function reset():void
		{
			var f:FormString = getField( CMD.USSD_STRING, 1 ) as FormString;
			if (f) {
				f.setTextColor( COLOR.GREEN_DARK );
				f.setCellInfo( loc("waiting_for_response") );
			}
			battery.put(0,0);
			signal.put(0);
		}
		override public function putData(p:Package):void
		{
			var f:FormString;
			switch( p.cmd ) {
				case CMD.VER_INFO1:
					
					var f5:FSSimple = getField( p.cmd, 5 ) as FSSimple; 
					
					//getField( p.cmd, 5 ).setCellInfo( loc(p.getStructure()[4]) );
					f5.setCellInfo( loc(p.getStructure()[4]) );
					var param5:String = p.getParamString(5);
					var param6:String = loc(p.getStructure(1)[5]);
					var field:FormString = getField( operatingCMD, 6 ) as FormString;
					f5.setTextColor( COLOR.GREEN_DARK );
					if ( param5 == "Нет SIM-карты" ) {
						
						param5 = loc(p.getParamString(5));
						
						f5.setCellInfo( param5 );
						f5.setTextColor( COLOR.RED );
						
						field.setCellInfo( param5 )
						field.setTextColor( COLOR.RED );
						
						if (LOC.language == LOC.RU) {
							f = getField( CMD.USSD_STRING, 1 ) as FormString;
							f.setCellInfo( param6 );
							f.setTextColor( COLOR.RED );
						}
						return;
					} else if ( param6 == "Не определён" ) {
						param6 = loc("sim_ussd_notrecognized")
						field.setTextColor( COLOR.RED );
					} else
						field.setTextColor( COLOR.GREEN_DARK );
					
					field.setCellInfo( param6 )
					
					break;
				case CMD.USSD_STRING:
					f = getField( CMD.USSD_STRING, 1 ) as FormString;
					f.setTextColor( COLOR.GREEN_DARK );
					f.setCellInfo( p.getStructure()[0] );
					break;
				case CMD.USSD_FUNCT:
					if (p.getStructure()[0] == 4 ) {
						f = getField( CMD.USSD_STRING, 1 ) as FormString;
						f.setCellInfo( loc("sim_ussd_notrecognized") );
						f.setTextColor( COLOR.RED );
					}
					break;
			}
		}
		override public function putState(re:Array):void
		{
			if (re)
				signal.put(re[0]);
		}
		public function putBattery(a:Array):void
		{
			battery.put( a[0], a[1] );
		}
	}
}