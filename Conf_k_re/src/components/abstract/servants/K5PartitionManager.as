package components.abstract.servants
{
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.UTIL;

	public final class K5PartitionManager
	{
		private static var inst:K5PartitionManager;
		public static function access():K5PartitionManager
		{
			if(!inst)
				inst = new K5PartitionManager;
			return inst;
		}
		
		private var loader:Array;
		private var list24h:Object;
		
		public function launch():void
		{
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_PART_PARAMS,put));
			
			loader = [];
			loader.push( new Request(CMD.K5_KBD_KEY_CNT,put) );
			loader.push( new Request(CMD.K5_TM_KEY_CNT,put) );
		}
		private function put(p:Package):void
		{
			var len:int, i:int;
			switch(p.cmd) {
				case CMD.K5_PART_PARAMS:
					/**	Команда K5_PART_PARAMS - параметры разделов
					 Параметр 1 - состояние раздела, 0 - без охраны; 1 - под охраной, 2 - под охраной, была тревога
					 Параметр 2 - Быстрая постановка: 1 - разрешена; 0 - запрещена 
					 Параметр 3 - Ожидать передачу на пульт: 1 - разрешено; 0 - запрещено 
					 Параметр 4 - Включать сирену при тревоге: 1 - разрешено; 0 - запрещено 
					 Параметр 5 - 24-х-часовой раздел: 1 - да; 0 - нет 
					 Параметр 6 - пожарный раздел: 1 - да; 0 - нет	*/  
					
					list24h = {};
					var a:Array = OPERATOR.getData(CMD.K5_PART_PARAMS);
					len = a.length;
					for (i=0; i<len; i++) {
						if( a[i][4] == 1)
							list24h[i+1] = true;
					}
					
					next();
					break;
				case CMD.K5_KBD_KEY_CNT:
					if (p.getParamInt(1) > 0)
						RequestAssembler.getInstance().fireReadSequence(CMD.K5_KBD_KEY,put,p.getParamInt(1));
					else
						next();
					break;
				case CMD.K5_KBD_KEY:
				case CMD.K5_TM_KEY:
					/**	Команда K5_KBD_KEY - клавиатурные ключи пользователей
						Параметр 1 - Клавиатурный ключ пользователя ( 0-9999 ).
						Параметр 2 - Разделы, к которым относится ключ пользователя  (для Контакта-5 = 16разделов, для Контакта-9 = 6разделов) ( Битовое поле, указывающее разделы. 0x0001 - первый раздел, 0x0002 - второй раздел, 0x0004 - третий раздел..., 0x8000 - 16 раздел). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление );
						Параметр 3 - Флаг использования ключа под принуждением ( 0x00 - нет, 0x01 - да ).	*/
					
					/** Команда K5_TM_KEY - для чтения и записи ключей ТМ
					 Параметры 1-8 - код ключа ТМ
					 Параметр 9 - битовая маска разделов, которые ставятся/снимаются этим ключом
					 Параметр 10 - флаг того, что этот ключ используется для снятия ""под принуждением"" (0 - обычный, 1 - под принуждением)
					 Параметр 11 - битовая маска:
					 0 -бит - флаг того, что этот ключ используется для отметки группы быстрого реагирования  (1 - не ставим отметку в истории, 0 - ставим отметку CID 750.1 (используем для теста ) - прибытие группы)
					 !!!!NB: Инверсная логика битов 11-го параметра сделана для того, чтобы при обновлении прошивки битовые поля по-умолчанию были отключены (пустое значение  байта флэш-памяти = 0xFF)
					 1-7биты - резерв.
					 !NB: При записи ключей программа настройки должна сама отслеживать повторение кодов ключей.	*/
					
					len = p.length;
					var bf:int;
					var changed:Boolean;	// если битовое поле было изменено, надо отсылать структуру на прибор, 
					var removed:int;		//removed - (номер первой удаленной структуры) значит было удалена структура, после этого приходится писать все структуры, вне зависимости от того были они удалены или нет
					var total:int;			// тотал - общее количество активных структур
					var keys:Array;
					
					
					
					// перебор всех видимых ключей
					for (i=0; i<len; i++) {
						if (p.cmd == CMD.K5_KBD_KEY)
							bf = p.getParamInt(2,i+1);
						else
							bf = p.getParamInt(9,i+1);
						changed = false;	// каждый новый ключ изначально неизменен
						for (var j:int=0; j<16; j++) {
							// проверка 16 разделов - отмечен ли раздел в ключе и если да, 24х часовой ли он
							if ( UTIL.isBit(j,bf) && is24h(j+1) ) {
								// убрать этот раздел
								bf = UTIL.changeBit( bf,j,false );
								changed = true;
							}
						}
						// если раздел был изменен либо был один из ключей ранее был удален
						if (changed || removed > 0 ) {
							// если разделы не выбраны и при этом было удаление сохрняем изменение дял дальнейшей отсылки
							if (bf > 0 && removed > 0) {
								if (p.cmd == CMD.K5_KBD_KEY)
									keys.push( [p.getParam(1,i+1),bf,p.getParam(3,i+1)] );
								else
									keys.push( [p.getParam(1,i+1),p.getParam(2,i+1),p.getParam(3,i+1),p.getParam(4,i+1),p.getParam(5,i+1),p.getParam(6,i+1),
										p.getParam(7,i+1),p.getParam(8,i+1),bf,p.getParam(10,i+1),p.getParam(11,i+1)] );
							}
							// если разделы не выбраны и удаления не было, отмечаем удаление
							if (bf == 0 && removed == 0) {
								removed = i+1;
								keys = [];
							}
							// если разделы выбраны и удалений не было, отсылаем все в обычном порядке
							if (bf > 0 && removed == 0) {
								if (p.cmd == CMD.K5_KBD_KEY)
									RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_KBD_KEY,null,i+1,[p.getParam(1,i+1),bf,p.getParam(3,i+1)]));
								else {
									RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_TM_KEY,null,i+1,
										[p.getParam(1,i+1),p.getParam(2,i+1),p.getParam(3,i+1),p.getParam(4,i+1),p.getParam(5,i+1),p.getParam(6,i+1),
											p.getParam(7,i+1),p.getParam(8,i+1),bf,p.getParam(10,i+1),p.getParam(11,i+1)]));
								}
							}
						}
					}
					if (keys) {
						// наличие массива подтверждает хотябы одно удаление
						len = keys.length;
						// надо отослать все сохраненные структуры с новыми индексами
						for (i=0; i<len; i++) {
							if (p.cmd == CMD.K5_KBD_KEY)
								RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_KBD_KEY,null,i+removed,keys[i]));
							else {
								RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_TM_KEY,null,i+removed,keys[i]));
							}
						}
						// и надо уменьшить общее количество ключей
						if (p.cmd == CMD.K5_KBD_KEY)
							RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_KBD_KEY_CNT,null,1,[i+removed-1]));
						else
							RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_TM_KEY_CNT,null,1,[i+removed-1]));
					}
					next();
					break;
				case CMD.K5_TM_KEY_CNT:
					if (p.getParamInt(1) > 0)
						RequestAssembler.getInstance().fireReadSequence(CMD.K5_TM_KEY,put,p.getParamInt(1));
					else
						next();
					break;
				default:
					break;
			}
		}
		private function onComplete():void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigationSilent, {"isBlock":false} );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
		}
		private function next():void
		{
			if (loader.length > 0)
				RequestAssembler.getInstance().fireEvent( loader.shift() );
			else
				onComplete();
		}
		private function is24h(n:int):Boolean
		{
			return Boolean(list24h[n]);
		}
	}
}