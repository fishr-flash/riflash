package components.screens.ui
{
	import flash.display.Bitmap;
	
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.PopUp;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptRctrl;
	import components.static.CMD;
	import components.static.RF_STATE;
	import components.system.Library;
	
	public class UIRctrl extends UI_BaseComponent
	{
		private const FUNCT_ADD:int = 0x01;// - Добавить радиоустройство;
		private const FUNCT_REMOVE:int = 0x02// - Удалить радиоустройство;
		private const FUNCT_RESTORE:int = 0x03// - Восстановить радиоустройство (Отменить удаление);
		public static const FUNCT_CANCEL:int = 0x04// - прервать добавление радиоустройства;
		
		public static const TYPE:int = 0x05;// - радиобрелок
		
		private var last_state:Array;
		
		public function UIRctrl()
		{
			RF_STATE.ADDING
			
			super();
			
			var header:Header = new Header( [{label:loc("rctrl_label"),xpos:18, width:200},{label:loc("rctrl_press_event"), xpos:276+79-16, width:200},
				{label:loc("rctrl_press_event"), xpos:476+134-16, width:200},{label:loc("rctrl_press_event"), xpos:776+89-16, width:200}],
				{size:12, leading:0} );
			addChild( header );
			header.y = 8;
			
			var img:Bitmap = new Library.cLock;
			addChild( img );
			img.x = 276+79+100-16;
			
			img = new Library.cUnlock;
			addChild( img );
			img.x = 476+134+100-16;
			
			img = new Library.cStar;
			addChild( img );
			img.x = 776+89+100-16;
			
			list = new OptList;
			addChild( list );
			list.attune( CMD.RF_RCTRL2, 1, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_SCROLLING_ALWAYS_HIIDDEN, {funcOperator:callFunct} );
			list.y = 40;
			list.width = 1100;
			list.height = 600;
			list.buttonsExistance(false);
			width = 1050;
			
			starterCMD = CMD.RF_RCTRL2;
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
			list.put( p, OptRctrl  );
			list.height = list.getActualLinesCount()*25+50;
			height = list.height + 30;
			initSpamTimer( CMD.RF_STATE );
			loadComplete();
		}
		private function callFunct(struct:int, action:int):void
		{
			var funct_action:int;
			switch( action ) {
				case OptList.ADD:
					funct_action = FUNCT_ADD;
					break;
				case OptList.REMOVE:
					funct_action = FUNCT_REMOVE;
					break;
				case OptList.RESTORE:
					funct_action = FUNCT_RESTORE;
					break;
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_FUNCT, null, 1, [TYPE,struct,funct_action,0] ));
		}
		private function insert(p:Package):void
		{
			if (p.getStructure()[0] == 0 )
			{
				const o:OptRctrl = new OptRctrl( int( p.structure ) );
				list.deletedLine = o as OptionListBlock;
			}
				
			list.putStructure(p);
			list.height = list.getActualLinesCount()*25+50;
			height = list.height + 30;
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			/** Команда RF_STATE
			 * 	Параметр 1 - Тип радиоустройства ( 0x00 - не определен, 0x01 - Геркон, 0x02 - ИП дымовой, 0x04 - ИО объемный, 0x05 - радиобрелок, 0x06 - радиореле, 0x07 - радиоклавиатура ), 0x08 - ИО разбития стекла, 0xFE - любой датчик ( только для "идет добавление");
			 * 	Параметр 2 - Номер радиоустройства в списке ( номер радиодатчика , номер брелока, номер клавиатуры, номер радиореле )
			 * 	Параметр 3 - Статус радиоустройства ( 0x00 - нет;
			 *  			0x01 - идет добавление радиоустройства; 
			 *				0x02 - радиоустройство не найдено; 
			 * 				0x03 - радиоустройство уже есть в системе; 
			 * 				0x04 - радиоустройство успешно добавлено; 
			 * 				0x05 - добавление радиоустройства отменено; 
			 * 				0x06 - номер радиоустройства занят, добавить нельзя; 
			 * 				0x07 - ошибка добавления/удаления (например - некорректный номер, тип или действие, нет радиосистемы ); 
			 * 				0x08 - Нельзя добавить через оболочку, идет добавление через перемычку; 
			 * 				0x09 - места для добавления больше нет; 
			 * 				0x0A - радиодатчик удален; 
			 * 				0x0B - вход в режим добавления через перемычку; 
			 * 				0x0C - Выход из режима добавления через перемычку в рабочий режим; 
			 * 				0x0D - Восстановление успешно; 
			 * 				0x0E - Восстановление не возможно; 
			 * 				0x0F - Все радиоустройства помечены, как потерянные при создании новой радиосистемы, параметры 1,2 - не используются =0x00). */
			
			if( !isStateRepeating(p.getStructure() ) ) {
				last_state = p.getStructure();
				switch( p.getStructure()[2] ) {
					case RF_STATE.ADDING:
						
						GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {isBlock:true} );
						
						var fake:Package = new Package;
						fake.cmd = CMD.RF_RCTRL2;
						fake.data = [[1,"",0,0,0]];
						fake.structure = p.getStructure()[1];
						
						list.putStructure(fake);
						list.height = list.getActualLinesCount()*25+50;
						height = list.height + 30;
						list.callEach( null, p.getStructure()[1] );
						break;
					case RF_STATE.SUCCESS:
					case RF_STATE.DELETED:
					case RF_STATE.CANCELED:
					case RF_STATE.RESTORE_SUCCESS:
						GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {isBlock:false} );
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_RCTRL2, insert, p.getStructure()[1] ));
						//RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_STATE, null,1,[0,0,0] ));
						break;
					case RF_STATE.ALREADYEXIST:
						if (!popup)
							popup = PopUp.getInstance();
						popup.construct( PopUp.wrapHeader( "tmkey_add_error"), 
							PopUp.wrapMessage( loc("ui_trinket")+" #"+p.getStructure()[1]+" "+loc("g_already_exist") ),
							PopUp.BUTTON_OK );
						popup.open();
						list.select( p.getStructure()[1] );
						break;
					default:
						if (!popup)
							popup = PopUp.getInstance();
						var txt:String = loc("g_error_unkwn") + " #" + p.getStructure()[2];
						if (  RF_STATE.NAMES_UNI[p.getStructure()[2]] != null )
							txt = RF_STATE.NAMES_UNI[ p.getStructure()[2]];
						popup.construct( PopUp.wrapHeader( "sys_error"), PopUp.wrapMessage( txt ), PopUp.BUTTON_OK );
						popup.open();
						break;
				}
				last_state = null;
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_STATE, null, 1, [0,0,0]));
			}
		}
		private function isStateRepeating(state:Array):Boolean
		{
			if (state[0] == 0 && state[1] == 0 && state[2] == 0 )
				return true;
			
			if (!last_state || !state)
				return false;
			
			for(var i:int=0; i<4; ++i ) {
				if( last_state[i] != state[i] )
					return false;
			}
			return true;
		}
	}
}