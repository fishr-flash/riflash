package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.TimeValidationBot;
	import components.abstract.TimeZoneAdapter;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.system.UTIL;

	public class OptModeCustom extends OptModeRoot
	{
		private var sched1:OptEnergySchedule;
		private var sched2:OptEnergySchedule;
		private var sched3:OptEnergySchedule;
		private var sched4:OptEnergySchedule;
		
		public function OptModeCustom(s:int)
		{
			super(s);
			
			var isEven:Boolean = UTIL.isEven(s);
			
			var xplace:int = 400;
			var fieldShift:int = 180;
			var xshift2Cells:int = 63;

			var list:Array = [{label:"нет", data:0},{label:"постоянно", data:4},{label:"регулярно с интервалом", data:3} ];
			var list2:Array = [{label:"нет", data:0},{label:"однократно", data:1},{label:"однократно через", data:2} ];
			var list3:Array;
			if (isEven)
				list3 = [{label:"выход на связь при условии", data:0},{label:"всегда на связи с сервером", data:1}]
			else
				list3 = [{label:"определение координат при условии", data:0}, {label:"постоянное определение координат", data:1}]
			
			createUIElement( new FSComboBox, CMD.VR_WORKMODE_SET, isEven?"":"Режим работы:", callModeLogic, 1, list3 );
			attuneElement( isEven?NaN:fieldShift, 344, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			if(isEven)
				getLastElement().x = fieldShift;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			if (VoyagerBot.isEngine()) {
				createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_START, isEven?"":"При пуске двигателя:", callFiledLogic, 1, list2 );
				attuneElement( isEven?NaN:fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				if(isEven)
					getLastElement().x = fieldShift;
				
				var vbot:TimeValidationBot = new TimeValidationBot(1);
				
				createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_START, "", null, 2, null, "0-9", 2, re_hours ).x = xplace;
				attuneElement( 30, NaN, FormString.F_EDITABLE );
				vbot.add( getLastElement(), TimeValidationBot.HOURS );
				createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_START ).x = xplace+32;
				attuneElement( 30 );
				createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_START, "", null, 3, null, "0-9", 2, re_minutes ).x = xplace + 63;
				attuneElement( 30, NaN, FormString.F_EDITABLE );
				vbot.add( getLastElement(), TimeValidationBot.MINUTES );
				FLAG_VERTICAL_PLACEMENT = true;
				createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_START+1 ).x = xplace + 96;
				attuneElement( 30 );
				
				
				FLAG_VERTICAL_PLACEMENT = false;
				createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_RUNS, isEven?"":"При работе двигателя:", callFiledLogic, 1, list );
				attuneElement( isEven?NaN:fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				if(isEven)
					getLastElement().x = fieldShift;
				
				vbot = new TimeValidationBot(15);
				
				createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 2, null, "0-9", 2, re_hours ).x = xplace;
				attuneElement( 30, NaN, FormString.F_EDITABLE );
				vbot.add( getLastElement(), TimeValidationBot.HOURS );
				createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_RUNS ).x = xplace+32;
				attuneElement( 30 );
				createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 3, null, "0-9", 2, re_minutes  ).x = xplace + 63;
				attuneElement( 30, NaN, FormString.F_EDITABLE );
				FLAG_VERTICAL_PLACEMENT = true;
				vbot.add( getLastElement(), TimeValidationBot.MINUTES );
				createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_RUNS+1 ).x = xplace + 96;
				attuneElement( 30 );
				
				FLAG_VERTICAL_PLACEMENT = false;
				createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_STOP, isEven?"":"При остановке двигателя:", callFiledLogic, 1, list2 );
				attuneElement( isEven?NaN:fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				if(isEven)
					getLastElement().x = fieldShift;
			
				vbot = new TimeValidationBot(1);
				
				createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 2, null, "0-9", 2, re_hours ).x = xplace;
				attuneElement( 30, NaN, FormString.F_EDITABLE );
				vbot.add( getLastElement(), TimeValidationBot.HOURS );
				createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_STOP ).x = xplace+32;
				attuneElement( 30 );
				createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 3, null, "0-9", 2, re_minutes  ).x = xplace + 63;
				attuneElement( 30, NaN, FormString.F_EDITABLE );
				FLAG_VERTICAL_PLACEMENT = true;
				vbot.add( getLastElement(), TimeValidationBot.MINUTES );
				createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_STOP+1 ).x = xplace + 96;
				attuneElement( 30 );
				
			} else {
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_START, "", null, 1 );
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_START, "", null, 2 );
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_START, "", null, 3 );
				createUIElement( new FSShadow, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_START );
				createUIElement( new FSShadow, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_START+1 );
				
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 1 );
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 2 );
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 3 );
				createUIElement( new FSShadow, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_RUNS );
				createUIElement( new FSShadow, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_RUNS+1 );
				
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 1 );
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 2 );
				createUIElement( new FSShadow, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 3 );
				createUIElement( new FSShadow, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_STOP );
				createUIElement( new FSShadow, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_STOP+1 );
			}
		
			
			FLAG_VERTICAL_PLACEMENT = false;
			createUIElement( new FSComboBox, CMD.VR_WORKMODE_START, isEven?"":"При начале движения:", callFiledLogic, 1, list2 );
			attuneElement( isEven?NaN:fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			if(isEven)
				getLastElement().x = fieldShift;
			
			vbot = new TimeValidationBot(1);
			
			createUIElement( new FormString, CMD.VR_WORKMODE_START, "", null, 2, null, "0-9", 2, re_hours ).x = xplace;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			vbot.add( getLastElement(), TimeValidationBot.HOURS );
			createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_START ).x = xplace+32;
			attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_START, "", null, 3, null, "0-9", 2, re_minutes  ).x = xplace + 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			FLAG_VERTICAL_PLACEMENT = true;
			vbot.add( getLastElement(), TimeValidationBot.MINUTES );
			createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_START+1 ).x = xplace + 96;
			attuneElement( 30 );
			
			
			FLAG_VERTICAL_PLACEMENT = false;
			createUIElement( new FSComboBox, CMD.VR_WORKMODE_MOVE, isEven?"":"При движении:", callFiledLogic, 1, list );
			attuneElement( isEven?NaN:fieldShift, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			if(isEven)
				getLastElement().x = fieldShift;
			
			vbot = new TimeValidationBot(15);
			
			createUIElement( new FormString, CMD.VR_WORKMODE_MOVE, "", null, 2, null, "0-9", 2, re_hours ).x = xplace;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			vbot.add( getLastElement(), TimeValidationBot.HOURS );
			createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_MOVE ).x = xplace+32;
			attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_MOVE, "", null, 3, null, "0-9", 2, re_minutes  ).x = xplace + 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			FLAG_VERTICAL_PLACEMENT = true;
			vbot.add( getLastElement(), TimeValidationBot.MINUTES );
			createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_MOVE+1 ).x = xplace + 96;
			attuneElement( 30 );
			
			FLAG_VERTICAL_PLACEMENT = false;
			createUIElement( new FSComboBox, CMD.VR_WORKMODE_STOP, isEven?"":"При прекращении\rдвижения:", callFiledLogic, 1, list2 );
			attuneElement( isEven?NaN:fieldShift, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			if(isEven)
				getLastElement().x = fieldShift;
			
			vbot = new TimeValidationBot(1);
			
			createUIElement( new FormString, CMD.VR_WORKMODE_STOP, "", null, 2, null, "0-9", 2, re_hours ).x = xplace;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			vbot.add( getLastElement(), TimeValidationBot.HOURS );
			createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_STOP ).x = xplace+32;
			attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_STOP, "", null, 3, null, "0-9", 2, re_minutes ).x = xplace + 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			FLAG_VERTICAL_PLACEMENT = true;
			vbot.add( getLastElement(), TimeValidationBot.MINUTES );
			createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_STOP+1 ).x = xplace + 96;
			attuneElement( 30 );
			
			FLAG_VERTICAL_PLACEMENT = false;
			createUIElement( new FSComboBox, CMD.VR_WORKMODE_PARK, isEven?"":"При стоянке:", callFiledLogic, 1, list );
			attuneElement( isEven?NaN:fieldShift, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			if(isEven)
				getLastElement().x = fieldShift;
			
			vbot = new TimeValidationBot(15);
			
			createUIElement( new FormString, CMD.VR_WORKMODE_PARK, "", null, 2, null, "0-9", 2, re_hours ).x = xplace;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			vbot.add( getLastElement(), TimeValidationBot.HOURS );
			createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_PARK ).x = xplace+32;
			attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_PARK, "", null, 3, null, "0-9", 2, re_minutes ).x = xplace + 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			FLAG_VERTICAL_PLACEMENT = true;
			vbot.add( getLastElement(), TimeValidationBot.MINUTES );
			createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_PARK+1 ).x = xplace + 96;
			attuneElement( 30 );
			
			list = [{label:"нет", data:0},{label:"регулярно с интервалом", data:3} ];
			
			FLAG_VERTICAL_PLACEMENT = false;
			createUIElement( new FSComboBox, CMD.VR_WORKMODE_REGULAR, isEven?"":"Регулярно:", callFiledLogic, 1, list );
			attuneElement( isEven?NaN:fieldShift, 150, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			if(isEven)
				getLastElement().x = fieldShift;
			
			vbot = new TimeValidationBot(15);
			
			createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 2, null, "0-9", 2 ).x = xplace - 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			vbot.add( getLastElement(), TimeValidationBot.DAYS );
			createUIElement( new FormString, 0, "сут.", null, CMD.VR_WORKMODE_REGULAR ).x = xplace - 32;
			attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 3, null, "0-9", 2, re_hours ).x = xplace;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			vbot.add( getLastElement(), TimeValidationBot.HOURS );
			createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_REGULAR+1 ).x = xplace + 32;
			attuneElement( 30 );
			createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 4, null, "0-9", 2, re_minutes  ).x = xplace + 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			FLAG_VERTICAL_PLACEMENT = true;
			vbot.add( getLastElement(), TimeValidationBot.MINUTES );
			createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_REGULAR+2 ).x = xplace + 96;
			attuneElement( 30 );
			
			var a:IDataAdapter = new TimeZoneAdapter;
			
			sched1 = new OptEnergySchedule(isEven?"":"Расписание 1", getStructure(), fieldShift, xplace, a);
			addChild( sched1 );
			sched1.x = globalX;
			sched1.y = globalY;
			globalY += 33;
			sched1.addEventListener( Event.CHANGE, onShedChange );
			
			sched2 = new OptEnergySchedule(isEven?"":"Расписание 2", getStructure()+ 12, fieldShift, xplace, a);
			addChild( sched2 );
			sched2.x = globalX;
			sched2.y = globalY;
			globalY += 33;
			sched2.addEventListener( Event.CHANGE, onShedChange );
			
			sched3 = new OptEnergySchedule(isEven?"":"Расписание 3", getStructure() + 24, fieldShift, xplace, a);
			addChild( sched3 );
			sched3.x = globalX;
			sched3.y = globalY;
			globalY += 33;
			sched3.addEventListener( Event.CHANGE, onShedChange );
			
			sched4 = new OptEnergySchedule(isEven?"":"Расписание 4", getStructure() + 36, fieldShift, xplace, a);
			addChild( sched4 );
			sched4.x = globalX;
			sched4.y = globalY;
			globalY += 50;
			sched4.addEventListener( Event.CHANGE, onShedChange );

			// нужно блокировать все поля для адекватной загрузки
			blockEveryField();
			
			this.complexHeight = globalY;
		}
		override public function putAssemblege(a:Array):void
		{
			LOADING = true;
			blockEveryField();
			
			var re01:Array = [new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),re_hours,re_minutes];
			var re012:Array = [new RegExp(/[012]/),re_hours,re_minutes];
			var re034:Array = [new RegExp(/[034]/),re_hours,re_minutes];
			
			compareSoft(CMD.VR_WORKMODE_SET, a, [new RegExp(/[12]/)] );
			
			if (VoyagerBot.isEngine()) {
				compareSoft(CMD.VR_WORKMODE_ENGINE_START, a, re012 );
				compareSoft(CMD.VR_WORKMODE_ENGINE_RUNS, a, re034 );
				compareSoft(CMD.VR_WORKMODE_ENGINE_STOP, a, re012 );
			} else {
				compare(CMD.VR_WORKMODE_ENGINE_START, a );
				compare(CMD.VR_WORKMODE_ENGINE_RUNS, a );
				compare(CMD.VR_WORKMODE_ENGINE_STOP, a );
			}
			
			compareSoft(CMD.VR_WORKMODE_START, a, re012 );
			compareSoft(CMD.VR_WORKMODE_MOVE, a, re034 );
			compareSoft(CMD.VR_WORKMODE_STOP, a, re012 );
			compareSoft(CMD.VR_WORKMODE_PARK, a, re034 );
			
			compareSoft(CMD.VR_WORKMODE_REGULAR, a,[new RegExp(/[03]/),re_days,re_hours,re_minutes]);
			
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID);
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID+12);
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID+24);
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID+36);
			
			distribute( a[CMD.VR_WORKMODE_SET][structureID-1], CMD.VR_WORKMODE_SET );
			
			if (a[CMD.VR_WORKMODE_ENGINE_START]) {
				/*
				var bb1:Boolean = (getField( CMD.VR_WORKMODE_ENGINE_START, 1 ) as FormString).disabled;
				var bb2:Boolean = (getField( CMD.VR_WORKMODE_ENGINE_START, 2 ) as FormString).disabled;
				var bb3:Boolean = (getField( CMD.VR_WORKMODE_ENGINE_START, 3 ) as FormString).disabled;
				*/
				
				distribute( a[CMD.VR_WORKMODE_ENGINE_START][structureID-1], CMD.VR_WORKMODE_ENGINE_START );
				distribute( a[CMD.VR_WORKMODE_ENGINE_RUNS][structureID-1], CMD.VR_WORKMODE_ENGINE_RUNS );
				distribute( a[CMD.VR_WORKMODE_ENGINE_STOP][structureID-1], CMD.VR_WORKMODE_ENGINE_STOP );
			}
			
			distribute( a[CMD.VR_WORKMODE_START][structureID-1], CMD.VR_WORKMODE_START );
			distribute( a[CMD.VR_WORKMODE_MOVE][structureID-1], CMD.VR_WORKMODE_MOVE );
			distribute( a[CMD.VR_WORKMODE_STOP][structureID-1], CMD.VR_WORKMODE_STOP );
			distribute( a[CMD.VR_WORKMODE_PARK][structureID-1], CMD.VR_WORKMODE_PARK );
			distribute( a[CMD.VR_WORKMODE_REGULAR][structureID-1], CMD.VR_WORKMODE_REGULAR );
			
			sched1.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1] );
			sched2.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1+12] );
			sched3.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1+24] );
			sched4.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1+36] );
			
			callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_START, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_RUNS, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_STOP, 1 ));
			
			callFiledLogic( getField( CMD.VR_WORKMODE_START, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_MOVE, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_STOP, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_PARK, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_REGULAR, 1 ));
			
			callModeLogic(null);
			
			LOADING = false;
		}
		override public function adaptTimeZone(obj:Object):void
		{
			switch(obj.struct) {
				case sched1.getStructure():
					sched1.adaptTimeZone(obj.data);
					break;
				case sched2.getStructure():
					sched2.adaptTimeZone(obj.data);
					break;
				case sched3.getStructure():
					sched3.adaptTimeZone(obj.data);
					break;
				case sched4.getStructure():
					sched4.adaptTimeZone(obj.data);
					break;
			}
		}
		private function callFiledLogic(t:IFormString):void
		{
			var vis:Boolean = Boolean((t.getCellInfo() == 2 || t.getCellInfo() == 3));
			var f2:IFormString = getField(t.cmd, 2);
			var f3:IFormString = getField(t.cmd, 3); 
			f2.visible = vis;
			f3.visible = vis;
			
			if (!vis) {	// если основное поле с неВыставляемом временем - надо прятать и в случае инвалидности полей - грузить в них дефолты
				if (t.cmd == CMD.VR_WORKMODE_REGULAR ) {
					var f4:IFormString = getField(t.cmd, 4);
					if ( !f2.isValid() || !f3.isValid() || !f4.isValid() ) {
						f2.setCellInfo(0);
						f3.setCellInfo(0);
						f4.setCellInfo( (f3 as FormEmpty).vbot ? ((f3 as FormEmpty).vbot as TimeValidationBot).minTime : 0 );
						f2.isValid();
						f3.isValid();
						f4.isValid();
					}
				} else {
					if ( !f2.isValid() || !f3.isValid() ) {
						f2.setCellInfo(0);
						f3.setCellInfo( (f3 as FormEmpty).vbot ? ((f3 as FormEmpty).vbot as TimeValidationBot).minTime : 0 );
						f2.isValid();
						f3.isValid();
					}
				}
			}
			
			getField(0, t.cmd).visible = vis;
			getField(0, t.cmd+1).visible = vis;
			if (t.cmd == CMD.VR_WORKMODE_REGULAR) {
				getField(t.cmd, 4).visible = vis;
				getField(0, t.cmd+2).visible = vis;
			}
			if(!LOADING)
				remember(t);
		}
		private function callModeLogic(t:IFormString):void
		{
			var b:Boolean = Boolean(getField( CMD.VR_WORKMODE_SET, 1 ).getCellInfo() == 1);
			
			getField( CMD.VR_WORKMODE_ENGINE_START, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_START, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_START, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_ENGINE_START, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_ENGINE_START, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_START ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_START+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_RUNS ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_RUNS+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_STOP ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_STOP+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_START, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_START, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_START, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_START, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_START, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_START ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_START+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_MOVE, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_MOVE, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_MOVE, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_MOVE, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_MOVE, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_MOVE ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_MOVE+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_STOP, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_STOP, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_STOP, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_STOP, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_STOP, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_STOP ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_STOP+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_PARK, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_PARK, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_PARK, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_PARK, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_PARK, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_PARK ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_PARK+1 ).visible = !b;			
			
			getField( CMD.VR_WORKMODE_REGULAR, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_REGULAR, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_REGULAR, 3 ).disabled = b;
			getField( CMD.VR_WORKMODE_REGULAR, 4 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_REGULAR, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_REGULAR, 3 ).visible = !b;
			getField( CMD.VR_WORKMODE_REGULAR, 4 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_REGULAR ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_REGULAR+1 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_REGULAR+2 ).visible = !b;
			
			sched1.disabled = b;
			sched2.disabled = b;
			sched3.disabled = b;
			sched4.disabled = b;
			
			if (b) {
				
				getField( CMD.VR_WORKMODE_START, 1 ).disabled = b;
				getField( CMD.VR_WORKMODE_START, 2 ).visible = !b;
				getField( CMD.VR_WORKMODE_START, 3 ).visible = !b;
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_START, 1 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_START, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_START, 3 ), 0 );
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_RUNS, 1 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_RUNS, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_RUNS, 3 ), 0 );
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_STOP, 1 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_STOP, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_ENGINE_STOP, 3 ), 0 );
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_START, 1 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_START, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_START, 3 ), 0 );
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_MOVE, 1 ), 4 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_MOVE, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_MOVE, 3 ), 0 );
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_STOP, 1 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_STOP, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_STOP, 3 ), 0 );
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_PARK, 1 ), 4 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_PARK, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_PARK, 3 ), 0 );
				
				smartSetCellInfo( getField( CMD.VR_WORKMODE_REGULAR, 1 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_REGULAR, 2 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_REGULAR, 3 ), 0 );
				smartSetCellInfo( getField( CMD.VR_WORKMODE_REGULAR, 4 ), 0 );
				
				var a:Array = [0,0,0,0,0,0,0,0,0];
				if(LOADING) {
					sched1.putRawData( a );
					sched2.putRawData( a );
					sched3.putRawData( a );
					sched4.putRawData( a );
				} else { 
					sched1.putSmart( a );
					sched2.putSmart( a );
					sched3.putSmart( a );
					sched4.putSmart( a );
				}
			} else {
				callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_START, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_RUNS, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_STOP, 1 ));
				
				callFiledLogic( getField( CMD.VR_WORKMODE_START, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_MOVE, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_STOP, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_PARK, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_REGULAR, 1 ));				
			}
			
			if(!LOADING)
				remember(t);
		}
		private function smartSetCellInfo(t:IFormString, info:Object):void
		{
			if (t.getCellInfo() != info) {
				t.setCellInfo( info );
				if(!LOADING)
					remember( t );
			}
		}
		private function blockEveryField():void
		{
			var b:Boolean = true;
			
			getField( CMD.VR_WORKMODE_ENGINE_START, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_START, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_START, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_START, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_START, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_START, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_MOVE, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_MOVE, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_MOVE, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_STOP, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_STOP, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_STOP, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_PARK, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_PARK, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_PARK, 3 ).disabled = b;
			
			getField( CMD.VR_WORKMODE_REGULAR, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_REGULAR, 2 ).disabled = b;
			getField( CMD.VR_WORKMODE_REGULAR, 3 ).disabled = b;
			getField( CMD.VR_WORKMODE_REGULAR, 4 ).disabled = b;
		}
		private function onShedChange(e:Event):void
		{
			this.dispatchEvent( new Event( Event.CHANGE));
		}
		public function dispatchChange():void
		{
			sched1.dispatchChange();
			sched2.dispatchChange();
			sched3.dispatchChange();
			sched4.dispatchChange();
		}
	}
}