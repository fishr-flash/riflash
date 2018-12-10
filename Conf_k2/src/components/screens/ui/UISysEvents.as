package components.screens.ui
{
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.SmsServant;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UISysEvents extends UI_BaseComponent
	{
		private var servant:SmsServant;

		public function UISysEvents()
		{
			super();
			
			var list:Array = [{data:"255:255",label:loc("g_no")},{data:"00:00",label:"00:00"},{data:"23:59",label:"23:59"}];
			
			createUIElement( new FSShadow, CMD.AUTOTEST, "", null, 1 );
			createUIElement( new FSComboBox, CMD.AUTOTEST, loc("sysev_gen_period"), callLogic_autotest, 2, list, 
				"0-9:", 5, new RegExp( RegExpCollection.REF_TIME_00to2359_FF ));
			attuneElement( 450,NaN,FSComboBox.F_COMBOBOX_TIME );
			
			list = [{data:1,label:loc("sysev_daily")},{data:2,label:loc("sysev_2day")},{data:3,label:loc("sysev_3day")},{data:4,label:loc("sysev_4day")},
				{data:5,label:loc("sysev_5day")},{data:6,label:loc("sysev_6day")},{data:7,label:loc("sysev_7day")}];
			createUIElement( new FSComboBox, CMD.AUTOTEST_CYCLE, loc("sysev_send_period"), null, 1, list );
			attuneElement( 450,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSCheckBox, CMD.SYS_NOTIF2, loc("sysev_send_balance"), null, 1 );
			attuneElement( 450 );
			if (LOC.language != LOC.RU)
				getLastElement().disabled = true;
			
			
			createUIElement( new FSCheckBox, CMD.SYS_NOTIF2, loc("sysev_send_battery"), null, 2 );
			attuneElement( 450, NaN, FormString.F_MULTYLINE );
			
			drawSeparator(590);
			
			var addlist:Array = UTIL.getComboBoxList( [[0,loc("g_no")],[1,loc("sysev_every1h")],[2,loc("sysev_every2h")],[3,loc("sysev_every3h")],[4,loc("sysev_every4h")]] );
			createUIElement( new FSComboBox, CMD.AUTOTEST_ADD_CYCLE, loc("sysev_gen_add_period"), null, 1, addlist );
			attuneElement( 450, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator(590);
			
			list = [{data:"Авто",label:"Авто"},{data:"_*100#",label:"МТС (*100#)"},{data:"_*100#",label:"МегаФон (*100#)"},
				{data:"_*102#",label:"БиЛайн (*102#)"},{data:"_*105#",label:"Теле2 (*105#)"}];
			
			createUIElement( new FSShadow, CMD.USSD_BALANS, "", null, 1 );
			createUIElement( new FSComboBox, CMD.USSD_BALANS, loc("sysev_ussd_number"), callLogic_balans, 2, list, "*#+0-9", 10 );
			attuneElement( 450 );
			if (LOC.language != LOC.RU)
				getLastElement().disabled = true;
			//attuneElement( 450, NaN, FSComboBox.F_COMBOBOX_PROMT_MODE );
			
			drawSeparator(590);
			
			var txt:String = loc("sysev_gen_events");
			
			list = [{data:"00:00",label:loc("g_no")},{data:"00:10",label:"00:10"},{data:"10:00",label:"10:00"}];
			
			createUIElement( new FSShadow, CMD.SYS_NOTIF2, "", null, 3 );
			globalY += 20;
			createUIElement( new FSComboBox, CMD.SYS_NOTIF2, txt, callLogic_event, 4, list,
				"0-9:", 5, new RegExp( RegExpCollection.REF_TIME_0and0010to1000));
			attuneElement( 450,NaN,FSComboBox.F_COMBOBOX_TIME );
			
			servant = SmsServant.getInst();
			
			width = 625;
			height = 330;
			
			starterCMD = [CMD.AUTOTEST,CMD.USSD_BALANS,CMD.AUTOTEST_CYCLE]
		}
		override public function open():void
		{
			super.open();
			servant.load(put);
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.AUTOTEST:
					getField( p.cmd, 1 ).setCellInfo( String( p.getStructure()[0] ) );
					getField( p.cmd, 2 ).setCellInfo( mergeIntoTime( p.getStructure()[1], p.getStructure()[2] ) );
					break;
				case CMD.SYS_NOTIF2:
					getField( p.cmd, 1 ).setCellInfo( String( p.getStructure()[0] ) );
					getField( p.cmd, 2 ).setCellInfo( String( p.getStructure()[1] ) );
					getField( p.cmd, 3 ).setCellInfo( String( p.getStructure()[2] ) );
					getField( p.cmd, 4 ).setCellInfo( mergeIntoTime( p.getStructure()[3], p.getStructure()[4] ) );
					loadComplete();
					
					getField( p.cmd, 1 ).disabled = servant.isCID || servant.isImeiCID || LOC.language != LOC.RU;
					getField( p.cmd, 2 ).disabled = servant.isCID || servant.isImeiCID;
					// AUTOTEST_ADD_CYCLE подгружается в servat'е
					distribute( OPERATOR.dataModel.getData(CMD.AUTOTEST_ADD_CYCLE)[0], CMD.AUTOTEST_ADD_CYCLE )
					getField(CMD.AUTOTEST_ADD_CYCLE,1).disabled = !( servant.isCID || servant.isImeiCID ) || OPERATOR.dataModel.getData(CMD.AUTOTEST)[0][0] == 0;
					break;
				case CMD.USSD_BALANS:
				case CMD.AUTOTEST_CYCLE:
					distribute( p.getStructure(), p.cmd );
					break;
			}
		}
		private function callLogic_autotest(target:IFormString):void
		{
			var arr:Array = target.getCellInfo() as Array;
			var f:IFormString = getField( CMD.AUTOTEST_ADD_CYCLE, 1 );
			if (arr[0] == 0xFF && arr[1] == 0xFF ) {
				getField( CMD.AUTOTEST, 1 ).setCellInfo("0");
				f.disabled = true;
				if( int(f.getCellInfo()) != 0 ) {
					f.setCellInfo(0);
					remember( f );
				}
			} else {
				getField( CMD.AUTOTEST, 1 ).setCellInfo("1");
				f.disabled = !servant.isCID;
			}
			remember( target );
		}
		private function callLogic_event(target:IFormString):void
		{
			var arr:Array = target.getCellInfo() as Array;
			if (arr[0] == 0 && arr[1] == 0 )
				getField( CMD.SYS_NOTIF2, 3 ).setCellInfo("0");
			else
				getField( CMD.SYS_NOTIF2, 3 ).setCellInfo("1");
			remember( target );
		}
		private function callLogic_balans(target:IFormString):void
		{
			var value:String = target.getCellInfo() as String;
			switch( value ) {
				case "Авто":
					getField( CMD.USSD_BALANS, 1 ).setCellInfo("1");
					RequestAssembler.getInstance().fireEvent( new Request( CMD.VER_INFO1, info ));
					break;
				case "":
					getField( CMD.USSD_BALANS, 1 ).setCellInfo("0");
					remember( target );
					break;
				default:
					getField( CMD.USSD_BALANS, 1 ).setCellInfo("2");
					var r:Array = value.match( /\*(\d|\*)+#/g );
					if(r && r.length > 0) {
						target.setCellInfo( r[0] );
						(getField( CMD.USSD_BALANS, 2) as FSComboBox).close();
						remember( target );
					}
					break;
			}
		}
		private function info(p:Package):void
		{
			if (p.cmd == CMD.VER_INFO1) {
				var operator:String = (p.getStructure()[5] as String).toLowerCase()
				var num:String = "";
				
				switch( operator ) {
					case "mts rus":
					case "megafon":
						num = "*100#";
						break;
					case "tele2":
						num = "*105#";
						break;
					case "beeline":
						num = "*102#";
						break;
				}
				
				if (num.length == 0) {
					if ( operator.search("mts") > -1 || operator.search("megafon") > -1 ) {
						num = "*100#";
					} else if ( operator.search("tele2") > -1 ) {
						num = "*105#";
					} else if ( operator.search("beeline") > -1 ) {
						num = "*102#";
					}
				}
				
				stage.focus = null;
				var f:IFormString = getField( CMD.USSD_BALANS, 2);
				f.setCellInfo( num );
				remember( f );
			}
		}
	}
}