package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.DecimalToHHMMAdapter;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSBitBox;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class UISysEventsUni extends UI_BaseComponent
	{
		private var adv_atest:int;
		private var main_atest:int;
		private var timefields:Vector.<IFormString>;
		
		public function UISysEventsUni()
		{
			super();
			var wid:int = 350;
			var cwid:int = 70;
			globalX = 370;
			
			if ( DS.isfam( DS.K5 ))
				main_atest = CMD.K5_MAIN_ATEST;
			else
				main_atest = CMD.K9_MAIN_ATEST; 
			
			var list:Array = UTIL.getComboBoxList( [[0,loc("g_no")],[1,loc("k5_sysev_one")],[2,loc("k5_sysev_two")],[3,loc("k5_sysev_three")]] );
			addui( new FSComboBox, main_atest, loc("k5_sysev_autotests"), onAmount, 1, list );
			attuneElement( 161, cwid, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			var reg:RegExp = new RegExp("^("+RegExpCollection.RE_00to2359+")$");
		
			timefields = new Vector.<IFormString>;
			
			var time_list:Array = [ {label:"00:00", data:"00:00"},
				{label:"08:00", data:"08:00"},
				{label:"16:00", data:"16:00"} ];
			
			if ( DS.isfam( DS.K5 )) {
				main_atest = CMD.K5_MAIN_ATEST;
				addui( new FSComboBox, CMD.K5_MAIN_ATEST, loc("k5_sysev_at")+" 1", null,2,time_list,"0-9:",5,
					new RegExp( reg ));
				attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
				addui( new FSComboBox, CMD.K5_MAIN_ATEST, loc("k5_sysev_at")+" 2", null,4,time_list,"0-9:",5,
					new RegExp( reg ));
				attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
				addui( new FSComboBox, CMD.K5_MAIN_ATEST, loc("k5_sysev_at")+" 3", null,6,time_list,"0-9:",5,
					new RegExp( reg ));
				attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
			} else {
				
				main_atest = CMD.K9_MAIN_ATEST; 
				
				addui( new FSShadow, main_atest, "", null, 2 );
				addui( new FSShadow, main_atest, "", null, 3 );
				addui( new FSShadow, main_atest, "", null, 4 );
				addui( new FSShadow, main_atest, "", null, 5 );
				addui( new FSShadow, main_atest, "", null, 6 );
				addui( new FSShadow, main_atest, "", null, 7 );
				
				FLAG_SAVABLE = false;
				addui( new FSComboBox, 1, loc("k5_sysev_at")+" 1", onTime,1,time_list,"0-9:",5,
					new RegExp( reg ));
				attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
				timefields.push( getLastElement() );
				addui( new FSComboBox, 1, loc("k5_sysev_at")+" 2", onTime,2,time_list,"0-9:",5,
					new RegExp( reg ));
				attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
				timefields.push( getLastElement() );
				addui( new FSComboBox, 1, loc("k5_sysev_at")+" 3", onTime,3,time_list,"0-9:",5,
					new RegExp( reg ));
				attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
				timefields.push( getLastElement() );
				FLAG_SAVABLE = true;
			}
			var anchor:int = globalY;
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			
			addui( new FormString, 0, loc("ui_sysev_gen_autotest"), null, 10 );
			attuneElement( NaN, NaN, FormString.F_MULTYLINE );
			getLastElement().y -= 76;
			globalY = anchor;
			
			drawSeparator(641+109-140);
			
			if ( DS.isfam( DS.K5 )) {
				adv_atest = CMD.K5_ADV_ATEST;
				
				time_list = [ {label:loc("g_off"), data:"00:00"},
					{label:"08:00", data:"08:00"},
					{label:"16:00", data:"16:00"} ];
				
				addui( new FSComboBox, adv_atest , loc("k5_sysev_atdop"), null,1,time_list,"0-9:",5,
					new RegExp( reg ));
				attuneElement( wid+151,cwid, FSComboBox.F_COMBOBOX_TIME | FSComboBox.F_ADAPTER_OVERRIDES_RECOVERY );
				getLastElement().setAdapter( new DecimalToHHMMAdapter );
			} else if (DS.isfam(DS.K9) ) {
				adv_atest = CMD.K9_ADV_ATEST;
				time_list = [ {label:loc("g_off"), data:"0"},
					{label:"1", data:1},
					{label:"6", data:6},
					{label:"12", data:12},
					{label:"24", data:24}	];
				addui( new FSComboBox, adv_atest , loc("k9_sysev_atdop"), null,1,time_list,"0-9",3,
					new RegExp( RegExpCollection.REF_0to255 ));
				attuneElement( wid+151,cwid );
			}
			drawSeparator(641+109-140);
			
			wid = 500;
			cwid = 70;
			
			FLAG_SAVABLE = false;
			
			addui( new FSCheckBox, 0, loc("k5_sysev_genevents"), on220w, 1 );
			attuneElement( wid+cwid-13);

			FLAG_SAVABLE = true;
			
			if ( (DS.isDevice(DS.K5)|| DS.isDevice(DS.K53G)) && DS.release <= 4 ) {
				addui( new FSSimple, CMD.K5_TIME_CPW, loc("k5_sysev_gen_events_period_hour"), 
					null, 1,null,"0-9",3, new RegExp( RegExpCollection.REF_0to255 ) );
				attuneElement( wid,cwid);
			} else {
				time_list = [ {label:"01:00", data:"01:00"},
					{label:"05:00", data:"05:00"},
					{label:"15:00", data:"15:00"},
					{label:"30:00", data:"30:00"}];
				
				addui( new FSComboBox, CMD.K5_TIME_CPW, loc("k5_sysev_gen_events_period"), null,1,time_list,"0-9:",5,
					new RegExp( RegExpCollection.REF_TIME_0005to3000_NO00));
				attuneElement( wid,cwid, FSComboBox.F_COMBOBOX_TIME | FSComboBox.F_ADAPTER_OVERRIDES_RECOVERY );
				getLastElement().setAdapter( new DecimalToHHMMAdapter );
			}
			
			FLAG_SAVABLE = false;
			var isakb:Boolean = DS.app != "006"; 
			
			if( (  DS.isfam( DS.K5 ) && int( DS.app ) != 6 && int( DS.app ) != 8 ) || DS.isfam( DS.K9 ) )
			{
				addui( new FSCheckBox, 0, loc("ui_sysev_gen_acu_fail"), onFailAkb, 2 );
				attuneElement( wid+cwid-13);
				getLastElement().disabled = !isakb;
				
				addui( new FSCheckBox, 0, loc("ui_sysev_gen_acu_low"), onDischargeAkb, 3 );
				attuneElement( wid+cwid-13);
				getLastElement().disabled = !isakb;
					
			}
			
			drawSeparator(641+109-140);
			
			FLAG_SAVABLE = true;
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 1 );
					addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 2 );
					addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 3 );
					starterCMD = [CMD.K5_BIT_SWITCHES,CMD.K5_ADV_ATEST,CMD.K5_TIME_CPW,CMD.K5_MAIN_ATEST];
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
					addui( new FSBitBox, CMD.K9_BIT_SWITCHES, loc("ui_sysev_gen_ev_restart"), null, 1,[0] );
					attuneElement( wid+cwid-13);
					//addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 1 );
					addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 2 );
					addui( new FSShadow, CMD.K9_BAT_EVENTS, "", null, 1 );
					starterCMD = [CMD.K9_BIT_SWITCHES,CMD.K9_BAT_EVENTS,CMD.K9_ADV_ATEST,CMD.K5_TIME_CPW,CMD.K9_MAIN_ATEST];
					break;
			}
			
			if(  DS.isfam( DS.K5, DS.K5A, DS.A_BRD ) && ( int( DS.app ) == 6 || int( DS.app ) == 8  ) && DS.release > 16  )
			{
				addui( new FSCheckBox, CMD.CPW_LIMITS, loc("power_on_when_cpw_without_v"), null, 1 );
				attuneElement( wid+cwid-13);
				
				starterRefine( CMD.CPW_LIMITS, true )
			}
		}
		override public function put(p:Package):void
		{
			var bf:int;
			switch(p.cmd) {
				case CMD.K9_BAT_EVENTS:
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					bf = p.getStructure()[0];
					
					getField(0,2).setCellInfo(UTIL.isBit( 1, bf ));
					getField(0,3).setCellInfo(UTIL.isBit( 0, bf ));
					break;
				case CMD.K9_BIT_SWITCHES:
				case CMD.K5_BIT_SWITCHES:
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					
					if (DS.isfam( DS.K5 )) {
						bf = p.getStructure()[0];
	
						if( DS.isfam( DS.K5 ) && int( DS.app ) != 6 && int( DS.app ) != 8 )
						{
							getField(0,2).setCellInfo(UTIL.isBit( 7, bf ));
							getField(0,3).setCellInfo(UTIL.isBit( 6, bf ));	
						}
						
						
						bf = p.getStructure()[1];
						getField(0,1).setCellInfo(UTIL.isBit( 7, bf ));
						getField(CMD.K5_TIME_CPW,1).disabled = !UTIL.isBit( 7, bf );
					} else if (DS.isfam(DS.K9) ) {
						bf = p.getStructure()[1];
						getField(0,1).setCellInfo(UTIL.isBit( 0, bf ));
						getField(CMD.K5_TIME_CPW,1).disabled = !UTIL.isBit( 0, bf );
					}
					break;
				case CMD.K5_ADV_ATEST:
				case CMD.K9_ADV_ATEST:
				case CMD.K5_TIME_CPW:
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.K5_MAIN_ATEST:
					getField(p.cmd, 1 ).setCellInfo( p.getStructure()[0] ); 
					getField(p.cmd, 2 ).setCellInfo( mergeIntoTime( p.getStructure()[1], p.getStructure()[2] ) );
					getField(p.cmd, 4 ).setCellInfo( mergeIntoTime( p.getStructure()[3], p.getStructure()[4] ) );
					getField(p.cmd, 6 ).setCellInfo( mergeIntoTime( p.getStructure()[5], p.getStructure()[6] ) );
					onAmount(null);
					loadComplete();
					break;
				case CMD.CPW_LIMITS:
					pdistribute(p);
					break;
				case CMD.K9_MAIN_ATEST:
					pdistribute(p);
					//getField(p.cmd, 1 ).setCellInfo( p.getParam(1) );
					getField(1,1).setCellInfo( mergeIntoTime( p.getStructure()[1], p.getStructure()[4] ) );
					getField(1,2).setCellInfo( mergeIntoTime( p.getStructure()[2], p.getStructure()[5] ) );
					getField(1,3).setCellInfo( mergeIntoTime( p.getStructure()[3], p.getStructure()[6] ) );
					onAmount(null);
					loadComplete();
					break;
				default:
					break;
			}
		}
		private function onAmount(t:IFormString):void
		{
			var f:IFormString = getField( main_atest, 1 );
			var n:int = int(f.getCellInfo());
			
			getField(adv_atest,1).disabled = true;
			
			if (DS.isfam( DS.K5 ) ) {
				getField(CMD.K5_MAIN_ATEST, 6).disabled = true;
				getField(CMD.K5_MAIN_ATEST, 4).disabled = true;
				getField(CMD.K5_MAIN_ATEST, 2).disabled = true;
				
				switch(n) {
					case 3:
						getField(CMD.K5_MAIN_ATEST, 6).disabled = false;
					case 2:
						getField(CMD.K5_MAIN_ATEST, 4).disabled = false;
					case 1:
						getField(CMD.K5_MAIN_ATEST, 2).disabled = false;
						getField(adv_atest,1).disabled = false;
						break;
				}
			} else {
				getField(1,1).disabled = true;
				getField(1,2).disabled = true;
				getField(1,3).disabled = true;
				
				switch(n) {
					case 3:
						getField(1,3).disabled = false;
					case 2:
						getField(1,2).disabled = false;
					case 1:
						getField(1,1).disabled = false;
						getField(adv_atest,1).disabled = false;
						break;
				}
			}
			if (t)
				remember(t);
		}
		private function on220w():void
		{
			var b:Boolean = int((getField(0,1) as FSCheckBox).getCellInfo()) == 1;
			var f:IFormString;
			var bf:uint;
			
			if (DS.isfam( DS.K5 ) ) {
				f = getField( CMD.K5_BIT_SWITCHES, 2 );
				bf = UTIL.changeBit( int(f.getCellInfo()), [6,7], b );
			} else if (DS.isfam(DS.K9) ) {
				f = getField( CMD.K9_BIT_SWITCHES, 2 );
				bf = UTIL.changeBit( int(f.getCellInfo()), [0,1], b );
			}
			
			f.setCellInfo( bf );
			getField(CMD.K5_TIME_CPW,1).disabled = !b;
			remember( f );
		}
		private function onFailAkb():void
		{
			var b:Boolean = int((getField(0,2) as FSCheckBox).getCellInfo()) == 1;
			var f:IFormString;
			var bf:uint;
			
			if (DS.isfam( DS.K5 )) {
				f = getField( CMD.K5_BIT_SWITCHES, 1 );
				bf = UTIL.changeBit( int(f.getCellInfo()), 7, b );
			} else if (DS.isfam(DS.K9) ) {
				f = getField( CMD.K9_BAT_EVENTS, 1 );
				bf = UTIL.changeBit( int(f.getCellInfo()), 1, b );
			}
			f.setCellInfo( bf );
			remember( f );
		}
		private function onDischargeAkb():void
		{
			var b:Boolean = int((getField(0,3) as FSCheckBox).getCellInfo()) == 1;
			var f:IFormString;
			var bf:uint;
			
			if (DS.isfam( DS.K5 ) ) {
				f = getField( CMD.K5_BIT_SWITCHES, 1 );
				bf = UTIL.changeBit( int(f.getCellInfo()), 6, b );
			} else if (DS.isfam(DS.K9) ) {
				f = getField( CMD.K9_BAT_EVENTS, 1 );
				bf = UTIL.changeBit( int(f.getCellInfo()), 0, b );
			}
			f.setCellInfo( bf );
			remember( f );
		}
		private function onTime():void
		{
			var f:IFormString = getField( main_atest, 1 );
			var a:Array = [f.getCellInfo()];
			a = a.concat(timefields[0].getCellInfo());
			a = a.concat(timefields[1].getCellInfo());
			a = a.concat(timefields[2].getCellInfo());
			
			distribute( [a[0],a[1],a[3],a[5],a[2],a[4],a[6]], CMD.K9_MAIN_ATEST );
			remember(f);
		}
	}
}