package components.screens.opt
{
	import flash.events.Event;
	
	import mx.events.ResizeEvent;
	
	import components.abstract.RegExpCollection;
	import components.abstract.Utility;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboBoxExt;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.visual.wire.WirePanel;
	import components.gui.visual.wire.WireResBlock;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIWire;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptWire extends OptionsBlock
	{
		private var fsWireSelection:FSComboBox;
		private var fsWireTypeSecond:FSShadow;
		
		private var oWire:Object;
		private var aDualData:Array;
		private var aRes:Array;
		private var useDual:Boolean = true;
		private var _width:int = 220;
		private var wirePanel:WirePanel;
		private var hashStructure1st:Object = { 1:0, 2:1, 3:2, 4:3, 5:4, 6:5, 7:6, 8:7 };
		private var hashStructure2nd:Object = { 9:0, 10:1, 11:2, 12:3, 13:4, 14:5, 15:6, 16:7 };
		private var hash16to8:Object = {1:1, 3:2, 5:3, 7:4, 9:5, 11:6, 13:7, 15:8 }
		private var currentWireBlock:OptWireBlock;
		private var currentTreshold:Array;
		private var wireRes:WireResBlock;
		private var aSectionList:Array;
		private var allSectionList:Array;
		
		private var WIRE_IS_CREATING:Boolean = false;
		
		public function OptWire()
		{
			super();
			
			/** Параметр 1 - Вид шлейфа, 0x00 - Нет, 0x01 - Пожарный с питанием, 0x02 - Охранный резистивный, 0x03 - Пожарный без питания, 0x04 - Охранный сухой контакт.*/
			fsWireSelection = createUIElement( new FSComboBox, CMD.ALARM_WIRE_SET, loc("wire_type"), this.changeWire, 1 , UIWire.WIRE_NAMES ) as FSComboBox;
			attuneElement( _width, 165 );
			fsWireSelection.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			wirePanel = new WirePanel(loc("measure_resist_s"));
			addChild( wirePanel );
			wirePanel.visible = false;
			wirePanel.addEventListener( Event.CHANGE, levelChanged );
			wirePanel.f = revert;
			
			wireRes = new WireResBlock;
			addChild( wireRes );
			wireRes.x = 230;
		}
		public function put(_re:Array, _dual:Array, _res:Array, _struct:int ):void
		{
			structureID = _struct;
			aData = _re;
			aDualData = _dual;
			aRes = _res;

			fsWireSelection.focusgroup = (structureID-1)*500+50;
			
			WIRE_IS_CREATING = Boolean(aData[0]==0);
			
			
			var aResFields:Array = wireRes.getFields();
			wireRes.structure = hash16to8[_struct];
			for( var key:String in aResFields ) {
				addUIElement( (aResFields[key] as FormEmpty), CMD.ALARM_WIRE_RES, int(key)+1, wireRes.change, hash16to8[structureID] );
				
			}
			
			wireRes.fill( aRes );
			
			var aLevelFields:Array = wirePanel.getFields();
			for( var keya:String in aLevelFields ) {
				addUIElement( (aLevelFields[keya] as FormEmpty), CMD.ALARM_WIRE_LEVEL, int(keya)+1, null, hash16to8[structureID] ); 
			}
			
			if ( _re[0] == 0xFF ) {
				fsWireSelection.setCellInfo( String(0) );
				createWire( UIWire.TYPE_WIRE_NO );
				RequestAssembler.getInstance().fireEvent( new Request(CMD.ALARM_WIRE_SET, null, getStructure(), [0,0,0,0,0,0,0,0]));
			} else {
				fsWireSelection.setCellInfo( String(_re[0]) );
				createWire( _re[0] );
			}
			distribute_data();
			placeWirePanel();
			wirePanel.visible = false;
		}
		private var hash16toA:Object = { 1:0, 3:2, 5:4, 7:6, 9:8, 11:10, 13:12, 15:14 };
		private function getDataByStructure( struct:int ):Array
		{
			return OPERATOR.dataModel.getData( CMD.ALARM_WIRE_SET )[ hash16toA[struct] ];
		}
		private function getDualStructure( struct:int ):Array
		{
			return OPERATOR.dataModel.getData( CMD.ALARM_WIRE_SET )[ hash16toA[struct]+1 ];
		}
		private function getFreeZone(dual:Boolean=false, firstWireZone:int=0):int
		{
			var a:Array = OPERATOR.dataModel.getData( CMD.ALARM_WIRE_SET );
			var zones:Array = [];
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if ( (!dual && i+1 != structureID ) || ( dual && i != structureID )) {
					if (a[i][0] != 0)
						zones.push( a[i][1] );
				}
			}
			var zone:int = 1;
			len = zones.length;
			while(true) {
				var free:Boolean=true;
				for (i=0; i<len; ++i) {
					if ( zone == zones[i] ) {
						free = false;
						zone++;
						break;
					}
				}
				if (dual) {
					if (zone == firstWireZone) {
						zone++;
						free = false;
					}
				}
				if (free)
					break;
			}
			return zone;
		}
		private function getZoneTypeBySensor(type:int):int
		{
			var zone:int=0;
			switch(type) {
				case UIWire.TYPE_WIRE_GUARD_DRY:
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					var a:Array = OPERATOR.dataModel.getData( CMD.ALARM_WIRE_SET );
					var len:int = a.length;
					var exist:Boolean = false;
					for (var i:int=0; i<len; ++i) {
						if ( i+1 != structureID && (a[i][0] == UIWire.TYPE_WIRE_GUARD_DRY || a[i][0] == UIWire.TYPE_WIRE_GUARD_RESIST ) )
							exist = true;
						i++;
					}
					if (exist)
						zone = CIDServant.ZONE_TYPE_MGNOVENNAYA;
					else
						zone = CIDServant.ZONE_TYPE_VHODNAYA;
					break;
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					zone = CIDServant.ZONE_TYPE_S_PEREZAPROSOM;
					break;
				default:
					break;
			}
			return zone;
		}
		private function getEnterDelay(type:int, zoneYpe:int):int
		{
			var value:int = 0;
			switch(type) {
				case UIWire.TYPE_WIRE_GUARD_RESIST:
				case UIWire.TYPE_WIRE_GUARD_DRY:
					if (zoneYpe == CIDServant.ZONE_TYPE_VHODNAYA)
						value = 30;
					else
						value = 0;
					break;
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					value = 5;
					break;
			}
			return value;
		}
		private function getPartition():int
		{
			if ( UIWire.LAST_PARTITION == 0 || PartitionServant.getPartitonByBitshift(UIWire.LAST_PARTITION) == null )
				UIWire.LAST_PARTITION = PartitionServant.getFirstPartition();
			return UIWire.LAST_PARTITION;
		}
		private function getCID(type:int, dual:Boolean=false, zone:int=0):int
		{
			var value:int = 0;
			switch(type) {
				case UIWire.TYPE_WIRE_GUARD_RESIST:
				case UIWire.TYPE_WIRE_GUARD_DRY:
					if (zone == CIDServant.ZONE_TYPE_VHODNAYA)
						value = 0x1341;
					else
						value = 0x1301;
					break;
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					if (dual)
						value = 0x1101;
					else
						value = 0x1181;
					break;
			}
			return value;
		}
		private function distribute_data():void
		{
			for( var key:String in aCells ) {
				
				var fs:IFormString = aCells[key] as IFormString;
				
				switch( fs.param ) {
					case 1:	// тип шлейфп
						continue;
						break;
					case 2:	// номер зоны
						if (WIRE_IS_CREATING) {
							aData[ hashStructure1st[fs.param]] = getFreeZone();
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 3:	// нормальнео состояние
						switch( type ) {
							case UIWire.TYPE_WIRE_FIRE_BATTERY:
								if ( aData[ hashStructure1st[fs.param] ] != 0 ) {
									aData[ hashStructure1st[fs.param]] = 0;
									SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
								}
								break;
							case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
								if ( aData[ hashStructure1st[fs.param] ] != 1 ) {
									aData[ hashStructure1st[fs.param]] = 1;
									SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
								}
								break;
							case UIWire.TYPE_WIRE_GUARD_DRY:
							case UIWire.TYPE_WIRE_GUARD_RESIST:
								if (WIRE_IS_CREATING) {
									aData[ hashStructure1st[fs.param]] = 1;
									SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
								}
								break;
						}
						break;
					case 4:	// тип зоны
						if (WIRE_IS_CREATING) {
							aData[ hashStructure1st[fs.param]] = getZoneTypeBySensor( type );
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 5:	// задержка на вход
						if (WIRE_IS_CREATING ) {
							aData[ hashStructure1st[fs.param]] = getEnterDelay(type,aData[3]);
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 6:	// Partition
						if (WIRE_IS_CREATING ) {
							aData[ hashStructure1st[fs.param]] = getPartition();
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 10:	// номер зоны 2
						if (type == UIWire.TYPE_WIRE_GUARD_RESIST && WIRE_IS_CREATING) {
							aDualData[ hashStructure2nd[fs.param]] = getFreeZone(true, aData[1] );
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 11:	// нормальнео состояние 2
						switch( type ) {
							case UIWire.TYPE_WIRE_GUARD_DRY:
							case UIWire.TYPE_WIRE_GUARD_RESIST:
								if (WIRE_IS_CREATING) {
									aDualData[ hashStructure2nd[fs.param]] = 1;
									SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
								}
								break;
						}
						break;
					case 12:	// тип зоны 2
						if (WIRE_IS_CREATING) {
							aDualData[ hashStructure2nd[fs.param]] = getZoneTypeBySensor( type );
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 13:	// задержка на вход 2
						if (WIRE_IS_CREATING) {
							aDualData[ hashStructure2nd[fs.param]] = getEnterDelay(type,aDualData[3]);
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 14:	// Partition
						if (WIRE_IS_CREATING ) {
							aDualData[ hashStructure2nd[fs.param] ] = getPartition();
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						break;
					case 8:
						if (WIRE_IS_CREATING ) {
							aData[ hashStructure1st[fs.param]] = getCID(type,false,aData[ hashStructure1st[4]]);
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						
						
						fs.setCellInfo( Number( aData[ hashStructure1st[fs.param]] ).toString(16) );
						continue;
						break;
					case 16:
						if (WIRE_IS_CREATING ) {
							aDualData[ hashStructure2nd[fs.param]] = getCID(type,true,aDualData[ hashStructure2nd[12]]);
							SavePerformer.remember( getStructure(),  (aCells[key] as IFormString) );
						}
						fs.setCellInfo(  Number(aDualData[ hashStructure2nd[fs.param]] ).toString(16) );
						continue;
						break;
				}
				
				if ( fs.param > aData.length )
					fs.setCellInfo( String(aDualData[ hashStructure2nd[fs.param]] ) );
				else
					fs.setCellInfo( String( aData[ hashStructure1st[fs.param]] ) );
			}
			switch( type ) {
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					onZoneDual();
				case UIWire.TYPE_WIRE_GUARD_DRY:
					onZone();
					break;
			}
			
			switch( type ) {
				case UIWire.TYPE_WIRE_GUARD_RESIST:
				case UIWire.TYPE_WIRE_GUARD_DRY:
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					width = 880;
					height = 725;
					break;
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					width = 880;
					height = 790;
					break;
				default:
					width = 570;
					height = 200;
					break;
			}
			this.dispatchEvent( new ResizeEvent(ResizeEvent.RESIZE));
			
			var f:IFormString = getField( CMD.ALARM_WIRE_SET, 6);
			if (f) {
				(f as FSComboBox).setList( aSectionList );
				f.disabled = Boolean(type == UIWire.TYPE_WIRE_NO);
			}
			f = getField( CMD.ALARM_WIRE_SET, 14);
			if (f) {
				(f as FSComboBox).setList( aSectionList );
				f.disabled = Boolean(type == UIWire.TYPE_WIRE_NO);
			}
		}
		
		private function revert():void
		{
			changeWire(fsWireSelection);
		}
		private function createWire( _type:int ):void
		{
			globalFocusGroup = (structureID-1)*500+50;
			wireRes.focusgroup( globalFocusGroup + 100 ); // необходимо обновлять фокусгруппу во время создания нового шлейфа
			//wires
			// надо отключать валидацию при _type == 0
			var f:IFormString = getField( CMD.ALARM_WIRE_SET, 6);
			if (f)
				f.disabled = Boolean(_type == UIWire.TYPE_WIRE_NO);
			f = getField( CMD.ALARM_WIRE_SET, 14);
			if (f)
				f.disabled = Boolean(_type == UIWire.TYPE_WIRE_NO);
				
			aCells.length = 1;
			if (fsWireTypeSecond)
				aCells.push( fsWireTypeSecond );
			
			if ( !oWire )
				oWire = new Object;
			
			for( var key:String in oWire )
				(oWire[key] as OptWireBlock).visible = false;
			
			useDual = Boolean( _type == UIWire.TYPE_WIRE_GUARD_RESIST );
			
			if ( oWire[_type] is OptWireBlock ) {
				( oWire[_type] as OptWireBlock ).visible = true;
				aCells = aCells.concat( ( oWire[_type] as OptWireBlock ).getCells() );
				
				currentWireBlock = ( oWire[_type] as OptWireBlock );
				refreshCells(CMD.ALARM_WIRE_SET);
				return;
			}
			
			if ( _type == UIWire.TYPE_WIRE_NO ) {
				wirePanel.visible = false;
				wireRes.show(_type,0);
				return;
			}
				
			var _small:int = 60;
			var _medium:int = 120;
			var _long:int = 180;
			
			var block:OptWireBlock = new OptWireBlock( _width, useDual );
			currentWireBlock = block;
			addChild( block );
			
			/** Параметр 2 - Номер зоны, 0x00 - Нет, 1-999 - номер зоны; */
			addUIElement( block.put( OptWireBlock.GUIE_COMBOBOX, loc("guard_zonenum"), UTIL.comboBoxNumericDataGenerator(1,99), _small ),
				CMD.ALARM_WIRE_SET, 2, changeZone );
			(getLastElement() as FSComboBox).restrict( "0-9",3);
			
			/** Параметр 3 - Нормальное состояние, 0x00 - разомкнутое, 0x01 - замкнутое; */
			addUIElement( block.put( 
				OptWireBlock.GUIE_COMBOBOX, loc("guard_norm"),	[{data:0x00, label:loc("wire_state_open").toLowerCase()},
					{data:0x01, label:loc("wire_state_closed").toLowerCase()} ], _medium ), 
				CMD.ALARM_WIRE_SET, 3, changeResistorState );
			
			switch( _type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					elementEnabled(false);
					break;
				default:
					elementEnabled(true);
					break;
			}
			
			/**Параметр 4 - Тип зоны - 0x00 - нет, 0x01 - проходная, 0x02 - входная, 0x03 - 24 часа, 0x04 - Мгновенная, 0x05 - Ключевая, 0x06 - с перезапросом (сброс пожарного извещателя), 0x07 - без перезапроса ( без сброса пожарного извещателя);*/
			switch( _type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					addUIElement( block.put( OptWireBlock.GUIE_COMBOBOX, loc("g_zonetype"), CIDServant.getZoneTypeBySensor(CIDServant.WIRE_FIRE_BATTERY), _medium ), CMD.ALARM_WIRE_SET, 4 );
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
				case UIWire.TYPE_WIRE_GUARD_DRY:
					addUIElement( block.put( OptWireBlock.GUIE_COMBOBOX, loc("g_zonetype"), CIDServant.getZoneTypeBySensor(), _medium ), CMD.ALARM_WIRE_SET, 4, onZone );
					break;
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					addUIElement( block.put( OptWireBlock.GUIE_SHADOW, "", null, 0 ) as FSShadow, CMD.ALARM_WIRE_SET, 4 );
					getLastElement().setCellInfo(7);
					break;
			}	
			getLastElement().attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			switch( _type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					/** Параметр 5 - Задержка на вход/сброс шлейфа ( 0- нет задержки или 0 - при пожарном шлейфе, без перезапроса состояния ); */
					addUIElement( block.put( OptWireBlock.GUIE_TEXT, loc("wire_reset_time_fire"),null, _small ),
						CMD.ALARM_WIRE_SET, 5 );
					break;
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					addUIElement( block.put( OptWireBlock.GUIE_SHADOW, "", null, 0 ) as FSShadow, CMD.ALARM_WIRE_SET, 5 );
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					/** Параметр 5 - Задержка на вход/сброс шлейфа ( 0- нет задержки или 0 - при пожарном шлейфе, без перезапроса состояния ); */
					addUIElement( block.put( OptWireBlock.GUIE_TEXT, loc("wire_enter_delay"),null, _small ), 
						CMD.ALARM_WIRE_SET, 5 );
					break;
				case UIWire.TYPE_WIRE_GUARD_DRY:
					/** Параметр 5 - Задержка на вход/сброс шлейфа ( 0- нет задержки или 0 - при пожарном шлейфе, без перезапроса состояния ); */
					addUIElement( block.put( OptWireBlock.GUIE_TEXT, loc("wire_enter_delay"),null, _small ), 
						CMD.ALARM_WIRE_SET, 5 );
					break;
			}
			if (_type != UIWire.TYPE_WIRE_FIRE_NOBATTERY) {
				var field:FormEmpty = getLastElement() as FormEmpty;
				field.restrict("0-9",3);
				field.rule = new RegExp( RegExpCollection.REF_0to255 );
			}

			/** Параметр 6 - Раздел - ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Если Параметр 7 "Мастер раздела" не равен 0, то раздел задается числом 1-99; */
			addUIElement( block.put( OptWireBlock.GUIE_COMBOBOX, loc("guard_partnum"),PartitionServant.getPartitionList(), _small ),	CMD.ALARM_WIRE_SET, 6 );
			(getLastElement() as FSComboBox).restrict( "0-9",2);
			
			/** Параметр 7 - Мастер раздела - адрес прибора, которому принадлежит зона из раздела - 1-254; */
			addUIElement( block.put( OptWireBlock.GUIE_SHADOW, "", null, 0 ) as FSShadow, CMD.ALARM_WIRE_SET, 7);
			
			switch( _type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					/** Параметр 8 - Событие, при срабатывании зоны - Событие ContactID. */
					addUIElement( block.put( OptWireBlock.GUIE_COMBOBOXEXT, loc("wire_event_1fire_sensor"), CIDServant.getEvent( CIDServant.CID_WIRE_FIRE ), _long ), 
						CMD.ALARM_WIRE_SET, 8 );
					(getLastElement() as FSComboBoxExt).attune( FSComboBox.F_RETURNS_HEXDATA );
					(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent(CIDServant.CID_WIRE_ALL) );
					
					/** Параметр 1(9) четная структура - Вид шлейфа, 0x00 - Нет, 0x01 - Пожарный с питанием, 0x02 - Охранный резистивный, 0x03 - Пожарный без питания, 0x04 - Охранный сухой контакт.*/
					fsWireTypeSecond = createUIElement( new FSShadow, CMD.ALARM_WIRE_SET, "",null,9 ) as FSShadow;
					
					/** Параметр 8(16) четная структура  - Событие, при срабатывании зоны - Событие ContactID. */
					addUIElement( block.put( OptWireBlock.GUIE_COMBOBOXEXT, loc("wire_event_2fire_sensor"), CIDServant.getEvent( CIDServant.CID_WIRE_FIRE ), _long ), 
						CMD.ALARM_WIRE_SET, 16 );
					(getLastElement() as FSComboBoxExt).attune( FSComboBox.F_RETURNS_HEXDATA );
					(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent(CIDServant.CID_WIRE_ALL) );
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					/** Параметр 8 - Событие, при срабатывании зоны - Событие ContactID. */
					addUIElement( block.put( OptWireBlock.GUIE_COMBOBOXEXT, loc("wire_event_zone"), CIDServant.getEvent( CIDServant.CID_WIRE_GUARD ), _long ), 
						CMD.ALARM_WIRE_SET, 8 );
					(getLastElement() as FSComboBoxExt).attune( FSComboBox.F_RETURNS_HEXDATA );
					(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent(CIDServant.CID_WIRE_ALL) );
					/** Параметр 1(9) четная структура - Вид шлейфа, 0x00 - Нет, 0x01 - Пожарный с питанием, 0x02 - Охранный резистивный, 0x03 - Пожарный без питания, 0x04 - Охранный сухой контакт.*/
					fsWireTypeSecond = createUIElement( new FSShadow, CMD.ALARM_WIRE_SET, "",null,9 ) as FSShadow;
					break;
				case UIWire.TYPE_WIRE_GUARD_DRY:
					/** Параметр 8 - Событие, при срабатывании зоны - Событие ContactID. */
					addUIElement( block.put( OptWireBlock.GUIE_COMBOBOXEXT, loc("wire_event_triggers"), CIDServant.getEvent( CIDServant.CID_WIRE_GUARD ), _long ), 
						CMD.ALARM_WIRE_SET, 8 );
					(getLastElement() as FSComboBoxExt).attune( FSComboBox.F_RETURNS_HEXDATA );
					(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent(CIDServant.CID_WIRE_ALL) );
					break;
			}
			
			if ( useDual ) {
				/** Параметр 2 - Номер зоны, 0x00 - Нет, 1-999 - номер зоны; */
				addUIElement( block.aDual[0], CMD.ALARM_WIRE_SET, 10, changeZone );
				(getLastElement() as FSComboBox).restrict( "0-9",3);
				
				/** Параметр 3 - Нормальное состояние, 0x00 - разомкнутое, 0x01 - замкнутое; */
				addUIElement( block.aDual[1], CMD.ALARM_WIRE_SET, 11, changeResistorState );
				
				/**Параметр 4 - Тип зоны - 0x00 - нет, 0x01 - проходная, 0x02 - входная, 0x03 - 24 часа, 0x04 - Мгновенная, 0x05 - Ключевая, 0x06 - с перезапросом (сброс пожарного извещателя), 0x07 - без перезапроса ( без сброса пожарного извещателя);*/
				addUIElement( block.aDual[2], CMD.ALARM_WIRE_SET, 12, onZoneDual );
				(getLastElement() as FSComboBox).attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
				
				/** Параметр 5 - Задержка на вход/сброс шлейфа ( 0- нет задержки или 0 - при пожарном шлейфе, без перезапроса состояния ); */
				addUIElement( block.aDual[3], CMD.ALARM_WIRE_SET, 13 );
				field = getLastElement() as FormEmpty;
				field.restrict("0-9",3);
				field.rule = new RegExp( RegExpCollection.REF_0to255 );
				
				/** Параметр 6 - Раздел - ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Если Параметр 7 "Мастер раздела" не равен 0, то раздел задается числом 1-99; */
				addUIElement( block.aDual[4], CMD.ALARM_WIRE_SET, 14 );
				(getLastElement() as FSComboBox).restrict( "0-9",2);
				
				/** Параметр 7 - Мастер раздела - адрес прибора, которому принадлежит зона из раздела - 1-254; */
				addUIElement( block.aDual[5], CMD.ALARM_WIRE_SET, 15 );
				
				/** Параметр 8 - Событие, при срабатывании зоны - Событие ContactID. */
				addUIElement( block.aDual[6], CMD.ALARM_WIRE_SET, 16 );
				(getLastElement() as FSComboBox).attune( FSComboBox.F_RETURNS_HEXDATA );
				(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent(CIDServant.CID_WIRE_ALL) );
			}
			
			block.finish();
			block.y = globalY;
			
			refreshCells( CMD.ALARM_WIRE_SET);
			oWire[_type] = block;
		}
		private function buildWireDiagramm():void
		{
			var arr:Array;
			
			/** Параметр 2 - Номер зоны, 0x00 - Нет, 1-999 - номер зоны; */
			var zoneNum:int = int( this.getField(CMD.ALARM_WIRE_SET,2).getCellInfo() );
			/** Параметр 3 - Нормальное состояние, 0x00 - разомкнутое, 0x01 - замкнутое; */ 
			var closedInt:int = int( this.getField(CMD.ALARM_WIRE_SET,3).getCellInfo() );
			var closed:Boolean = Boolean(closedInt==1);
			
			var thr:Array;
			var aRes:Array;
			var norm:Number;
			var first:Number;
			var second:Number;
			var all:Number;
			
			// высчитываются сопротивления для каждого из шлейфов
			switch( type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					wireRes.show(type,0,WIRE_IS_CREATING);
					aRes = wireRes.getResitors();
					
					norm = 	 3;//6700;//16000;
					first =	 4;//4100;//10000;
					second = 5;//3100;//7000;
					all =	 6;//2300;//3000;
					
					thr = [3818,3817,3198,2517,1808,879,710];
					break;
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					wireRes.show(type,1,WIRE_IS_CREATING);
					aRes = wireRes.getResitors();

					norm =	 6;//2300;//aRes[0]; // 2.4
					first =	 5;//3400;//aRes[0] + aRes[0]; // 4.8
					second = 4;//4400;//aRes[0] + aRes[0] + aRes[0]; // 7.2
					all =	 3;//8200;//aRes[0] + aRes[0] + aRes[0] + aRes[0]; // 9.6
					
					thr = [3818,3817,2778,1712,1245,879,710];
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					/** Параметр 2 - Номер зоны, 0x00 - Нет, 1-999 - номер зоны; */
					var zoneNumSecond:int = int( this.getField(CMD.ALARM_WIRE_SET,10).getCellInfo() );//  int((aDualCells[0] as IFormString).getCellInfo());
					var closedIntSecond:int = int( this.getField(CMD.ALARM_WIRE_SET,11).getCellInfo() );//int((aDualCells[1] as IFormString).getCellInfo());
					var bit:int = Utility.calcCreateBitfield( [closedInt,closedIntSecond] );
					wireRes.show(type,bit,WIRE_IS_CREATING );
					
					
					//	+ALARM_WIRE_LEVEL=X, ,3818,3024,2392,1576,1014,
					//	10 6.3 
					thr = [3818,3817,3024,2392,1576,879,710];
					aRes = wireRes.getResitors();
					
					switch( bit ) {
						case 0: // 0 0
							norm = 		3;//8200;//1/(1/aRes[0]); // 10
							first = 	4;//4400;//1/(1/aRes[0]+1/aRes[1]); // 4.51
							second = 	5;//3400;//1/(1/aRes[0]+1/aRes[2]); // 3.38
							all = 		6;//2300;//1/(1/aRes[0]+1/aRes[1]+1/aRes[2]); // 2.39
							// записываем порядок зон для отображения тревоги датчика на картинке
							Utility.GUARD_RESIST_ALL = 2;
							Utility.GUARD_RESIST_FIRST= 4;
							Utility.GUARD_RESIST_SECOND = 3;
							break;
						case 1:// 0 1
							norm = 		4;//4400;//1/(1/aRes[0] + 1/aRes[1]); // 4.51
							first = 	3;//8200;//1/(1/aRes[0] ); // 10.0
							second = 	6;//2300;//1/(1/aRes[0]+1/aRes[1]+1/aRes[2]); // 2.39
							all = 		5;//3400;//1/(1/aRes[0]+1/aRes[2]); // 3.38
							// записываем порядок зон для отображения тревоги датчика на картинке
							Utility.GUARD_RESIST_ALL = 3;
							Utility.GUARD_RESIST_FIRST= 5;
							Utility.GUARD_RESIST_SECOND = 2;
							break;
						case 2:// 1 0
							norm = 		5;//3400;//1/(1/aRes[0] + 1/aRes[2]); // 3.38
							first = 	6;//2300;//1/(1/aRes[0]+1/aRes[1]+1/aRes[2]); // 2.39 
							second = 	3;//8200;//1/(1/aRes[0] ); // 10.0
							all = 		4;//4400;//1/(1/aRes[0]+1/aRes[1] ); // 4.51
							// записываем порядок зон для отображения тревоги датчика на картинке
							Utility.GUARD_RESIST_ALL = 4;
							Utility.GUARD_RESIST_FIRST= 2;
							Utility.GUARD_RESIST_SECOND = 5;
							break;
						case 3:// 1 1
							norm = 		6;//2300;//1/(1/aRes[0]+1/aRes[1]+1/aRes[2]); // 2.39
							first = 	5;//3400;//1/(1/aRes[0]+1/aRes[2]); // 3.38
							second = 	4;//4400;//1/(1/aRes[0]+1/aRes[1]); // 4.51
							all = 		3;//8200;//1/(1/aRes[0]); // 10.0
							// записываем порядок зон для отображения тревоги датчика на картинке
							Utility.GUARD_RESIST_ALL = 5;
							Utility.GUARD_RESIST_FIRST= 3;
							Utility.GUARD_RESIST_SECOND = 4;
							break;
					}
					break;
				case UIWire.TYPE_WIRE_GUARD_DRY:
					// записываем порядок зон для отображения тревоги датчика на картинке
					Utility.GUARD_DRY_OPEN = closed;
					if ( closed )
						arr = [ {label:loc("wire_state_alarm_zone")+" "+zoneNum,color:0xF15A29, acp:UIWire.MIN_LEVEL_ACP}, {label:loc("wire_norm"),color:0x1C75BC, acp:UIWire.MAX_LEVEL_ACP}];
					else
						arr = [ {label:loc("wire_norm"),color:0x1C75BC, acp:UIWire.MIN_LEVEL_ACP}, {label:loc("wire_state_alarm_zone")+" "+zoneNum,color:0xF15A29, acp:UIWire.MAX_LEVEL_ACP}];
					wireRes.show(type,closedInt,WIRE_IS_CREATING);
					break;
			}
			// генерятся названия зона и прочее, заодно каждому значению присваевается значение в ОМах
			switch( type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					arr = [ {label:loc("wire_short_circuit"),color:0xF15A29, acp:7}, {label:loc("wire_norm"),color:0x39B54A, acp:norm}, 
						{label:loc("wire_atention_zone")+" "+zoneNum,color:0xC49A6C, acp:first}, {label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E, acp:second,passive:true}, 
						{label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E, acp:all}, {label:loc("wire_cut"),color:0x1C75BC, acp:0 }];
					break;
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					arr = [ {label:loc("wire_short_circuit"),color:0xF15A29, acp:7}, {label:loc("wire_norm"),color:0x39B54A, acp:norm}, 
						{label:loc("wire_atention_zone")+" "+zoneNum,color:0xC49A6C, acp:first}, {label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E, acp:second}, 
						{label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E, acp:all,passive:true}, {label:loc("wire_cut"),color:0x1C75BC, acp:0 }];
					//0x9E1F63
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					arr = [ {label:loc("wire_short_circuit"),color:0xF15A29, acp:7}, {label:loc("wire_norm"),color:0x39B54A, acp:norm }, 
						{label:loc("wire_state_alarm_zone")+" "+zoneNum,color:0xC49A6C, acp:first }, {label:loc("wire_state_alarm_zone")+" "+zoneNumSecond,color:0xF7941E, acp:second }, 
						{label:loc("wire_state_alarm_zones")+" "+zoneNum+" и "+zoneNumSecond,color:0x9E1F63, acp:all}, {label:loc("wire_cut"),color:0x1C75BC, acp:0 }];
					break;
			}
			
			wireRes.y = wirePanel.y + wirePanel.height + 20;
			// генерится цветная панель в правильном порядке
			arr.sortOn( "acp", Array.NUMERIC );
			wirePanel.build( arr );
			
			// генерится линейка казателей на цветной панели
			switch( type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					 
					if ( !WIRE_IS_CREATING ) { // Если загружается страница
						if ( currentTreshold ) {
							wirePanel.put( currentTreshold );
						}
					} else { // Если шлеф изменили после загрузки страниы
						wirePanel.put(thr.reverse())
					}
					break;
				case UIWire.TYPE_WIRE_GUARD_DRY:
					wirePanel.put( [ UIWire.MIN_LEVEL_ACP, Utility.mathOMtoACP(UIWire.MIDDLE_DRY_TIMELINE_OM) , UIWire.MAX_LEVEL_ACP ]);
					break;
			}
			// Переменная false, когда шлейф генерится, а не приходит с сервера
			WIRE_IS_CREATING = false;
		}
		private function placeWirePanel():void
		{
			if ( int(fsWireSelection.getCellInfo()) > 0 ) {
				wirePanel.visible = true;
				wirePanel.y = currentWireBlock.y + currentWireBlock.height+ 60;
				buildWireDiagramm();
			}
		}
		public function putThreshold(re:Array):void
		{
			currentTreshold = re;
			placeWirePanel();
//			if ( wirePanel.visible )
//				wirePanel.put(re);
			if ( type != UIWire.TYPE_WIRE_NO ) {
				wirePanel.visible = true;
				wirePanel.put(re);
			}
		}
		public function putWireResistance(resist:int, zone:int ):void
		{
			wirePanel.putWireResistance( resist );
			wireRes.putState(zone);
		}
		public function get needUpdate():Boolean
		{
			return wirePanel.visible;
		}
		private function changeWire(target:IFormString ):void
		{
			WIRE_IS_CREATING = true;
			
			createWire( int(fsWireSelection.getCellInfo()) );
			aData = getDataByStructure(getStructure()).slice();
			aDualData = getDualStructure(getStructure()).slice();
			
			distribute_data();
			
			if ( type == UIWire.TYPE_WIRE_GUARD_RESIST )
				fsWireTypeSecond.setCellInfo( String(UIWire.TYPE_WIRE_GUARD_RESIST));
			else {
				if( fsWireTypeSecond )
					fsWireTypeSecond.setCellInfo( "0" );
			}
			
			placeWirePanel();
			SavePerformer.remember( getStructure() , target );
			SavePerformer.remember( hash16to8[getStructure()] , wirePanel.getTarget() );
		}
		private function changeResistorState(target:IFormString ):void
		{
			WIRE_IS_CREATING = true;
			buildWireDiagramm();
			SavePerformer.remember( getStructure() , target );
			SavePerformer.remember( hash16to8[getStructure()] , wirePanel.getTarget() );
		}
		private function changeZone(target:IFormString ):void
		{
			/** Параметр 2 - Номер зоны, 0x00 - Нет, 1-999 - номер зоны; */
			var zoneNum:int = int( this.getField(CMD.ALARM_WIRE_SET,2).getCellInfo() );
			
			var arr:Array;
			switch( type ) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					arr = [ {label:loc("wire_short_circuit"),color:0xF15A29}, {label:loc("wire_norm"),color:0x39B54A}, 
						{label:loc("wire_atention_zone")+" "+zoneNum,color:0xC49A6C}, {label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E,passive:true}, 
						{label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E},{label:loc("wire_cut"),color:0x1C75BC} ];
					break;
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					arr = [ {label:loc("wire_short_circuit"),color:0xF15A29}, {label:loc("wire_norm"),color:0x39B54A}, 
						{label:loc("wire_atention_zone")+" "+zoneNum,color:0xC49A6C}, {label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E}, 
						{label:loc("wire_fire_zone")+" "+zoneNum,color:0xF7941E,passive:true},{label:loc("wire_cut"),color:0x1C75BC} ];
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					var zoneNumSecond:int = int( this.getField(CMD.ALARM_WIRE_SET,10).getCellInfo() );
					arr = [ {label:loc("wire_short_circuit"),color:0xF15A29}, {label:loc("wire_norm"),color:0x39B54A}, 
						{label:loc("wire_state_alarm_zone")+" "+zoneNum,color:0xC49A6C}, {label:loc("wire_state_alarm_zone")+" "+zoneNumSecond,color:0xF7941E}, 
						{label:loc("wire_state_alarm_zones")+" "+zoneNum+" и "+zoneNumSecond,color:0x9E1F63},{label:loc("wire_cut"),color:0x1C75BC} ];
					break;
				case UIWire.TYPE_WIRE_GUARD_DRY:
					if ( Utility.GUARD_DRY_OPEN )
						arr = [ {label:loc("wire_state_alarm_zone")+" "+zoneNum,color:0xF15A29, acp:UIWire.MIN_LEVEL_ACP}, {label:loc("wire_norm"),color:0x1C75BC, acp:UIWire.MAX_LEVEL_ACP}];
					else
						arr = [ {label:loc("wire_norm"),color:0x1C75BC, acp:UIWire.MIN_LEVEL_ACP}, {label:loc("wire_state_alarm_zone")+" "+zoneNum,color:0xF15A29, acp:UIWire.MAX_LEVEL_ACP}];
					break;
			}
			
			wirePanel.rename(arr);
			
			SavePerformer.remember( getStructure() , target );
		}
		public function set section( value:Array ):void
		{
			var field:FormEmpty = getField( CMD.ALARM_WIRE_SET,6) as FormEmpty;
			var field2:FormEmpty = getField( CMD.ALARM_WIRE_SET,14) as FormEmpty;
			aSectionList = value;
			if ( field ) field.setList( aSectionList );
			if ( field2 ) field2.setList( aSectionList );
		}
		public function set allSection( value:Array ):void
		{
			allSectionList = value;
		}
		private function get type():int
		{
			return int( fsWireSelection.getCellInfo() );
		}
		private function levelChanged(ev:Event=null):void
		{
			SavePerformer.remember( hash16to8[getStructure()] , wirePanel.getTarget() );
		}
		override protected function remember(target:IFormString):void
		{
			if( target.cmd == CMD.ALARM_WIRE_SET )
				SavePerformer.remember( getStructure(), target );
			else {
				SavePerformer.remember( hash16to8[ getStructure() ], target );
			}
		}
		private function onZone(t:IFormString=null):void
		{// нужно блокировать задержку если зона не входная
			var f:IFormString;
			if (t)
				f = t;
			else
				f = getField(CMD.ALARM_WIRE_SET, 4);
			
			doZoneLogic(f, getField(CMD.ALARM_WIRE_SET,5), Boolean(t!=null));
			
			if (t)
				SavePerformer.remember(getStructure(), t);
		}
		private function onZoneDual(t:IFormString=null):void
		{// нужно блокировать задержку если зона не входная
			var f:IFormString;
			if (t)
				f = t;
			else
				f = getField(CMD.ALARM_WIRE_SET, 12);
			
			doZoneLogic(f, getField(CMD.ALARM_WIRE_SET,13),Boolean(t!=null));
			
			if (t)
				SavePerformer.remember(getStructure(), t);
		}
		private function doZoneLogic(f:IFormString, delay:IFormString, changeInfo:Boolean):void
		{
			// Если зона не входная
			if( int(f.getCellInfo()) != 2 ) {
				if( changeInfo)
					delay.setCellInfo(0);
				delay.disabled = true;
			} else {
				if( changeInfo )
					delay.setCellInfo(30);
				delay.disabled = false;
			}
		}
	}
}