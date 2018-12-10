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
	import components.interfaces.IResizeDependant;
	import components.interfaces.IRfDevice;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.opt.OptAlKey;
	import components.screens.opt.OptLrDevice;
	import components.static.CMD;
	import components.static.LR_RF_STATE;
	import components.static.RF_FUNCT;

	public class UIRfDevicesLr extends UI_BaseComponent implements IResizeDependant, IWidget
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
		
		public function UIRfDevicesLr()
		{
			super();
			
			manager = new StateManager(onClick);
			
			var h:Header = getHeader();
			addChild( h );
			h.y = globalY;
			h.x = globalX;
			globalY += 30;
			
			flist = new MflexListSensor( OptLrDevice,manager);
			addChild( flist );
			flist.width = 630;
			flist.height = 300;
			flist.x = globalX;
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
					var len:int = p.data.length;
					for (var i:int=0; i<len; i++) 
					{
						if( p.data[ i ][ 1 ] == 0 ) 
						{
							p.data.splice( i, len - i );
							break;
						}
						
						
					}
					
					flist.put(p,false);
					ResizeWatcher.addDependent(this);
					WidgetMaster.access().registerWidget(CMD.LR_RF_STATE,this);
					update();
					loadComplete();
					break;
				case CMD.LR_RF_STATE:
					
					/** Команда LR_RF_STATE - состояние по радиосистеме (Ritm-bin2-no-ack)

						Параметр 1 - Адрес устройства, 1..240;
						Параметр 2 - Состояние по радиосистеме:
						...0-Нет добавления;
						...1-Идет добавление;
						...2-Добавлено удачно;
						...3-Адрес занят;
						...4-Добавить не удалось (по ошибке или по таймауту 2 минуты).
						...5-Удалено удачно
						...6-Удаление не удалось.
						...7-Восстановлено
						...8-Восстановить не удалось.*/
					
					
					var str:int = p.getParamInt(1);
					var state:int = p.getParamInt(2);
					
					if (state != LR_RF_STATE.DELETED  )
						(flist.getLine(str-1) as IRfDevice).setState(state, p);
					if (state != LR_RF_STATE.ADDING  )
						manager.busy = false;
					
					switch(state) {
						case LR_RF_STATE.DELETED:
						case LR_RF_STATE.SUCCESS:
						case LR_RF_STATE.RESTORE_SUCCESS:
							manager.put(str,state);
							listUpdate();
							break;
						case LR_RF_STATE.ADDING:
							manager.put(str,state);
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
			WidgetMaster.access().unregisterWidget(CMD.LR_RF_STATE);
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
			var opt:IRfDevice;
			switch(n) {
				case ADD:
					if ( !manager.busy && flist.selected > -1 && (flist.getSelected() as IRfDevice).isAddable() ) {
						opt = (flist.getSelected() as IRfDevice);
						var str:int = opt.getStructure();
						//funct(str,RF_FUNCT.DO_ADD,addValue);
						funct( 0, 0);
						manager.line = flist.selected;
						manager.busy = true;
					}
					break;
				case REMOVE:
					if (flist.isSelected()) {
						var o:Object = flist.getSelected();
						//funct(flist.selected+1,RF_FUNCT.DO_DEL,addValue);
						funct( 0, 0);
						manager.busy = true;
					}
				case RESTORE:
					if (flist.isSelected()) {
						//funct(flist.selected+1,RF_FUNCT.DO_RESTORE,addValue);
						funct( 0, 0);
						manager.busy = true;
					}
					break;
				case CANCEL:
					if (flist.isSelected()) {
						//funct(flist.selected+1,RF_FUNCT.DO_CANCEL,addValue);
						funct( 0, 0);
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
		//private function funct(str:int, action:int, type:int):void
		private function funct(address:int = 0, type:int = 0):void
		{
			/** Команда RF_FUNCT - Действие с радиоустройством ( см.п.3)
			 Параметр 1 - Тип радиоустройства ( 0x00 - не определен, 0x01 - ИО Геркон, 0x02 - ИП дымовой, 0x03 - ИО разбития стекла, 0x04 - ИО объемный, 0x05 - радиобрелок, 0x06 - радиореле, 0x07 - радиоклавиатура, 0x08 - ИПР, 0x09 - ИО затопления, 0x0A - Геркон CR2032, 0xFE - новый радиодатчик, код используется для добавления любого радиодатчика ). К радиодатчикам относятся: ИП и ИПР, ИО. К радиодатчикам не относятся радиоклавиатуры, радиореле и брелоки;
			 Параметр 2 - Номер радиоустройства в списке, видимый пользователем ( порядковый номер радиодатчика , порядковый номер брелока, порядковый номер клавиатуры, порядковый номер радиореле );
			 Параметр 3 - Действие с радиоустройством ( 0x01 - Добавить радиоустройство; 0x02 - Удалить радиоустройство; 0x03 - Восстановить радиоустройство (Отменить удаление); 0x04 - прервать добавление радиоустройства; 0x05 - пометить все радиоустройства, как потерянные (новая радиосистема), но не удаленные ( код 0x02 ), значения параметров 1,2,4 - не используются = 0x00:  ).
			 Параметр 4 - период передачи тревожных сообщений в сек, 5-255, 0 - использовать по умолчанию из радиосистемы	*/
			
			/**
			 * Команда LR_DEVICE_ADD_TO_RF_SYSTEM - добавить устройство в радиосистему
			
			Параметр 1 - Адрес ( номер структуры в списке устройств ), в который хотим добавить устройство, 
			 * 1..240 - адрес добавляемого устройства, 0-на любой свободный адрес.
				Параметр 2 - Фильтр добавляемого устройства:
			...0-добавление любого устройства;
			...1-добавление только радиоизвещателей;
			...2-добавление только радиореле, радиосирены, радиотабло;
			...3-добавление только радиоклавиатуры;
			...4-добавление только радиобрелоков;
			...5-добавление только тревожной кнопки дальнего действия.*/

			
			//RequestAssembler.getInstance().fireEvent( new Request(CMD.LR_DEVICE_ADD_TO_RF_SYSTEM, null, 1, [type,str,action,0]));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.LR_DEVICE_ADD_TO_RF_SYSTEM, null, 1, [ address, type ]));
		}
		protected function update():void
		{
			btns[ADD].disabled = !(!manager.busy && flist.isSelected() && (flist.getSelected() as IRfDevice).isAddable() && !CLIENT.JUMPER_BLOCK);
			btns[REMOVE].disabled = manager.busy || !flist.isSelected() || !(flist.isSelected() && (flist.getSelected() as IRfDevice).isRemovable()) || CLIENT.JUMPER_BLOCK;
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