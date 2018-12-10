package components.static
{
	public class RF_CTRL
	{
		/**
		 * Идентификационный номер шаблона для параметров 3, 4, 5
			......0 - Реакция не настроена ( Выключен )
			......1 - Индикация состояния раздела
			......2 - Срабатывание по тревоге в разделе
			......3 - Индикация непереданных событий
			......4 - Индикация неисправности
			......5 - Ручное управление выходом
		 */
		
		public static const TEMPLATE_OUT:int = 0x00;
		public static const TEMPLATE_INDICATION_PART:int = 0x01;
		public static const TEMPLATE_ACTUATION_ONALARM:int = 0x02;
		public static const TEMPLATE_INDICATION_NOSEND:int = 0x03;
		public static const TEMPLATE_INDICATION_FAULT:int = 0x04;
		public static const TEMPLATE_MANUAL_CONTROL:int = 0x05;
		
	}
}							