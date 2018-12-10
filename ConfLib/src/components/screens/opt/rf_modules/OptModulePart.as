package components.screens.opt.rf_modules
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCCBMaximumSelections;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptModulePart extends OptionsBlock
	{

		private var groups:GroupOperator;
		private var bsep:Separator;
		// порядковый номер выхода на который назначен шаблон
		private var _partId:int = 0;
		private var inpatterns:Array;
		private var fatherType:int;
		private var paramNmRfCtrl:int;
		private var fspart:FSCCBMaximumSelections;
		
		private const T4_SWITCH_ON:int = 1;
		private const T4_SWITCH_ON_FREQ:int = 2;
		private const T4_SWITCH_OFF:int = 4;
		private const T4_SWITCH_DELAY:int = 5;

		private var howLong:FSSimple;

		private var delayCBox:FSComboBox;
		private var reqConditTask:ITask;

		private var periodMMSSBox:FSComboBox;

		private var _cbSection:FSComboBox;
		
		
		public function set strc( nm:int ):void
		{
			
			
			structureID = nm;
			
			
		}
		public function OptModulePart( pId:int  )
		{
			super();
			
			
			
			init( pId );
		}
		
		private function init( pId:int ):void
		{
			_partId = pId;
			
			structureID = _partId; 
			
			operatingCMD = CMD.RF_CTRL;
			const padding:int = 300;
			const lengthDraw:int = 700;
			
			inpatterns =
				[ 
					[ 0, loc( "out_no_action" ) ], /// реакция не настроена
					[ 1, loc( "ui_led_partition_state" ) ], ///Индикация состояния раздела
					[ 2, loc( "out_trigger_on_part_alarm" ) ], /// Срабатывание по тревоге в разделе
					[ 3, loc( "ui_led_unsend_events" ) ], /// Индикация непереданных событий
					[ 4, loc( "out_failure_ind" ) ], /// Индикация неисправности
					[ 5, loc( "output_manual" ) ]/// Ручное управление выводом
				];
			
			
			addui( new FSSimple, CMD.RF_CTRL_OUT_STATE, loc( "out_current_state" ) , null, 1 );
			attuneElement( padding, 95, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_BOLD | FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_HTML_TEXT );
			getLastElement().setAdapter( new AdaptKeySensor );
			
			
			paramNmRfCtrl = _partId + 2;
			
			
			
			addui( new FSComboBox, 0, loc("ui_pattern_output") + " " + _partId, switchPattern, paramNmRfCtrl, null); 
			attuneElement( padding, padding );
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, loc("cden"), null, 10, null );
			getLastElement().y = getField( 0, paramNmRfCtrl ).y;
			getLastElement().x = 200;
			
			
			
			globalY -= getLastElement().height - 10;
			
			bsep = drawSeparator( lengthDraw );
			
			FLAG_SAVABLE = true;
			
			groups = new GroupOperator;
			
			const gr0:String = "gr0";
			
			groups.add( gr0, null );
			
			const anchore:int = globalY;
			
			/***	1	******************************************/
			
			const gr1:String = "gr1";
			
			
			_cbSection = addui(new FSComboBox, CMD.RF_CTRL_TEMPLATE_ST_PART, loc( "ui_led_partition_state" ), dlgChkValue, 1,  PartitionServant.getExistParts()) as FSComboBox;
			
			
			attuneElement(padding, 80);
			_cbSection.setAdapter( new AdaptComboBoxParts );
			
			
			
			groups.add( gr1, _cbSection );
			
			const warn:SimpleTextField = new SimpleTextField(  loc( "faq_info_for_rfmodules"), 600, COLOR.GREEN_DARK);
			warn.x = globalX;
			warn.y = globalY;
			addChild( warn );
			globalY += warn.height;
			
			groups.add( gr1, warn );
			
			groups.add( gr1, drawSeparator( lengthDraw ) );
			
			
			
			
			/***	2	******************************************/
			
			globalY = anchore;
			
			const gr2:String = "gr2";
			
			var sh:int = 250;
			var w:int = 250;
			var sw:int = 540;
			fspart = addui( new FSCCBMaximumSelections, 0, loc("ui_out_turnon_when_part_alarm"), onPart, 1) as FSCCBMaximumSelections;
			attuneElement(padding, 80);
			groups.add(gr2,getLastElement());
			fspart.MAX_SELECTED_ITEMS = 16;
			fspart.REACH_MAX_TEXT = loc("out_part_max");
			
			
			
			for (var i:int=0; i<16; i++) {
				addui( new FSShadow, CMD.RF_CTRL_TEMPLATE_AL_LST_PART, "", null, i+1 );				
			}
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, loc("alarm_type_line"), null, 1 );
			attuneElement( sh, w, FormString.F_TEXT_BOLD );
			groups.add(gr2,getLastElement());
			
			FLAG_VERTICAL_PLACEMENT = true;
			
			addui( new FormString, 0, loc("alarm_run_command"), null, 1 ).x = 300;
			attuneElement( NaN, NaN, FormString.F_TEXT_BOLD );
			groups.add(gr2,getLastElement());
			
			/** "Команда RF_CTRL_TEMPLATE_AL_PART - данные шаблонов ""Срабатывание по тревоге в разделе""
			 
			 Параметр 1 - Выполняемая команда при охранной тревоге
			 ........0-Нет действия
			 ........1-Включить до сброса тревоги
			 ........2-Включить на время
			 ........3-Включить на время с частотой 1Гц
			 ........4-импульсы раз в 6 сек на время
			 Параметр 2 - Выполняемая команда при пожарной тревоге
			 ........0-Нет действия
			 ........1-Включить до сброса тревоги
			 ........2-Включить на время
			 ........3-Включить на время с частотой 1Гц
			 ........4-Импульсы раз в 6 сек на время
			 Параметр 3 - Время срабатывания, минуты 00-99
			 Параметр 4 - Время срабатывания, секунды 00-59
			 Параметр 5 - Индикация задержки на вход, 0-нет задержки, 1-есть задержка
			 Параметр 6 - Индиказия задержки на выход, 0-нет задержки, 1-есть задержка */
			
			var l:Array = UTIL.getComboBoxList([[0,loc("g_no_action")],[1,loc("out_switch_until_alarm_reset")],
				[2,loc("g_switchon_time")],[3,loc("g_switchon_1hz")],[4,loc("out_short_impulse_6sec")]]);
			addui( new FSComboBox, CMD.RF_CTRL_TEMPLATE_AL_PART, loc("out_state_while_alarm"), onAlarm, 1, l.slice());
			attuneElement(sh,w,FSComboBox.F_COMBOBOX_NOTEDITABLE);
			groups.add(gr2,getLastElement());
			
			addui( new FSComboBox, CMD.RF_CTRL_TEMPLATE_AL_PART, loc("out_state_while_fire"), onAlarm, 2, l.slice());
			attuneElement(sh,w,FSComboBox.F_COMBOBOX_NOTEDITABLE);
			groups.add( gr2,getLastElement());
			//getLastElement().setAdapter( new AdaptComboBoxParts );
			
			var li:Array = [ {label:"01:00", data:"01:00"},{label:"15:00", data:"15:00"},
				{label:"30:00", data:"30:00"},{label:"45:00", data:"45:00"} ];
			
			addui( new FSComboBox, CMD.RF_CTRL_TEMPLATE_AL_PART, loc("out_switchon_time"), null, 3, li, "0-9:",5,new RegExp( RegExpCollection.REF_TIME_0005to9959) );
			attuneElement(sh+(w-70),70, FSComboBox.F_COMBOBOX_TIME );
			groups.add(gr2,getLastElement());
			
			globalY += 5;
			
			groups.add(gr2,drawIndent());
			
			var tf:SimpleTextField = new SimpleTextField(loc("out_fire_priority"), 500 );
			addChild( tf );
			tf.x = globalX + 10;
			tf.y = globalY;
			groups.add(gr2,tf);
			
			globalX = 0;
			globalY += 40;
			
			addui( new FSCheckBox, CMD.RF_CTRL_TEMPLATE_AL_PART, loc("ui_out_ind_enter_delay"), null, 5 );
			attuneElement( sh );
			groups.add(gr2,getLastElement());
			addui( new FSCheckBox, CMD.RF_CTRL_TEMPLATE_AL_PART, loc("ui_out_ind_exit_delay"), null, 6 );
			attuneElement( sh );
			groups.add(gr2,getLastElement());
			
			groups.add( gr2, drawSeparator( lengthDraw ) );
			
			
			
			/***	3	******************************************/
			globalY = anchore;
			const gr3:String = "gr3";
			
			var l2:Array = UTIL.getComboBoxList( [ 
				[0x01,loc("g_switchon")],
				[0x02,loc("out_switchon_1hz")],
				[0x03,loc("out_short_impulse_6sec")],
				[0x04,loc("g_switchoff")] ] );  
			
			
			groups.add(gr3, addui( new FSComboBox, CMD.RF_CTRL_TEMPLATE_UNSENT_MESS, loc("output_events_exist"), null, 1, l2 ) );
			attuneElement(padding, padding);
			groups.add( gr3, drawSeparator( lengthDraw ) );
			
			/***	4	******************************************/
			globalY = anchore - 40;
			const gr4:String = "gr4";
			var header:Header = new Header( [
				{label:loc("out_fault_type"), width:160, xpos:0, align:"left"},
				{label:loc("ui_indsound_cmd"), width:200, xpos:300},
				
			] );
			header.x = globalX;
			header.y = globalY ;
			
			this.addChild( header );
			groups.add( gr4, header );
			
			
			globalY += 40;
			
			groups.add(gr4, addui( new FSComboBox, CMD.RF_CTRL_TEMPLATE_FAULT, loc("out_device_fault"),  delegateEnablerTField, 1, l.slice() ) );
			attuneElement(padding, padding);
			
			groups.add(gr4, addui( new FSComboBox, CMD.RF_CTRL_TEMPLATE_FAULT, loc("out_radiosensore_fault"), delegateEnablerTField, 2, l.slice() ) );
			attuneElement(padding, padding);
			
			
			var menu_t:Array = 
				[
					{label:"00:05", data:"00:05", selectedIndex:1 },
					{label:"00:15", data:"00:15"},
					{label:"00:30", data:"00:30"},
					{label:"01:00", data:"01:00"},
					{label:"01:30", data:"01:30"}
				];
			
			
			periodMMSSBox = addui( new FSComboBox,0, loc( "out_switchon_time" ), delegateTime, 1, menu_t , "0-9:",5,new RegExp( "^("+RegExpCollection.RE_TIME_0000to9959+"|255:255)$" ) ) as FSComboBox; 
			periodMMSSBox.disabled = true;
			groups.add( gr4, periodMMSSBox );
			attuneElement(padding );
			
			
			addui( new FSShadow, CMD.RF_CTRL_TEMPLATE_FAULT, "", null, 3 );
			addui( new FSShadow, CMD.RF_CTRL_TEMPLATE_FAULT, "", null, 4 );
			
			
			
			groups.add( gr4, drawSeparator( lengthDraw ) );
			
			
			/***	5	******************************************/
			
			globalY = anchore;
			
			const gr5:String = "gr5";
			
			
			
			groups.add( gr5, addui( new FormString, 0, loc( "ui_part_action" ), null, 1 ) );
			
			howLong = new FSSimple;
			howLong.cmd = CMD.RF_CTRL_TEMPLATE_MANUAL_CNT;
			howLong.setTextColor( COLOR.GREEN_DARK );
			( howLong as FormString ).setTextColor( COLOR.GREEN_DARK );
			howLong.attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_BOLD | FSSimple.F_HTML_TEXT );
			howLong.setWidth( 180 );
			howLong.setName( "<font color='#006838' ><b>" + loc( "how_long" ) + ": " + "</b></font>" );
			howLong.param = 1;
			this.addChild( howLong );
			howLong.visible = false;
			
			
			
			groups.add( gr5, howLong );
			howLong.x = 450;
			howLong.y = getField( CMD.RF_CTRL_OUT_STATE, 1 ).y + 1;
			
			
			
			const butOn:TextButton = new TextButton;
			butOn.setUp( loc( "g_switchon" ), manualSwitcher, T4_SWITCH_ON );
			groups.add( gr5, butOn );
			butOn.x = getLastElement().x + getLastElement().width + 100;
			butOn.y = getLastElement().y;
			this.addChild( butOn );
			
			const butOnII:TextButton = new TextButton;
			butOnII.setUp( loc( "g_switchoff" ), manualSwitcher, T4_SWITCH_OFF );
			groups.add( gr5, butOnII );
			butOnII.x = butOn.x + butOn.width + 100;
			butOnII.y = getLastElement().y;
			this.addChild( butOnII );
			
			
			const butOnIII:TextButton = new TextButton;
			butOnIII.setUp( loc( "g_switchon_time" ) + " " +  loc( "g_time_hhmm" ), manualSwitcher, T4_SWITCH_DELAY );
			groups.add( gr5, butOnIII );
			butOnIII.x = getLastElement().x + getLastElement().width + 100;
			butOnIII.y = globalY;
			this.addChild( butOnIII );
			
			var list_times:Array = 
				[
					{label:"00:05", data:"00:05", selectedIndex:1 },
					{label:"00:15", data:"00:15"},
					{label:"00:30", data:"00:30"},
					{label:"01:00", data:"01:00"},
					{label:"01:30", data:"01:30"}
				];
			
			FLAG_SAVABLE = false;
			/// с обработкой в делегате для записи, но по идее запись не нужна в момент выбора, только в момент включения
			//delayCBox = addui( new FSComboBox,0, "", delegateSelectTimes, 1, list_times , "0-9:",5,new RegExp( "^("+RegExpCollection.RE_TIME_0000to9959+"|255:255)$" ) ) as FSComboBox;
			delayCBox = addui( new FSComboBox,0, "", null, 1, list_times , "0-9:",5,new RegExp( "^("+RegExpCollection.RE_TIME_0000to9959+"|255:255)$" ) ) as FSComboBox;
			attuneElement( NaN, NaN, FSComboBox.F_COMBOBOX_TIME );
			groups.add( gr5, delayCBox );
			getLastElement().x = butOnIII.x + butOnIII.width + 7;
			globalY += butOnIII.height;
			delayCBox.setCellInfo( "00:05" );
			
				
			
			groups.add( gr5, drawSeparator( lengthDraw ) );
			/***	the end	******************************************/
			groups.removeFromTheSceneGroups();
			FLAG_SAVABLE = true;
			addui( new FSShadow, CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, "", null, 1 );			
			addui( new FSShadow, CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, "", null, 2 );			
			addui( new FSShadow, CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, "", null, 3 );			
			addui( new FSShadow, CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, "", null, 4 );		
			
			
			this.height = this.getChildAt( this.numChildren - 1 ).y + this.getChildAt( this.numChildren - 1 ).height; 
			
			manualResize();
			
		}
		
			
			
				
		
		
		override public function putData(p:Package):void 
		{
			
			switch( p.cmd ) {
				case CMD.RF_CTRL:
					refreshCells( p.cmd, false, structureID );
					
					fatherType = p.data[ 1 ];
					( getField( 0, paramNmRfCtrl ) as FSComboBox ).setList( getPatternsSet( createMaskParts( fatherType ), "" ) );
					/// добавляем окончание к строке если это не радиореле
					getField( 0, 10 ).setName( createEnding() );
					getField( 0, paramNmRfCtrl ).setCellInfo( p.data[ paramNmRfCtrl - 1 ] );
					
					if( !reqConditTask )reqConditTask = TaskManager.callLater( getConditionModules, 5000 );
					
					break;
				
				
				case CMD.RF_CTRL_TEMPLATE_ST_PART:
					refreshCells( p.cmd, false, structureID );
					_cbSection.setList( PartitionServant.getExistParts() )
					if( p.data[ 0 ][ 0 ] == 0x00 || p.data[ 0 ][ 0 ] == 0xFF )
					{
						getField( p.cmd, 1 ).setCellInfo( p.data[ 0 ][ 0 ] );
						p.data[ 0 ][ 0 ] = getField( p.cmd, 1 ).getCellInfo(); 
						RequestAssembler.getInstance().fireEvent( new Request( p.cmd, null, structureID, p.data ) );
						break;
					}
					
					
				case CMD.RF_CTRL_OUT_STATE:
					
					getField( p.cmd, 1 ).setCellInfo( p.data[ 0 ][ 0 ] );
				
					
					break;
				case CMD.RF_CTRL_TEMPLATE_AL_PART:
					refreshCells( p.cmd, false, structureID );
					if( p.data[ 0 ][ 2 ] == 0 && p.data[ 0 ][ 3 ] == 0 )
																	p.data[ 0 ][ 3 ] = 5;
					
					getField( p.cmd, 1 ).setCellInfo( p.data [ 0 ][ 0 ] );
					getField( p.cmd, 2 ).setCellInfo( p.data [ 0 ][ 1 ] );
					getField( p.cmd, 3 ).setCellInfo(  mergeIntoTime(  p.data [ 0 ][ 2 ],  p.data [ 0 ][ 3 ] ) );
					getField( p.cmd, 5 ).setCellInfo( p.data [ 0 ][ 4 ] );
					getField( p.cmd, 6 ).setCellInfo( p.data [ 0 ][ 5 ] );
					
					onAlarm( null );
					break;
				case CMD.RF_CTRL_TEMPLATE_AL_LST_PART:
					
					refreshCells( p.cmd, false, structureID );
					if( DS.isfam( DS.K14 ) ) fspart.setList( PartitionServant.partitionGeneratorFromK14( p.data[ 0 ] as Array  ) );
						else fspart.setList( PartitionServant.partitionGenerator( p.data[ 0 ] as Array  ) );
					
					
					break;
				
				case CMD.RF_CTRL_TEMPLATE_MANUAL_CNT:
					refreshCells( p.cmd, false, structureID );
					
					const timevalue:String = "" +  UTIL.formateZerosInFront( p.data [ 0 ][ 0 ], 2 ) + ":" + UTIL.formateZerosInFront( p.data [ 0 ][ 1 ], 2 ) + ":" + UTIL.formateZerosInFront( p.data [ 0 ][ 2 ] + "", 2 );
					
					if( timevalue != "00:00:00" ) howLong.visible = true;
					
					
					howLong.setCellInfo( timevalue );
					
					
					break;
				
				case CMD.RF_CTRL_TEMPLATE_MANUAL_TIME:
					refreshCells( p.cmd, false, structureID );
					pdistribute( p );
					
					
						break;
				case CMD.RF_CTRL_TEMPLATE_UNSENT_MESS:
					refreshCells( p.cmd, false, structureID );
					
					
					/// если с прибора дефолтный 0, указываем Выключить "4"
					getField( CMD.RF_CTRL_TEMPLATE_UNSENT_MESS, 1 ).setCellInfo( p.data[ 0 ][ 0 ] || 4 );
					
					break;
				
				case CMD.RF_CTRL_TEMPLATE_FAULT:
					
					refreshCells( p.cmd, false, structureID );
					getField( CMD.RF_CTRL_TEMPLATE_FAULT, 1 ).setCellInfo( p.data[ 0 ][ 0 ] );
					getField( CMD.RF_CTRL_TEMPLATE_FAULT, 2 ).setCellInfo( p.data[ 0 ][ 1 ] );
					getField( CMD.RF_CTRL_TEMPLATE_FAULT, 3 ).setCellInfo( p.data[ 0 ][ 2 ] );
					getField( CMD.RF_CTRL_TEMPLATE_FAULT, 4 ).setCellInfo( p.data[ 0 ][ 3 ] );
					
					
					const mm:String = UTIL.formateZerosInFront( p.data [ 0 ][ 2 ], 2 );
					const ss:String = UTIL.formateZerosInFront( p.data [ 0 ][ 3 ], 2 );
					
					periodMMSSBox.setCellInfo( "" + mm + ":" + ss + "" );
					
					
					
					periodMMSSBox.disabled = isTimeFieldEnable( p.data[ 0 ][ 0 ], p.data[ 0 ][ 1 ] ); 	
					break;
				
				default:
					
					break;
			}
			
			
			switchPattern( null );
		}
		
		public function close():void
		{
			
			if( reqConditTask )
			{
				reqConditTask.kill();
				reqConditTask = null;
			}
		}
		
		
		
			
		private function manualSwitcher( id:int ):void
		{
			/** Команда CTRL_TEMPLATE_MANUAL - команда управления выходами из шаблона ""Ручное управление""
			 
			 Параметр 1 - Действие
			 .......1-Включить
			 .......2-Включить с частотой 1Гц
			 .......3-Короткие импульсы раз в 6 сек
			 .......4-Выключить
			 .......5-Включить с отсрочкой*/
			
			
			
			SavePerformer.saveForce( sendSwitch );
			
			function sendSwitch():void
			{
				if( id == T4_SWITCH_DELAY )
				{
					selectManualTime();
					
					const data:Array =
					[
						getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 1 ).getCellInfo(),
						getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 2 ).getCellInfo(),
						getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 3 ).getCellInfo(),
						getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 4 ).getCellInfo(),
					];
					
					howLong.visible = true;
					RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, null,structureID, data));
				}
				else 
				{
					howLong.visible = false;
				}
				RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_CTRL_TEMPLATE_MANUAL, null,structureID,[ id ]));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_CTRL_OUT_STATE, putData,structureID ));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_CTRL_TEMPLATE_MANUAL_CNT, putData,structureID ));
				
				
			}
			
		}
		
		private function switchPattern( iform:IFormString ):void
		{
			
			const nameIndex:int =  int( getField( 0, paramNmRfCtrl ).getCellInfo() );
			groups.removeFromTheSceneGroups();
			
			
			
			groups.addToTheScene( groups.names[ nameIndex ], this  );
			bsep.visible = nameIndex == 0;
			
			this.height = this.getChildAt( this.numChildren - 1 ).y + this.getChildAt( this.numChildren - 1 ).height; 
			
			
				
			GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.ON_RESIZE,{ subject:this } ) );
			
			if( iform )GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.CHANGE_RFMODULE_TEMPLATE, { param:paramNmRfCtrl, data:nameIndex } ) );
			
			
			
		}
		
		
		
		private function getPatternsSet( mask:int, value:String ="" ):Array
		{
			if( value )
			{
				mask = 0;
				for (var j:int= 0 ; j < value.length; j++)
					if( value.charAt( j ) == "1" )mask |= 1 << ( value.length -  j - 1 );
			}
			
			
			
			var outPatterns:Array = new Array;
			
			var len:int = inpatterns.length;
			for (var i:int=0; i<len; i++)
			{
				
				if( !( ( mask >> i ) & 1 )  ) continue;
				outPatterns.push( inpatterns[ i ] );
				
			}
			
			
			const list:Array =  UTIL.getComboBoxList( outPatterns );

			
			return list;
		}
		
		private function onPart(t:IFormString):void
		{	// Темплейт 2, сохранение партишенов
			if (t) {
				var a:Array = t.getCellInfo() as Array;
				for (var i:int=0; i<16; i++) {
					getField(CMD.RF_CTRL_TEMPLATE_AL_LST_PART,i+1).setCellInfo( a[i] != null ? a[i] : 0 );
				}
				remember(getField(CMD.RF_CTRL_TEMPLATE_AL_LST_PART,1));
			}
		}
		
		private function onAlarm(t:IFormString=null):void
		{	// Темплейт 2, отображение времени если включено "на время"
			var f1:int = int(getField(CMD.RF_CTRL_TEMPLATE_AL_PART,1).getCellInfo());
			var f2:int = int(getField(CMD.RF_CTRL_TEMPLATE_AL_PART,2).getCellInfo());
			
			getField(CMD.RF_CTRL_TEMPLATE_AL_PART,3).disabled = !(f1 == 2 || f1 == 3 || f1 == 4 || f2 == 2 || f2  == 3 || f2 == 4);
			if (t)
				remember(t);
		}
		
		private function createMaskParts( device:int ):int
		{
			var mask:int = 1;
			
			// bit 1 [ 0, loc( "out_no_action" ) ], /// реакция не настроена
			// bit 2 [ 1, loc( "ui_led_partition_state" ) ], ///Индикация состояния раздела
			// bit 4 [ 2, loc( "out_trigger_on_part_alarm" ) ], /// Срабатывание по тревоге в разделе
			// bit 8 [ 3, loc( "ui_led_unsend_events" ) ], /// Индикация непереданных событий
			// bit 16 [ 4, loc( "out_failure_ind" ) ], /// Индикация неисправности
			// bit 32 [ 5, loc( "output_manual" ) ]/// Ручное управление выводом
			
			switch( device ) {
				case RF_FUNCT.TYPE_RFSIREN:
				case RF_FUNCT.TYPE_RFBOARD:
				
					if( _partId == 1 )
						mask |= 38;
					else 
						mask |= 36;
					break;
				
				case RF_FUNCT.TYPE_RFRELAY:
				
					///TODO: изменено в соотв. с задачей https://megaplan.ritm.ru/task/1059169/card/
					mask |= 62;
					/*if( _partId == 1 )
						mask |= 38;
					else if( _partId == 2 )
						mask |= 36;
					else
						mask |= 36;
					*/
					break;
				
				default:
					break;
			}
			
			
			return mask;
		}
		
		private function createEnding():String
		{
			var str:String = "";
			if( fatherType != RF_FUNCT.TYPE_RFRELAY )
			{
				if( _partId == 1 )
					str = " (" + loc("wd_light").toLowerCase() + ") ";
				else if( _partId == 2 )
					str = " (" + loc("msgterm_sound").toLowerCase() + ") ";
			}
			
			
			return str;
		}
		
		private function getConditionModules():void
		{
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_OUT_STATE, putData, getStructure()  ));	
			if( howLong.visible )RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_MANUAL_CNT, putData, getStructure()  ));	
			
			if( reqConditTask )reqConditTask.repeat();
			
			
		}
		
		
		
		private function selectManualTime( ):void
		{
			
			const dts:Array = delayCBox.getCellInfo() as Array;
			getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 1 ).setCellInfo( 0 );
			getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 2 ).setCellInfo( 0 );
			getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 3 ).setCellInfo( dts[ 0 ] );
			getField( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, 4 ).setCellInfo( dts[ 1 ] );
			
			
			
		}
		
		private function dlgChkValue( ifrm:IFormString):void
		{
			
			SavePerformer.remember( structureID, ifrm );
		}		
		
		private function delegateTime( ifrm:IFormString  ):void
		{
			/*const value:int = int( ifrm.getCellInfo()
			(value:Object):Object
			{
				const data:int = int( value );
				const min:int = data / 60;
				const sec:int = data % 60;
				
				const time:String = ( min < 10? "0" + min:min ) + ":" +( sec < 10? "0" + sec:sec );
				
				
				
				return time;
			}*/
			
			
			var comb:Array = ( ifrm.getCellInfo() as String ).split( ":" );
			
			
			
			getField( CMD.RF_CTRL_TEMPLATE_FAULT, 3 ).setCellInfo( comb[ 0 ] );
			getField( CMD.RF_CTRL_TEMPLATE_FAULT, 4 ).setCellInfo( comb[ 1 ] );
			
			SavePerformer.remember( structureID, getField( CMD.RF_CTRL_TEMPLATE_FAULT, 3 ) );
			SavePerformer.remember( structureID, getField( CMD.RF_CTRL_TEMPLATE_FAULT, 4 ) );
			
			
			
		}
		
		private function delegateEnablerTField( ifs:IFormString ):void
		{
			
			
			remember( ifs );
			periodMMSSBox.disabled = isTimeFieldEnable( int( getField( CMD.RF_CTRL_TEMPLATE_FAULT, 1 ).getCellInfo() )
														, int( getField( CMD.RF_CTRL_TEMPLATE_FAULT, 2 ).getCellInfo() ) );
			
		}	
		
		private function isTimeFieldEnable( dataField1:int,  dataField2:int):Boolean
		{
			
			
			
			if( dataField1 == 2 || 
				dataField1 == 3 || 
				//getField( CMD.RF_CTRL_TEMPLATE_FAULT, 1 ).getCellInfo() == 4 || 
				dataField2 == 2 || 
				//getField( CMD.RF_CTRL_TEMPLATE_FAULT, 2 ).getCellInfo() == 4 || 
				dataField2 == 3 ) 
					return false;
			
			return true;
				
		}
		
		/*private function delegateSelectTimes():void
		{
			
			
			getField( CMD.RF_CTRL_TEMPLATE_FAULT, 3 ).setCellInfo( delayCBox.getCellInfo()[ 0 ] ); 
			getField( CMD.RF_CTRL_TEMPLATE_FAULT, 4 ).setCellInfo( delayCBox.getCellInfo()[ 1 ] ); 
			
			remember( getField( CMD.RF_CTRL_TEMPLATE_FAULT, 3 ) );
			remember( getField( CMD.RF_CTRL_TEMPLATE_FAULT, 4 ) );
		}	*/
		
	}
}

