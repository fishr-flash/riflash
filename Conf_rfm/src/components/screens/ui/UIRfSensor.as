package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.WidgetMaster;
	import components.gui.Header;
	import components.interfaces.IRfDevice;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.ui.abstract.UIRfDevices;
	import components.static.CMD;
	import components.static.RF_STATE;
	
	public class UIRfSensor extends UIRfDevices
	{
		public function UIRfSensor()
		{
			super();
			
			addButton( ADD, loc("sensor_add"));
			addButton( REMOVE, loc("sensor_remove"));
			
			listCmd = CMD.RF_SENSOR;
			addValue = 0xfe;
			
			manager.titles = {"add":loc("rfd_sensor_add_inprogress"),"notfound":loc("rfd_sensor_not_found"),
				"exist":loc("rfd_sensor_already_exist_num"),"deleted":loc("rfd_sensor_removed"),"cancelled":loc("rfd_sensor_add_canceled")};
			
			starterCMD = CMD.RF_SENSOR;
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.RF_SENSOR:
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
							RequestAssembler.getInstance().fireEvent(new Request(CMD.RF_SENSOR,put));
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
		override protected function listUpdate():void
		{
			RequestAssembler.getInstance().fireEvent(new Request(CMD.RF_SENSOR,put));
		}
		override protected function getHeader():Header
		{
			return new Header( [{label:loc("his_exp_index"),xpos:10, width:100, align:"center"},
				{label:loc("rf_sen_h_type"), xpos:globalX + 95, width:100} ], {size:11, border:false, align:"left"} );
		}
	}
}