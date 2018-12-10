package components.screens.opt
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import components.abstract.DEVICESB;
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.TabOperator;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.basement.UIRadioDeviceRoot;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSTextPic;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.DS;
	import components.static.GuiLib;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptKeyboard extends OptionsBlock
	{
		private var section:FormString;
		private var tZummerAlarm:FormString;
		
		private var cbSection:FSComboCheckBox;
		private var cbZummerAlarm:FSComboCheckBox;
		private var cbExit:FSComboCheckBox;
		private var cbStay:FSComboCheckBox;
		
		private var fsFire:FSTextPic;
		private var fsMedical:FSTextPic;
		private var fsPanic:FSTextPic;
		private var fsExit:FormString;
		private var fsStay:FormString;
		
		private var cbFire:FSComboBox;
		private var cbMedical:FSComboBox;
		private var cbPanic:FSComboBox;
		protected var cbZummerOnFireTime:FSComboBox;
		protected var cbZummerOnPanicTime:FSComboBox;
		
		private var cbTrigger:FSComboBox;
		protected var cbZummerOnFire:FSComboBox;
		protected var cbZummerOnPanic:FSComboBox;
		
		private var checkExit:FSCheckBox;
		private var checkEnter:FSCheckBox;
		
		private var tType:SimpleTextField;
		private var tCmd:SimpleTextField;
		private var tTime:SimpleTextField;
		
		protected var cmd_keyboard:int;;
		protected var cmd_bzi:int;
		protected var cmd_bzp:int;
		protected var isRfKey:Boolean;
		
		private var blocker:Sprite;

		private var go:GroupOperator;
		
		public function OptKeyboard(radio:Boolean)
		{
			init_commands();
			
			super();
			
			globalX = 30;
			
			section = new FormString;
			if (radio)
				section.setName( loc("rfd_partition_control_key") );
			else
				section.setName( loc("rfd_data_partition_control_key") );
			addChild( section );
			section.x = globalX;
			section.y = 10;
			
			operatingCMD = cmd_keyboard;
			
			createUIElement( new FSShadow, operatingCMD,"1",null,1);
			
			go = new GroupOperator;
			
			
			cbSection = createUIElement(new FSComboCheckBox, operatingCMD,"",null,2) as FSComboCheckBox;
			attuneElement(NaN,200);
			cbSection.turnToBitfield = PartitionServant.turnToPartitionBitfield;
			cbSection.x = globalX + 250;
			cbSection.y = 10;
			
			
			var sep1:Separator = new Separator;
			addChild( sep1 );
			sep1.y = 50;
			sep1.x = 10;
			
			go.add( "no_lcd", sep1 );
			
			fsFire = new FSTextPic;
			addChild( fsFire );
			fsFire.setWidth( 220 );
			fsFire.setName( loc("rfd_event_on_press") );
			fsFire.attachPic( GuiLib.cFire );
			fsFire.y = 70;
			fsFire.x = globalX;
			go.add( "no_lcd", fsFire );
			
			fsMedical = new FSTextPic;
			addChild( fsMedical );
			fsMedical.setWidth( 220 );
			fsMedical.setName( loc("rfd_event_on_press") );
			fsMedical.attachPic( GuiLib.cMedical );
			fsMedical.y = 100;
			fsMedical.x = globalX;
			go.add( "no_lcd", fsMedical );
			
			fsPanic = new FSTextPic;
			addChild( fsPanic );
			fsPanic.setName( loc("rfd_event_on_press") );
			fsPanic.setWidth( 220 );
			fsPanic.attachPic( GuiLib.cPanic );
			fsPanic.y = 130;
			fsPanic.x = globalX;
			go.add( "no_lcd", fsPanic );
			
			cbFire = createUIElement( new FSComboBox, operatingCMD, "",null,3,CIDServant.getEvent(CIDServant.CID_RF_KEY_FIRE) ) as FSComboBox;
			attuneElement( 200,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_RETURNS_HEXDATA );
			cbFire.x = globalX + 250; 
			cbFire.y = fsFire.y;
			go.add( "no_lcd", cbFire );
			
			cbMedical = createUIElement( new FSComboBox, operatingCMD, "",null,4,CIDServant.getEvent(CIDServant.CID_RF_KEY_MED) ) as FSComboBox;
			attuneElement( 200,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_RETURNS_HEXDATA);
			cbMedical.x = globalX + 250; 
			cbMedical.y = fsMedical.y;
			go.add( "no_lcd", cbMedical );
			
			cbPanic = createUIElement( new FSComboBox, operatingCMD, "",null,5,CIDServant.getEvent(CIDServant.CID_RF_KEY_PANIC) ) as FSComboBox;
			attuneElement( 200,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_RETURNS_HEXDATA);
			cbPanic.x = globalX + 250; 
			cbPanic.y = fsPanic.y;
			go.add( "no_lcd", cbPanic );
			
			/*var sep2:Separator = new Separator;
			addChild( sep2 );
			sep2.y = 170;
			sep2.x = 10;*/
			
			var cbTriggetList:Array = [ {label:loc("ui_alarmkey_immediatley"), data:0x01}, {label:loc("ui_alarmkey_hold1sek"), data:0x02},
				{label:loc("ui_alarmkey_hold2sek"), data:0x04},	{label:loc("ui_alarmkey_hold3sek"), data:0x06} ];
			
			cbTrigger = createUIElement( new FSComboBox, operatingCMD,loc("rfd_alarm_button_pressing_time"),null,6,cbTriggetList) as FSComboBox;
			attuneElement( 320,130, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbTrigger.x = globalX; 
			cbTrigger.y = 170;
			go.add( "no_lcd", cbTrigger );
			
			
			var sep3:Separator = new Separator;
			addChild( sep3 );
			sep3.y = 210;
			sep3.x = 10;
			go.add( "bottom", sep3 );
			
			fsExit = new FormString;
			addChild( fsExit );
			fsExit.setWidth( 340 );
			fsExit.setName( loc("rfd_set_partition_perimeter") + " ( STAY )" );
			fsExit.y = 230;
			fsExit.x = globalX;
			go.add( "bottom", fsExit );
			
			fsStay = new FormString;
			addChild( fsStay );
			fsStay.setName( loc("rfd_set_partition_exit") + " ( EXIT )" );
			fsStay.setWidth( 320 );
			fsStay.y = 260;
			fsStay.x = globalX;
			go.add( "bottom", fsStay );
			
			cbExit = createUIElement( new FSComboCheckBox, operatingCMD, "", null, 7 ) as FSComboCheckBox;
			attuneElement( 0, 80 );
			cbExit.turnToBitfield = PartitionServant.turnToPartitionBitfield;
			cbExit.x = globalX + 370; 
			cbExit.y = fsExit.y;
			go.add( "bottom", cbExit );
			
			cbStay = createUIElement( new FSComboCheckBox, operatingCMD, "", null, 8 ) as FSComboCheckBox;
			attuneElement( 0,80 );
			cbStay.turnToBitfield = PartitionServant.turnToPartitionBitfield;
			cbStay.x = globalX + 370; 
			cbStay.y = fsStay.y;
			go.add( "bottom", cbStay );
			
			var sep4:Separator = new Separator;
			addChild( sep4 );
			sep4.y = 300;
			sep4.x = 10;
			go.add( "bottom", sep4 );
			var shiftY:int = 320;
			
			if (!isRfKey) {
				checkEnter = createUIElement( new FSCheckBox, cmd_bzi,loc("rfd_zummer_signal_enter_delay") ,
					null, 1 ) as FSCheckBox;
				attuneElement( 428+9 );
				checkEnter.x = globalX; 
				checkEnter.y = shiftY;
				shiftY += 30;
				go.add( "bottom", checkEnter );
			} else {
				createUIElement( new FSShadow, cmd_bzi, "", null, 1 );
			}
				
			checkExit = createUIElement( new FSCheckBox, cmd_bzi,loc("rfd_zummer_signal_exit_delay") ,
				null, 2 ) as FSCheckBox;
			attuneElement( 428+9);
			checkExit.x = globalX; 
			checkExit.y = shiftY;
			shiftY += 40
			go.add( "bottom", checkExit );
			
			var sep5:Separator = new Separator;
			addChild( sep5 );
			sep5.y = shiftY;
			sep5.x = 10;
			go.add( "bottom", sep5 );
			
			if (!isRfKey) {
			
				FLAG_SAVABLE = false;
				tZummerAlarm = createUIElement( new FormString, cmd_bzp, loc("rfd_turnon_zummer_on_alarm"),null,0 ) as FormString;
				tZummerAlarm.setWidth( 280 );
				tZummerAlarm.x = globalX;
				tZummerAlarm.y = sep5.y + 20;
				FLAG_SAVABLE = true;
				go.add( "bottom", tZummerAlarm );
				
				cbZummerAlarm = createUIElement( new FSComboCheckBox, cmd_bzp,"",null,1) as FSComboCheckBox;
				attuneElement( 0, 20+40 );
				cbZummerAlarm.turnToBitfield = PartitionServant.turnToPartitionBitfield;
				cbZummerAlarm.x = globalX + 290; 
				cbZummerAlarm.y = tZummerAlarm.y;
				go.add( "bottom", cbZummerAlarm );
				
				tType = new SimpleTextField(loc("alarm_type_line"), 210);
				addChild( tType );
				tType.setSimpleFormat( "center",0,12,true );
				tType.y = tZummerAlarm.y + tZummerAlarm.getHeight() + 20;
				tType.x = globalX;
				go.add( "bottom", tType );
				
				tCmd = new SimpleTextField(loc("alarm_run_command"), 150);
				addChild( tCmd );
				tCmd.setSimpleFormat( "center",0,12,true );
				tCmd.y = tZummerAlarm.y + tZummerAlarm.getHeight() + 20;
				tCmd.x = globalX + 210;			
				go.add( "bottom", tCmd );
				
				tTime = new SimpleTextField(loc("ui_indsound_switchon_time"), 150);
				addChild( tTime );
				tTime.setSimpleFormat( "center",-7,12,true );
				tTime.y = tZummerAlarm.y + tZummerAlarm.getHeight() + 20;
				tTime.x = globalX + 360;
				go.add( "bottom", tTime );
				
				var aZummerList:Array = [ {label:loc("g_nocmd"), data:0x00}, 
					{label:loc("g_switchon"), data:0x01}, 
					{label:loc("g_switchon_time"), data:0x04},
					{label:loc("g_switchon_1hz"), data:0x07}		];
				
				cbZummerOnPanic = createUIElement( new FSComboBox, cmd_bzp, loc("ui_indsound_switchon_zummer_on_alarm"), onCall,2,aZummerList) as FSComboBox;
				attuneElement( 220, 180, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				cbZummerOnPanic.x = globalX; 
				cbZummerOnPanic.y = 470 + 20;
				go.add( "bottom", cbZummerOnPanic );
				
				cbZummerOnFire = createUIElement( new FSComboBox,cmd_bzp,loc("ui_indsound_switchon_zummer_on_fire"),onCall,5,aZummerList ) as FSComboBox;
				attuneElement( 220, 180, FSComboBox.F_COMBOBOX_NOTEDITABLE  );
				cbZummerOnFire.x = globalX; 
				cbZummerOnFire.y = 510 + 20;
				go.add( "bottom", cbZummerOnFire );
				
				var aPeriod:Array = [ {label:"05:00", data:"05:00" }, {label:"10:00", data:"10:00" }, {label:"30:00", data:"30:00" }, {label:"60:00", data:"60:00" }];
				
				cbZummerOnPanicTime = createUIElement( new FSComboBox, cmd_bzp,"",null,3,aPeriod,"0-9:",5,
					new RegExp( new RegExp(RegExpCollection.REF_0000to6000) )) as FSComboBox;
				attuneElement( 0,70,FSComboBox.F_COMBOBOX_TIME);
				cbZummerOnPanicTime.x = globalX + 387 + 20; 
				cbZummerOnPanicTime.y = cbZummerOnPanic.y;
				go.add( "bottom", cbZummerOnPanicTime );
				
				cbZummerOnFireTime = createUIElement( new FSComboBox, cmd_bzp,"",null,6,aPeriod,"0-9:",5,
					new RegExp( new RegExp(RegExpCollection.REF_0000to6000) )) as FSComboBox;
				attuneElement( 0,70,FSComboBox.F_COMBOBOX_TIME);
				cbZummerOnFireTime.x = globalX + 387 + 20; 
				cbZummerOnFireTime.y = cbZummerOnFire.y;
				go.add( "bottom", cbZummerOnFireTime );
			}
			
			blocker = new Sprite;
			addChild( blocker );
			blocker.graphics.beginFill( 0xffffff, 0.0 );
			blocker.graphics.drawRect( 0,0,550,600 );
			blocker.visible = false;
		}
		override public function set loading(value:Boolean):void
		{
			if (value) {
				blocker.visible = true;
				super.loading = true;
			}
		}
		protected function onCall(t:IFormString):void
		{
			if (t)
				SavePerformer.remember(getStructure(),t);
		}
		protected function init_commands():void
		{
			cmd_keyboard = CMD.RF_KEY;
			cmd_bzi = CMD.RF_KEY_BZI;
			cmd_bzp = CMD.RF_KEY_BZP;
			
			if( DS.isDevice(DS.K16) && DEVICESB.release < 8)
				isRfKey = true;
		}
		override public function putData(p:Package):void
		{
			
			structureID = p.structure;
			globalFocusGroup = 200*(structureID-1)+50;
			refreshCells(operatingCMD);
			var aInfo:Array = p.data;
			old = Boolean( aInfo[0]==2 );
			
			
			
			if( p.data[ p.data.length - 1 ] == RF_FUNCT.TYPE_RADIOKLAVIATURA_LCD )
			{
				go.visible( "no_lcd", false );
				go.movey( "bottom", 60 );
			}
			else
			{
				go.visible( "no_lcd", true );
				go.movey( "bottom", 210 );
			}
			
			
	/** Команда RF_KEY */
	/** Параметр 1 - Наличие радиоклавиатуры ( 0x00 - Нет радиоклавиатуры в приборе, 0x01 - Есть радиоклавиатуры в приборе);*/
			getField(operatingCMD,1).setCellInfo( aInfo[0] );
	/** Параметр 2 - Разделы для управления с радиоклавиатуры ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление );*/
			cbSection.setList( partitionGenerator( aInfo[1] ) );
	/** Параметр 3 - Событие ContactID, возникающее при нажатии тревожной кнопки “Пожар”; */
			cbFire.setCellInfo( aInfo[2].toString(16) );
	/** Параметр 4 - Событие ContactID, возникающее при нажатии тревожной кнопки “Медицина”; */
			cbMedical.setCellInfo( aInfo[3].toString(16) );
	/** Параметр 5 - Событие ContactID, возникающее при нажатии тревожной кнопки “Охрана”; */
			cbPanic.setCellInfo( aInfo[4].toString(16) );
	/** Параметр 6 - Нажатие на тревожные кнопки ( 0x01 - короткое, 0x02 - держать>1сек, 0x03 - держать>1,5сек, 0x04 - держать>2 сек, 0x05 - держать>2,5сек, 0x06 - держать>3 сек ); */
			cbTrigger.setCellInfo( aInfo[5].toString() );
	/** Параметр 7 - Постановка раздела под охрану кнопкой “Периметр” ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - четвертая строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление ); */
			cbExit.setList( partitionGenerator( aInfo[6] ));
	/** Параметр 8 - Постановка раздела под охрану кнопкой “Выход” ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - четвертая строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление ); */
			cbStay.setList( partitionGenerator( aInfo[7] ));
			
			RequestAssembler.getInstance().fireEvent( new Request( cmd_bzi, addData, structureID ));
			if (!isRfKey)
				RequestAssembler.getInstance().fireEvent( new Request( cmd_bzp, addData, structureID ));
		}
		private function addData(p:Package):void
		{
			switch( p.cmd ) {
				case cmd_bzi:
					refreshCells(cmd_bzi);
					var aInfoBZI:Array = p.getStructure();//_re[1][8];
					/**	 Радиоклавиатура Команда RF_KEY_BZI */
					/** Параметр 1 - Индикация зуммером задержки на вход (0x00 - нет, 0x01 - да ); */
					getField(cmd_bzi,1).setCellInfo( String( aInfoBZI[0] ));
					/** Параметр 2 - Индикация зуммером задержки на выход (0x00 - нет, 0x01 - да ); */
					checkExit.setCellInfo( String( aInfoBZI[1] ));
					if(isRfKey) {
						this.dispatchEvent( new Event( UIRadioDeviceRoot.EVENT_LOADED ));
						blocker.visible = false;
						TabOperator.ACTIVE = !value;
					}
					break;
				case cmd_bzp:
					refreshCells(cmd_bzp);
					var aInfoBZP:Array = p.getStructure();
					/**	 Команда RF_KEY_BZP */
					/** Параметр 1 - Включение зуммера по тревоге в разделе ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление ); */
					cbZummerAlarm.setList( partitionGenerator( aInfoBZP[0] ) );
					/** Параметр 2 - Выполняемая команда при охранной тревоге ( 0x00 - Нет команды, 0x01 - Включить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц ); */
					cbZummerOnPanic.setCellInfo( aInfoBZP[1].toString() );
					/** Параметр 3,4 - Время включения зуммера при охранной тревоге, Параметр 3 - минуты ( 0-59 ), Параметр 4 - секунды ( 0-99 ); */
					var value:String;
					value = UTIL.formateZerosInFront( aInfoBZP[2].toString(), 2)+":"+ UTIL.formateZerosInFront( aInfoBZP[3].toString(), 2 );
					cbZummerOnPanicTime.setCellInfo( value );
					/** Параметр 5 - Выполняемая команда при пожарной тревоге( 0x00 - Нет команды, 0x01 - Включить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц ); */
					cbZummerOnFire.setCellInfo( aInfoBZP[4].toString() );
					/** Параметр 6,7 - Время включения зуммера при пожарной тревоге, Параметр 6 - минуты ( 0-59 ), Параметр 7 - секунды ( 0-99 ); */
					value = UTIL.formateZerosInFront( aInfoBZP[5].toString(), 2)+":"+ UTIL.formateZerosInFront( aInfoBZP[6].toString(), 2 );
					cbZummerOnFireTime.setCellInfo( value );
					
					if (!isRfKey)
						onCall(null);
					this.dispatchEvent( new Event( UIRadioDeviceRoot.EVENT_LOADED ));
					blocker.visible = false;
				//	TabOperator.ACTIVE = !value;	- не понятно зачем нужна эта строка
					break;
			}
		}
			
		private function partitionGenerator( _bit:int ):Array
		{
			var list:Array = new Array;
			var selected:int;
			var allChecked:Boolean = true;
			list.push( {"label":loc("part_all"), "data":0, "trigger":FSComboCheckBox.TRIGGER_SELECT_ALL} );
			for( var key:String in PartitionServant.PARTITION ) {
				selected = 0;
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
			return list;
		}
	}
}
//500