import components.abstract.functions.loc;
import components.abstract.sysservants.PartitionServant;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.static.COLOR;

class AdaptKeySensor implements IDataAdapter
{
	private const LABELS:Array =
		[
			"<font color='#"+ COLOR.RED_BLOOD.toString( 16 ) + "' >" + loc( "g_disabled" )  + "</font>",
			"<font color='#"+ COLOR.GREEN_SIGNAL.toString( 16 ) + "' >" + loc( "g_enabled" )  + "</font>"
		];
	
	public function change(value:Object):Object{ return value; } 	// меняет вбитое значение до валидации
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		
		return LABELS[ int( value ) == 4 || !value ?0:1 ]; 
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object{ return value;  }
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void{}
}


class AdaptComboBoxParts implements IDataAdapter
{
	public function change(value:Object):Object// меняет вбитое значение до валидации
	{
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		
		return value == 0xFF || value == 0x00 ?PartitionServant.getExistParts()[ 0 ][ "data" ] || 1:value;
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object
	{
		
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void
	{
		
	}
}


class AdaptFSPart implements IDataAdapter
{
	public function AdaptFSPart()
	{
	}
	
	public function change(value:Object):Object
	{
		return value;
	}
	
	public function adapt(value:Object):Object
	{
		return value;
	}
	
	public function recover(value:Object):Object
	{
		return value;
	}
	
	public function perform(field:IFormString):void
	{
	}
}


class AdaptTimeNew implements IDataAdapter
{
	public function change(value:Object):Object
	{
		
		// меняет вбитое значение до валидации
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		const data:int = int( value );
		const min:int = data / 60;
		const sec:int = data % 60;
		
		const time:String = ( min < 10? "0" + min:min ) + ":" +( sec < 10? "0" + sec:sec );
		
		
		
		return time;
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object
	{
		var comb:Array = ( value as String ).split( ":" );
		
		
		const res:int = int( comb[ 0 ] ) * 60 + int( comb[ 1 ] );
		return res;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void
	{
		
	}
}
