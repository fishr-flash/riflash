package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public final class OptRfSystem extends OptionsBlock
	{
		private var _blocked:Boolean; // запоминает, была ли блокировка радиосистемы
		private var aDefault:Array = [1,1,4,1,0,12,0,0,0,7];
		
		public function OptRfSystem()
		{
			super();
			
			operatingCMD = CMD.RF_SYSTEM;
			const pwidth:int = 430;
			createUIElement( new FSShadow,operatingCMD , "", null, 1 );
			createUIElement( new FSComboBox, operatingCMD, loc("rfd_num_rf_channel"), change, 2, UTIL.comboBoxNumericDataGenerator(1, 7),"1-7",1, new RegExp("^([1-7])$") );
			attuneElement( pwidth );
			
			createUIElement( new FSSimple, operatingCMD, loc("rf_system_autotest_period"),change,3,null,"0-9", 2, 
				new RegExp("^([1-9]|[1-5][0-9])$") ).y;
			attuneElement( pwidth, NaN );
			
			createUIElement( new FSComboBox, operatingCMD, loc("rfd_sensor_ind_while_alarm"),change,4);
			attuneElement(pwidth,NaN, FSComboBox.F_COMBOBOX_BOOLEAN | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			if( DS.isDevice( DS.RDK ) )
			{
				
				
				var l:Array = [ {label:"04:00", data:"04:00" }, {label:"08:00", data:"08:00" }, {label:"12:00", data:"12:00" }, {label:"18:00", data:"18:00" }, {label:"22:00", data:"22:00" }, {label:loc("g_no"), data:"00:00"}];
				
				createUIElement( new FSComboBox, operatingCMD,loc("rfd_second_alarm_period_autotest_fail"),change,6,
					l,"",0,new RegExp( "^((([01]?\\d|2[0-3]):([0]?\\d|[0-5]\\d))|"+loc("g_no")+")$" ) );
				attuneElement( pwidth,NaN, FSComboBox.F_MULTYLINE | FSComboBox.F_COMBOBOX_TIME);
				globalY += 10;
				
				createUIElement( new FSComboBox, operatingCMD,loc("rfd_second_alarm_period_battery_low"),change,10,
					UTIL.getComboBoxList([1,7,14]),"",0,new RegExp( "^([1-9]|1[0-4])$" ) );
				attuneElement( pwidth,NaN, FSComboBox.F_MULTYLINE );
				globalY += 10;
				
			}
			else
			{
				
				createUIElement( new FSShadow,operatingCMD , "", null, 6 );
				createUIElement( new FSShadow,operatingCMD , "", null, 10 );
			}
			
			
			createUIElement( new FSShadow,operatingCMD , "", null, 5 );
			createUIElement( new FSShadow,operatingCMD , "", null, 7 );
			
			
			
			createUIElement( new FSShadow,operatingCMD , "", null, 8 );
			createUIElement( new FSShadow,operatingCMD , "", null, 9 );
			
			
			
			complexHeight = globalY;
		}
		override public function putRawData(a:Array):void
		{
		
			getField(CMD.RF_SYSTEM,1).setCellInfo( a[0] );
			getField(CMD.RF_SYSTEM,2).setCellInfo( a[1] );
			getField(CMD.RF_SYSTEM,3).setCellInfo( a[2] );
			getField(CMD.RF_SYSTEM,4).setCellInfo( a[3] );
			getField(CMD.RF_SYSTEM,5).setCellInfo( 0 );
			getField(CMD.RF_SYSTEM,6).setCellInfo( mergeIntoTime(a[5],a[6]) );
			getField(CMD.RF_SYSTEM,8).setCellInfo( 0 );
			getField(CMD.RF_SYSTEM,9).setCellInfo( 0 );
			getField(CMD.RF_SYSTEM,10).setCellInfo( a[9] );
		}
		public function block(b:Boolean):void
		{
			_blocked = b;
			for( var fields:String in aCells ) {
				if ((aCells[fields] as FormEmpty).cmd == operatingCMD)
					(aCells[fields] as FormEmpty).disabled = b;
			}
		}
		public function setDefault():void 
		{
			aDefault[1] = int( Math.random()*7)+1;
			//aDefault[7] = 12;
			putRawData( aDefault );
			SavePerformer.remember(1,getField(operatingCMD,10));
			//valid = true;
		}
		private function change(t:IFormString):void
		{
			if (t)
				remember(t);
		}
		
	}
}