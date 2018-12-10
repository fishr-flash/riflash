package components.abstract
{
	public class CTRL_TEMPLATE_OUT
	{
		public static const R0_NO_REACT:int = 0;
		public static const R1_PART_STATE_IND:int = 1;
		public static const R2_TRIGGER_ON_PART_ALARM:int = 2;
		public static const R3_IND_UNSENT_EVENT:int = 3;
		public static const R4_IND_FAIL:int = 4;
		public static const R5_MANUAL_CTRL:int = 5;
		public static const R6_TRINKET_BUTTON:int = 6;
		public static const R7_ALARM_FROM_SENSOR:int = 7;
		public static const R8_REPEATER:int = 8;
		public static const R9_REACT_PART_STATE:int = 9;
		public static const R10_REACT_ZONE_STATE:int = 10;
		public static const R11_NOTIF_FIRE:int = 11;
		public static const R12_REACT_EXT:int = 12;
		
		/** Команда CTRL_TEMPLATE_OUT - настроенные шаблоны для выходов

			Параметр 1 - идентификационный номер шаблона
			......0 - Реакция не настроена ( Выключен )
			......1 - Индикация состояния раздела
			......2 - Срабатывание по тревоге в разделе
			......3 - Индикация непереданных событий
			......4 - Индикация неисправности
			......5 - Ручное управление выходом
			......6 - Кнопки от брелока (RDK)
			......7 - Тревоги от радиодатчиков (RDK)
			......8 - Повторитель состояния радиодатчиков (RDK)
			......9 - Реакция на состояние раздела. (Реле10)
			....10 - Реакция на состояние зоны. (Реле10)
			....11 - Оповещение о пожаре (Реле 10)
			....12 - Реакция дополнительная (Реле 10)	*/
	}
}