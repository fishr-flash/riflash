package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptOut_patternK14;
	import components.static.CMD;
	
	public class UIAOut extends UI_BaseComponent
	{
		private var selection:int=1;
		private var opt_pattern:OptOut_patternK14;
		private var opt_led:Vector.<OptOutLed>;
		private var go:GroupOperator;
		private const structureHash:Object = {0:3,1:0,2:1,3:2};
		
		public function UIAOut()
		{
			super();
			
			go = new GroupOperator;
			
			opt_led = new Vector.<OptOutLed>;
			
			initNavi();
			navi.setUp( openOut, 40 );
			navi.setXOffset(50);
			navi.addButton( loc("ui_out_alarm") , 1, 0);
			
			opt_pattern = new OptOut_patternK14;
			addChild( opt_pattern );
			opt_pattern.x = globalX;
			go.add("1",opt_pattern);
			
			var hash:Array = [0, 4, 1];
			var counter:int = 1;
			for (var i:int=1; i<3; ++i) {
				navi.addButton( loc("rfd_output")+" "+counter++, (i+1), 1000*(i+1) );
				opt_led.push( new OptOutLed(hash[i]) );
				addChild( opt_led[i-1] );
				opt_led[i-1].x = globalX;
				go.add((i+1).toString(),opt_led[i-1]);
			}
			
			
			visualize(0);
			
			starterCMD = [CMD.LED14_IND,CMD.OUT_INDPART,CMD.OUT_ALARM1,CMD.OUT_ALARM2];
		}
		override public function put(p:Package):void
		{
			if ( p.cmd == CMD.OUT_ALARM2 ) {
				navi.selection = selection;
				openOut(selection);
				loadComplete();
			}
		}
		private function openOut(num:int):void
		{
			selection = num;
			var pattern:Array;
			
			
			
			if (num == 1) {
				if( opt_pattern.getStructure() != selection )
					opt_pattern.structure = selection;
				
				var array_adress:int = opt_pattern.getStructure()-1;
				
				pattern = OPERATOR.dataModel.getData( CMD.OUT_INDPART );
				var pack:Array = new Array;
				pack.push( pattern[array_adress] );
				pattern = OPERATOR.dataModel.getData( CMD.OUT_ALARM1 );
				pack.push( pattern[array_adress] );
				opt_pattern.putRawData( pack );
				opt_pattern.visible = true;
			} else {
				pattern = OPERATOR.dataModel.getData( CMD.LED14_IND );
				
				opt_led[num-2].putRawData( pattern[structureHash[num-2]] );
				//opt_led[num-2].putRawData( pattern[num-2] );
			}
			visualize(num);
		}
		private function visualize(num:int):void
		{
			go.show(num.toString());
		}
	}
}
import components.abstract.functions.loc;
import components.abstract.sysservants.PartitionServant;
import components.basement.OptionsBlock;
import components.gui.fields.FSComboBox;
import components.gui.fields.FormString;
import components.gui.visual.HLine;
import components.interfaces.IFormString;
import components.static.CMD;
import components.static.DS;
import components.static.PAGE;
import components.system.SavePerformer;

class OptOutLed extends OptionsBlock
{
	private var selected_led:int;
	//private const structureHash:Object = {1:4,2:1,3:2,4:3};
	private const structureHash:Object = {1:4,2:1,3:2,4:3};

	private var fags:Array;
	
	public function OptOutLed(_str:int)
	{
		super();
		
		structureID = _str;//structureHash[_str];
		
		
		
		operatingCMD = CMD.LED14_IND;
		
		globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT;
		globalY = PAGE.CONTENT_TOP_SHIFT;
		
		
		
		
		var list:Array = [{label:loc("ui_led_noind"),data:0x00},
			{label:loc("ui_led_partition_state"),data:0x01},
			{label:loc("ui_led_unsend_events"),data:0x02},
			{label:loc("ui_led_power"),data:0x03},
			{label:loc("ui_led_gsm"),data:0x04}];
		
		createUIElement( new FSComboBox, operatingCMD,  loc("ui_pattern_output_control"), changeLed, 1,list );
		attuneElement( 250,300, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		
		var hl:HLine = new HLine(550);
		addChild(hl);
		hl.y = globalY;
		hl.x = globalX;
		
		globalY += 8;
		
		createUIElement( new FSComboBox, operatingCMD, loc("ui_pattern_output_control"), null, 2, PartitionServant.getPartitionList() );
		attuneElement( 250,60,FSComboBox.F_COMBOBOX_NOTEDITABLE );
		getLastElement().disabled = true;
		
		
		fags = 
			[
				"",
				loc( "faq_info_for_rfmodules" ), 
				loc( "out_info_i" ), 
				loc( "faq_info_out_states_2_3" ),
				loc( "faq_info_out_states_4" ) 
			];
		addui( new FormString, 0, "", null, 1 );
		attuneElement( 700, NaN, FormString.F_HTML_TEXT );
		getLastElement().y += 30;
		
		
		complexHeight = 25;
		
		manualResize();
	}
	override public function putRawData(re:Array):void
	{
		
		getField( operatingCMD,1).setCellInfo( String(re[0]) );
		(getField( operatingCMD,2) as FSComboBox).setList( PartitionServant.getPartitionList() );
		getField( operatingCMD,2).setCellInfo( String(re[1]) );
		changeLed();
	}
	private function changeLed(target:IFormString=null):void
	{
		const led14one:int = int(getField( operatingCMD,1).getCellInfo());
		/// если с прибора прилетает 0xFF
		selected_led = led14one < 0xFF?led14one:0;
		
		
		var field:FSComboBox = getField( operatingCMD,2) as FSComboBox;
		field.disabled = Boolean(selected_led != 1);
		field.visible = Boolean(selected_led == 1);
		
		if (target) {
			if (selected_led == 1)
				field.setCellInfo( String(PartitionServant.getFirstPartition()) );
			else
				field.setCellInfo( "0" );
			SavePerformer.remember( getStructure(), field );
		}
		
		
		
		
		if( ( DS.isDevice( DS.K14 ) == false )  && int( DS.release ) > 15 )
												getField( 0, 1 ).setName( fags[ selected_led ] );
		
	}
}