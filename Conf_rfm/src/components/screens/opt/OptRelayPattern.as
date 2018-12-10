package components.screens.opt
{
	import components.abstract.CTRL_TEMPLATE_OUT;
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.OptionsBlock;
	import components.gui.Header;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public final class OptRelayPattern extends OptionsBlock
	{
		private static const WARN_TEXT:String = 'warnText';
		private var go:GroupOperator;
		private var lastsWarns:Array = [];
		
		
		private const T4_SWITCH_ON:int = 1;
		private const T4_SWITCH_ON_FREQ:int = 2;
		private const T4_SWITCH_OFF:int = 4;
		

		

		
		private var reqConditTask:ITask;

		private var _butOn:TextButton;

		private var _butOff:TextButton;

		

		private var _openPart:int;
		
		public function OptRelayPattern(str:int)
		{
			super();
			
			go = new GroupOperator;
			
			structureID = str;
			
			var sh:int = 250;
			var w:int = 250;
			
			/***	5	******************************************/
			
			
			
			const gr5:String = "5";
			
			
			
			go.add( gr5, addui( new FormString, 0, loc( "ui_part_action" ), null, 1 ) );
			
			
			
			_butOn = new TextButton;
			_butOn.setUp( loc( "g_switchon" ), manualSwitcher, T4_SWITCH_ON );
			go.add( gr5, _butOn );
			_butOn.x = getLastElement().x + getLastElement().width + 100;
			_butOn.y = getLastElement().y;
			this.addChild( _butOn );
			
			_butOff = new TextButton;
			_butOff.setUp( loc( "g_switchoff" ), manualSwitcher, T4_SWITCH_OFF );
			go.add( gr5, _butOff );
			_butOff.x = _butOn.x + _butOn.width + 100;
			_butOff.y = _butOn.y;
			this.addChild( _butOff );
			
			globalY += _butOff.height;
			
			
			
			
			
			globalY -= 20;
			
			
			
			/**	Команда CTRL_TEMPLATE_REACT_ST_PART - шаблон ""Реакция на состояние раздела""   

				Параметр 1 - Разделы, по которым реагирует шаблон, битовое поле, биты 0..31 - разделы с номерами 1..32 соответственно, 0-раздел не используется в шаблоне, 1-раздел используется в шаблоне.
				
				Параметр 2 - Выполняемая команда, раздел в тревоге
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 3 - Выполняемая команда, раздел под охраной
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 4 - Выполняемая команда, раздел снят с охраны
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 5 - Время срабатывания, минуты 00-99
				Параметр 6 - Время срабатывания, секунды 00-59												*/
			
			var wtime:int = 70;
			
			addui( new FSComboCheckBox, CMD.CTRL_TEMPLATE_REACT_ST_PART, loc("sms_menu_part"), null, 1 );
			attuneElement(sh,w);
			(getLastElement() as FSComboCheckBox).turnToBitfield = turnToBitfield;
			go.add(CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE.toString(), getLastElement() );
			
			var h:Header = new Header([
					{label:loc("ui_part_state"),xpos:0, width:sh},
					{label:loc("alarm_run_command"), xpos:sh, width:200}
				], {size:12, border:false, align:"left"});
			addChild( h );
			
			go.add(CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE.toString(), h );
			h.y = globalY - 100;
			//globalY += 30;
			
			var alarmSet:Array = UTIL.getComboBoxList([[0, loc("g_no_action")],[1,loc("out_switch_until_alarm_reset")],
				[2,loc("g_switchon_time")],[3, loc("g_switchon_1hz")],[4,loc("out_impulse_6sec")],[5, loc("out_7hz_pulse")],[6, loc("g_switchoff")]]);
			var allSet:Array = UTIL.getComboBoxList([[0, loc("g_no_action")],
				[2,loc("g_switchon_time")],[3, loc("g_switchon_1hz")],[4,loc("out_impulse_6sec")],[5, loc("out_7hz_pulse")],[6, loc("g_switchoff")]]);
			var ltime:Array = UTIL.getComboBoxList([["01:00","01:00"],["05:00","05:00"],["10:00","10:00"],["30:00","30:00"]]);
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_PART, loc("out_part_alarm"), onClick, 2, alarmSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_PART, loc("out_part_armed"), onClick, 3, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_PART, loc("out_part_unarmed"), onClick, 4, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE.toString(), getLastElement() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_PART, loc("g_switchon_time") + " (MM:SS)", null, 5, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0000to9959) );
			go.add(CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE.toString(), getLastElement() );
			attuneElement(sh + (w-wtime),wtime, FSComboBox.F_COMBOBOX_TIME );

			var wrn:OptWarnText = new OptWarnText;
			wrn.y = globalY;
			wrn.x = globalX;
			this.addChild( wrn );
			go.add(CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE.toString(), wrn );
			go.add(WARN_TEXT, wrn );
			
			/**	Команда CTRL_TEMPLATE_REACT_ST_ZONE - шаблон ""Реакция на состояние зон""

				Параметр 1 - Зоны, по которым реагирует шаблон, битовое поле, биты 0..31 - зоны с номерами 1..32 соответственно, 0-зона не используется в шаблоне, 1-зона используется в шаблоне.
				Параметр 2 - Зоны, по которым реагирует шаблон, битовое поле, биты 0..31 - зоны с номерами 33..64 соответственно, 0-зона не используется в шаблоне, 1-зона используется в шаблоне.
				
				Параметр 3 - Выполняемая команда, зона в тревоге
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 4 - Выполняемая команда, зона в норме
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 5 - Выполняемая команда, зона в неисправности
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 6 - Время срабатывания, минуты 00-99
				Параметр 7 - Время срабатывания, секунды 00-59	*/
			
			globalY = 0;
			
			addui( new FSComboCheckBox, 0, loc("sms_menu_zone"), onZoneCheck, 3 );
			attuneElement(sh,w);
			//(getLastElement() as FSComboCheckBox).turnToBitfield = turnToBitfield;
			go.add(CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE.toString(), getLastElement() );
			
			addui( new FSShadow, CMD.CTRL_TEMPLATE_REACT_ST_ZONE, "", null, 1 );
			addui( new FSShadow, CMD.CTRL_TEMPLATE_REACT_ST_ZONE, "", null, 2 );
			
			go.add(CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE.toString(), h );
			globalY += 30;
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_ZONE, loc("out_zone_alarm"), onZone, 3, alarmSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE.toString(), getLastElement() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_ZONE, loc("out_fault"), onZone, 5, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE.toString(), getLastElement() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_ZONE, loc("out_zone_normal"), onZone, 4, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE.toString(), getLastElement() );
			
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_ZONE, loc("g_switchon_time") + " (MM:SS)", null, 6, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0000to9959) );
			go.add(CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE.toString(), getLastElement() );
			attuneElement(sh + (w-wtime),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			wrn = new OptWarnText;
			wrn.y = globalY;
			wrn.x = globalX;
			this.addChild( wrn );
			go.add(CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE.toString(), wrn );
			go.add(WARN_TEXT, wrn );
			
			/** Команда CTRL_TEMPLATE_ALL_FIRE - шаблон "Оповещение о пожаре"
				Параметр 1 - Выполняемая команда, сигнал пожар
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 2 - Выполняемая команда, норма
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 3 - Время срабатывания, минуты 00-99
				Параметр 4 - Время срабатывания, секунды 00-59		*/
			
			globalY = 0;
			
			h = new Header([
			{label:loc("ui_part_state"),xpos:0, width:sh},
			{label:loc("alarm_run_command"), xpos:sh, width:200}
			], {size:12, border:false, align:"left"});
			addChild( h );
			go.add(CTRL_TEMPLATE_OUT.R11_NOTIF_FIRE.toString(), h );
			h.y = globalY;
			globalY += 30;
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_ALL_FIRE, loc("out_fire_signal"), onFire, 1, alarmSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R11_NOTIF_FIRE.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_ALL_FIRE, loc("sensor_norm"), onFire, 2, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R11_NOTIF_FIRE.toString(), getLastElement() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_ALL_FIRE, loc("g_switchon_time") + " (MM:SS)", null, 3, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0000to9959) );
			go.add(CTRL_TEMPLATE_OUT.R11_NOTIF_FIRE.toString(), getLastElement() );
			attuneElement(sh + (w-wtime),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			wrn = new OptWarnText;
			wrn.y = globalY;
			wrn.x = globalX;
			this.addChild( wrn );
			go.add(CTRL_TEMPLATE_OUT.R11_NOTIF_FIRE.toString(), wrn );
			go.add(WARN_TEXT, wrn );
			
			/**	Команда CTRL_TEMPLATE_REACT_ST_EXT - шаблон ""Реакция дополнительная""

				Параметр 1 - Выполняемая команда, внешнее питание отсутствует (аналогично параметру 1)
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 2 - Выполняемая команда, внешнее питание в норме (аналогично параметру 2)
				........0-Нет действия
				........1-Включить до сброса тревоги
				........2-Включить на время
				........3-Включить на время с частотой 1Гц
				........4-Импульсы раз в 6 сек на время
				........5-Импульсы 7Гц
				........6-Выключить
				Параметр 3 - Время срабатывания, минуты 00-99
				Параметр 4 - Время срабатывания, секунды 00-59
				
				Параметр 5 - Выполняемая команда, задержка на вход/выход (аналогично параметру 1)
				Параметр 6 - Выполняемая команда, задержка завершена (аналогично параметру 2)
				Параметр 7 - Время срабатывания, минуты 00-99
				Параметр 8 - Время срабатывания, секунды 00-59
				
				Параметр 9 - Выполняемая команда, журнал событий не пустой (аналогично параметру 1)
				Параметр 10 - Выполняемая команда, все события переданы (аналогично параметру 2)
				Параметр 11- Время срабатывания, минуты 00-99
				Параметр 12 - Время срабатывания, секунды 00-59"	*/
			
			globalY = 0;
			
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), h );
			globalY += 30;
			
			attuneElement(sh + (w-wtime),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("out_ext_power_off"), onExt, 1, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("out_ext_power_ok"), onExt, 2, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("g_switchon_time") + " (MM:SS)", null, 3, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0000to9959) );
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			attuneElement(sh + (w-wtime),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			wrn = new OptWarnText;
			wrn.y = globalY;
			wrn.x = globalX;
			this.addChild( wrn );
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), wrn );
			globalY += wrn.height;
			
			lastsWarns.push( wrn );
			
			
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), drawSeparator() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("out_exit_enter_delay"), onExt, 5, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("out_delay_complete"), onExt, 6, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("g_switchon_time") + " (MM:SS)", null, 7, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0000to9959) );
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			attuneElement(sh + (w-wtime),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			wrn = new OptWarnText;
			wrn.y = globalY;
			wrn.x = globalX;
			this.addChild( wrn );
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), wrn );
			globalY += wrn.height;
			
			lastsWarns.push( wrn );
			
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), drawSeparator() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("out_log_not_empty"), onExt, 9, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("out_all_events_sent"), onExt, 10, allSet );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_REACT_ST_EXT, loc("g_switchon_time") + " (MM:SS)", null, 11, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0000to9959) );
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), getLastElement() );
			attuneElement(sh + (w-wtime),wtime, FSComboBox.F_COMBOBOX_TIME );
			wrn = new OptWarnText;
			wrn.y = globalY;
			wrn.x = globalX;
			this.addChild( wrn );
			go.add(CTRL_TEMPLATE_OUT.R12_REACT_EXT.toString(), wrn );
			globalY += wrn.height;
			
			
			lastsWarns.push( wrn );
			
		}
		
		
		public function open(n:int):void
		{
			_openPart = n;
			go.show(_openPart.toString());
			
			
			switch(_openPart) {
				case CTRL_TEMPLATE_OUT.R9_REACT_PART_STATE:
					(getField(CMD.CTRL_TEMPLATE_REACT_ST_PART,1) as FSComboCheckBox).setList( 
						getCCBlist( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_PART)[structureID-1][0], loc("rf_sen_h_part") ));
					getField(CMD.CTRL_TEMPLATE_REACT_ST_PART,2).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_PART)[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_PART,3).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_PART)[structureID-1][2] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_PART,4).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_PART)[structureID-1][3] );
					
					getField(CMD.CTRL_TEMPLATE_REACT_ST_PART,5).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_PART)[structureID-1][4],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_PART)[structureID-1][5] ));
					//onClick(null);
					
					break;
				case CTRL_TEMPLATE_OUT.R10_REACT_ZONE_STATE:
					
					(getField(0,3) as FSComboCheckBox).setList( 
						getCCB8bytelist( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][0]
							, OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][1]
							, loc("rf_sen_h_zone") 
						)
					);
					getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,1).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][0] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,2).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,3).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][2] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,4).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][3] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,5).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][4] );
					
					getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,6).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][5],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[structureID-1][6] ));
					
					onZone();
					
					break;
				case CTRL_TEMPLATE_OUT.R11_NOTIF_FIRE:
					getField(CMD.CTRL_TEMPLATE_ALL_FIRE,1).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_ALL_FIRE)[structureID-1][0] );
					getField(CMD.CTRL_TEMPLATE_ALL_FIRE,2).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_ALL_FIRE)[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_ALL_FIRE,3).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_ALL_FIRE)[structureID-1][2],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_ALL_FIRE)[structureID-1][3] ));
					onFire(null);
					break;
				case CTRL_TEMPLATE_OUT.R12_REACT_EXT:
				
				
					
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,1).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][0] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,2).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,3).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][2],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][3] ));
					
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,5).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][4] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,6).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][5] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,7).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][6],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][7] ));
					
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,9).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][8] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,10).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][9] );
					getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,11).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][10],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_REACT_ST_EXT)[structureID-1][11] ));
					onExt(null);
					break;
				
				
			}
			
			
			
		}
		
		
		
		
		override public function putData(p:Package):void
		{
			
			
			
			switch( p.cmd ){
				case CMD.CTRL_TEMPLATE_MANUAL_CNT:
					
					if( p.getParam( 3 ) == 0xFF && p.getParam( 4 ) == 0xFF )
					{
						/// таймер выключен
						
						if( reqConditTask )
						{
							reqConditTask.kill();
							reqConditTask = null;
						}
					}
					
					break;
				
				
				case CMD.CTRL_DOUT_SENSOR:
					
					
					
					switch( p.getParam(  1, structureID )) {
						
						
						case T4_SWITCH_OFF:
							_butOn.disabled =   false;
							_butOff.disabled = true;	
							
							
							if( reqConditTask )
							{
								reqConditTask.kill();
								reqConditTask = null;
							}
							
							break;
						
						
						case T4_SWITCH_ON:
							
							RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_TEMPLATE_MANUAL_CNT, putData, structureID  ));
						default:
							
							_butOn.disabled = true;
							_butOff.disabled = false ;
							break;
					}
					
					break;
			}
			
			
		}

		///FIXME: Debug value! Remove it now!
		///private function onZoneCheck(t:IFormString):void
		private function onZoneCheck(t:* = null ):void
		{
			
			
			
			var a:Array = t.getCellInfo() as Array;
			var len:int = a.length;
			var bf:uint;
			var bf2:uint;
			var current:uint;
			for (var i:int=0; i<len; i++) {
				current = uint(a[i]);
				
				if (current == 0xffffffff) {
					bf = 0xffffffff;
					bf2 = 0xffffffff;
				}
					
				if (current < 33)
					bf |= 1<< (current-1);
				else
					bf2 |= 1<< (current-33);
			}
			getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,1).setCellInfo( bf );
			getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,2).setCellInfo( bf2 );
			saveStateZone();
		}
		private function onZone( t:IFormString = null):void
		{
			

			var field:IFormString;
			var n:int;
			var disabled:Boolean = true;
			for (var i:int=0; i<3; i++) {
				field = getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,i+3);
				n = int(field.getCellInfo());
				if (n == 2 || n == 3 || n == 4 || n == 5) {
					disabled = false;
					break;
				}
			}
			
			getField(CMD.CTRL_TEMPLATE_REACT_ST_ZONE,6).disabled = disabled;
			go.alpha( WARN_TEXT, disabled?.2:1 );
			
			saveStateZone();
		}
		
		private function saveStateZone():void
		{
			var len:int = OPERATOR.dataModel.getData( CMD.CTRL_TEMPLATE_REACT_ST_ZONE).length;
			for (var i:int=0; i<len; i++) {
				
				if( OPERATOR.dataModel.getData( CMD.CTRL_TEMPLATE_REACT_ST_ZONE)[ structureID - 1 ][ i ] != getField( CMD.CTRL_TEMPLATE_REACT_ST_ZONE, i + 1 ).getCellInfo() )
																				remember( getField( CMD.CTRL_TEMPLATE_REACT_ST_ZONE, i + 1 ) );
			}
			
		}
		private function onFire(t:IFormString):void
		{
			var n:int;
			var disabled:Boolean = true;
			for (var i:int=0; i<2; i++) {
				n = int(getField(CMD.CTRL_TEMPLATE_ALL_FIRE,i+1).getCellInfo());
				if (n == 2 || n == 3 || n == 4 || n == 5) {
					disabled = false;
					break;
				}
			}
			
			getField(CMD.CTRL_TEMPLATE_ALL_FIRE,3).disabled = disabled;
			go.alpha( WARN_TEXT, disabled?.2:1 );
			if (t)
				remember(t);
		}
		private function onExt(t:IFormString):void
		{
			
			var n:int;
			var disabled:Boolean = true;
			for (var i:int=0; i<2; i++) {
				n = int(getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,i+1).getCellInfo());
				if (n == 2 || n == 3 || n == 4 || n == 5) {
					disabled = false;
					break;
				}
			}
			getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,3).disabled = disabled;
			var a:Number = disabled?.2:1;
			lastsWarns[ 0 ].alpha = a;
			disabled = true;
			for (i=0; i<2; i++) {
				n = int(getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,4+i+1).getCellInfo());
				if (n == 2 || n == 3 || n == 4 || n == 5) {
					disabled = false;
					break;
				}
			}
			getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,7).disabled = disabled;
			a = disabled?.2:1;
			lastsWarns[ 1 ].alpha = a;
			disabled = true;
			for (i=0; i<2; i++) {
				n = int(getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,8+i+1).getCellInfo());
				if (n == 2 || n == 3 || n == 4 || n == 5) {
					disabled = false;
					break;
				}
			}
			
			getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,11).disabled = disabled;
			a = disabled?.2:1;
			lastsWarns[ 2 ].alpha = a;
			
			var f1:IFormString = getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,1);
			var f12:IFormString = getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,2);
			var f2:IFormString = getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,5);
			var f22:IFormString = getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,6);
			var f3:IFormString = getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,9);
			var f32:IFormString = getField(CMD.CTRL_TEMPLATE_REACT_ST_EXT,10);
			
			var needRerunFunction:Boolean = false;	// если была изменена какая то информация в полях, надо пробежать по фукнции и отключить возможные поля
			f1.disabled = int(f2.getCellInfo())>0 || int(f22.getCellInfo())>0 || int(f3.getCellInfo())>0 || int(f32.getCellInfo())>0;
			f12.disabled = f1.disabled; 
			if( dataProcess(f1,f12) )
				needRerunFunction = true;
			f2.disabled = int(f1.getCellInfo())>0 || int(f3.getCellInfo())>0 || int(f12.getCellInfo())>0 || int(f32.getCellInfo())>0;
			f22.disabled = f2.disabled;
			if( dataProcess(f2,f22) )
				needRerunFunction = true;
			f3.disabled = int(f1.getCellInfo())>0 || int(f2.getCellInfo())>0 || int(f12.getCellInfo())>0 || int(f22.getCellInfo())>0;
			f32.disabled = f3.disabled;
			if( dataProcess(f3,f32) )
				needRerunFunction = true;
			
			if (needRerunFunction)
				onExt(t);
			
			if (t)
				remember(t);
		}
		private function dataProcess(t:IFormString, t2:IFormString):Boolean
		{	// если филд отключен и при этом не 0, надо сделать 0 
			var res:Boolean = false;
			if ((t as FSComboBox).disabled && int(t.getCellInfo())>0) {
				t.setCellInfo(0);
				remember(t);
				res = true;
			}
			if ((t2 as FSComboBox).disabled && int(t2.getCellInfo())>0) {
				t2.setCellInfo(0);
				remember(t2);
				res = true;
			}
			return res;
		}
		
		private function onClick(t:IFormString = null):void
		{
			var n:int;
			
			
			var disabled:Boolean = true;
			for (var i:int=0; i<3; i++) {
				t = getField(CMD.CTRL_TEMPLATE_REACT_ST_PART,i+2) as IFormString;
				n = int( t.getCellInfo());
				/*if (t)
					remember(t);*/
				
				
				if (n == 2 || n == 3 || n == 4 || n == 5) {
					disabled = false;
					
				}
			}
			
			remember( getField(CMD.CTRL_TEMPLATE_REACT_ST_PART, 2) );
			
			getField(CMD.CTRL_TEMPLATE_REACT_ST_PART,5).disabled = disabled;
			go.alpha( WARN_TEXT, disabled?.2:1 );
			
			
			
		}
		private function getCCB8bytelist(bf:int, bf2:int, itemttl:String = ""):Array
		{
			var list:Array = new Array;
			var code_all:int = 0xFFFFFFFF;
			list.push( {"label":loc("g_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL, "senddata":code_all } );
			
			var select_all:Boolean = false;
			var select:int;
			for (var i:int=0; i<32; i++) {
				select = UTIL.isBit(i,bf) ?1:0;
				
				list.push( {"labeldata":(i+1), 
					"label":itemttl+ " " + (i+1), 
					"data":select } );
			}
			for (i=0; i<32; i++) {
				select = UTIL.isBit(i,bf2) ?1:0;
				
				list.push( {"labeldata":(32+i+1), 
					"label":itemttl+ " " + (32+i+1), 
					"data":select } );
			}
			return list;
		}
		private function getCCBlist(bf:int, itemttl:String):Array
		{
			var list:Array = new Array;
			var code_all:int = 0xFFFFFFFF;
			list.push( {"label":loc("g_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL, "senddata":code_all } );
			
			var select_all:Boolean = false;
			var select:int;
			for (var i:int=0; i<32; i++) {
				select = UTIL.isBit(i,bf) ?1:0;
				
				list.push( {"labeldata":(i+1), 
					"label":itemttl+ " " + (i+1), 
					"data":select } );
			}
			return list;
		}
		private function turnToBitfield( arr:Array ):int
		{
			var num:int = 0;
			var len:int = arr.length;
			for (var i:int=0; i<len; i++) {
				num |= (1<< int(arr[i]-1));
			}
			return num;
		}
		
		private function manualSwitcher( id:int ):void
		{
			
			SavePerformer.saveForce( sendSwitch );
			
			function sendSwitch():void
			{
				switch( id ) {
					
					
					default:
						
						
						RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_TEMPLATE_MANUAL,null,structureID,[ id ]));
						break;
				}
				
				
				
				
			}
			
		}
		
				
		
		
		private function getManualCnt():void
		{
			
				
			
			if( reqConditTask )reqConditTask.repeat();
			
			
		}
		
		private function delegateSelectTimes( t:IFormString ):void
		{
			
			
			
			const data:Array =
				[
					getField( CMD.CTRL_TEMPLATE_MANUAL_TIME, 1 ).getCellInfo(),
					getField( CMD.CTRL_TEMPLATE_MANUAL_TIME, 2 ).getCellInfo(),
					getField( CMD.CTRL_TEMPLATE_MANUAL_TIME, 3 ).getCellInfo(),
					getField( CMD.CTRL_TEMPLATE_MANUAL_TIME, 4 ).getCellInfo(),
				];
			
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_TEMPLATE_MANUAL_TIME, null,structureID, data));
			
			
			
			
		}
		
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.SimpleTextField;


class OptWarnText extends OptionsBlock{
	
	
	public function OptWarnText():void{
		init();
	}
	
	private function init():void
	{
		drawIndent( 20 );
		
		const wtext:String = loc( "value_of_mode_constantly" );
		//const tf:SimpleTextField = new SimpleTextField( wtext, 0, 0x951530 ) ;
		const tf:SimpleTextField = new SimpleTextField( wtext, 0, 0xD2554F ) ;
		tf.x = globalX; 
		
		this.addChild( tf );
		
		this.scaleX = this.scaleY = .95;
		
	}}