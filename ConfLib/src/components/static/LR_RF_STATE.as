package components.static
{
	public class LR_RF_STATE
	{
		// RF_STATE FROM SERVER
		public static const NO:int = 0x00;				// нет
		public static const ADDING:int = 0x01;			// идет добавление радиоустройства
		public static const SUCCESS:int = 0x02;			// радиоустройство успешно добавлено
		public static const ADDRESS_BUSY:int = 0x03;	// адрес занят
		public static const ON_FAIL_ADDED:int = 0x04;	// Добавить не удалось (по ошибке или по таймауту 2 минуты).
		public static const DELETED:int = 0x05;			// Удалено удачно
		public static const CANNOT_DELETE:int = 0x06;	// Удаление не удалось.
		public static const RESTORE_SUCCESS:int = 0x07; // Восстановлено
		public static const CANNOT_RESTORE:int = 0x08;		// Восстановить не удалось.
		
		
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