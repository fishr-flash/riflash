package components.screens.ui
{
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.opt.OptLed;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.SavePerformer;
	
	public class UIIndSound extends UI_BaseComponent
	{
		private var leds:Vector.<OptLed>;
		
		public function UIIndSound()
		{
			super();
			
			if (!DS.isDevice(DS.K14A)) {
			
				leds = new Vector.<OptLed>;
				var opt:OptLed;
				for(var i:int=0; i<4; ++i) {
					
					var title:String = LOC.loc("ui_indsound_indicator")+(i+1);
					if(i>2)
						title += " ("+LOC.loc("g_button")+")";
					opt = new OptLed(i+1,title);
					addChild( opt );
					opt.y = globalY;
					opt.x = globalX;
					globalY += opt.getHeight();
					leds.push( opt); 
				}
				
				var sep1:Separator = new Separator(720);
				addChild( sep1 );
				sep1.x = globalXSep;
				sep1.y = globalY;
				globalY += 20;
				yshift = 10;
			}
			
			createUIElement( new FSCheckBox, CMD.BUZZER14, LOC.loc("ui_indsound_signal_on_gsm"), null,1);
			attuneElement( 600 );
			createUIElement( new FSCheckBox, CMD.BUZZER14, LOC.loc("ui_indsound_signal_on_call"), null,2);
			attuneElement( 600 );
			createUIElement( new FSCheckBox, CMD.BUZZER14, LOC.loc("ui_indsound_signal_on_enterdelay"), null,3);
			attuneElement( 600 );
			createUIElement( new FSCheckBox, CMD.BUZZER14, LOC.loc("ui_indsound_signal_on_exitdelay"), null,4);
			attuneElement( 600);
			
			var sep2:Separator = new Separator(720);
			addChild( sep2 );
			sep2.x = globalXSep;
			sep2.y = globalY;
			globalY += 20;
			
			var aZummerList:Array = [ {label:LOC.loc("g_nocmd"), data:0x00}, {label:LOC.loc("g_switchon"), data:0x01}, {label:LOC.loc("g_switchon_time"), data:0x04},
				{label:LOC.loc("g_switchon_05hz"), data:0x06},{label:LOC.loc("g_switchon_1hz"), data:0x07},{label:LOC.loc("g_switchon_2hz"), data:0x08} ];
			
			var anchor:int = globalY;

			addui( new FSComboCheckBox, CMD.BUZ_PART,LOC.loc("ui_indsound_zummer_on_alarm"),null,1);
			attuneElement( 300,120 );
			(getLastElement() as FSComboCheckBox).turnToBitfield = PartitionServant.turnToPartitionBitfield;
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			globalY +=10;
			
			var tType:SimpleTextField = new SimpleTextField(LOC.loc("ui_indsound_alarm_type"), 210);
			addChild( tType );
			tType.setSimpleFormat( "center",0,12,true );
			tType.y = globalY;
			tType.x = globalX;
			
			var tCmd:SimpleTextField = new SimpleTextField(LOC.loc("ui_indsound_cmd"), 170);
			addChild( tCmd );
			tCmd.setSimpleFormat( "center",0,12,true );
			tCmd.y = globalY;
			tCmd.x = globalX + 240;			
			
			var tTime:SimpleTextField = new SimpleTextField(LOC.loc("ui_indsound_switchon_time"), 150);
			addChild( tTime );
			tTime.setSimpleFormat( "center",-7,12,true );
			tTime.y = globalY;
			tTime.x = globalX + 445;
			
			globalY +=40;
			anchor = globalY;
				
			createUIElement( new FSComboBox, CMD.BUZ_PART, LOC.loc("ui_indsound_switchon_zummer_on_alarm"), onCall,2,aZummerList);
			attuneElement( 220, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSComboBox,CMD.BUZ_PART,LOC.loc("ui_indsound_switchon_zummer_on_fire"),onCall,5,aZummerList );
			attuneElement( 220, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE  );
			
			var aPeriod:Array = [ {label:"05:00", data:"05:00" }, {label:"10:00", data:"10:00" }, {label:"30:00", data:"30:00" }, {label:"60:00", data:"60:00" }];
			globalX = 480;
				
			globalY = anchor;
			
			createUIElement( new FSComboBox, CMD.BUZ_PART,"",null,3,aPeriod,"0-9:",5,
				new RegExp( RegExpCollection.REF_TIME_0001to9959));
			attuneElement( NaN,100,FSComboBox.F_COMBOBOX_TIME);
			
			createUIElement( new FSComboBox, CMD.BUZ_PART,"",null,6,aPeriod,"0-9:",5,
				new RegExp( RegExpCollection.REF_TIME_0001to9959 ));
			attuneElement( NaN,100,FSComboBox.F_COMBOBOX_TIME);
			
			if (DS.isDevice(DS.K14A))
				starterCMD = [CMD.BUZZER14, CMD.BUZ_PART];
			else
				starterCMD = [CMD.LED14_IND, CMD.BUZZER14, CMD.BUZ_PART];
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.LED14_IND:
					LOADING = true;
					for(var i:int=0; i<4; ++i) {
						leds[i].putRawData( p.getStructure(i+1) );
					}
					break;
				case CMD.BUZZER14:
					LOADING = true;
					getField( CMD.BUZZER14, 1 ).setCellInfo( String( p.getStructure()[0]));
					getField( CMD.BUZZER14, 2 ).setCellInfo( String(p.getStructure()[1]));
					getField( CMD.BUZZER14, 3 ).setCellInfo( String(p.getStructure()[2]));
					getField( CMD.BUZZER14, 4 ).setCellInfo( String(p.getStructure()[3]));
					break;
				case CMD.BUZ_PART:
					(getField( CMD.BUZ_PART, 1 ) as FSComboCheckBox).setList( PartitionServant.getPartitionCCBList(p.getStructure()[0]));
					getField( CMD.BUZ_PART, 2 ).setCellInfo( String(p.getStructure()[1]));
					getField( CMD.BUZ_PART, 3 ).setCellInfo( mergeIntoTime(p.getStructure()[2],p.getStructure()[3]) );
					getField( CMD.BUZ_PART, 5 ).setCellInfo( String(p.getStructure()[4]));
					getField( CMD.BUZ_PART, 6 ).setCellInfo( mergeIntoTime(p.getStructure()[5],p.getStructure()[6]) );
					
					onCall(getField( CMD.BUZ_PART, 2 ));
					onCall(getField( CMD.BUZ_PART, 5 ));
					
					LOADING = false;
					loadComplete();
					break;
			}
		}
		private function onCall(t:IFormString):void
		{
			var value:int = int(t.getCellInfo());
			var f:IFormString = getField( CMD.BUZ_PART, t.param+1 );
			f.disabled = Boolean(value == 0 || value == 1);
			if ( value == 0 || value == 1)
				f.setCellInfo( "05:00" );
			if (!LOADING)
				SavePerformer.remember( getStructure(), t );
		}
	}
}