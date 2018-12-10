package components.static
{
	public class RF_STATE
	{
		// RF_STATE FROM SERVER
		public static const NO:int = 0x00;				// нет
		public static const ADDING:int = 0x01;			// идет добавление радиоустройства
		public static const NOTFOUND:int = 0x02;		// радиоустройство не найдено
		public static const ALREADYEXIST:int = 0x03;	// радиоустройство уже есть в системе
		public static const SUCCESS:int = 0x04;			// радиоустройство успешно добавлено
		public static const CANCELED:int = 0x05;		// добавление радиоустройства отменено
		public static const CANNOTADD:int = 0x06;		// номер радиоустройства занят, добавить нельзя
		public static const ERROR:int = 0x07; 			// ошибка добавления/удаления (например - некорректный номер, тип или действие, нет радиосистемы )
		public static const JUMPERBLOCK:int = 0x08;		// Нельзя добавить через оболочку, идет добавление через перемычку
		public static const LACKOFSPACE:int = 0x09;		// места для добавления больше нет
		public static const DELETED:int = 0x0A;			// Датчик был удален
		public static const JUMPER_ON:int = 0x0B;		// Вход в режим добавления через перемычку
		public static const JUMPER_OFF:int = 0x0C;		// Выход из режима добавления через перемычку в рабочий режим
		public static const RESTORE_SUCCESS:int = 0x0D;	// Восстановление успешно
		public static const RESTORE_IMPOSSIBLE:int = 0x0E;	// Восстановление не возможно
		public static const ALL_DEVICES_LOST:int = 0x0F;	// Все устройства помечены как забытые
		public static const CUSTOM_DELETED:int = 0xA1;	// Если в сессию клиента датчик был удален
		public static const CUSTOM_ENABLED:int = 0xA2;	// Датчик включен
		public static const CUSTOM_BLANK:int = 0xA3;		// Датчик чистый
			
		public static const NAMES:Object = {
			0x00:"Нет",
			0x01:"Идет добавление радиоустройства",
			0x02:"Радиоустройство не найдено",
			0x03:"Радиоустройство уже есть в системе",
			0x04:"Радиоустройство успешно добавлено",
			0x05:"Добавление радиоустройства отменено",
			0x06:"Номер радиоустройства занят, добавить нельзя",
			0x07:"Ошибка добавления/удаления (например - некорректный номер, тип или действие, нет радиосистемы )",
			0x08:"Нельзя добавить через оболочку, идет добавление через перемычку",
			0x09:"Места для добавления больше нет",
			0x0A:"Датчик был удален",
			0x0B:"Вход в режим добавления через перемычку",
			0x0C:"Выход из режима добавления через перемычку в рабочий режим",
			0x0D:"Восстановление успешно",
			0x0E:"Восстановление невозможно",
			0x0F:"Все устройства помечены как забытые",
			0xA1:"Если в сессию клиента датчик был удален",
			0xA2:"Датчик включен",
			0xA3:"Датчик чистый"
		}
		public static const NAMES_UNI:Object = {
			0x00:"Нет",
			0x01:"Идет добавление устройства",
			0x02:"Устройство не найдено",
			0x03:"Устройство уже есть в системе",
			0x04:"Устройство успешно добавлено",
			0x05:"Добавление устройства отменено",
			0x06:"Номер устройства занят, добавить нельзя",
			0x07:"Ошибка добавления/удаления",
			0x08:"Нельзя добавить через оболочку, идет добавление через перемычку",
			0x09:"Места для добавления больше нет",
			0x0A:"Устойство было удалено",
			0x0B:"Вход в режим добавления через перемычку",
			0x0C:"Выход из режима добавления через перемычку в рабочий режим",
			0x0D:"Восстановление успешно",
			0x0E:"Восстановление невозможно",
			0x0F:"Все устройства помечены как забытые"
		}
	}
}