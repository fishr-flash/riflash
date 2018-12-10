package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.basement.UIRadioDeviceRoot;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSTextPic;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.GuiLib;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class OptRctrl extends OptionsBlock
	{
		private var section:FormString;
		private var fsLock:FSTextPic;
		private var fsUnlock:FSTextPic;
		private var fsStar:FSTextPic;
		
		public function OptRctrl( s:int = 0 )
		{
			super();
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			
			operatingCMD = CMD.RF_RCTRL;
			
			section = new FormString;
			section.setName( loc("rfd_partition_control") );
			addChild( section );
			section.x = globalX;
			section.y = 10;
			
			createUIElement( new FSShadow, operatingCMD,"1",null,1);
			
			var field:FormEmpty = createUIElement( new FSComboCheckBox, operatingCMD,"",null,2);
			(getLastElement() as FSComboCheckBox).turnToBitfield = PartitionServant.turnToPartitionBitfield;
			attuneElement( NaN,200);
			field.x = globalX + 250;
			field.y = 10;
			
			var sep:Separator = new Separator;
			addChild( sep );
			sep.y = 50;
			sep.x = 10;
			
			fsLock = new FSTextPic;
			addChild( fsLock );
			fsLock.setWidth( 220 );
			fsLock.setName( loc("rfd_event_on_press") );
			fsLock.attachPic( GuiLib.cLock );
			fsLock.y = 80;
			fsLock.x = globalX;
			
			fsUnlock = new FSTextPic;
			addChild( fsUnlock );
			fsUnlock.setWidth( 220 );
			fsUnlock.setName( loc("rfd_event_on_press") );
			fsUnlock.attachPic( GuiLib.cUnlock );
			fsUnlock.y = 110;
			fsUnlock.x = globalX;
			
			fsStar = new FSTextPic;
			addChild( fsStar );
			fsStar.setName( loc("rfd_event_on_press") );
			fsStar.setWidth( 220 );
			fsStar.attachPic( GuiLib.cStar );
			fsStar.y = 140;
			fsStar.x = globalX;
			
			field = createUIElement( new FSComboBox, operatingCMD,"",null,3,CIDServant.getEvent(CIDServant.CID_RF_RCTRL_GUARD) );
			attuneElement( 200,NaN, FSComboBox.F_RETURNS_HEXDATA | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			field.x = globalX + 250;
			field.y = fsLock.y;
			
			field = createUIElement( new FSComboBox, operatingCMD,"",null,4,CIDServant.getEvent(CIDServant.CID_RF_RCTRL_UNGUARD) );
			attuneElement( 200,NaN, FSComboBox.F_RETURNS_HEXDATA | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			field.x = globalX + 250;
			field.y = fsUnlock.y;
			
			field = createUIElement( new FSComboBox, operatingCMD,"",null,5,CIDServant.getEvent(CIDServant.CID_RF_RCTRL_PANIC) );
			attuneElement( 200,NaN, FSComboBox.F_RETURNS_HEXDATA | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			field.x = globalX + 250;
			field.y = fsStar.y;
			
			/**	Команда RF_RCTRL */
			/**	Параметр 1 - Наличие радиобрелока ( 0x00 - нет, 0x01 - да; 0x02 - радиоустройство потеряно из-за новой радиостемы ).*/
			/**	Параметр 2 - Разделы, к которым относится радиобрелок ( Битовое поле, указывающее на на строку в PARTITION. */
			/**	Параметр 3 - Событие ContactID, возникающее при нажатии на кнопку “Замок закрыт”;*/
			/**	Параметр 4 - Событие ContactID, возникающее при нажатии на кнопку “Замок открыт”;*/
			/**	Параметр 5 - Событие ContactID, возникающее при нажатии на кнопку “Звездочка”;*/
		}
		private function isCodeVaries():Boolean
		{
			var code:int = 0;
			for( var key:String in PartitionServant.PARTITION ) {
				if ( code == 0 )
					code = PartitionServant.PARTITION[key].code;
				else {
					if ( code != PartitionServant.PARTITION[key].code)
						return true;
				}
			}
			return false;
		}
		override public function putData(p:Package):void
		{
			structureID = p.structure
			globalFocusGroup = 200*(structureID-1)+50;
			refreshCells(operatingCMD);
			var aBrelokInfo:Array = p.data;
			
			old = Boolean( aBrelokInfo[0]==2 );
			getField(operatingCMD,1).setCellInfo( aBrelokInfo[0] );
			
			var list:Array = new Array;
			var allChecked:Boolean = true;
			list.push( {"label":loc("part_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL } );
			
			for( var key:String in PartitionServant.PARTITION ) {
				var _bit:int = p.data[1];
				var selected:int = 0;
				for( var i:int=0; i<16; ++i ) {
					if ( (_bit & int(1<<i)) > 0 && i+1 == int(key) ) {
						selected = 1;
						break;
					}
				}
				if ( selected == 0 )
					allChecked = false;
				var codeX16:String = UTIL.formateZerosInFront( (PartitionServant.PARTITION[key].code as int).toString(16), 4).toUpperCase();
				
				list.push( {"labeldata":PartitionServant.PARTITION[key].section, 
							"label":PartitionServant.PARTITION[key].section + "   " + "("+loc("g_object")+" "+codeX16+")", 
							"data":selected, 
							"block":0 } ); // param = partition (45,65,99 etc)
			}
			if ( allChecked )
				list[0].data = 1;
			(getField(operatingCMD,2) as FSComboCheckBox).setList( list ); 
			
			getField(operatingCMD,3).setCellInfo( aBrelokInfo[2].toString(16) );
			getField(operatingCMD,4).setCellInfo( aBrelokInfo[3].toString(16) );
			getField(operatingCMD,5).setCellInfo( aBrelokInfo[4].toString(16) );
			
			this.dispatchEvent( new Event( UIRadioDeviceRoot.EVENT_LOADED ));
		}
	}
}