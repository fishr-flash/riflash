package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.BitAdapter;
	import components.abstract.functions.loc;
	import components.abstract.functions.turnToPartitionBitfield;
	import components.abstract.servants.BitMasterMind;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSComboCheckBoxGroupDisabler;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIOutputK9 extends UI_BaseComponent
	{
		private var buttons:Vector.<TextButton>;
		private var outs:Vector.<int>;
		private var bitmm_9:BitMasterMind;
		private var bitmm:BitMasterMind;

		private var exitPart:FormEmpty;
		
		public function UIOutputK9()
		{
			super();
			
			bitmm_9 = new BitMasterMind;
			bitmm = new BitMasterMind;
			
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 1 );
			bitmm_9.addContainer( getLastElement() );
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 2 );
			bitmm_9.addContainer( getLastElement() );
			
			var isDeviceAM:Boolean = DS.alias == DS.K9A || DS.alias == DS.K9M;
			
			var w:int = 552;
			
			globalY += 20;
			
			
			var locString:String = "";
			
			if( isDeviceAM )
					locString = loc("output_k9_ok1")+" 1 " + "\r" + loc("output_k9_ok2_short");
			else
				locString = loc("output_k9_ok1")+" 1 " + "\r" + loc("output_k9_ok2");
			
			addui( new FormString, 0, locString , null, 1 );
			attuneElement(w+18, NaN, FormString.F_MULTYLINE);
			
			addbutton( getLastElement().y - 14);
			
			addui( new FSShadow, CMD.BIT_SWITCHES, "", null, 1 );
			bitmm.addContainer( getLastElement() );
			
			addui( new FSShadow, CMD.BIT_SWITCHES, "", null, 2 );
			bitmm.addContainer( getLastElement() );
			
			addui( new FSShadow, CMD.BIT_SWITCHES, "", null, 3 );
			bitmm.addContainer( getLastElement() );
			
			addui( new FSShadow, CMD.BIT_SWITCHES, "", null, 4 );
			bitmm.addContainer( getLastElement() );
			
			globalY += 20;
			
			addui( new FSCheckBox, 0, loc("ui_out_ind_enter_delay"), null, 2 );
			attuneElement( w+18 );
			bitmm.addController( getLastElement(), 1, 0 );
			
			addui( new FSCheckBox, 0, loc("ui_out_ind_exit_delay"), null, 3 );
			bitmm.addController( getLastElement(), 1, 1 );
			attuneElement( w+18 );
			
			if(  isDeviceAM )
			{
				exitPart = addui( new FSComboCheckBoxGroupDisabler, CMD.K9_EXIT_PART, loc("out_part_state_indication"), null, 1 );
				attuneElement( w,140 );
				(getLastElement() as FSComboCheckBoxGroupDisabler).turnToBitfield =  turnToPartitionBitfield;
				(getLastElement() as FSComboCheckBoxGroupDisabler).blackText = loc("g_no");
				getLastElement().setAdapter( new BitAdapter() ); 
				getLastElement().y += 30;
				globalY += 30;
				
			}
			
			
			drawSeparator(500+163);
			
			
			addui( new FormString, 0, loc("output_k9_ok1")+" 2 "+ "\r" + loc("output_k9_ok3"), null, 2 );
			attuneElement(w+18, NaN, FormString.F_MULTYLINE);
			addbutton( getLastElement().y - 6 );
			
			drawSeparator(500+163);
			
			addui( new FSSimple, CMD.K5_SYR_LEN, loc("ui_part_k5_time_siren"), null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_1to255) );
			attuneElement(w,60);
			
			if( DS.alias == DS.K9 || DS.alias == DS.K9K)addui( new FSCheckBox, 0, loc("ui_part_k5_cancel_syr"), null, 3 );
			else addui( new FSShadow(), 0, "", null, 3 );
			
			bitmm_9.addController( getLastElement(), 2, 5 );
			attuneElement(w,60);
			
			drawSeparator(500+163);
			
			var list:Array =
				[
					{ data:0, label:loc("g_switchedoff" ) },
					{ data:1, label:loc("ui_part_k5_syr_1hz" ) },
					{ data:2, label:loc("ui_part_k5_syr_05hz" ) },
					{ data:3, label:loc("ui_part_k5_continuously" ) }
				];
			addui( new FSComboBox, CMD.SYR_PAR, loc( "ui_part_k5_syr_mode_fire_warning" ), null, 1, list ); 
			attuneElement( w - 90, 150 );
			addui( new FSComboBox, CMD.SYR_PAR, loc( "ui_part_k5_syr_mode_fire_alarm" ), null, 2, list ); 
			attuneElement( w - 90, 150 );
			addui( new FSComboBox, CMD.SYR_PAR, loc( "ui_part_k5_syr_mode_guard_alarm" ), null, 3, list ); 
			attuneElement( w - 90, 150 );
			addui( new FSComboBox, CMD.SYR_PAR, loc( "syr_mode_guard_alarm" ), null, 4, list ); 
			attuneElement( w - 90, 150 );
			
			starterCMD = [ CMD.K9_AWIRE_TYPE, CMD.K9_PART_PARAMS, CMD.K9_BIT_SWITCHES,CMD.K5_OUT_DRIVE,CMD.K5_SYR_LEN, CMD.BIT_SWITCHES, CMD.SYR_PAR ];
			
			
			if(  isDeviceAM )
			{
				starterCMD = ( starterCMD as Array ).concat( CMD.K9_EXIT_PART  );
				
			}
				
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K9_BIT_SWITCHES:
					refreshCells(p.cmd);
					bitmm_9.put(p);
					break;
				case CMD.BIT_SWITCHES:
					refreshCells(p.cmd);
					bitmm.put(p);
					break;
				case CMD.K5_OUT_DRIVE:
					if (!outs)
						outs = new Vector.<int>(2);
					outs[0] = int(p.getParam(1,1));
					outs[1] = int(p.getParam(1,2));
					buttons[0].disabled = false;
					buttons[1].disabled = false;
					updateButtons();
					break;
				case CMD.K5_SYR_LEN:
					distribute(p.getStructure(),p.cmd);
					onLoad();
					
					break;
				case CMD.SYR_PAR:
					pdistribute( p );
					break;
				case CMD.K9_EXIT_PART:
					//distribute(p.getStructure(),p.cmd);
					
					(getField(p.cmd, 1) as FSComboCheckBoxGroupDisabler).setList( getAllPartitionCCBListForExit( int(p.getParam(1)) ) );
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
			var len:int = a?a.length:0;
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
		private function onLoad():void
		{
			loadComplete();
		}
		private function addbutton( yy:int ):void
		{
			if( !buttons )
				buttons = new Vector.<TextButton>;
			var b:TextButton = new TextButton;
			addChild( b );
			b.x = 552+28;
			b.y = yy;
			b.setUp( "", onClick, buttons.length );
			buttons.push( b );
		}
		private function onClick(num:int):void
		{
			
			buttons[0].disabled = true;
			buttons[1].disabled = true;
			if( !bitmm_9.getBit( 1, 7 ))
			{
				
				const arr:Array = OPERATOR.getData( CMD.K9_BIT_SWITCHES )[ 0 ];
				arr[ 0 ] += 1<<7;
				RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_BIT_SWITCHES, null, 1, OPERATOR.getData( CMD.K9_BIT_SWITCHES )[ 0 ] ) );
				
			}
			RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_OUT_DRIVE, null, num+1, [outs[num] == 1?0:1]));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_BIT_SWITCHES, put) );
			RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_OUT_DRIVE, put));
			
			
		}
		private function updateButtons():void
		{
			buttons[0].setName( outs[0] == 0 ? loc("g_test") : loc("g_switchoff") );
			buttons[1].setName( outs[1] == 0 ? loc("g_test") : loc("g_switchoff") );
		}
	}
}