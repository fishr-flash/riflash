package components.interfaces
{
	public interface IDataAdapter
	{
		function change(value:Object):Object; 	// меняет вбитое значение до валидации
		/**
		 * Вызывается при первой загрузке входных данных 
		 * @param value собственно данные полученые с прибора
		 * @return данные которые будут сообщены закрепленному компоненту
		 * 
		 */		
		function adapt(value:Object):Object;
		/**
		 * Вызывается при изменении значения эл-та, например
		 * при чеке чекбокса
		 *  
		 * @param value данные полученные компонентом в результате изменения состояния
		 * @return данные которые будут переданны на прибор в результате преобразования
		 * 
		 */		
		function recover(value:Object):Object;
		/**
		 * Вызывается при первой загрузке входных данных 
		 * @param field элемент за которым закреплен адаптер
		 * @return 
		 * 
		 */	
		function perform(field:IFormString):void;
	}
}