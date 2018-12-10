package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UIOutputK5 extends UI_BaseComponent
	{
		private var opts:Vector.<OptDrive>;
		private var rg:FSRadioGroup;
		private var go:GroupOperator;
		
		public function UIOutputK5()
		{
			super();
			
			const twoLabel:String = DS.isDevice( DS.K5GL) == false ?loc("ui_out_dup_part_indication"):loc("ui_out_dup_part_indication_k5a");
			rg = new FSRadioGroup( [
				{label:loc("ui_out_controlled_atcmd"), selected:false, id:0},
				{label:twoLabel, selected:false, id:1}
			], 1, 30 );
			
			
			rg.width = 400;
			addChild( rg );
			rg.setUp( onChange );
			rg.x = globalX;
			rg.y = globalY;
			
			globalY = rg.getHeight()+20;

			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 1 );
			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 2 );
			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 3 );
			
			opts = new Vector.<OptDrive>;
			
			go = new GroupOperator;
			var anchor:int = globalY;
			
			var h:Header = new Header( [ {label:loc("ui_out_relay_num"),align:"left",xpos:30},{label:loc("ui_part_state"), width:100, xpos:118} ], {size:12} );
			go.add("0", h );
			addChild( h );
			h.y = globalY;
			globalY += 30;
			
			const len:int = DS.alias == DS.K5 || DS.isDevice(DS.K53G) || DS.isDevice(DS.K5GL) || DS.isDevice(DS.A_BRD ) || DS.isDevice(DS.K5AA )?5:4;
			for (var i:int=0; i<len; i++) {
				opts.push( new OptDrive(i+1) );
				addChild( opts[i] );
				opts[i].x = globalX;
				opts[i].y = globalY;
				globalY += opts[i].getHeight() + 6;
				go.add( "0", opts[i] );
			}
			
			globalY = anchor;
			
			//h = new Header( [ {label:loc("ui_out_relay_num"),align:"center",xpos:30},{label:loc("ui_out_part_num"), xpos:118, width:220} ], {size:12} );
			h = new Header( [ {label:loc("ui_out_part_num"), xpos:118, width:220} ], {size:12} );
			go.add("1", h );
			addChild( h );
			h.y = globalY;
			globalY += 30;
			
			var arrK5A:Array = [[0,"1"],[1,"2"],[2,"3"],[3,"4"],
				[4,"5"],[5,"6"],[6,"7"],[7,"8"] ];
			
			if(  DS.isfam( DS.K5, DS.K5A,  DS.K5GL  )) arrK5A =  arrK5A.concat( [ [8,"9"],[9,"10"],[10,"11"], [11,"12"],[12,"13"],[13,"14"],[14,"15"],[15,"16"] ]);  
			
			var l:Array = UTIL.getComboBoxList( arrK5A);
			
			var name:String = "4 (OK 1)";
			
			///FIXME: Debug value! Remove it now! убрано по задаче 
			/// https://megaplan.ritm.ru/task/1027228/card/
			//if( DS.isDevice( DS.K5A ) == false )
			//{
				addui( new FSComboBox, CMD.K5_PART_OUT, "1", null, 1, l );
				attuneElement( 90, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("1", getLastElement() );
				addui( new FSComboBox, CMD.K5_PART_OUT, "2", null, 2, l );
				attuneElement( 90, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("1", getLastElement() );
				addui( new FSComboBox, CMD.K5_PART_OUT, "3", null, 3, l );
				attuneElement( 90, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("1", getLastElement() );
			/*}
			else
			{
				addui( new FSShadow, CMD.K5_PART_OUT, "", null, 1 );
				addui( new FSShadow, CMD.K5_PART_OUT, "", null, 2 );
				addui( new FSShadow, CMD.K5_PART_OUT, "", null, 3 );
				name = "OK 1";
			}*/
			
			addui( new FSComboBox, CMD.K5_PART_OUT, name, null, 4, l );
			attuneElement( 90, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			go.add("1", getLastElement() );
			
			if( DS.isDevice( DS.K5 )
				|| DS.isDevice(DS.K53G) 
				|| DS.isDevice(DS.A_BRD ) 
				|| DS.isDevice(DS.K5GL) )
			{
				
				
				addui( new FSComboBox, CMD.K5_PART_OUT, "5 (OK 2)", null, 5, l );
				attuneElement( 90, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("1", getLastElement() );
			}
			else if( DS.isDevice( DS.K5AA ) )
			{
				
				
				addui( new FSComboBox, CMD.K5_PART_OUT, "5", null, 5, l );
				attuneElement( 90, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("1", getLastElement() );
			}
			else
			{
				addui( new FSShadow, CMD.K5_PART_OUT, "", null, 5 );
			}
			
			
			
			
			starterCMD = [CMD.K5_BIT_SWITCHES, CMD.K5_OUT_DRIVE, CMD.K5_PART_OUT];
		}
		override public function put(p:Package):void 
		{
			switch(p.cmd) {
				case CMD.K5_BIT_SWITCHES:
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					var b:Boolean = UTIL.isBit(5,p.getStructure()[2]);
					rg.setCellInfo( b ? 1:0 );
					onChange(false);
					break;
				case CMD.K5_OUT_DRIVE:
					var len:int = opts.length;
					for (var i:int=0; i<len; i++) {
						opts[i].putData( p );
					}
					break;
				case CMD.K5_PART_OUT:
					distribute( p.getStructure(), p.cmd );
					loadComplete();
					break;
			}
		}
		private function onChange(save:Boolean=true):void
		{
			var b:Boolean = int(rg.getCellInfo()) == 1;
			go.visible( "0", !b );
			go.visible( "1", b );
			
			if (save) {
				var f:IFormString = getField( CMD.K5_BIT_SWITCHES, 3 );
				var bf:int = UTIL.changeBit( int(f.getCellInfo()), 5, b );
				f.setCellInfo( bf );
				remember( f );
			}				
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionListBlock;
import components.gui.fields.FSComboBox;
import components.protocol.Package;
import components.static.CMD;
import components.static.DS;
import components.system.UTIL;

class OptDrive extends OptionListBlock
{
	public function OptDrive(n:int)
	{
		super();
		
		structureID = n;
		
		var l:Array = UTIL.getComboBoxList([[1,loc("ui_out_closed")],[0,loc("ui_out_opened")]]);
		var s:String = n.toString();
		if (n == 4)
			s += " ("+loc("ui_out_ok")+" 1)"
		if (n == 5 && !DS.isDevice( DS.K5AA ))
			s += " ("+loc("ui_out_ok")+" 2)"
			
		addui( new FSComboBox, CMD.K5_OUT_DRIVE, s, null, 1, l );
		attuneElement( 90, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
	}
	override public function putData(p:Package):void
	{
		distribute(p.getStructure(structureID), p.cmd);
	}
}