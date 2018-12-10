package components.screens.opt
{
	import components.abstract.ClientArrays;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.gui.Header;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.visual.HLine;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptReleWire_pattern extends OptionsBlock
	{
		private var screens:Vector.<Object>;
		private const screens_length:int=5;
		private var validationFields:Vector.<Object>;
		private var isAllValid:Boolean=true;
		private var NEED_SAVE:Boolean = false;
		private var CURRENT_SELECTION:int = 0;
		
		private var pattern_1_wasSelected:Boolean=false;
		private var pattern_2_wasSelected:Boolean=false;
		private var pattern_3_wasSelected:Boolean=false;
		private var pattern_4_wasSelected:Boolean=false;
		
		public function OptReleWire_pattern()
		{
			super();
			
			globalX = 10;
			
			FLAG_SAVABLE = false;
		/*	createUIElement( new FormString,0,loc("ui_pattern_output_control"),null,1);
			globalX = 210;
			globalY = 0;
			createUIElement( new FSComboBox, 0, "", callSwitchPattern, 2, ClientArrays.RELE_PATTERNS ) as FSComboBox;
			attuneElement(400,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setCellInfo("0");*/
			
			createUIElement( new FSComboBox, 0, loc("ui_pattern_output_control"), callSwitchPattern, 2, ClientArrays.RELE_PATTERNS ) as FSComboBox;
			attuneElement(250,300, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setCellInfo("0");
			
			var hl:HLine = new HLine(887);
			addChild(hl);
			hl.y = 31;
			
			screens = new Vector.<Object>;
			screens[0] = new Vector.<Object>;
			screens.length = screens_length;
			screens.fixed = true;
			
			validationFields = new Vector.<Object>;
		}
		private function callSwitchPattern():void
		{
			NEED_SAVE = true;
			switchPattern();
		}
		private function switchPattern():void
		{
			CURRENT_SELECTION = int(getField( 0,2 ).getCellInfo());
			callVisualizer( CURRENT_SELECTION );
			switch( CURRENT_SELECTION ) {
				case 0:
					pattern_0();
					break;
				case 1:
					pattern_1();
					break;
				case 2:
					pattern_2();
					break;
				case 3:
					pattern_3();
					break;
				case 4:
					pattern_4();
					break;
			}
		}
		override public function putRawData(a:Array):void
		{
			pattern_1_wasSelected = false;
			pattern_2_wasSelected = false;
			pattern_3_wasSelected = false;
			pattern_4_wasSelected = false;

			refreshCells( CMD.RELAY_PERMANENTLY_ON);
			refreshCells( CMD.RELAY_INDPART );
			refreshCells( CMD.RELAY_ALARM1);
			refreshCells( CMD.RELAY_ALARM2 );
			refreshCells( CMD.RELAY_INDMES );
			
			if ( a[0][0] == 1)
				getField( 0,2 ).setCellInfo( "1" );
			else if (a[1][0] == 1)
				getField( 0,2 ).setCellInfo( "2" );
			else if (a[2][0] == 1)
				getField( 0,2 ).setCellInfo( "3" );
			else if (a[3][0] == 1)
				getField( 0,2 ).setCellInfo( "4" );
			else
				getField( 0,2 ).setCellInfo( "0" );
			
			NEED_SAVE = false;
			switchPattern();
			SavePerformer.trigger( {"after":after} );
		}
		private function pattern_0():void	
		{
			if (pattern_1_wasSelected || pattern_2_wasSelected || pattern_3_wasSelected || pattern_4_wasSelected )
				SavePerformer.rememberBlank();
		}
		private function pattern_1():void	
		{
			/**Команда RELAY_INDPART настройка шаблонов выхода "Индикация состояния раздела" ( 5 - выходов - 5 структур )
			 * Параметр 1 - 0 - Шаблон не действует, 1 - Шаблон действует;
			 * Параметр 2 - Номер раздела.( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка).*/	
			
			pattern_1_wasSelected = true;
			
			if( !screens[1] ) {
				screens[1] = new Vector.<Object>;
				
				globalY = 50;
				globalX = 10;
				(screens[1] as Vector.<Object>).push( 
					createUIElement( new FormString, 1,loc("ui_led_partition_state")+" ",null,3)
				);
				attuneElement(210);
				globalY = 50;
				globalX = 260;
				FLAG_SAVABLE = true;
				createUIElement( new FSShadow, CMD.RELAY_INDPART, "1", null, 1 );
				(screens[1] as Vector.<Object>).push(	createUIElement( new FSComboBox, CMD.RELAY_INDPART,"",null,2, PartitionServant.getPartitionList())	);
				attuneElement(60,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				FLAG_SAVABLE = false;
				
				var ann:String = loc("ui_pattern_rele_note1")
				
				var tAnnotaion:SimpleTextField = new SimpleTextField( ann );
				addChild( tAnnotaion );
				tAnnotaion.x = 10;
				tAnnotaion.y = 90;
				
				(screens[1] as Vector.<Object>).push( tAnnotaion );
			}
			
			var data:Array = OPERATOR.dataModel.getData( CMD.RELAY_INDPART )[getStructure()-1];
			(getField( CMD.RELAY_INDPART, 2 ) as FSComboBox).setList( PartitionServant.getPartitionList() );
			if (data[1] == 0) {
				getField( CMD.RELAY_INDPART, 2 ).setCellInfo( String(PartitionServant.getFirstPartition()) );
				NEED_SAVE = true;
			} else
				getField( CMD.RELAY_INDPART, 2 ).setCellInfo( String(data[1]) );
			
			if ( NEED_SAVE )
				remember( getField(CMD.RELAY_INDPART,1) );
		}
		private function pattern_2():void	
		{
			/**Команда RELAY_ALARM1 назначение разделов для включения выхода по тревоге ( 5 - выходов - 5 структур )
			 * Параметр 1 - 0 - Шаблон не действует, 1 - Шаблон действует;
			 * Параметр 2 - Разделы ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление );

 			 * Команда RELAY_ALARM2 Команда настройки включения выхода по тревоге в разделе ( 5 - выходов - 5 структур )
			 * Параметр 1 - команда при охранной тревоге ( 0x00 - Нет команды, 0x01 - Включить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц );
			 * Параметр 2,3 - время включения (ММ,СС) 00:00-99:59;
			 * Параметр 4 - команда при пожарной тревоге ( 0x00 - Нет команды, 0x01 - Включить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц );
			 * Параметр 5,6 - время включения (ММ,СС) 00:00-99:59;
			 * Параметр 7 - Индикация задержки на вход ( 0-нет,1 -да)
			 * Параметр 8 - Индикация задержки на выход (0-нет,1-да) */
			
			
			pattern_2_wasSelected = true;
			
			if( !screens[2] ) {
				screens[2] = new Vector.<Object>;
				
				globalY = 50;
				globalX = 10;
				(screens[2] as Vector.<Object>).push(	createUIElement( new FormString, 2, loc("ui_out_turnon_when_part_alarm"), null, 1 ) 		);
				attuneElement( 300 );
				globalY = 50;
				globalX = 310;
				FLAG_SAVABLE = true;
				createUIElement( new FSShadow, CMD.RELAY_ALARM1, "1",null,1);
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboCheckBox, CMD.RELAY_ALARM1, "", null, 2 )			);
				(getLastElement() as FSComboCheckBox).turnToBitfield = PartitionServant.turnToPartitionBitfield;
				FLAG_SAVABLE = false;
				globalX = 10;
				var sep1:Separator = new Separator(550);
				addChild( sep1 );
				sep1.x = globalX;
				sep1.y = globalY;
				globalY += 20;
				(screens[2] as Vector.<Object>).push( sep1 );
				
				var header:Header = new Header( [{label:loc("alarm_type"),xpos:15},{label:loc("alarm_run_command"), xpos:250, width:200},
					{label:loc("ui_indsound_switchon_time"), xpos:400,width:200,align:"center"}],
					{size:12, leading:0} );
				
				addChild( header );
				header.y = globalY;
				globalY += 40;
				(screens[2] as Vector.<Object>).push( header );
				FLAG_SAVABLE = true;
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FormString, 2, loc("ui_out_turnon_out_when_guard_alarm"), null, 2 )		);
				attuneElement(230,NaN,FormString.F_MULTYLINE);
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FormString, 2, loc("ui_out_turnon_out_when_fire_alarm"), null, 3 )		);
				attuneElement(230,NaN,FormString.F_MULTYLINE);
				
				var menu:Array = [{label:loc("g_nocmd"), data:0x00},
					{label:loc("g_switchon"), data:0x01},
					{label:loc("g_switchon_time"), data:0x04},
					{label:loc("g_switchon_05hz"), data:0x06},
					{label:loc("g_switchon_1hz"), data:0x07},
					{label:loc("g_switchon_2hz"), data:0x08}];
				
				globalY = 143;
				globalX = 250;
				
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RELAY_ALARM2, "", onTimeCall, 1, menu )		);
				attuneElement( 170,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE );
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RELAY_ALARM2, "", onTimeCall, 4, menu )		);
				attuneElement( 170,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE );
				
				var menu_time:Array = [{label:"05:00", data:"05:00"},
					{label:"15:00", data:"15:00"},
					{label:"30:00", data:"30:00"},
					{label:"60:00", data:"60:00"},
					{label:"90:00", data:"90:00"}]
				
				globalY = 143;
				globalX = 450;
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RELAY_ALARM2, "", null, 2, menu_time,"0-9:",5,new RegExp( RegExpCollection.REF_TIME_0000to9959) )		);
				validationFields.push( getLastElement() );
				attuneElement(NaN,NaN,FSComboBox.F_COMBOBOX_TIME);
				globalY = 153+21;
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RELAY_ALARM2, "", null, 5, menu_time,"0-9:",5,new RegExp( RegExpCollection.REF_TIME_0000to9959) )		);
				validationFields.push( getLastElement() );
				attuneElement(NaN,NaN,FSComboBox.F_COMBOBOX_TIME);
				
				globalX = 10;
				var sep2:Separator = new Separator(550);
				addChild( sep2 );
				sep2.x = globalX;
				sep2.y = globalY;
				globalY += 20;
				(screens[2] as Vector.<Object>).push( sep2 );
				yshift = 10;
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSCheckBox, CMD.RELAY_ALARM2, loc("ui_out_ind_enter_delay"),null,7)	);
				attuneElement( 230 );
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSCheckBox, CMD.RELAY_ALARM2, loc("ui_out_ind_exit_delay"),null,8)	);
				attuneElement( 230 );
				FLAG_SAVABLE = false;
				yshift = 20;
				var txt:String = loc("ui_out_ptrn2_note");
				var tf:SimpleTextField = new SimpleTextField(txt);
				addChild( tf );
				tf.y = globalY;
				tf.x = globalX;
				(screens[2] as Vector.<Object>).push( tf );
			}
			var data:Array = OPERATOR.dataModel.getData( CMD.RELAY_ALARM2 )[ getStructure()-1 ];			
			
			getField( CMD.RELAY_ALARM2, 1 ).setCellInfo( String(data[0]) );
			var value:String = UTIL.formateZerosInFront( data[1].toString(), 2)+":"+ UTIL.formateZerosInFront( data[2].toString(), 2 );
			getField( CMD.RELAY_ALARM2, 2 ).setCellInfo( value );
			getField( CMD.RELAY_ALARM2, 4 ).setCellInfo( String(data[3]) );
			value = UTIL.formateZerosInFront( data[4].toString(), 2)+":"+ UTIL.formateZerosInFront( data[5].toString(), 2 );
			getField( CMD.RELAY_ALARM2, 5 ).setCellInfo( value );
			getField( CMD.RELAY_ALARM2, 7 ).setCellInfo( String(data[6]) );
			getField( CMD.RELAY_ALARM2, 8 ).setCellInfo( String(data[7]) );
			
			data = OPERATOR.dataModel.getData( CMD.RELAY_ALARM1 )[ getStructure()-1 ];			///
			(getField( CMD.RELAY_ALARM1,2) as FSComboCheckBox).setList( PartitionServant.getPartitionCCBList( data[1] ));		///
			
			onTimeCall(null);
			
			if ( NEED_SAVE )
				remember( getField(CMD.RELAY_ALARM1,1) );
		}
		private function onTimeCall(t:IFormString):void
		{
			var ffire:IFormString = getField(CMD.RELAY_ALARM2,1);
			var fpanic:IFormString = getField(CMD.RELAY_ALARM2,4);
			if (t) {
				var disable:Boolean = Boolean(int(t.getCellInfo()) == 0 || int(t.getCellInfo()) == 1);
				if (t == ffire)
					getField(CMD.RELAY_ALARM2,2).disabled = disable;
				if (t == fpanic)
					getField(CMD.RELAY_ALARM2,5).disabled = disable;
			} else {
				getField(CMD.RELAY_ALARM2,2).disabled = Boolean(int(ffire.getCellInfo()) == 0 || int(ffire.getCellInfo()) == 1);
				getField(CMD.RELAY_ALARM2,5).disabled = Boolean(int(fpanic.getCellInfo()) == 0 || int(fpanic.getCellInfo()) == 1);
			}
			if (t)
				SavePerformer.remember(getStructure(),t);
		}
		
		private function pattern_3():void	
		{
			/**Команда RELAY_INDMES настройки индикации непереданных событий ( 5 - выходов - 5 структур )
			 * Параметр 1 - 0 - Шаблон не действует, 1 - Шаблон действует;
			 * Параметр 2 - Есть события, требующие передачи ( 0x00 - Нет команды, 0x01 - Включить, 0x02 - Выключить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц );
			 * Параметр 3 - Все события переданы ( 0x00 - Нет команды, 0x01 - Включить, 0x02 - Выключить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц ).*/
			
			pattern_3_wasSelected = true;
			
			if( !screens[3] ) {
				screens[3] = new Vector.<Object>;
				
				var header:Header = new Header( [{label:loc("ui_pattern_device_state"),xpos:15},{label:loc("alarm_run_command"), xpos:260, width:200}],
					{size:12, leading:0} );
				
				addChild( header );
				header.y = 50;
				
				(screens[3] as Vector.<Object>).push( header );
				
				var menu:Array = [{label:loc("g_nocmd"), data:0x00},
					{label:loc("g_switchon"), data:0x01},
					{label:loc("g_switchoff"), data:0x02},
					{label:loc("out_switchon_05hz"), data:0x06},
					{label:loc("out_switchon_1hz"), data:0x07},
					{label:loc("out_switchon_2hz"), data:0x08}];
				
				globalY = 90;
				globalX = 10;
			/*	(screens[3] as Vector.<Object>).push(
					createUIElement( new FormString, 3,loc("rfd_exist_events_require_transfer"),null,3)
				);
				attuneElement(NaN,NaN,FormString.F_MULTYLINE);
				(screens[3] as Vector.<Object>).push(	createUIElement( new FormString, 3,loc("rfd_all_events_transfered"),null,4)					);*/
				
			//	globalY = 90;
			//	globalX = 210;
				FLAG_SAVABLE = true;
				createUIElement( new FSShadow, CMD.RELAY_INDMES,"1",null,1 );
				(screens[3] as Vector.<Object>).push(	createUIElement( new FSComboBox, CMD.RELAY_INDMES,loc("output_events_exist"),null,2,menu)				);
				attuneElement(250,200,FSComboBox.F_COMBOBOX_NOTEDITABLE);
				(screens[3] as Vector.<Object>).push(	createUIElement( new FSComboBox, CMD.RELAY_INDMES,loc("rfd_all_events_transfered"),null,3,menu)				);
				attuneElement(250,200,FSComboBox.F_COMBOBOX_NOTEDITABLE);
				
				/*
				createUIElement( new FSShadow, CMD.RELAY_INDMES,"1",null,1 );
				(screens[3] as Vector.<Object>).push( addui( new FSComboBox, CMD.RELAY_INDMES, loc("output_events_exist"), null, 2, menu ) );
				attuneElement( 250, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				(screens[3] as Vector.<Object>).push( addui( new FSComboBox, CMD.RELAY_INDMES, loc("rfd_all_events_transfered"), null, 3, menu ) );
				attuneElement( 250, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				*/
				
				FLAG_SAVABLE = false;
			}
			var data:Array = OPERATOR.dataModel.getData( CMD.RELAY_INDMES )[getStructure()-1];
			getField( CMD.RELAY_INDMES, 2 ).setCellInfo( String(data[1]) );
			getField( CMD.RELAY_INDMES, 3 ).setCellInfo( String(data[2]) );

			if ( NEED_SAVE ) {
				getField( CMD.RELAY_INDMES, 2 ).setCellInfo( 6 );
				getField( CMD.RELAY_INDMES, 3 ).setCellInfo( 2 );	
				remember( getField(CMD.RELAY_INDMES,1) );
			}
		}
		private function pattern_4():void	
		{
			pattern_4_wasSelected = true;
			
			if( !screens[4] ) {
				screens[4] = new Vector.<Object>;
				FLAG_SAVABLE = true;
				createUIElement( new FSShadow, CMD.RELAY_PERMANENTLY_ON, "", null, 1 );
				FLAG_SAVABLE = false;
			}
			
			getField( CMD.RELAY_PERMANENTLY_ON, 1 ).setCellInfo( 1 );
			
			if ( NEED_SAVE )
				SavePerformer.remember( getStructure(), getField(CMD.RELAY_PERMANENTLY_ON,1) );
		}
		private function after():void
		{
			if (!this.visible) {
				SavePerformer.trigger();
				return;
			}
			switch( CURRENT_SELECTION ) {
				case 0:
					if (pattern_1_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDPART, null, getStructure(), [0,0] ));
					if (pattern_2_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_ALARM1, null, getStructure(), [0,0]) );
					if (pattern_3_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDMES, null, getStructure(), [0,0,0]) );
					if (pattern_4_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_PERMANENTLY_ON, null, getStructure(), [0]) );
					break;
				case 1:
					if (pattern_2_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_ALARM1, null, getStructure(), [0,0]) );
					if (pattern_3_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDMES, null, getStructure(), [0,0,0]) );
					if (pattern_4_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_PERMANENTLY_ON, null, getStructure(), [0]) );
					break;
				case 2:
					if (pattern_1_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDPART, null, getStructure(), [0,0]) );
					if (pattern_3_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDMES, null, getStructure(), [0,0,0]) );
					if (pattern_4_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_PERMANENTLY_ON, null, getStructure(), [0]) );
					break;
				case 3:
					if (pattern_1_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDPART, null, getStructure(), [0,0]) );
					if (pattern_2_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_ALARM1, null, getStructure(), [0,0]) );
					if (pattern_4_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_PERMANENTLY_ON, null, getStructure(), [0]) );
					break;
				case 4:
					if (pattern_1_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDPART, null, getStructure(), [0,0] ));
					if (pattern_2_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_ALARM1, null, getStructure(), [0,0]) );
					if (pattern_3_wasSelected)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDMES, null, getStructure(), [0,0,0]) );
					break;
			}
			pattern_1_wasSelected = false;
			pattern_2_wasSelected = false;
			pattern_3_wasSelected = false;
			pattern_4_wasSelected = false;
			if (CURRENT_SELECTION == 1)
				pattern_1_wasSelected = true;
			if (CURRENT_SELECTION == 2)
				pattern_2_wasSelected = true;
			if (CURRENT_SELECTION == 3)
				pattern_3_wasSelected = true;
			if (CURRENT_SELECTION == 4)
				pattern_4_wasSelected = true;
		}
		private function callVisualizer(num:int):void
		{
			var len:int;
			for( var i:int=0; i<screens_length; ++i ) {
				if( screens[i] != null ) {
					len = (screens[i] as Vector.<Object>).length;
					for( var c:int=0; c<len; ++c ) {
						screens[i][c].visible = Boolean(i == num);
					}
				}
			}
		}
		public function set structure(value:int):void
		{
			structureID = value;
		}
		/*override public function set x(value:Number):void
		{
			super.x = value;
		}*/
	}
}