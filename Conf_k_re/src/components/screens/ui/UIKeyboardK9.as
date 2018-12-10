package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.BitAdapter;
	import components.abstract.functions.getAllPartitionCCBList;
	import components.abstract.functions.loc;
	import components.abstract.functions.turnToPartitionBitfield;
	import components.abstract.servants.BitMasterMind;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSComboCheckBoxGroupDisabler;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	// Клавиатуры
	
	public class UIKeyboardK9 extends UI_BaseComponent
	{
		private var bitmm:BitMasterMind;

		private var cbModeIndications:FSComboBox;

		private var cbIndicationOnTime:FSComboBox;
		
		public function UIKeyboardK9()
		{
			super();
			
			bitmm = new BitMasterMind;
			
			addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 1 );
			bitmm.addContainer( getLastElement() );
			addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 2 );
			bitmm.addContainer( getLastElement() );
			
			var w:int = 360;
			var wf:int = 140;
			
			var list:Array = UTIL.getComboBoxList( [[1,loc("keyboard_buttons_disabled")],[0,loc("keyboard_buttons_enabled")],[2,loc("keyboard_buttons_enabled_with_delay")]] );
			addui( new FSComboBox, 0, loc("keyboard_panic_services"), null, 1, list );
			attuneElement( w, wf, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			bitmm.addController( getLastElement(), 2, [2,3] );
			
			addui( new FSComboCheckBoxGroupDisabler, CMD.K9_PERIM_PART, loc("keyboard_quick_perimetr"), null, 1 );
			(getLastElement() as FSComboCheckBoxGroupDisabler).turnToBitfield = turnToPartitionBitfield;
			(getLastElement() as FSComboCheckBoxGroupDisabler).blackText = loc("g_no");
			getLastElement().setAdapter( new BitAdapter );
			attuneElement( w, wf, FSComboCheckBox.F_MULTYLINE );
			addui( new FSComboCheckBoxGroupDisabler, CMD.K9_EXIT_PART, loc("keyboard_quick_exit"), null, 1 );
			attuneElement( w, wf, FSComboCheckBox.F_MULTYLINE );
			(getLastElement() as FSComboCheckBoxGroupDisabler).turnToBitfield = turnToPartitionBitfield;
			(getLastElement() as FSComboCheckBoxGroupDisabler).blackText = loc("g_no");
			getLastElement().setAdapter( new BitAdapter ); 
			
			
			
			starterCMD = [CMD.K9_BIT_SWITCHES, CMD.K9_EXIT_PART, CMD.K9_PERIM_PART];
			starterRefine(CMD.K9_AWIRE_TYPE);
			starterRefine(CMD.K9_PART_PARAMS);
			
			if( DS.isDevice( DS.K9K ) )
			{
				const aOptIndications:Array =
					[
						{label:loc("g_switchon"), data:0x00}, 
						{label:loc("g_switchon_time"), data:0x01}	
					];
				
				cbModeIndications = createUIElement( new FSComboBox, CMD.LED_IND,loc("ind_mode"),onCallModeInd,1,aOptIndications ) as FSComboBox;
				attuneElement( w, wf, FSComboBox.F_COMBOBOX_NOTEDITABLE  );
				cbModeIndications.x = globalX; 
				
				var aPeriod:Array = [ {label:"05:00", data:"05:00" }, {label:"10:00", data:"10:00" }, {label:"30:00", data:"30:00" }, {label:"60:00", data:"60:00" }];
				
				cbIndicationOnTime = createUIElement( new FSComboBox, CMD.LED_IND,"", makeTimeIndication, 2,aPeriod,"0-9:",5,
					new RegExp( new RegExp(RegExpCollection.REF_TIME_0030to6000_NO00) )) as FSComboBox;
				attuneElement( 0,70,FSComboBox.F_COMBOBOX_TIME);
				cbIndicationOnTime.x = cbModeIndications.x + cbModeIndications.width + cbIndicationOnTime.width - 40;
				cbIndicationOnTime.y = cbModeIndications.y;
				
				starterRefine( CMD.LED_IND, true );
			}
		}
		
		protected function onCallModeInd(t:IFormString):void
		{
			
			
			cbIndicationOnTime.disabled = t.getCellInfo() == "0";			
			
			if (t)
				SavePerformer.remember( 1,t);
		}
		
		private function makeTimeIndication( t:IFormString ):void
		{
			
			var second:Boolean = true;
			if( getField( CMD.LED_IND, 2 ).getCellInfo() === "" ) second = false;  
			const vals:Array = t.getCellInfo() as Array;
			if( !second ) return;
			
			
			SavePerformer.remember( 1, t );
		
			
		}
		
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K9_BIT_SWITCHES:
					refreshCells(p.cmd);
					bitmm.put(p);
					break;
				case CMD.K9_PERIM_PART:
					(getField(p.cmd, 1) as FSComboCheckBoxGroupDisabler).setList( getAllPartitionCCBList( int(p.getParam(1)), true ) );
					loadComplete();
					break;
				case CMD.K9_EXIT_PART:
					
					(getField(p.cmd, 1) as FSComboCheckBoxGroupDisabler).setList( getAllPartitionCCBList( int(p.getParam(1)), true ) );
					break;
				case CMD.LED_IND:
					
					
					cbModeIndications.setCellInfo( p.getParam( 1 ) );
					var value:String;
					value = UTIL.formateZerosInFront( p.getParam( 2 ).toString(), 2)+":"+ UTIL.formateZerosInFront( p.getParam( 3 ).toString(), 2 );
					cbIndicationOnTime.setCellInfo( value );
					
					cbIndicationOnTime.disabled =  p.getParam( 1 ) == "0";
					
					break;
			}
		}
		public function getAllPartitionCCBListForExit(bit:int):Array
		{	// для приборов, где все разделы есть всегда
			var list:Array = new Array;
			list.push( {"label":loc("part_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL } );
			var selected:int;
			
			var a:Array = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
			
			var add:String;
			var g:int;
			var d:Boolean;
			var i:int;
			var len:int = a.length;
			for (var j:int=0; j<len; j++) {
				var _bit:int = bit;
				selected = 0;
				for( i=0; i<len; ++i ) {
					if ( (_bit & int(1<<i)) > 0 && i == j ) {
						selected = 1;
						break;
					}
				}
				g = 0;
				
				// добавляем в список только существующие разделы
				if (!PartitionServant.isPartitionAssigned(j+1))
					continue;
				
				if (!PartitionServant.isPartitionAssigned(j+1)) {
					g = 3;	// неактивные разделы заносятся в группу 3 которая всегда блокирована в FSComboCheckBoxGroupDisabler
				}
				
				add = "";
				if (a[j] && a[j][4] > 0)
					add = " "+loc("zone_24");
				if (a[j] && a[j][5] > 0)
					add = " "+loc("wire_type_fire").toLowerCase();
				
				list.push( {"labeldata":1<<j, 
					"label":(j+1) + add,
					"disabled": d,
					"group":g,
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
				
			}
			return list;
		}
		
	}
}