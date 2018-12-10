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
	import components.gui.fields.FormString;
	import components.gui.visual.HLine;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIRFRele;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptRele_pattern extends OptionsBlock
	{
		private const MAX_PATTERN_STRUCTURES:int = 16;
		
		private var releNum:int;
		private var relayNum:int;
		private var screens:Vector.<Object>;
		private const screens_length:int=4;
		private var NEED_SAVE:Boolean = false;
		private var CURRENT_SELECTION:int = 0;
		private var patternStructures:Array;
		private var validationFields:Vector.<Object>;
		private var isAllValid:Boolean=true;
		
		private var HASH_CMD:Object = {156:1,158:2,159:2,157:3};
		
		private var pattern_1_wasSelected:Boolean=false;
		private var pattern_2_wasSelected:Boolean=false;
		private var pattern_3_wasSelected:Boolean=false;
		private var tPatternLimit:SimpleTextField;
		
		public function OptRele_pattern()
		{
			super();
			globalX = 10;
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString,0,loc("ui_pattern_output_control"),null,1);
			globalX = 210;
			globalY = 0;
			createUIElement( new FSComboBox, 0, "", callSwitchPattern, 2, ClientArrays.RELE_PATTERNS ) as FSComboBox;
			attuneElement(400,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setCellInfo("0");
			
			var hl:HLine = new HLine(887);
			addChild(hl);
			hl.y = 31;
			
			screens = new Vector.<Object>;
			screens[0] = new Vector.<Object>;
			screens.length = screens_length;
			screens.fixed = true;
			 
			validationFields = new Vector.<Object>;
			
			var txt:String = loc("ui_pattern_limit_reach")+" ("+MAX_PATTERN_STRUCTURES+")\r"+
				loc("ui_pattern_should_remove_one");
			
			tPatternLimit = new SimpleTextField( txt,400 );
			tPatternLimit.setSimpleFormat( "center",0,16 );
			addChild( tPatternLimit );
			tPatternLimit.x = 117;
			tPatternLimit.y = 108;
			tPatternLimit.visible = false;	
		}
		private function callSwitchPattern():void
		{
			NEED_SAVE = true;
			switchPattern();
		}
		private function switchPattern():void
		{
			CURRENT_SELECTION = int(getField( 0,2 ).getCellInfo());
			
			if ( patternStructures[CURRENT_SELECTION] > MAX_PATTERN_STRUCTURES && CURRENT_SELECTION > 0 ) {
				tPatternLimit.visible = true;
				return;
			} else
				tPatternLimit.visible = false;

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
			}
		}
		override public function putRawData(a:Array):void
		{
			NEED_SAVE = false;
			patternStructures = a[3];
			releNum = a[0]+1;
			relayNum = a[1];
			getField( 0,2 ).setCellInfo( String(a[2]) );
			switchPattern();
			SavePerformer.trigger( {"after":after} );
		}
		private function pattern_0():void	
		{
			if ( pattern_1_wasSelected || pattern_2_wasSelected || pattern_3_wasSelected )
				rememberBlank();
		}
		private function pattern_1():void	
		{
			/**	RFRELAY_INDPART
			 *	Команда настройки шаблона выхода "Индикация состояния раздела" (шаблонов 16шт.):
			 * 	Параметр 1 - Номер радиореле (0 - шаблон не действует);//параметр1 =0 и параметр2=0 указывают, что шаблон не действует
			 *  Параметр 2 - Номер выхода радиореле (0-шаблон не действует, 1-6 );
			 *  Параметр 3 - Номер раздела.( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Если Параметр 5 "Мастер раздела" не равен 0, то раздел задается числом 1-99
			 *  Параметр 4 - Номер мастера раздела ( 0x00 - Нет мастера, собственный раздел. 1-254 - номер мастера раздела - адрес прибора, который является управляющим для данного выхода ) */	
			
			pattern_1_wasSelected = true;
			
			if( !screens[1] ) {
				screens[1] = new Vector.<Object>;
				
				globalY = 50;
				globalX = 10;
				(screens[1] as Vector.<Object>).push( 
					createUIElement( new FormString, 1,loc("ui_led_partition_state")+" ",null,3)
					);
				
				globalY = 50;
				globalX = 260;
				(screens[1] as Vector.<Object>).push(	createUIElement( new FSComboBox, CMD.RFRELAY_INDPART,"",rememberBlank,3, PartitionServant.getPartitionList())	);
				attuneElement(60,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				
				var ann:String = loc("ui_pattern_rele_note1")
				
				var tAnnotaion:SimpleTextField = new SimpleTextField( ann );
				addChild( tAnnotaion );
				tAnnotaion.x = 10;
				tAnnotaion.y = 90;
				
				(screens[1] as Vector.<Object>).push( tAnnotaion );
			}
			
			var data:Array = OPERATOR.dataModel.getData( CMD.RFRELAY_INDPART )[getStructure()-1];
			(getField( CMD.RFRELAY_INDPART, 3 ) as FSComboBox).setList( PartitionServant.getPartitionList() );
		//	getField( ProjConst.EVENT_RFRELAY_INDPART, 3 ).setCellInfo( String(data[2]) ); 
			
			if (data[2] == 0) {
				getField( CMD.RFRELAY_INDPART, 3 ).setCellInfo( String(PartitionServant.getFirstPartition()) );
				NEED_SAVE = true;
			} else
				getField( CMD.RFRELAY_INDPART, 3 ).setCellInfo( String(data[2]) );
			
			if ( NEED_SAVE )
				rememberBlank();
		}
		private function pattern_2():void	
		{
			/**	Команды используются совместно.
			 * 	Команда RFRELAY_ALARM1 Команда назначения разделов для включения выхода по тревоге ( всего: 16 шаблонов)
			 * 	Параметр 1 - Номер радиореле;
			 * 	Параметр 2 - Номер выхода радиореле; //параметр1 =0 и параметр2=0 указывают, что шаблон не действует
			 * 	Параметр 3 - Разделы ( используется если Параметр 9 Команды RFRELAY_ALARM2 "Мастер раздела" равен 0 ) ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление );
			 *
 			 *	Команда RFRELAY_ALARM2 Команда настройки включения выхода по тревоге в разделе ( всего: 16 шаблонов )
			 * 	Параметр 1 - команда при охранной тревоге ( 0x00 - Нет команды, 0x01 - Включить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц );
			 * 	Параметр 2,3 - время включения (ММ,СС) 00:00-99:59;
			 * 	Параметр 4 - команда при пожарной тревоге ( 0x00 - Нет команды, 0x01 - Включить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц );
			 * 	Параметр 5,6 - время включения (ММ,СС) 00:00-99:59;
			 * 	Параметр 7 - Индикация задержки на вход ( 0-нет,1 -да)
			 * 	Параметр 8 - Индикация задержки на выход (0-нет,1-да)
			 * 
			 * 	Команда RFRELAY_ALARM3 - разделы от мастера разделов
			 * 	Параметр 1,2,3,4,5,6,7,8 - Разделы, по которым включается выход ( 0x00 - Нет , 1-99 номера разделов, используются только, если Параметр 9 "Мастер раздела" задан ).
			 * 	Параметр 9 - мастер раздела. (1-254) */
			
			pattern_2_wasSelected = true;
			
			if( !screens[2] ) {
				screens[2] = new Vector.<Object>;
			
				globalY = 50;
				globalX = 10;
				(screens[2] as Vector.<Object>).push(	createUIElement( new FormString, 2, loc("ui_out_turnon_when_part_alarm"), null, 1 ) 		);
				attuneElement( 300 );
				globalY = 50;
				globalX = 310;
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboCheckBox, CMD.RFRELAY_ALARM1, "", rememberBlank, 3 )			);
				(getLastElement() as FSComboCheckBox).turnToBitfield = PartitionServant.turnToPartitionBitfield;
				globalX = 10;
				var sep1:Separator = new Separator(550);
				addChild( sep1 );
				sep1.x = globalX;
				sep1.y = globalY;
				globalY += 20;
				(screens[2] as Vector.<Object>).push( sep1 );
				
				var header:Header = new Header( [{label:loc("ui_indsound_alarm_type"),xpos:15, width:150},{label:loc("ui_indsound_cmd"), xpos:250, width:200},
					{label:loc("ui_indsound_switchon_time"), xpos:400,width:200,align:"center"}],
					{size:12, leading:0} );
				
				addChild( header );
				header.y = globalY;
				globalY += 40;
				(screens[2] as Vector.<Object>).push( header );
				
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
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RFRELAY_ALARM2, "", rememberBlank, 1, menu )		);
				attuneElement( 170,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RFRELAY_ALARM2, "", rememberBlank, 4, menu )		);
				attuneElement( 170,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				
				var menu_time:Array = [{label:"05:00", data:"05:00"},
					{label:"15:00", data:"15:00"},
					{label:"30:00", data:"30:00"},
					{label:"60:00", data:"60:00"},
					{label:"90:00", data:"90:00"}]
				
				globalY = 143;
				globalX = 450;
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RFRELAY_ALARM2, "", rememberBlank, 2, menu_time,"0-9:",5,new RegExp(RegExpCollection.REF_TIME_0000to9959) )		);
				validationFields.push( getLastElement() );
				attuneElement(NaN,NaN,FSComboBox.F_COMBOBOX_TIME);
				globalY = 153+21;
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSComboBox, CMD.RFRELAY_ALARM2, "", rememberBlank, 5, menu_time,"0-9:",5,new RegExp(RegExpCollection.REF_TIME_0000to9959) )		);
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
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSCheckBox, CMD.RFRELAY_ALARM2, loc("ui_out_ind_enter_delay"),rememberBlank,7)	);
				attuneElement( 230 );
				(screens[2] as Vector.<Object>).push(  	createUIElement( new FSCheckBox, CMD.RFRELAY_ALARM2, loc("ui_out_ind_exit_delay"),rememberBlank,8)	);
				attuneElement( 230 );
				yshift = 20;
				var txt:String = loc("ui_out_ptrn2_note");
				var tf:SimpleTextField = new SimpleTextField(txt);
				addChild( tf );
				tf.y = globalY;
				tf.x = globalX;
				(screens[2] as Vector.<Object>).push( tf );
			}
			var data:Array = OPERATOR.dataModel.getData( CMD.RFRELAY_ALARM2 )[ getStructure()-1 ];			
			
			getField( CMD.RFRELAY_ALARM2, 1 ).setCellInfo( String(data[0]) );
			var value:String = UTIL.formateZerosInFront( data[1].toString(), 2)+":"+ UTIL.formateZerosInFront( data[2].toString(), 2 );
			getField( CMD.RFRELAY_ALARM2, 2 ).setCellInfo( value );
			
			var data2:Array = OPERATOR.dataModel.getData( CMD.RFRELAY_ALARM1 )[ getStructure()-1 ];
			(getField( CMD.RFRELAY_ALARM1,3) as FSComboCheckBox).setList( PartitionServant.getPartitionCCBList( data2[2] ));
			
			getField( CMD.RFRELAY_ALARM2, 4 ).setCellInfo( String(data[3]) );
			value = UTIL.formateZerosInFront( data[4].toString(), 2)+":"+ UTIL.formateZerosInFront( data[5].toString(), 2 );
			getField( CMD.RFRELAY_ALARM2, 5 ).setCellInfo( value );
			getField( CMD.RFRELAY_ALARM2, 7 ).setCellInfo( String(data[6]) );
			getField( CMD.RFRELAY_ALARM2, 8 ).setCellInfo( String(data[7]) );
			
			onTimeCall();
			
			if ( NEED_SAVE )
				rememberBlank();
		}
		private function onTimeCall():void
		{
			var ffire:IFormString = getField(CMD.RFRELAY_ALARM2,1);
			var fpanic:IFormString = getField(CMD.RFRELAY_ALARM2,4);

			getField(CMD.RFRELAY_ALARM2,2).disabled = Boolean(int(ffire.getCellInfo()) == 0 || int(ffire.getCellInfo()) == 1);
			getField(CMD.RFRELAY_ALARM2,5).disabled = Boolean(int(fpanic.getCellInfo()) == 0 || int(fpanic.getCellInfo()) == 1);
		}
		private function pattern_3():void  
		{
			/** RFRELAY_INDMES
			 *	Команда настройки индикации непереданных событий ( всего: 16 шаблонов )
			 * 	Параметр 1 - Номер радиореле ( 0 - шаблон не действует );
			 * 	Параметр 2 - Номер выхода радиореле (0-шаблон не действует, 1-6 );//параметр1 =0 и параметр2=0 указывают, что шаблон не действует
			 * 	Параметр 3 - Есть события, требующие передачи ( 0x00 - Нет команды, 0x01 - Включить, 0x02 - Выключить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц );
			 * 	Параметр 4 - Все события переданы ( 0x00 - Нет команды, 0x01 - Включить, 0x02 - Выключить, 0x04 - Включить на время, 0x06 - Включить на время с частотой 0,5Гц, 0x07 - Включить на время с частотой 1Гц, 0x08 - Включить на время с частотой 2Гц ). */
			
			pattern_3_wasSelected = true;
			
			if( !screens[3] ) {
				screens[3] = new Vector.<Object>;
			
				var header:Header = new Header( [{label:loc("ui_pattern_device_state"),xpos:15},{label:loc("ui_indsound_cmd"), xpos:220, width:200}],
					{size:12, leading:0} );
				
				addChild( header );
				header.y = 50;
				
				(screens[3] as Vector.<Object>).push( header );
				
				var menu:Array = [{label:loc("g_nocmd"), data:0x00},
					{label:loc("g_switchon"), data:0x01},
					{label:loc("g_switchoff"), data:0x02},
					{label:loc("g_switchon_05hz"), data:0x06},
					{label:loc("g_switchon_1hz"), data:0x07},
					{label:loc("g_switchon_2hz"), data:0x08}];
				
				globalY = 90;
				globalX = 10;
				(screens[3] as Vector.<Object>).push(
					createUIElement( new FormString, 3,loc("rfd_exist_events_require_transfer"),null,3)
					);
				attuneElement(NaN,NaN, FormString.F_MULTYLINE );
				(screens[3] as Vector.<Object>).push(	createUIElement( new FormString, 3,loc("rfd_all_events_transfered"),null,4)					);
				
				globalY = 90;
				globalX = 210;
				(screens[3] as Vector.<Object>).push(	createUIElement( new FSComboBox, CMD.RFRELAY_INDMES,"",rememberBlank,3,menu)				);
				attuneElement(200,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				(screens[3] as Vector.<Object>).push(	createUIElement( new FSComboBox, CMD.RFRELAY_INDMES,"",rememberBlank,4,menu)				);
				attuneElement(200,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			}
			var data:Array = OPERATOR.dataModel.getData( CMD.RFRELAY_INDMES )[getStructure()-1];
			getField( CMD.RFRELAY_INDMES, 3 ).setCellInfo( String(data[2]) );
			getField( CMD.RFRELAY_INDMES, 4 ).setCellInfo( String(data[3]) );
			
			//getField( ProjConst.EVENT_RFRELAY_INDMES, 3 ).setCellInfo(); 
			
			if ( NEED_SAVE )
				rememberBlank();
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
		override public function getStructure():int
		{
			return patternStructures[CURRENT_SELECTION];
		}
		private function rememberBlank():void
		{
			isAllValid = true;
			var len:int = validationFields.length; 
			for(var i:int=0; i<len; ++i) {
				
				if( !(validationFields[i] as IFormString).isValid() && CURRENT_SELECTION == HASH_CMD[ (validationFields[i] as IFormString).cmd ] ) {
					isAllValid = false;
					return;
				}
			}
			
			onTimeCall();
			
			SavePerformer.rememberBlank();
		}
		private function after():void
		{
			if (!this.visible) {
				SavePerformer.trigger();
				return;
			}
			if (!isAllValid) {
				trace("save impossible")
				return;
			}
			trace("after "+CURRENT_SELECTION + " реле/выход " +releNum+"/"+relayNum + " сохраняем в "+getStructure() );
			
			
			for( var i:int=1; i<4; ++i) {
				sendSmartCMD(i);
			}
		}
		private function sendSmartCMD(num:int):void
		{
			var cmd:int;
			var data:Array;
			var struct:int;
			var field:IFormString;
			switch(num) {
				case UIRFRele.SWITCH_RFRELAY_INDPART:
					cmd = CMD.RFRELAY_INDPART;
					struct = patternStructures[1];
					field = getField(cmd,3); 
					if(!field)
						break;
					if (num == CURRENT_SELECTION) {
						pattern_1_wasSelected = true;
						data = [ releNum, relayNum, int(field.getCellInfo()), 0 ];
					} else {
						if( pattern_1_wasSelected ) {
							data = [0,0,0,0];
							pattern_1_wasSelected = false;
						}
					}
					break;
				case UIRFRele.SWITCH_RFRELAY_ALARM:
					cmd = CMD.RFRELAY_ALARM1;
					struct = patternStructures[2];
					field = getField(cmd,3);
					if(!field)
						break;
					if (num == CURRENT_SELECTION) {
						pattern_2_wasSelected = true;
						data = [ releNum, relayNum, int(field.getCellInfo()) ];
						var data2:Array = [int(getField(CMD.RFRELAY_ALARM2,1).getCellInfo()),
							int(getField(CMD.RFRELAY_ALARM2,2).getCellInfo()[0]),
							int(getField(CMD.RFRELAY_ALARM2,2).getCellInfo()[1]),
							int(getField(CMD.RFRELAY_ALARM2,4).getCellInfo()),
							int(getField(CMD.RFRELAY_ALARM2,5).getCellInfo()[0]),
							int(getField(CMD.RFRELAY_ALARM2,5).getCellInfo()[1]),
							int(getField(CMD.RFRELAY_ALARM2,7).getCellInfo()),
							int(getField(CMD.RFRELAY_ALARM2,8).getCellInfo()) ];

						RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_ALARM2, null, getStructure(), data2 ));
						//OPERATOR.dataModel.putStructure( CMD.RFRELAY_ALARM2, getStructure(), data2);
					} else {
						if( pattern_2_wasSelected ) {
							data = [0,0,0];
							pattern_2_wasSelected = false;
						}
					}
					break;
				case UIRFRele.SWITCH_RFRELAY_INDMES:
					cmd = CMD.RFRELAY_INDMES;
					struct = patternStructures[3];

					field = getField(cmd,3);
					if(!field)
						break;
					
					if (num == CURRENT_SELECTION) {
						pattern_3_wasSelected = true;
						data = [ releNum, relayNum, int(field.getCellInfo()), int(getField(cmd,4).getCellInfo()) ];
					} else {
						if( pattern_1_wasSelected ) {
							data = [0,0,0,0];
							pattern_3_wasSelected = false;
						}
					}
					break;
			}
			if (data) {
				trace( struct );
				RequestAssembler.getInstance().fireEvent( new Request( cmd, null, struct, data ));
				//OPERATOR.dataModel.putStructure( cmd, struct, data);
			}
		}
	}
}