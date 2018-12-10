package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.CidAdapter;
	import components.abstract.adapters.DecimalToHHMMAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	import su.fishr.utils.searcPropValueInArr;
	
	public class UISysEventsRT1 extends UI_BaseComponent
	{
		public function UISysEventsRT1()
		{
			super();
			
			var wid:int = 611;
			var cwid:int = 70;
			var awid:int = 261;
			var time_list:Array = [ {label:"00:00", data:"00:00"},
				{label:"08:00", data:"08:00"},
				{label:"16:00", data:"16:00"} ];
			var reg:RegExp = new RegExp("^("+RegExpCollection.RE_00to2359+")$");
			
			var anchor:int = globalY;
			
			addui( new FormString, 0, loc("ui_sysev_gen_autotest"), null, 1 );
			attuneElement( NaN, NaN, FormString.F_MULTYLINE );
			globalY = anchor;
			
			globalX = 380;
			var list:Array = UTIL.getComboBoxList( [[0,loc("g_no")],[1,loc("k5_sysev_one")],[2,loc("k5_sysev_two")],[3,loc("k5_sysev_three")]] );
			addui( new FSComboBox, CMD.K5_MAIN_ATEST, loc("k5_sysev_autotests"), onAmount, 1, list );
			attuneElement( awid, cwid, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			addui( new FSComboBox, CMD.K5_MAIN_ATEST, loc("k5_sysev_at")+" 1 ("+loc("g_time_hhmm") + ")", null,2,time_list,"0-9:",5,
				new RegExp( reg ));
			attuneElement( awid,cwid, FSComboBox.F_COMBOBOX_TIME );
			addui( new FSComboBox, CMD.K5_MAIN_ATEST, loc("k5_sysev_at")+" 2 ("+loc("g_time_hhmm") + ")", null,4,time_list,"0-9:",5,
				new RegExp( reg ));
			attuneElement( awid,cwid, FSComboBox.F_COMBOBOX_TIME );
			addui( new FSComboBox, CMD.K5_MAIN_ATEST, loc("k5_sysev_at")+" 3 ("+loc("g_time_hhmm") + ")", null,6,time_list,"0-9:",5,
				new RegExp( reg ));
			attuneElement( awid,cwid, FSComboBox.F_COMBOBOX_TIME );
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			anchor = globalY;
			
			time_list = [ {label:loc("g_off"), data:"00:00"},
				{label:"08:00", data:"08:00"},
				{label:"16:00", data:"16:00"} ];
			
			addui( new FSComboBox, CMD.K5_ADV_ATEST , loc("ui_sysev_gen_ad_autotest"), null,1,time_list,"0-9:",5,
				new RegExp( RegExpCollection.RE_00to2359 ));
			attuneElement( wid,cwid, FSComboBox.F_COMBOBOX_TIME | FSComboBox.F_ADAPTER_OVERRIDES_RECOVERY );
			getLastElement().setAdapter( new DecimalToHHMMAdapter );
			if( DS.alias == DS.K5RT1 || DS.isDevice(DS.K5RT13G)|| DS.alias == DS.K5RT1L)
			{
				///TODO: внесены кастомные изменения 07.06.2017 по задаче https://megaplan.ritm.ru/task/1050710/card/
				var listI:Array = CIDServant.getEvent();
				const index:int = searcPropValueInArr( "data", 6021, listI );
				listI.splice( 0, 1);//,  listI.splice( index, 1 )[ 0 ] );
				
				
				addui( new FSComboBox, CMD.K5RT_ATEST_CODE , loc("sysev_autotest_code"), null,1, listI);
				attuneElement( wid - (200-cwid)-29-200, 400+29, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				getLastElement().setAdapter(new CidAdapter);
				addui( new FSSimple, CMD.K5RT_ATEST_CODE, loc("guard_partnum"), null, 2, null, "0-9", 2, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) );
				attuneElement( wid,cwid );
				addui( new FSSimple, CMD.K5RT_ATEST_CODE, loc("guard_wirenum"), null, 3, null, "0-9", 3, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL)  );
				attuneElement( wid,cwid );
			}
			
			
			drawSeparator(722);
			
			addui( new FormString, 0, loc("sysev_gen_events_title"), null, 1 );
			
			/**"Настройка системных событий
				Команда SYS_NOTIF
					Параметр 1 - Генерировать событие "Перезагрузка" (0x00 - нет, 0x01 - да ); 
					Параметр 2 - Генерировать события - "Исчезновение 220В и Восстановление 220В" (0x00 - нет, 0x01 - да );
				Параметр 3,4 - Время для генерации событий "исчезновение и восстановление 220В" (ММ:СС) ( Параметр 3 - минуты, Параметр 4 - секунды );
					Параметр 5 - Генерировать событие - "Неисправность АКБ";
					Параметр 6 - Генерировать событие - "Разряд АКБ";	*/

			var chbwid:int = 350+119+200;
			
			addui( new FSCheckBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_ev_restart"), null, 1 );
			attuneElement( chbwid );
			addui( new FSCheckBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_no_220"), on220, 2 );
			attuneElement( chbwid );
			addui( new FSCheckBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_acu_fail"), null, 5 );
			attuneElement( chbwid );
			addui( new FSCheckBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_acu_low"), null, 6 );
			attuneElement( chbwid );
			
			time_list = [{label:"05:00", data:"05:00"},{label:"08:00", data:"08:00"},
				{label:"16:00", data:"16:00"} ];
			
			addui( new FSComboBox, CMD.SYS_NOTIF, loc("rt1_sysev_gen_events_period"), null,3,time_list,"0-9:",5,
				new RegExp( RegExpCollection.REF_TIME_0015to6000_NO00));
			attuneElement( wid,cwid, FSComboBox.F_COMBOBOX_TIME );
			//attuneElement( wid,cwid, FSComboBox.F_COMBOBOX_TIME | FSComboBox.F_ADAPTER_OVERRIDES_RECOVERY );
			//getLastElement().setAdapter( new DecimalToHHMMAdapter );
			
			starterCMD = [CMD.SYS_NOTIF, CMD.K5_ADV_ATEST, CMD.K5_MAIN_ATEST];
			
			if( DS.alias == DS.K5RT1 || DS.isDevice(DS.K5RT13G) || DS.alias == DS.K5RT1L)( starterCMD as Array ).push( CMD.K5RT_ATEST_CODE );
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K5_ADV_ATEST:
				case CMD.K5RT_ATEST_CODE:
					pdistribute(p);
					break;
				case CMD.SYS_NOTIF:
					getField(p.cmd, 1 ).setCellInfo( p.getStructure()[0] );
					getField(p.cmd, 2 ).setCellInfo( p.getStructure()[1] );
					on220(null);
					getField(p.cmd, 3 ).setCellInfo( mergeIntoTime( p.getStructure()[2], p.getStructure()[3] ) );
					
					getField(p.cmd, 5 ).setCellInfo( p.getStructure()[4] );
					getField(p.cmd, 6 ).setCellInfo( p.getStructure()[5] );
					break;
				case CMD.K5_MAIN_ATEST:
					var o2:Object=  mergeIntoTime( p.getStructure()[1], p.getStructure()[2] );
					
					getField(p.cmd, 1 ).setCellInfo( p.getStructure()[0] ); 
					getField(p.cmd, 2 ).setCellInfo( mergeIntoTime( p.getStructure()[1], p.getStructure()[2] ) );
					getField(p.cmd, 4 ).setCellInfo( mergeIntoTime( p.getStructure()[3], p.getStructure()[4] ) );
					getField(p.cmd, 6 ).setCellInfo( mergeIntoTime( p.getStructure()[5], p.getStructure()[6] ) );
					onAmount(null);
					loadComplete();
					break;
			}
		}
		private function on220(t:IFormString):void
		{
			var b:Boolean = int(getField(CMD.SYS_NOTIF,2).getCellInfo())==0;
			getField(CMD.SYS_NOTIF,3).disabled = b;
			if (t)
				remember(t);
		}
		private function onAmount(t:IFormString):void
		{
			var f:IFormString = getField( CMD.K5_MAIN_ATEST, 1 );
			var n:int = int(f.getCellInfo());
			if( !n ) getField( CMD.K5_ADV_ATEST, 1 ).setCellInfo( n );
			
			getField(CMD.K5_ADV_ATEST,1).disabled = true;
			
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
						getField(CMD.K5_ADV_ATEST,1).disabled = false;
						break;
				}
			if (t)
				remember(t);
		}
	}
}