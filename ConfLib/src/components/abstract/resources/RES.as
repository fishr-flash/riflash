package components.abstract.resources
{
	public class RES
	{
		private static const ATTENTION:String = "Внимание!";
		private static const UNDEFINED:String = "UNDEFINED";
		private static const CONNECTED:String = "Подключен";
		private static const ERROR:String = "Ошибка!"
		private static const ERROR_UKWN:String = "Неизвестная ошибка";
		
		private static const CLIENT_VER_MISMATCH:String = "Версия программы конфигурации не совпадает с прибором.\nВозможны неточности в отображении информации";
		private static const CLIENT_MSMATCH_UPDATECLIENT:String = "Версия программы конфигурации устарела для данного прибора.\nНеобходимо обновить программу конфигурации";
		private static const CLIENT_MSMATCH_UPDATESERVER:String = "Программа конфигурации не совместима с прибором.\nНеобходимо обновить версию прибора";
		
		private static const UNKNOWN_SERVER:String = "неопознанный прибор";
		private static const CONNECTED_TO_UNKNOWN_SERVER:String= "Подключен неопознанный прибор";
		private static const SERVER_VER_NOT_RECOGNIZED:String = "Версия прибора не распознана";
		
		private static const MSG_RADIOSYSTEM:String = "В приборе отсутствует радиосистема\rНеобходимо создать новую";
		
		private static const MSG_CONF_LOAD_INTERRUPT:String = "Загрузка настроек была прервана. Для корректной работы прибора повторите загрузку настроек\n" +
			"или выполните настройку прибора вручную.";
		private static const FIRMWARE_TO_DEVICE:String = "Загрузка обновления в прибор";
		
			
		private static const HISTORY_DELETE_SURE:String = "Вы действительно хотите удалить историю?";
		private static const JOURNAL_DELETE_SURE:String = "Вы действительно хотите удалить журнал событий?";
		private static const HISTORY_WAIT_FOR_DELETE:String = "Ждите, история удаляется...";
		private static const HISTORY_WAIT_FOR_DELETE_MINUTES:String = "Ждите, история удаляется до нескольких минут";
		private static const HISTORY_TIME_DELETING:String = "Процесс займет несколько секунд";
		private static const HISTORY_TIME_DELETING_MINUTES:String = "Процесс может продолжаться вплоть до нескольких минут";
		private static const HISTORY_NOT_DELETED:String = "История не была удалена";
		private static const HISTORY_DELETING_WHILE_SAVE:String = "Внимание! При сохранении история полностью удаляется.";
		private static const HISTORY_CONTINUE_SAVE:String = "Продолжить?\rПри выборе \"Нет\" все флажки будут возвращены";
		private static const HISTORY_DELETING_WHILE_SAVE_SHORT:String = "При сохранении история полностью удаляется.";
		
		private static const SERVER_INCORRECT_DATA:String = "В приборе хранится некорректная информация";
		
		private static const PAGE_WOULD_NOT_LOAD:String = "Страница не будет загружена";
		private static const PAGE_LINKCH_NOT_SAVED:String = "Каналы связи не были сохранены, потому что настроены не правильно";
		private static const SAVE_ERROR:String = "Ошибка при сохранении";
		
		private static const EHANDLER_COMMUNICATION:String = "Произошла ошибка коммуникации с прибором";
		
		private static const LOGOLOADER_WRONG_FORMAT:String = "Графический формат не поддерживается,\rПожалуйста используйте GIF, PNG, JPG, BMP 24bit, TIFF 24bit без сжатия";
		
		private static const V2_NO_OUTPUT:String = "На приборе нет ни одного выхода";
	}
}