package components.screens.opt
{
	import components.abstract.GroupOperator;
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCCBMaximumSelections;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptOutPattern extends OptionsBlock
	{
		private var go:GroupOperator;
		private var notes:SimpleTextField;
		private var fspart:FSCCBMaximumSelections;
		
		private const T4_SWITCH_ON:int = 1;
		private const T4_SWITCH_ON_FREQ:int = 2;
		private const T4_SWITCH_OFF:int = 4;
		private const T4_SWITCH_DELAY:int = 5;
		
		private var templatenum:int;
		
		public function OptOutPattern(n:int)
		{
			super();
			
			structureID = n;
			
			var sh:int = 250;
			var w:int = 250;
			var sw:int = 540;
			
			var anchor:int = globalY;
			go = new GroupOperator;
			
			var l:Array = UTIL.getComboBoxList([ [0,loc("out_part_not_selected")]]).concat(UTIL.comboBoxNumericDataGenerator(1,99));
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_ST_PART, loc("ui_led_partition_state"), null, 1, l, "0-9", 2 );
			attuneElement( sh + 100, 150 );
			
			globalY += 10;
			
			var msg:String = loc("ui_pattern_rele_note1"); 
				
			notes = new SimpleTextField(msg, 600 );
			notes.setSimpleFormat("left", 4 );
			addChild( notes );
			notes.x = globalX;
			notes.y = globalY;
			notes.height = notes.textHeight + 10;
			
			go.add("1",getLastElement());
			go.add("1",notes);
			
			/***	2	******************************************/
			
			globalY = anchor;
			
			fspart = addui( new FSCCBMaximumSelections, 0, loc("out_trigger_on_part_alarm"), onPart, 1 ) as FSCCBMaximumSelections;
			attuneElement(sh,w);
			go.add("2",getLastElement());
			fspart.MAX_SELECTED_ITEMS = 16;
			fspart.REACH_MAX_TEXT = loc("out_part_max");
			
			for (var i:int=0; i<16; i++) {
				addui( new FSShadow, CMD.CTRL_TEMPLATE_AL_LST_PART, "", null, i+1 );				
			}
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, loc("alarm_type_line"), null, 1 );
			attuneElement( sh, w, FormString.F_TEXT_BOLD );
			go.add("2",getLastElement());
			
			FLAG_VERTICAL_PLACEMENT = true;
			
			addui( new FormString, 0, loc("alarm_run_command"), null, 1 ).x = 300;
			attuneElement( NaN, NaN, FormString.F_TEXT_BOLD );
			go.add("2",getLastElement());
			
			/** "Команда CTRL_TEMPLATE_AL_PART - данные шаблонов ""Срабатывание по тревоге в разделе""

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
			
			l = UTIL.getComboBoxList([[0,loc("g_no_action")],[1,loc("out_switch_until_alarm_reset")],
				[2,loc("g_switchon_time")],[3,loc("g_switchon_1hz")],[4,loc("out_impulse_6sec")]]);
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_AL_PART, loc("out_state_while_alarm"), onAlarm, 1, l);
			attuneElement(sh,w,FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add("2",getLastElement());
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_AL_PART, loc("out_state_while_fire"), onAlarm, 2, l);
			attuneElement(sh,w,FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add("2",getLastElement());
			
			l = [ {label:"01:00", data:"01:00"},{label:"15:00", data:"15:00"},
				{label:"30:00", data:"30:00"},{label:"45:00", data:"45:00"} ];
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_AL_PART, loc("out_switchon_time"), null, 3, l, "0-9:",5,new RegExp( RegExpCollection.REF_TIME_0000to9959) );
			attuneElement(sh+(w-70),70, FSComboBox.F_COMBOBOX_TIME );
			go.add("2",getLastElement());
			
			globalY += 5;
			
			go.add("2",drawIndent());
			
			var tf:SimpleTextField = new SimpleTextField(loc("out_fire_priority"), 500 );
			addChild( tf );
			tf.x = globalX + 10;
			tf.y = globalY;
			go.add("2",tf);
			
			globalX = 0;
			globalY += 40;
			
			addui( new FSCheckBox, CMD.CTRL_TEMPLATE_AL_PART, loc("ui_out_ind_enter_delay"), null, 5 );
			attuneElement( sh );
			go.add("2",getLastElement());
			addui( new FSCheckBox, CMD.CTRL_TEMPLATE_AL_PART, loc("ui_out_ind_exit_delay"), null, 6 );
			attuneElement( sh );
			go.add("2",getLastElement());
			
			/***	3	******************************************/
			
			globalY = anchor;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, loc("g_state"), null, 1 );
			attuneElement( sh, w, FormString.F_TEXT_BOLD );
			go.add("3",getLastElement());
			
			FLAG_VERTICAL_PLACEMENT = true;
			
			addui( new FormString, 0, loc("alarm_run_command"), null, 1 ).x = 300;
			attuneElement( NaN, NaN, FormString.F_TEXT_BOLD );
			go.add("3",getLastElement());
			
			
			/** Команда CTRL_TEMPLATE_UNSENT_MESS - шаблон ""Индикация непереданных событий""
			
			Параметр 1 - Есть события, требующие передачи,
			.......1-Включить
			.......2-Включить с частотой 1Гц
			.......3-Короткие импульсы раз в 6 сек
			.......4-Выключить	*/
			
			l = UTIL.getComboBoxList([[1,loc("g_switchon")],
				[2,loc("out_switchon_1hz")],[3,loc("out_short_impulse_6sec")]]);
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_UNSENT_MESS, loc("output_events_exist"), null, 1, l );
			attuneElement(sh,w,FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add("3",getLastElement());
			
			/***	4	******************************************/
			
			globalY = anchor;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, loc("out_fault_type"), null, 1 );
			attuneElement( sh, w, FormString.F_TEXT_BOLD );
			go.add("4",getLastElement());
			
			FLAG_VERTICAL_PLACEMENT = true;
			
			addui( new FormString, 0, loc("alarm_run_command"), null, 1 ).x = 300;
			attuneElement( NaN, NaN, FormString.F_TEXT_BOLD );
			go.add("4",getLastElement());
			
			l = UTIL.getComboBoxList([[0,loc("g_no_action")],[1,loc("out_switch_until_alarm_reset")],
				[2,loc("g_switchon_time")],[3,loc("g_switchon_1hz")],[4,loc("out_impulse_6sec")]]);
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_FAULT, loc("out_device_fault"), onFault, 1, l);
			attuneElement(sh,w,FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add("4",getLastElement());
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_FAULT, loc("out_wire_fault"), onFault, 2, l);
			attuneElement(sh,w,FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_MULTYLINE );
			go.add("4",getLastElement());
			
			globalY += 5;
			
			l = [ {label:"01:00", data:"01:00"},{label:"15:00", data:"15:00"},
				{label:"30:00", data:"30:00"},{label:"45:00", data:"45:00"} ];
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_FAULT, loc("out_switchon_time"), null, 3, l, "0-9:",5,new RegExp( RegExpCollection.REF_TIME_0000to9959) );
			attuneElement(sh+(w-70),70, FSComboBox.F_COMBOBOX_TIME );
			go.add("4",getLastElement());
			
			globalY += 10;
			
		/*	var ind:Indent = new Indent(PAGE.INDENT_HEIGHT);
			addChild( ind );
			ind.x = globalX+PAGE.INDENT_SHIFT;
			ind.y = globalY;
			go.add("4",ind);*/
			go.add("4",drawIndent());
			
			var t:SimpleTextField = new SimpleTextField(loc("out_priority_device_failure"),600 );
			addChild( t );
			t.x = globalX+10;
			t.y = globalY;
			go.add("4",t );
			globalX = 0;
			
			/***	5	******************************************/

			globalY = anchor;
			
			var b:TextButton = new TextButton;
			addChild( b );
			b.x = 80;
			b.y = globalY;
			b.setUp(loc("g_switchon"), onClick, T4_SWITCH_ON );
			go.add("5",b);
			
			b = new TextButton;
			b.x = 160;
			b.y = globalY;
			addChild( b );
			b.setUp(loc("out_switchon_1hz"), onClick, T4_SWITCH_ON_FREQ );
			go.add("5",b);
			
			b = new TextButton;
			if (LOC.language == LOC.IT)
				b.x = 410; // 340
			else
				b.x = 340;
			b.y = globalY;
			addChild( b );
			b.setUp(loc("g_switchoff"), onClick, T4_SWITCH_OFF);
			go.add("5",b);
			
			addui(new FormString, 0, loc("ui_part_action"), null, 1 );
			attuneElement( 65, NaN, FormString.F_NOTSELECTABLE );
			go.add("5",getLastElement());
			
			globalXSep = -20;
			go.add("5",drawSeparator(sw+60));
			
			tf = new SimpleTextField(loc("out_do_in_certain_time"), 500 );
			addChild( tf );
			tf.setSimpleFormat("left",0,12,true);
			tf.x = globalX;
			tf.y = globalY;
			go.add("5",tf);
			
			globalY += 30;
			
			/** Команда CTRL_TEMPLATE_MANUAL_TIME - Настройка времени для отложенного действия

				Параметр 1 - часы 00-99 - Выполнить через
				Параметр 2 - минуты 00-59 - Выполнить через
				Параметр 3 - часы 00-99 - Завершить через
				Параметр 4 - минуты 00-59 - Завершить через
				
				Параметр 3 и Параметр 4 = 0xFF - ""Не выключать*/
			
			l = [ {label:"01:00", data:"01:00"},
				{label:"04:00", data:"04:00"} ];
			
			var localanchor:int = globalY;
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_MANUAL_TIME, loc("out_run_after"), null, 1, l, "0-9:",5,new RegExp( "^("+RegExpCollection.RE_TIME_0000to9959+"|255:255)$") );
			attuneElement(190,70, FSComboBox.F_COMBOBOX_TIME );
			go.add("5",getLastElement());
			
			l = [ {label:loc("out_do_not_disable"), data:"255:255"},{label:"01:00", data:"01:00"},
				{label:"04:00", data:"04:00"} ];
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_MANUAL_TIME, loc("out_finish_after"), null, 3, l, "0-9:",5,new RegExp( "^("+RegExpCollection.RE_TIME_0000to9959+"|255:255)$") );
			attuneElement(190,70, FSComboBox.F_COMBOBOX_TIME );
			go.add("5",getLastElement());
			
			globalY = localanchor;
			globalX = 280;
			
			addui( new FSSimple, CMD.CTRL_TEMPLATE_MANUAL_CNT, loc("out_left_until_execute"), null, 1 );
			attuneElement(250,70, FSSimple.F_CELL_NOTSELECTABLE );
			go.add("5",getLastElement());
			getLastElement().setAdapter( new TimeAdapter );
			addui( new FSSimple, CMD.CTRL_TEMPLATE_MANUAL_CNT, loc("out_left_until_finish"), null, 3 );
			attuneElement(250,70, FSSimple.F_CELL_NOTSELECTABLE );
			go.add("5",getLastElement());
			getLastElement().setAdapter( new TimeAdapter );
			
			globalX = 0;
			
			b = new TextButton;
			b.x = globalX;
			b.y = globalY;
			addChild( b );
			b.setUp(loc("out_switchon_with_delay"), onClick, T4_SWITCH_DELAY);
			go.add("5",b);
			
			go.show("");
		}
		public function open(n:int):void
		{
			go.show(n.toString());

			templatenum = n;
				
			switch(n) {
				case 1:
					getField(CMD.CTRL_TEMPLATE_ST_PART,1).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_ST_PART)[structureID-1][0] );
					break;
				case 2:
					fspart.setList(	partitionGenerator(OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_AL_LST_PART)[structureID-1] ));
					
					getField(CMD.CTRL_TEMPLATE_AL_PART,1).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_AL_PART)[structureID-1][0] );
					getField(CMD.CTRL_TEMPLATE_AL_PART,2).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_AL_PART)[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_AL_PART,3).setCellInfo( 
						mergeIntoTime( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_AL_PART)[structureID-1][2], OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_AL_PART)[structureID-1][3] ));
					getField(CMD.CTRL_TEMPLATE_AL_PART,5).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_AL_PART)[structureID-1][4] );
					getField(CMD.CTRL_TEMPLATE_AL_PART,6).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_AL_PART)[structureID-1][5] );
					onAlarm();
					break;
				case 3:
					getField(CMD.CTRL_TEMPLATE_UNSENT_MESS,1).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_UNSENT_MESS)[structureID-1][0] );
					break;
				case 4:
					getField(CMD.CTRL_TEMPLATE_FAULT,1).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_FAULT)[structureID-1][0] );
					getField(CMD.CTRL_TEMPLATE_FAULT,2).setCellInfo( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_FAULT)[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_FAULT,3).setCellInfo( 
						mergeIntoTime( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_FAULT)[structureID-1][2], OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_FAULT)[structureID-1][3] ));
					onFault();
					break;
				case 5:
					getField(CMD.CTRL_TEMPLATE_MANUAL_TIME,1).setCellInfo( 
						mergeIntoTime( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_TIME)[structureID-1][0], OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_TIME)[structureID-1][1] ));
					getField(CMD.CTRL_TEMPLATE_MANUAL_TIME,3).setCellInfo( 
						mergeIntoTime( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_TIME)[structureID-1][2], OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_TIME)[structureID-1][3] ));
					
					getField(CMD.CTRL_TEMPLATE_MANUAL_CNT,1).setCellInfo( 
						mergeIntoTime( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_CNT)[structureID-1][0], OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_CNT)[structureID-1][1] ));
					getField(CMD.CTRL_TEMPLATE_MANUAL_CNT,3).setCellInfo( 
						mergeIntoTime( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_CNT)[structureID-1][2], OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_MANUAL_CNT)[structureID-1][3] ));
					break;
			}
		}
		public function timer():void
		{
			if (templatenum == 5)
				RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_TEMPLATE_MANUAL_CNT,put));
		}
		private function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.CTRL_TEMPLATE_MANUAL_CNT:
					getField(CMD.CTRL_TEMPLATE_MANUAL_CNT,1).setCellInfo( 
						mergeIntoTime( p.getStructure(structureID)[0], p.getStructure(structureID)[1] ));
					getField(CMD.CTRL_TEMPLATE_MANUAL_CNT,3).setCellInfo( 
						mergeIntoTime( p.getStructure(structureID)[2], p.getStructure(structureID)[3] ));
					break;
			}
		}
		private function partitionGenerator( a:Array ):Array
		{
			var list:Array = new Array;
			var selected:int;
			
			
			var len:int = 99;
			for (var i:int=0; i<len; i++) {
				
				selected = containsNum(i+1, a);
				
				list.push( {"labeldata":(i+1), 
					"label":(i+1),
					"data":selected, 
					"block":0 } ); // param = partition (45,65,99 etc)
			}
			return list;
		}
		private function containsNum(n:int, a:Array):int
		{
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if (n == a[i])
					return 1;
			}
			return 0;
		}
		private function onPart(t:IFormString):void
		{	// Темплейт 2, сохранение партишенов
			if (t) {
				var a:Array = t.getCellInfo() as Array;
				for (var i:int=0; i<16; i++) {
					getField(CMD.CTRL_TEMPLATE_AL_LST_PART,i+1).setCellInfo( a[i] != null ? a[i] : 0 );
				}
				remember(getField(CMD.CTRL_TEMPLATE_AL_LST_PART,1));
			}
		}
			
		private function onClick(n:int):void
		{	// функционал кнопок
			
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
				RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_TEMPLATE_MANUAL,null,structureID,[n]));
			}
		}
		private function onAlarm(t:IFormString=null):void
		{	// Темплейт 2, отображение времени если включено "на время"
			var f1:int = int(getField(CMD.CTRL_TEMPLATE_AL_PART,1).getCellInfo());
			var f2:int = int(getField(CMD.CTRL_TEMPLATE_AL_PART,2).getCellInfo());
			
			getField(CMD.CTRL_TEMPLATE_AL_PART,3).disabled = !(f1 == 2 || f1 == 3 || f1 == 4 || f2 == 2 || f2  == 3 || f2 == 4);
			if (t)
				remember(t);
		}
		private function onFault(t:IFormString=null):void
		{	// Темплейт 4, отображение времени если включено "на время"
			var f1:int = int(getField(CMD.CTRL_TEMPLATE_FAULT,1).getCellInfo());
			var f2:int = int(getField(CMD.CTRL_TEMPLATE_FAULT,2).getCellInfo());
			
			getField(CMD.CTRL_TEMPLATE_FAULT,3).disabled = !(f1 == 2 || f1 == 3 || f1 == 4 || f2 == 2 || f2  == 3 || f2 == 4);
			if (t)
				remember(t);
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class TimeAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if  (value == "255:255")
			return loc("g_off");
		return value;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
		
	}
	public function recover(value:Object):Object
	{
		return value;
	}
}