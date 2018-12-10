package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptKey;
	import components.static.CMD;
	import components.static.RF_STATE;
	
	public class UIKeysK2 extends UI_BaseComponent
	{
		private var note:SimpleTextField;
		
		public function UIKeysK2()
		{
			super();
			
			var header:Header = new Header( [{label:loc("tmkey_title"),xpos:105, width:200},{label:loc("tmkey_allowed_action"), xpos:303, width:200},
				{label:loc("rfd_tmkey_code"), xpos:436,width:200,align:"center"}],
				{size:12, leading:0} );
			addChild( header );
			
			list = new OptList;
			addChild( list );
			list.y = 30;
			list.attune( CMD.TM_KEY2,1, OptList.PARAM_SCROLLING_ALWAYS_HIIDDEN | OptList.PARAM_UNIQUE_FUNC_PARAM | OptList.PARAM_NEED_ADDITIONAL_EVENTS, 
				{funcOperator:callFunct} );
			list.width = 624;
			list.renameButtons( loc("tmkey_add_code_manually") );
			list.addEventListener( GUIEvents.onEventFiredSuccess, updateHeight );
			
			note = new SimpleTextField( loc("tmkey_adding_note"), 900 );
			addChild( note );
			note.x = 10;
			
			width = 630;
		}
		override public function open():void
		{
			super.open();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY2, put ));
		}
		override public function close():void
		{
			if (this.visible) {
				super.close();
				list.close();
			}
		}
		override public function put(p:Package):void
		{
			list.put( p, OptKey );
			initSpamTimer( CMD.TM_KEY_STATE );
			list.height = list.getActualLinesCount()*25+50;
			height = list.height + 30;
			updateHeight(null);
			loadComplete();
		}
		private function callFunct(struct:int, action:int):void
		{
			var funct_action:int;
			switch( action ) {
				case OptList.ADD:
					funct_action = 1;
					break;
				case OptList.REMOVE:
					funct_action = 2;
					break;
				case OptList.RESTORE:
					funct_action = 3;
					break;
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_FUNCT, null, 1, [struct,funct_action] ));
		}
		private function insert(p:Package):void
		{
			if (p.getStructure()[0] == 0 )
				list.deletedLine = new OptKey(p.structure);
			list.putStructure(p);
			list.height = list.getActualLinesCount()*25+50;
			
			height = list.height + 30;
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			/** Команда TM_KEY_STATE - ответ от прибора на команду TM_KEY_FUNCT
			 * 	Параметр 1 - порядковый номер ключа ТМ ( 1..n )
			 * 	Параметр 2 - Статус ключа ТМ ( 0x00 - нет; 
			 * 			0x01 - идет добавление ключа ТМ; 
			 * 			0x02 - ключ ТМ не найден ( после 2мин с момента начала добавления); 
			 * 			0x03 - ключ ТМ уже есть в системе; 
			 * 			0x04 - ключ ТМ успешно добавлен; 
			 * 			0x05 - добавление ключа ТМ отменено; 
			 * 			0x06 - строка ключа ТМ, куда добавляем занята, добавить нельзя; 
			 * 			0x07 - ошибка добавления/удаления (например - контрольная сумма или любая другая не описанная ошибка ); 
			 * 			0x08 - Нельзя добавить через оболочку, идет добавление через перемычку; 
			 * 			0x09 - места для добавления больше нет; 
			 * 			0x0A - ключ ТМ удален; 
			 * 			0x0B - вход в режим добавления через перемычку; 
			 * 			0x0C - Выход из режима добавления через перемычку в рабочий режим; 
			 * 			0x0D - Восстановление успешно; 
			 * 			0x0E - Восстановление не возможно; */
			if (p.getStructure()[0] > 0 ) {
				switch( p.getStructure()[1] ) {
					case RF_STATE.ADDING:
						list.ADD_BUSY = true;
						
						var fake:Package = new Package;
						fake.cmd = CMD.RF_RCTRL2;
						fake.data = [[1,"",0,0,0,0,0,0,0,0,0]];
						fake.structure = p.getStructure()[0];
						
						list.putStructure(fake);
						list.height = list.getActualLinesCount()*25+50;
						list.callEach( null, fake.structure );
						
						height = list.height + 80;
						break;
					case RF_STATE.SUCCESS:
					case RF_STATE.DELETED:
					case RF_STATE.RESTORE_SUCCESS:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY2, insert, p.getStructure()[0] ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_STATE, null, 1,[0,0] ));
						list.ADD_BUSY = false;
						break;
					case RF_STATE.RESTORE_IMPOSSIBLE:
						list.clearRestore();
					default:
						popup = PopUp.getInstance();
						switch ( p.getStructure()[1] ) {
							case RF_STATE.RESTORE_IMPOSSIBLE:
								popup.construct( PopUp.wrapHeader("sys_error"), PopUp.wrapMessage(loc("tmkey_unable_to_restore") + p.getStructure()[0] ), PopUp.BUTTON_OK);
								break;
							case RF_STATE.ERROR:
								popup.construct( PopUp.wrapHeader("sys_error"), PopUp.wrapMessage("tmkey_unable_to_add_remove" + p.getStructure()[0] ), PopUp.BUTTON_OK);
								break;
							case RF_STATE.ALREADYEXIST:
								popup.construct( PopUp.wrapHeader("tmkey_add_error"), PopUp.wrapMessage( loc("tmkey_k5_num")+p.getStructure()[0]+" "+loc("g_already_exist") ), PopUp.BUTTON_OK );
								break;
							default:
								var txt:String = loc("g_error_unkwn") + " №" + p.getStructure()[1];
								if (  RF_STATE.NAMES_UNI[p.getStructure()[1]] != null )
									txt = RF_STATE.NAMES_UNI[ p.getStructure()[1]];
								popup.construct( PopUp.wrapHeader( "sys_error"), PopUp.wrapMessage( txt ), PopUp.BUTTON_OK );
						}
						popup.open();
						RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_STATE, null, 1,[0,0] ));
						list.select( p.getStructure()[0] );
						break;
				}
			}
		}
		private function updateHeight(e:Event):void
		{
			var lines:int = list.getActualLinesCount() < 1 ? 1:list.getActualLinesCount();
			note.y = lines*25+80;
		}
	}
}