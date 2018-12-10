package components.screens.ui
{
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSComboBox;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UISerialPort extends UI_BaseComponent
	{
		public static const TYPE_RS232:int = 1;
		public static const TYPE_RS485:int = 2;
		
		public function UISerialPort(type:int)
		{
			super();
			
			structureID = type;
			var l:Array;
			/**
			 * "Команда VR_SERIAL_USE - назначение последовательного порта 232,
				Структура 1 - порт 1  - RS 232 - порт вояджера
				Структура 2 - порт 2  - RS 485 - порт вояджера
				Структура 3 - порт 3  - RS 232 - резерв
				
				Структура 1 Параметр 1 - назначение:
				.........0 - Не используется;
				.........1 - Протокол Ritm-bin;
				.........2 - Датчик топлива Стрела D232;
				.........4 - Расширитель входов (V-EB)
				.........5 - CAN_LOG
				.........6 - Датчик угла поворота
				
				Структура 2 Параметр 1 - назначение:
				.........0 - Не используется;
				.........1 - Протокол Ritm-bin; (резерв)
				.........2 - Датчик топлива Омникомм или аналог
				.........3 - BUS J1708   - (только в RS485)
				.........4 - (пропускаем этот идентификатор)."													
			 */
			switch(type) {
				case TYPE_RS232:
					l = UTIL.getComboBoxList
					([
						[0,loc("port_rs232_not_in_use")]
						,[1,loc("port_rs232_p_ritmbin")]
						,[2,loc("port_rs232_d232")]
						,[4,loc("extens_enters_vr")]
						,[5,loc("CAN-LOG")]
						//,[6,loc("sensor_angle_of_turn")]
					]);
					break;
				case TYPE_RS485:
					l = UTIL.getComboBoxList([[0,loc("port_rs232_not_in_use")],[1,loc("port_rs232_p_ritmbin")],[2,loc("port_omnicomm")],[3,loc("port_j1708")]]);
					break;
			}
			
			addui( new FSComboBox, CMD.VR_SERIAL_USE, loc("port_rs232_purpose"), null, 1, l );
			if (LOC.language == LOC.IT)
				attuneElement( 150, 420, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			else
				attuneElement( 150, 250+60, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			if (DS.release >= 36) {
				if (LOC.language == LOC.IT)
					drawSeparator(610);
				else
					drawSeparator();
				var t:SimpleTextField = new SimpleTextField(loc("port_warning"));
				addChild( t );
				t.x = globalX;
				t.y = globalY;
			}
			
			starterCMD = CMD.VR_SERIAL_USE;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			loadComplete();
			if (DS.release >= 36 && structureID == 2)
				SavePerformer.trigger({"cmd":refine});
		}
		/** 36+ релиз RS485, если переключили с BUS J1708 надо CAN_CAR_ID обнулить	*/   
		private function refine(value:Object):int
		{
			if(value is int) {
				switch(value) {
					case CMD.VR_SERIAL_USE:
						return SavePerformer.CMD_TRIGGER_TRUE;
				}
			} else {
				var was:int = OPERATOR.dataModel.getData(CMD.VR_SERIAL_USE)[1][0];
				var cancarid:int = OPERATOR.dataModel.getData(CMD.CAN_CAR_ID)[0][0];
				var current:int = int(getField(CMD.VR_SERIAL_USE,1).getCellInfo());
				if (was == 3 && was != current && cancarid == 66)
					RequestAssembler.getInstance().fireEvent( new Request(CMD.CAN_CAR_ID,null,1,[0]));
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
	}
}