package components.screens.opt
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.controls.ProgressBar;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.RFSensorServant;
	import components.abstract.servants.TabOperator;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionListBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboBoxExt;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIRadioSystem;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.RF_FUNCT;
	import components.static.RF_STATE;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptRFSensor extends OptionListBlock
	{
		private var TYPE:int;		// тип датчика
		
		private var sdisabled:Sprite;
		private var oldselection:Sprite;
		private var tnumPP:FormString;
		private var pBar:ProgressBar;
		private var block:Sprite;
		
		private var tStatus:FormString;
		private var tZoneNum:FormString;
		private var bRestoreSensor:TextButton;
		private var bCancelSensor:TextButton
		
		private var _isKeyZone:Boolean;
		
		private var tMultyPartBox:FormEmpty;
		
		private var mirrorCBox:FormEmpty;
		
		public function get isKeyZone():Boolean
		{
			return _isKeyZone;
		}
		
		
		public function OptRFSensor(n:int)
		{
			super();
			structureID = n;
			FLAG_VERTICAL_PLACEMENT = false;
			drawSelection(1010);
			construct()
		}
		//override protected function drawSelection(_width:int):void 	{}
		
		
		
		private function construct():void 
		{
			TabOperator.getInst().resetOrder();
			globalFocusGroup = 100*structureID;
			
			const wdth:int = 1010
			
			selection = new Sprite;
			addChild( selection );
			selection.graphics.beginFill( 0xcde0f2 );
			selection.graphics.drawRect(-18,-1,wdth,23);
			selection.graphics.endFill();
			selection.visible = false;
			
			sdisabled = new Sprite;
			addChild( sdisabled );
			sdisabled.graphics.beginFill( 0xffffff, 0.8 );
			sdisabled.graphics.drawRect(-18,-1,wdth,23);
			sdisabled.graphics.endFill();
			sdisabled.visible = false;
			
			oldselection = new Sprite;
			addChild( oldselection );
			oldselection.graphics.beginFill( 0xff0000, 0.2 );
			oldselection.graphics.drawRect(-18,-1,wdth,23);
			oldselection.graphics.endFill();
			oldselection.visible = false;
			
			tnumPP = new FormString;
			addChild( tnumPP );
			tnumPP.setWidth( 100 );
			tnumPP.setName( String(structureID) );
			
			var place:int = 0;
			operatingCMD = CMD.RF_SENSOR;
			
			createUIElement( new FSShadow, operatingCMD,"",null,1);
			place += 30;
			getLastFocusable().focusorder = 1;
			
			createUIElement( new FSComboBox, operatingCMD,"",null,2,UTIL.comboBoxNumericDataGenerator(1, 99),"0-9",2,new RegExp(RegExpCollection.REF_1to99)).x = place;// new RegExp("^([^0])|(\\d{2,3})$")).x = 30;
			attuneElement( 50 );
			place += 60;
			getLastFocusable().focusorder = 2;
			
			createUIElement( new FormString, operatingCMD,"",null,3).x = place;
			attuneElement( 180 );
			getLastElement().setAdapter( RFSensorServant.getInst().getSensorTypeAdapter() ); 
			place += 180;
			getLastFocusable().focusorder = 3;
			
			createUIElement( new FSComboBox, operatingCMD,"",onZone,4,CIDServant.getZoneTypeBySensor() ).x = place;
			attuneElement( 100,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			place += 130;
			getLastFocusable().focusorder = 4;
			
			createUIElement( new FormString, operatingCMD,"",null,5,null,"0-9", 3,new RegExp(RegExpCollection.REF_0to255)).x = place;
			attuneElement( 40, NaN, FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			place += 60+17;
			getLastFocusable().focusorder = 5;
			
			FLAG_SAVABLE = false;
			mirrorCBox = createUIElement( new FSComboBox, 0,"", dlgMirrorPartitions,6,RFSensorServant.PARTITION_LIST,"0-9",2);
			//( getLastElement() as DisplayObject ).parent.removeChild(( getLastElement() as DisplayObject ) )
			mirrorCBox.x = place;
			//createUIElement( new FSComboBox, 0,"", changePartition,6,RFSensorServant.PARTITION_LIST,"0-9",2).x = place;
			attuneElement(60,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			FLAG_SAVABLE = true;
			 
			
			tMultyPartBox = createUIElement( new FSComboCheckBox, operatingCMD,"", dlgPartsCheckBox,6, null,"0-9",2 );
			attuneElement(NaN, 60 );
			
			getLastElement().x = mirrorCBox.x;
			getLastElement().y = mirrorCBox.y;
			
			//( tMultyPartBox as DisplayObject ).parent.removeChild(  tMultyPartBox as DisplayObject ); 
			place += 70;
			getLastFocusable().focusorder = 6;
			
			createUIElement( new FSShadow, operatingCMD, "", null, 7 );
			getLastFocusable().focusorder = 7;
			
			createUIElement( new FSComboBoxExt, operatingCMD,"",null,8,CIDServant.getEvent(CIDServant.CID_WIRE_GUARD) ).x = place;
			attuneElement( 180,NaN,FSComboBox.F_RETURNS_HEXDATA | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent(CIDServant.CID_RFSENSORS) );
			place += 190;
			getLastFocusable().focusorder = 8;
			
			
			createUIElement( new FSComboBoxExt, operatingCMD,"",null,9,CIDServant.getEvent(CIDServant.CID_WIRE_GUARD) ).x = place;
			attuneElement( 180,NaN, FSComboBox.F_RETURNS_HEXDATA | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			(getLastElement() as FSComboBoxExt).setListExt( CIDServant.getEvent(CIDServant.CID_RFSENSORS) );
			place += 215+15;
			getLastFocusable().focusorder = 9;
			
			createUIElement( new FormString, operatingCMD,"",null,10).x = place;
			attuneElement( 40 );
			getLastFocusable().focusorder = 10;
			
			setChildIndex( sdisabled, this.numChildren-1 );
			
			block = new Sprite;
			addChild( block );
			block.graphics.beginFill( COLOR.WHITE, 0.4 );
			block.graphics.drawRect(-18,-1,place+40+18+5,23);
			block.graphics.endFill();
			block.visible = false;
			
			complexHeight = 25;
		}
		
		
		
		private function constructBlankSensor():void 
		{
			tStatus = new FormString;
			addChild( tStatus );
			tStatus.x = 90;
			tStatus.setWidth(350);
			tStatus.visible = false;
			
			tZoneNum = new FormString;
			addChild( tZoneNum );
			tZoneNum.x = 30;
			tZoneNum.setWidth( 50 );
			tZoneNum.visible = false;
			tZoneNum.attune(FormString.F_ALIGN_CENTER);
			
			bRestoreSensor = new TextButton;
			bRestoreSensor.focusgroup = globalFocusGroup;
			addChild( bRestoreSensor );
			bRestoreSensor.x = 230;//200;
			bRestoreSensor.setFormat( true );
			bRestoreSensor.setUp( loc("g_restore")+"...", restoreSensor );
			
			bCancelSensor = new TextButton;
			bCancelSensor.focusgroup = globalFocusGroup;
			addChild( bCancelSensor );
			bCancelSensor.x = 550;//520;
			bCancelSensor.setFormat( true );
			bCancelSensor.setUp( loc("g_cancel_add"), cancelSensor );
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.label = "";
			pBar.x = 300;
			pBar.enabled = true;
			pBar.indeterminate = true;
			pBar.width = 200;
			pBar.height = 5;
			pBar.y = 6;
			
			setChildIndex( sdisabled, this.numChildren-1 );
		}
		override public function putRawData(data:Array):void
		{
			
			
			trace("s:"+structureID + " active: "+Boolean(data[0]==1 && data[2] != 0xffff).toString() + "      state: "+STATE )
			
			if( !( (data[0] == 1 || data[0] == 2) && data[2] != 0xffff) )
				status(STATE);
			
			oldselection.visible = Boolean( data[0] == 2 );
			
			/** Команда RF_SENSOR */
			/**	Параметр 1 - Наличие радиодатчика ( 0x00 - Нет радиодатчика в приборе; 0x01 - Есть радиодатчик в приборе; 0x02 - радиоустройство потеряно из-за новой радиостемы); */
			getField(operatingCMD,1).setCellInfo( data[0] );
			/**	Параметр 2 - Номер зоны радиодатчика ( 1-999 ); */
			
			getField(operatingCMD,2).setCellInfo( data[1] || 1 );
			
			/**	Параметр 3 - Тип датчика ( 0x00 - не определен, 0x01 - Геркон, 0x02 - ИП дымовой, 0x04 - ИО объемный ); */
			getField(operatingCMD,3).setCellInfo( data[2] );
			/**	Параметр 4 - Тип зоны ( 0x00 - нет, 0x01 - проходная, 0x02 - входная, 0x03 - 24 часа, 0x04 - Мгновенная, 0x05 - Ключевая ); */
			(getField(operatingCMD,4) as FSComboBox).setList( CIDServant.getZoneTypeBySensor( data[2] ));
			getField(operatingCMD,4).setCellInfo( data[3] );
			
			TYPE = data[2];
			/**	Параметр 5 - Задержка на вход, в сек. (0-255); */
			getField(operatingCMD,5).setCellInfo( data[4] );
			
			/**	Параметр 6 - Раздел. Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка. Через номер строки получаем номер реального раздела. Если указан номер "Мастера раздела" (Параметр 7 ) отличный от 0, то используется число от 1 до 99 в качестве номера сетевого раздела. */
			(getField(operatingCMD, 6 ) as FSComboCheckBox).setList(  PartitionServant.getPartShortCCBList( data[5] )  );
			(getField(operatingCMD, 6 ) as FSComboCheckBox).turnToBitfield = PartitionServant.turnToPartitionBitfield;
			getField( 0, 6).setCellInfo( data[5] || 1);
			
			
			
			/**	Параметр 7 - ОТКЛЮЧЕНО Резерв для Контакт 14 и подобных приборов. "Мастер раздела"* для Контакт -16 - прибор с адресом 1-254, 255 - любой прибор с разделом (параметр 6), 0 - "Нет"  - нет "Мастера раздела"; */
			getField(operatingCMD,7).setCellInfo( 0 );
			/**	Параметр 8 - Событие ContactID при срабатывании основной зоны; */
			//(getField(operatingCMD,8) as FSComboBox).setList( CIDServant.getEvent( data[2] ));
			getField(operatingCMD,8).setCellInfo( uint(data[7]).toString(16) );
			/**	Параметр 9 - Событие ContactID при срабатывании дополнительного шлейфа; */
			var cidarr:Array = [];
			if( TYPE == RF_FUNCT.TYPE_IPDYMOVOY || TYPE == RF_FUNCT.TYPE_IOGERKON )
				cidarr = CIDServant.getEvent();
			else if( TYPE == RF_FUNCT.TYPE_IPZATOPLENIYA )
				cidarr = CIDServant.getEvent( RF_FUNCT.TYPE_IPZATOPLENIYA ) ;
			else if( TYPE == RF_FUNCT.TYPE_IOGERKON )
				cidarr = CIDServant.getEvent( CIDServant.CID_WIRE_GUARD ).concat( CIDServant.getEvent( CIDServant.CID_RF_GERKON ) ) ;
			else
				cidarr = CIDServant.getEvent(CIDServant.CID_WIRE_GUARD);
			
			
			
			
			(getField(operatingCMD,9) as FSComboBox).setList( cidarr );
			
			if( TYPE == RF_FUNCT.TYPE_IPZATOPLENIYA )
				getField(operatingCMD,9).setCellInfo( 0 );
			else 
				
				getField(operatingCMD,9).setCellInfo( uint(data[8]).toString(16)  );
			
			
			
			
			
			getField(operatingCMD,9).disabled = Boolean(TYPE == RF_FUNCT.TYPE_IPR 
				|| TYPE == RF_FUNCT.TYPE_IPZATOPLENIYA 
				|| TYPE == RF_FUNCT.TYPE_IPDYMOVOY 
				|| TYPE == RF_FUNCT.TYPE_IOGERKON_CR2032 
				|| TYPE == RF_FUNCT.TYPE_RFRETRANS);
			onZone();	// нужно блокировать задержку если зона не входная
			
			/**	Параметр 10 - период передачи тревожных сообщений в сек, 5-255 (информационный) - 
			 * записывается для вывода информации, которая отправлялась в радиодатчик при добавлении его радиосистему.*/
			getField(operatingCMD,10).setCellInfo( data[9] );
			if( !DS.isfam( DS.K15 ) )
				getField(operatingCMD,10).visible = OPERATOR.dataModel.getData(CMD.RF_SENSOR_TIME)[0][0] != UIRadioSystem.sensortime_active;
			else
				getField(operatingCMD,10).visible = true;
		}
		
		override public function isRemovable():Boolean
		{
			return STATE == RF_STATE.NO;
		}
		public function status(value:int):void
		{
			STATE = value;
			switchTo( value );
			switch(value) {
				case RF_STATE.NOTFOUND:
					label( loc("rfd_sensor_not_found"), COLOR.RED );
					break;
				case RF_STATE.CANCELED:
					label( loc("rfd_sensor_add_canceled"), COLOR.RED );
					break;
				case RF_STATE.ADDING:
					label( loc("rfd_sensor_add_inprogress")+"...", COLOR.BLUE_LIGHT);
					zone( RFSensorServant.getZone(getStructure()), COLOR.BLUE_LIGHT);
					break;
				case RF_STATE.DELETED:
					label( loc("rfd_sensor_removed"), COLOR.RED );
					zone( RFSensorServant.getZone(getStructure()), COLOR.RED );
					break;
				case RF_STATE.ALREADYEXIST:
					// исключение: массив зон используется для отображения номера датчика который уже есть в системе
					label( loc("rfd_sensor_already_exist_num")+" "+RFSensorServant.getZone(getStructure()), COLOR.RED );
					break;
				case RF_STATE.RESTORE_IMPOSSIBLE:
					label( loc("g_restore_impossible"), COLOR.RED );
					break;
				default:
					label( loc("rfd_error_unknown_status")+" "+value, COLOR.RED );
					break;
			}
		}
		
		private function switchTo(v:int):void
		{
			if (!tStatus)
				constructBlankSensor();
			
			if ( aCells ) {
				var l:int = aCells.length;
				for( var i:int; i < l; ++i ) {
					aCells[i].visible = false;
					aCells[i].disabled = true;
				}
			}
			
			
			tStatus.visible = true;
			tZoneNum.visible != v == RF_STATE.ADDING || v == RF_STATE.DELETED;
			mirrorCBox.visible != v == RF_STATE.ADDING || v == RF_STATE.DELETED;
			getField(0,6).visible != v == RF_STATE.ADDING || v == RF_STATE.DELETED;
			tMultyPartBox.visible != v == RF_STATE.ADDING || v == RF_STATE.DELETED;
			bRestoreSensor.visible = v == RF_STATE.DELETED;
			bCancelSensor.visible = v == RF_STATE.ADDING;
			pBar.visible = v == RF_STATE.ADDING;
			//( mirrorCBox as DisplayObject ).parent.removeChild(  mirrorCBox as DisplayObject );
			
			call( RFSensorServant.WAIT_FOR_STATE, 0 );
		}
		private function label(value:String, color:int):void
		{
			if ( tStatus ) {
				tStatus.setName( value );
				tStatus.setTextColor( color );
			}
		}
		private function zone(value:Object, color:int):void
		{
			if (tZoneNum) {
				tZoneNum.setName( value.toString() );
				tZoneNum.setTextColor( color );
			}
		}
		private function set STATE(v:int):void
		{
			RFSensorServant.setState(getStructure(),v);
		}
		private function get STATE():int
		{
			return RFSensorServant.getState(getStructure());
		}
		/******* EVENT SECTION *****************************************************************************/	
		public function restoreSensor():void 
		{
			RFSensorServant.getInst().fire( RF_FUNCT.TYPE_NEW, RF_FUNCT.DO_RESTORE, getStructure() );
			bRestoreSensor.disabled = true;
		}
		private function cancelSensor():void 
		{
			RFSensorServant.getInst().fire( RF_FUNCT.TYPE_NEW, RF_FUNCT.DO_CANCEL, getStructure() );
			bCancelSensor.disabled = true;
		}
		private function onZone(t:IFormString=null):void
		{// нужно блокировать задержку если зона не входная
			var f:IFormString;
			if (t)
				f = t;
			else
				f = getField(operatingCMD, 4);
			
			var delay:IFormString = getField(operatingCMD,5);
			// Если зона не входная
			// Меняем значение полей только если есть таргет тоесть внесение информации было не во время загрузки 
			if( int(f.getCellInfo()) != 2 ) {
				if (t)
					delay.setCellInfo(0);
				delay.disabled = true;
			} else {
				if (t)
					delay.setCellInfo(30);
				delay.disabled = false;
			}
			
			
			
			
			if(  f == getField( operatingCMD, 4 )  )
			{
				// если тип зоны выбран "ключевая"
				if( f.getCellInfo() == 5 )
				{
					getField(operatingCMD,8).setCellInfo( 0 );
					getField(operatingCMD,9).setCellInfo( 4091 );
					/// блокируем поля
					getField(operatingCMD,8).disabled = getField(operatingCMD,9).disabled = true;
					_isKeyZone = true;
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.SELECT_ZONE_AS_KEY, {isKeyZone: true } );
					/// ПОДМЕНЯЕМ ПОЛЯ ЗАМЕНЯЯ ПОЛЕ С ВОЗМОЖНОСТЬЮ ОДИНОЧНОГО ВЫБОРА НА ПОЛЕ С ВОЗМОЖНОСТЬЮ МНОЖЕСТВЕННОГО
					getField(operatingCMD,6).visible = true;
					getField(0,6).visible = false;
					
					
				}
				else
				{
					/// деблокируем поля
					getField(operatingCMD,8).disabled = getField(operatingCMD,9).disabled = false;
					_isKeyZone = false;
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.SELECT_ZONE_AS_KEY, {isKeyZone: false } );
					
					/// ПОДМЕНЯЕМ ПОЛЯ ЗАМЕНЯЯ ПОЛЕ С ВОЗМОЖНОСТЬЮ ОДИНОЧНОГО ВЫБОРА НА ПОЛЕ С ВОЗМОЖНОСТЬЮ МНОЖЕСТВЕННОГО
					getField(operatingCMD,6).visible = false;
					/// почему отталкиваемся от статуса
					//if(tStatus && !tStatus.visible )
						getField(0,6).visible = true;
						
					if(  t ) 
					{
						getField(0,6).setCellInfo( RFSensorServant.LAST_VALID_PARTITION );
						(getField(operatingCMD, 6 ) as FSComboCheckBox).setList(  PartitionServant.getPartShortCCBList( int( getField( 0, 6 ).getCellInfo( ) || 1  ) ) );
						
					}
					
				}
				
			}
			
			if (t)
				SavePerformer.remember(getStructure(), t);
		}
		
		private function dlgMirrorPartitions( t:IFormString = null):void
		{
			
			
			(getField(operatingCMD, 6 ) as FSComboCheckBox).setList(  PartitionServant.getPartShortCCBList( int( getField( 0, 6 ).getCellInfo( ) || 1  ) ) );
			//(getField(operatingCMD, 6 ) as FSComboCheckBox).setCellInfo( getField( 0, 6 ).getCellInfo( ) );
			changePartition( getField( operatingCMD, 6 ) );
		}
		
		private function changePartition(target:IFormString):void
		{	
			// Нужно запоминать последный выбранный партишен
			
			if ( target.valid )
				RFSensorServant.LAST_VALID_PARTITION = int( getField( 0, 6 ).getCellInfo( )  );
			SavePerformer.remember(getStructure(), (getField(operatingCMD, 6 )) );
		}
		
		private function dlgPartsCheckBox(target:IFormString = null ):void
		{
			
			
			if( !target.getCellInfo() )
				(getField(operatingCMD, 6 ) as FSComboCheckBox).setList(  PartitionServant.getPartShortCCBList(  1  ) );
				
			
			
			remember( target );
			
		}	
		
		/**** 	Public gets			*******************************/
	}
}