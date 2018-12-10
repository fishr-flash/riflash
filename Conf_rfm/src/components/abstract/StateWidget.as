package components.abstract
{
	import components.abstract.servants.WidgetMaster;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.static.RF_STATE;
	
	public class StateWidget implements IWidget
	{
		private static var inst:StateWidget;
		public static function access():StateWidget
		{
			if(!inst)
				inst = new StateWidget;
			return inst;
		}
		public function StateWidget()
		{
			
		}
		public function init():void
		{
			WidgetMaster.access().registerWidget( CMD.RF_STATE, this ); 
		}
		public function put(p:Package):void
		{
			/**	Команда RF_STATE - возращает состояние выполнения команды RF_FUNCT
			 Параметр 1 - Тип радиоустройства ( 0x00 - не определен, 0x01 - Геркон, 0x02 - ИП дымовой, 0x03 - ИО разбития стекла, 0x04 - ИО объемный, 0x05 - радиобрелок, 0x06 - радиореле, 0x07 - радиоклавиатура,  0x08 - ИПР, 0x09 - ИО затопления,  0x0A - Геркон CR2032 ), 0xFE - любой датчик ( только для ""идет добавление"");
			 Параметр 2 - Номер радиоустройства в списке ( номер радиодатчика , номер брелока, номер клавиатуры, номер радиореле )
			 Параметр 3 - Статус радиоустройства ( 0x00 - нет; 0x01 - идет добавление радиоустройства; 0x02 - радиоустройство не найдено; 0x03 - радиоустройство уже есть в системе; 0x04 - радиоустройство успешно добавлено; 0x05 - добавление радиоустройства отменено; 0x06 - номер радиоустройства занят, добавить нельзя; 0x07 - ошибка добавления/удаления (например - некорректный номер, тип или действие, нет радиосистемы ); 0x08 - Нельзя добавить через оболочку, идет добавление через перемычку; 0x09 - места для добавления больше нет; 0x0A - радиодатчик удален; 0x0B - вход в режим добавления через перемычку; 0x0C - Выход из режима добавления через перемычку в рабочий режим; 0x0D - Восстановление успешно; 0x0E - Восстановление не возможно; 0x0F - Все радиоустройства помечены, как потерянные при создании новой радиосистемы, параметры 1,2 - не используются =0x00)."*/												
			var state:int = p.getParamInt(3);
			
			switch(state) {
				case RF_STATE.JUMPER_ON:
					CLIENT.JUMPER_BLOCK = true;
					break;
				case RF_STATE.JUMPER_OFF:
					CLIENT.JUMPER_BLOCK = false;
					break;
			}
		}
	}
}