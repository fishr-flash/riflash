package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.adapter.AdapterCID;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboBoxExt;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.Zebra;
	import components.gui.visual.wire.SimpleWireRes;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.ui.UIWire;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public final class OptWire extends OptionsBlock
	{
		private var wireRes:SimpleWireRes;
		private var zebra:Zebra;
		
		public function OptWire()
		{
			super();
			
			var globalWidth:int = 300;
			
			zebra = new Zebra(7);
			zebra.y = -5;
			addChild( zebra );
			
			operatingCMD = CMD.K7_ALARM_WIRE_SET;
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("wire_type"), null, 1 );
			attuneElement( globalWidth, 300, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setCellInfo(loc("wire_type_guard_without_res"));
			FLAG_SAVABLE = true;
			
			createUIElement( new FSComboBox, operatingCMD,loc("guard_zonenum"),callChangeZone,1, UTIL.comboBoxNumericDataGenerator( 1, 99 ), "0-9",2,new RegExp(RegExpCollection.REF_1to99));
			attuneElement( globalWidth, 50 );
			
			createUIElement( new FSComboBox, operatingCMD, loc("guard_norm"),callChangeState,2, [{label:loc("ui_out_closed"), data:0 }, {label:loc("ui_out_opened"), data:1 }] );
			attuneElement( globalWidth, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSComboBox, operatingCMD,loc("rf_sen_zone_type"),onZoneType,3, UIWire.ZONE_TYPE_NAMES );
			attuneElement( globalWidth, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSSimple, operatingCMD, loc("wire_delay"), null, 4, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) );
			attuneElement( globalWidth, 50 );
			
			createUIElement( new FSComboBox, operatingCMD,loc("guard_partnum"),null,5 );
			attuneElement( globalWidth, 50, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			PartitionServant.getPartitionList()
			
			createUIElement( new FSShadow, operatingCMD, "", null, 6 );
			
			createUIElement( new FSComboBoxExt, operatingCMD,loc("guard_trigger_event"),null,7, CIDServant.getEvent(CIDServant.CID_WIRE_GUARD) );
			attuneElement( globalWidth, 250, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent() );
			(getLastElement() as FSComboBoxExt).setAdapter(new AdapterCID);
			
			drawSeparator(600);
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("wire_config_settings"), null, 1 );
			FLAG_SAVABLE = true;
			
			wireRes = new SimpleWireRes;
			addChild( wireRes );
			wireRes.y = globalY + 20;
			globalY += wireRes.height + 40;
			
			drawSeparator(600);
		}
		public function get state():int
		{
			return int(getField(operatingCMD,2).getCellInfo());
		}
		override public function putData(p:Package):void
		{
			structureID = p.structure;
			globalFocusGroup = (structureID-1)*1000+100;
			refreshCells( operatingCMD );
			(getField( operatingCMD, 5 ) as FSComboBox).setList( PartitionServant.getPartitionList() );
			
		//	var cb:FSComboBox = getField( operatingCMD, 7 ) as FSComboBox;
		//	cb.disabled = true;
			
			distribute( p.getStructure(), operatingCMD );

			var f:Array = PartitionServant.getPartitionList();
			
		//	cb.setCellInfo( int(p.getStructure()[6]).toString(16) );
		//	cb.disabled = false;
			
			wireRes.zone = p.getStructure()[0];
			wireRes.state( p.getStructure()[1] == 0 );
			
			onZoneType();
		}
		override public function putState(re:Array):void
		{
			wireRes.open( re[0] == 1 );
		}
		private function callChangeZone(t:IFormString):void
		{
			wireRes.zone = int(t.getCellInfo());
			SavePerformer.remember(structureID,t);
		}
		private function callChangeState(t:IFormString):void
		{
			this.dispatchEvent( new Event( "ChangeState" ));
			wireRes.state( int(t.getCellInfo()) == 0 );
			SavePerformer.remember(structureID,t);
		}
		private function onZoneType(t:IFormString=null):void
		{
			var f:IFormString = getField(operatingCMD,3);
			
			if( f.getCellInfo() != "2" ) {
				getField(operatingCMD,4).disabled = true;
				if (t)
					getField(operatingCMD,4).setCellInfo(0);
			} else {
				getField(operatingCMD,4).disabled = false;
				if (t)
					getField(operatingCMD,4).setCellInfo(30);
			}
				
			if (t)
				SavePerformer.remember(getStructure(), t);
		}
	}
}