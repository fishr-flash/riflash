package components.screens.ui.abstract
{
	import flash.events.Event;
	
	import components.abstract.StateWidget;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.MflexListSensor;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IResizeDependant;
	import components.interfaces.IRfDevice;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.opt.OptRfDevice;
	import components.static.CMD;
	import components.static.DS;
	import components.static.RF_FUNCT;
	import components.static.RF_STATE;

	public class UIRfDevices extends UI_BaseComponent implements IResizeDependant, IWidget
	{
		protected const ADD:int=0;
		protected const REMOVE:int=1;
		protected const RESTORE:int=2;
		protected const CANCEL:int=3;
		protected var listCmd:int;
		protected var addValue:int;
		
		protected var flist:MflexListSensor;
		protected var manager:StateManager;
		
		private var btns:Vector.<TextButton>;
		private var _addPos:IRfDevice;
		
		public function UIRfDevices()
		{
			super();
			
			manager = new StateManager(onClick);
			
			var h:Header = getHeader();
			addChild( h );
			h.y = globalY;
			globalY += 30;
			
			flist = new MflexListSensor(OptRfDevice,manager);
			addChild( flist );
			flist.width = 430;
			flist.height = 200;
			flist.x = globalX-10;
			flist.y = globalY;
			flist.addEventListener( GUIEvents.EVOKE_READY, onSelect );
		}
		override public function open():void
		{
			super.open();
			jumper();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case listCmd:
					flist.put(p,false);
					ResizeWatcher.addDependent(this);
					WidgetMaster.access().registerWidget(CMD.RF_STATE,this);
					update();
					loadComplete();
					break;
				case CMD.RF_STATE:
					/**	Команда RF_STATE - возращает состояние выполнения команды RF_FUNCT
					 Параметр 1 - Тип радиоустройства ( 0x00 - не определен, 0x01 - Геркон, 0x02 - ИП дымовой, 0x03 - ИО разбития стекла, 0x04 - ИО объемный, 0x05 - радиобрелок, 0x06 - радиореле, 0x07 - радиоклавиатура,  0x08 - ИПР, 0x09 - ИО затопления,  0x0A - Геркон CR2032 ), 0xFE - любой датчик ( только для ""идет добавление"");
					 Параметр 2 - Номер радиоустройства в списке ( номер радиодатчика , номер брелока, номер клавиатуры, номер радиореле )
					 Параметр 3 - Статус радиоустройства ( 0x00 - нет; 0x01 - идет добавление радиоустройства; 0x02 - радиоустройство не найдено; 0x03 - радиоустройство уже есть в системе; 0x04 - радиоустройство успешно добавлено; 0x05 - добавление радиоустройства отменено; 0x06 - номер радиоустройства занят, добавить нельзя; 0x07 - ошибка добавления/удаления (например - некорректный номер, тип или действие, нет радиосистемы ); 0x08 - Нельзя добавить через оболочку, идет добавление через перемычку; 0x09 - места для добавления больше нет; 0x0A - радиодатчик удален; 0x0B - вход в режим добавления через перемычку; 0x0C - Выход из режима добавления через перемычку в рабочий режим; 0x0D - Восстановление успешно; 0x0E - Восстановление не возможно; 0x0F - Все радиоустройства помечены, как потерянные при создании новой радиосистемы, параметры 1,2 - не используются =0x00)."*/												
					var str:int = p.getParamInt(2);
					var state:int = p.getParamInt(3);
					
					if (state != RF_STATE.ALREADYEXIST && state != RF_STATE.JUMPER_ON && state != RF_STATE.JUMPER_OFF )
						(flist.getLine(str-1) as IRfDevice).setState(state, p);
					if (state != RF_STATE.ADDING && state != RF_STATE.JUMPER_ON && state != RF_STATE.JUMPER_OFF )
						manager.busy = false;
					
					switch(state) {
						case RF_STATE.DELETED:
						case RF_STATE.SUCCESS:
						case RF_STATE.RESTORE_SUCCESS:
							manager.put(str,state);
							listUpdate();
							_addPos = null;
							break;
						case RF_STATE.ADDING:
							manager.put(str,state);
							break;
						case RF_STATE.ALREADYEXIST:
							(flist.getLine(manager.line) as IRfDevice).setState(state, p);
							break;
						case RF_STATE.JUMPER_ON:
							CLIENT.JUMPER_BLOCK = true;
							jumper();
							break;
						case RF_STATE.JUMPER_OFF:
							CLIENT.JUMPER_BLOCK = false;
							jumper();
							break;
					}
					update();
					break;
			}
		}
		override public function close():void
		{
			super.close();
			ResizeWatcher.removeDependent(this);
			WidgetMaster.access().unregisterWidget(CMD.RF_STATE);
			StateWidget.access().init();
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var ah:int = flist.getActualHeight();
			var fh:int;
			if (h - 80 > ah)
				fh = ah;
			else
				fh = h - 80;
			flist.height = fh;
			btns[ADD].y = fh + 50;
			btns[REMOVE].y = fh + 50;
		}
		private function onClick(n:int):void
		{
			
			switch(n) {
				case ADD:
					if ( !manager.busy && flist.selected > -1 && (flist.getSelected() as IRfDevice).isAddable() ) {
						_addPos = (flist.getSelected() as IRfDevice);
						var str:int = _addPos.getStructure();
						funct(str,RF_FUNCT.DO_ADD,addValue);
						manager.line = flist.selected;
						manager.busy = true;
					}
					break;
				case REMOVE:
					if (flist.isSelected()) {
						var o:Object = flist.getSelected();
						funct(flist.selected+1,RF_FUNCT.DO_DEL,addValue);
						manager.busy = true;
					}
				case RESTORE:
					if (flist.isSelected()) {
						funct(flist.selected+1,RF_FUNCT.DO_RESTORE,addValue);
						manager.busy = true;
					}
					break;
				case CANCEL:
					if (flist.isSelected()) {
						funct(flist.indexOf( _addPos as IFlexListItem ) + 1,RF_FUNCT.DO_CANCEL,addValue);
						_addPos = null;
						manager.busy = true;
					}
					break;
			}
			update();
		}
		
		private function onSelect(e:Event):void
		{
			update();
		}
		private function funct(str:int, action:int, type:int):void
		{
			/** Команда RF_FUNCT - Действие с радиоустройством ( см.п.3)
			 Параметр 1 - Тип радиоустройства ( 0x00 - не определен, 0x01 - ИО Геркон, 0x02 - ИП дымовой, 0x03 - ИО разбития стекла, 0x04 - ИО объемный, 0x05 - радиобрелок, 0x06 - радиореле, 0x07 - радиоклавиатура, 0x08 - ИПР, 0x09 - ИО затопления, 0x0A - Геркон CR2032, 0xFE - новый радиодатчик, код используется для добавления любого радиодатчика ). К радиодатчикам относятся: ИП и ИПР, ИО. К радиодатчикам не относятся радиоклавиатуры, радиореле и брелоки;
			 Параметр 2 - Номер радиоустройства в списке, видимый пользователем ( порядковый номер радиодатчика , порядковый номер брелока, порядковый номер клавиатуры, порядковый номер радиореле );
			 Параметр 3 - Действие с радиоустройством ( 0x01 - Добавить радиоустройство; 0x02 - Удалить радиоустройство; 0x03 - Восстановить радиоустройство (Отменить удаление); 0x04 - прервать добавление радиоустройства; 0x05 - пометить все радиоустройства, как потерянные (новая радиосистема), но не удаленные ( код 0x02 ), значения параметров 1,2,4 - не используются = 0x00:  ).
			 Параметр 4 - период передачи тревожных сообщений в сек, 5-255, 0 - использовать по умолчанию из радиосистемы	*/
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_FUNCT, null, 1, [type,str,action,0]));
		}
		protected function update():void
		{
			
			btns[ADD].disabled = !(!manager.busy && flist.isSelected() && (flist.getSelected() as IRfDevice).isAddable() && !CLIENT.JUMPER_BLOCK);
			btns[REMOVE].disabled = manager.busy || !flist.isSelected() || !(flist.isSelected() && (flist.getSelected() as IRfDevice).isRemovable()) || CLIENT.JUMPER_BLOCK;
			/// В MRR-1 последний датчик встроенный, поэтому блокируем возможность его удаления
			if( DS.isDevice(DS.M_RR1 ) && btns[ REMOVE ].disabled == false) 
										btns[ REMOVE ].disabled = flist.selected ==  31;
		}
		protected function isMaxLines():Boolean
		{
			return false;
		}
		protected function getHeader():Header
		{
			return null;
		}
		protected function addButton(num:int, ttl:String):void
		{
			if(!btns)
				btns = new Vector.<TextButton>(2);
			btns[num] = new TextButton;
			addChild( btns[num] );
			btns[num].x = globalX + (num*250);
			btns[num].setUp(ttl,onClick,num);
		}
		protected function listUpdate():void
		{
		}
		protected function jumper():void
		{
			if (CLIENT.JUMPER_BLOCK)
				changeSecondLabel(loc("rfd_jumper_adding"));
			else
				changeSecondLabel("");
			
			update();
		}
	}
}
import components.interfaces.IRfManager;

class StateManager implements IRfManager
{
	public var line:int;	// строка таблицы, с которой взаимодействоали во время добавления устройства
	public var busy:Boolean;
	public var titles:Object;
	
	private var data:Array;
	private var funct:Function;
	
	public function StateManager(f:Function)
	{
		funct = f;
	}
	public function put(str:int, state:int):void
	{
		if (!data)
			data = new Array;
		data[str] = state;
	}
	public function restore():void
	{
		funct(2);	// вызов onClick с функцией RESTORE
	}
	public function cancelAdd():void
	{
		funct(3);	// вызов onClick с функцией RESTORE
	}
	public function getTitles():Object
	{
		return titles;
	}
}