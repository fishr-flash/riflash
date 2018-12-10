package components.screens.opt
{
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.DS;
	
	public class OptEnergyModeDebug extends OptionsBlock
	{
		private const re_start_stop:RegExp = /^(0|1|2)$/g;
		private const re_move_park:RegExp = /^(0|3|4)$/g;
		private const re_regular:RegExp = /^(0|3)$/g;
		private const re_days:RegExp = /^(\d?\d)$/g;
		private const re_hours:RegExp = /^(0?\d|[0-1]\d|2[0-3])$/g;
		private const re_minutes:RegExp = /^([0-5]\d|0?\d)$/g;
		
		private var sched1:OptEnergySchedule;
		private var sched2:OptEnergySchedule;
		private var sched3:OptEnergySchedule;
		private var sched4:OptEnergySchedule;
		
		private var LOADING:Boolean = false;
		private var realStructure:int;
		
		public function OptEnergyModeDebug(s:int)
		{
			super();
			structureID = s;
			var list:Array;
			var list2:Array;
			var fieldShift:int = 180;
			var xplace:int;
			var xshift2Cells:int;
			
			switch(s) {
				case 11:
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_SET, "Режим работы:", callModeLogic, 1, 
						[{label:"Определение координат при условии", data:0}, {label:"Постоянное определение координат", data:1}] );
					attuneElement( fieldShift, 344, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					list = [{label:"нет", data:0},{label:"постоянно", data:4},{label:"регулярно с интервалом", data:3} ];
					list2= [{label:"нет", data:0},{label:"однократно", data:1},{label:"однократно через", data:2} ];
					
					xplace = 400;
					xshift2Cells = 63;
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_START, "При пуске двигателя:", callFiledLogic, 1, list2 );
					attuneElement( fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_START, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_START ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_START, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_START+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_RUNS, "При работе двигателя:", callFiledLogic, 1, list );
					attuneElement( fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_RUNS ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_RUNS+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_STOP, "При остановке двигателя:", callFiledLogic, 1, list2 );
					attuneElement( fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_STOP ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_STOP+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_START, "При начале движения:", callFiledLogic, 1, list2 );
					attuneElement( fieldShift, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_START, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_START ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_START, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_START+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_MOVE, "При движении:", callFiledLogic, 1, list );
					attuneElement( fieldShift, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_MOVE, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_MOVE ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_MOVE, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_MOVE+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_STOP, "При прекращении\rдвижения:", callFiledLogic, 1, list2 );
					attuneElement( fieldShift, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_STOP, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_STOP ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_STOP, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_STOP+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_PARK, "При стоянке:", callFiledLogic, 1, list );
					attuneElement( fieldShift, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_PARK, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_PARK ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_PARK, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_PARK+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					list = [{label:"нет", data:0},{label:"регулярно с интервалом", data:3} ];
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_REGULAR, "Регулярно:", callFiledLogic, 1, list );
					attuneElement( fieldShift, 150, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 2, null, "0-9", 2 ).x = xplace - 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "сут.", null, CMD.VR_WORKMODE_REGULAR ).x = xplace - 32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 3, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_REGULAR+1 ).x = xplace + 32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 4, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_REGULAR+2 ).x = xplace + 96;
					attuneElement( 30 );
					
					sched1 = new OptEnergySchedule("Расписание 1", getStructure(), fieldShift, xplace);
					addChild( sched1 );
					sched1.x = globalX;
					sched1.y = globalY;
					globalY += 33;
					
					sched2 = new OptEnergySchedule("Расписание 2", getStructure()+ 12, fieldShift, xplace);
					addChild( sched2 );
					sched2.x = globalX;
					sched2.y = globalY;
					globalY += 33;
					
					sched3 = new OptEnergySchedule("Расписание 3", getStructure() + 24, fieldShift, xplace);
					addChild( sched3 );
					sched3.x = globalX;
					sched3.y = globalY;
					globalY += 33;
					
					sched4 = new OptEnergySchedule("Расписание 4", getStructure() + 36, fieldShift, xplace);
					addChild( sched4 );
					sched4.x = globalX;
					sched4.y = globalY;
					globalY += 50;
					
					break;
				case 12:
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_SET, "", callModeLogic, 1, 
						[{label:"выход на связь при условии", data:0},{label:"всегда на связи с сервером", data:1}] );
					attuneElement( NaN, 344, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					list = [{label:"нет", data:0},{label:"постоянно", data:4},{label:"регулярно с интервалом", data:3} ];
					list2= [{label:"нет", data:0},{label:"однократно", data:1},{label:"однократно через", data:2} ];
					
					xplace = 400;
					xshift2Cells = 63;
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_START, "", callFiledLogic, 1, list2 );
					attuneElement( NaN, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_START, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_START ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_START, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_START+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_RUNS, "", callFiledLogic, 1, list );
					attuneElement( NaN, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_RUNS ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_RUNS, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_RUNS+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_ENGINE_STOP, "", callFiledLogic, 1, list2 );
					attuneElement( NaN, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_ENGINE_STOP ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_ENGINE_STOP, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_ENGINE_STOP+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_START, "", callFiledLogic, 1, list2 );
					attuneElement( NaN, 150+xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_START, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_START ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_START, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_START+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_MOVE, "", callFiledLogic, 1, list );
					attuneElement( NaN, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_MOVE, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_MOVE ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_MOVE, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_MOVE+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_STOP, "", callFiledLogic, 1, list2 );
					attuneElement( NaN, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_STOP, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_STOP ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_STOP, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_STOP+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_PARK, "", callFiledLogic, 1, list );
					attuneElement( NaN, 150 + xshift2Cells, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_PARK, "", null, 2, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_PARK ).x = xplace+32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_PARK, "", null, 3, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_PARK+1 ).x = xplace + 96;
					attuneElement( 30 );
					
					list = [{label:"нет", data:0},{label:"регулярно с интервалом", data:3} ];
					
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSComboBox, CMD.VR_WORKMODE_REGULAR, "", callFiledLogic, 1, list );
					attuneElement( NaN, 150, FSComboBox.F_COMBOBOX_NOTEDITABLE );
					getLastElement().x = fieldShift;
					
					createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 2, null, "0-9", 2 ).x = xplace - 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "сут.", null, CMD.VR_WORKMODE_REGULAR ).x = xplace - 32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 3, null, "0-9", 2 ).x = xplace;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					createUIElement( new FormString, 0, "час.", null, CMD.VR_WORKMODE_REGULAR+1 ).x = xplace + 32;
					attuneElement( 30 );
					createUIElement( new FormString, CMD.VR_WORKMODE_REGULAR, "", null, 4, null, "0-9", 2  ).x = xplace + 63;
					attuneElement( 30, NaN, FormString.F_EDITABLE );
					FLAG_VERTICAL_PLACEMENT = true;
					createUIElement( new FormString, 0, "мин.", null, CMD.VR_WORKMODE_REGULAR+2 ).x = xplace + 96;
					attuneElement( 30 );
					
					sched1 = new OptEnergySchedule("", getStructure(), fieldShift, xplace);
					addChild( sched1 );
					sched1.x = globalX;
					sched1.y = globalY;
					globalY += 33;
					
					sched2 = new OptEnergySchedule("", getStructure()+ 12, fieldShift, xplace);
					addChild( sched2 );
					sched2.x = globalX;
					sched2.y = globalY;
					globalY += 33;
					
					sched3 = new OptEnergySchedule("", getStructure() + 24, fieldShift, xplace);
					addChild( sched3 );
					sched3.x = globalX;
					sched3.y = globalY;
					globalY += 33;
					
					sched4 = new OptEnergySchedule("", getStructure() + 36, fieldShift, xplace);
					addChild( sched4 );
					sched4.x = globalX;
					sched4.y = globalY;
					globalY += 50;
					
					break;
			}
			this.complexHeight = globalY;
		}
		public function putAssemblege(a:Array, str:int):void
		{
			structureID = str;
			
			LOADING = true;
			
			getField( CMD.VR_WORKMODE_SET, 1).setCellInfo( a[CMD.VR_WORKMODE_SET][structureID-1][0] );
			callModeLogic( getField( CMD.VR_WORKMODE_SET, 1) );
			
			var engine:Boolean = !DS.isDevice(DS.V5) && !DS.isDevice(DS.V6);
				
			if (a[CMD.VR_WORKMODE_SET][structureID-1][0] == 1) {
				
				if (engine) {
					compare(CMD.VR_WORKMODE_ENGINE_START, a, [2,0,10]);
					compare(CMD.VR_WORKMODE_ENGINE_RUNS, a, [3,0,10]);
					compare(CMD.VR_WORKMODE_ENGINE_STOP, a, [2,0,10]);
				}
				
				compare(CMD.VR_WORKMODE_START, a, [2,0,10]);
				compare(CMD.VR_WORKMODE_MOVE, a, [3,0,10]);
				compare(CMD.VR_WORKMODE_STOP, a, [2,0,10]);
				compare(CMD.VR_WORKMODE_PARK, a, [3,1,0]);
				compare(CMD.VR_WORKMODE_REGULAR, a, [3,0,3,0]);
				
				testSchedule(a[CMD.VR_WORKMODE_SCHEDULE]);
					
			} else {
				
				if (engine) {
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
			}
			if (engine) {
				callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_START, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_RUNS, 1 ));
				callFiledLogic( getField( CMD.VR_WORKMODE_ENGINE_STOP, 1 ));
			}
				
			callFiledLogic( getField( CMD.VR_WORKMODE_START, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_MOVE, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_STOP, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_PARK, 1 ));
			callFiledLogic( getField( CMD.VR_WORKMODE_REGULAR, 1 ));
					
			LOADING = false;
		}
		/** Отсылает дефолты на прибор в случае несоответствия */
		private function compare(cmd:int, dataCome:Array, dataShould:Array, s:int=0):void
		{
			var str:int = structureID;
			if (s>0)
				str = s;
			
			var valid:Boolean = true;
			var len:int = dataShould.length;
			for (var i:int=0; i<len; ++i) {
				if( dataCome[cmd][str-1][i] != dataShould[i] ) {
					valid = false;
					break;
				}
			}
			if (!valid)
				RequestAssembler.getInstance().fireEvent( new Request(cmd,null,str,dataShould));
		}
		/** Подменяет дефол и в исходном массиве и отсылает на прибор */
		private function compareSoft(cmd:int, dataCome:Array, reg:Array, def:Array, s:int=0):void
		{
			var str:int = structureID;
			if (s>0)
				str = s;
			
			var txt:String;
			var target:Array = dataCome[cmd][str-1];
			
			var valid:Boolean = true;
			var len:int = reg.length;
			for (var i:int=0; i<len; ++i) {
				txt = String(dataCome[cmd][str-1][i]);
				if( txt.search( (reg[i] as RegExp) ) != 0 ) {
					valid = false;
					break;
				}
			}
			if (!valid) {
				dataCome[cmd][str-1] = def;
				RequestAssembler.getInstance().fireEvent( new Request(cmd,null,str,def));
			}
		}
		private function complareStructures(cmd:int, dataCome:Array, def:Array, s1:int, s2:int):void
		{
			var valid:Boolean = true;
			var len:int = dataCome[cmd][s1].length;
			for (var i:int=0; i<len; ++i) {
				if( dataCome[cmd][s1-1][i] != dataCome[cmd][s2-1][i] ) {
					var a1:Array = dataCome[cmd][s1-1];
					var a2:Array = dataCome[cmd][s2-1];
					trace(dataCome[cmd][s1-1][i]+ "!="+ dataCome[cmd][s2-1][i])
					valid = false;
					break;
				}
			}
			if (!valid) {
				dataCome[cmd][s1-1] = def;
				dataCome[cmd][s2-1] = def;
				RequestAssembler.getInstance().fireEvent( new Request(cmd,null,s1,def));
				RequestAssembler.getInstance().fireEvent( new Request(cmd,null,s2,def));
			}
		}
		private function testSchedule(a:Array):void
		{
			var len:int = a.length;
			var wrong:Boolean = false;
			for (var i:int=0; i<len; ++i) {
				
				for (var k:int=0; k<9; ++k) {
					if (a[i][k] != 0 ) {
						wrong = true;
						break;
					}
				}
				if (wrong)
					RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_SCHEDULE,null,getStructure()+(i*10),[0,0,0,0,0,0,0,0,0]));
			}
			
		}
		private function callFiledLogic(t:IFormString):void
		{
			var vis:Boolean = Boolean((t.getCellInfo() == 2 || t.getCellInfo() == 3));
			
			getField(t.cmd, 2).visible = vis;
			getField(t.cmd, 3).visible = vis;
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
			
		/*	if (getStructure() == 9)	// надпись к VR_WORKMODE_EVENT
				getField( 0, 1 ).disabled = b;*/
			
			getField( CMD.VR_WORKMODE_ENGINE_START, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_START, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_ENGINE_START, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_START ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_START+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_ENGINE_RUNS, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_RUNS ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_RUNS+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_ENGINE_STOP, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_STOP ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_ENGINE_STOP+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_START, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_START, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_START, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_START ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_START+1 ).visible = !b;
			
		//	getField( 0, 10 ).disabled = b; //CMD.VR_WORKMODE_START
			
			getField( CMD.VR_WORKMODE_MOVE, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_MOVE, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_MOVE, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_MOVE ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_MOVE+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_STOP, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_STOP, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_STOP, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_STOP ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_STOP+1 ).visible = !b;
			
			getField( CMD.VR_WORKMODE_PARK, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_PARK, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_PARK, 3 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_PARK ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_PARK+1 ).visible = !b;			
			
			getField( CMD.VR_WORKMODE_REGULAR, 1 ).disabled = b;
			getField( CMD.VR_WORKMODE_REGULAR, 2 ).visible = !b;
			getField( CMD.VR_WORKMODE_REGULAR, 3 ).visible = !b;
			getField( CMD.VR_WORKMODE_REGULAR, 4 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_REGULAR ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_REGULAR+1 ).visible = !b;
			getField( 0, CMD.VR_WORKMODE_REGULAR+2 ).visible = !b;
			
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
				
				if (getStructure() == 10)
					smartSetCellInfo( getField( CMD.VR_WORKMODE_PARK, 1 ), 4 );
				else
					smartSetCellInfo( getField( CMD.VR_WORKMODE_PARK, 1 ), 0 );
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
			
			sched1.disabled = b;
			sched2.disabled = b;
			sched3.disabled = b;
			sched4.disabled = b;
			
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
	}
}