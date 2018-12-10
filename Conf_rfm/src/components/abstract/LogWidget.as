package components.abstract
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class LogWidget implements IWidget
	{
		private static var inst:LogWidget;
		public static function access():LogWidget
		{
			if(!inst)
				inst = new LogWidget;
			return inst;
		}
		
		private var lines:Array
		private var delegate:Function;
		private var task:ITask;
		
		private var rfd:Array;
		private var alarms_p4:Array;
		private var alarms_p5:Array;
		private var index:int;
		
		public function LogWidget()
		{
		}
		
		public function init():void
		{
			WidgetMaster.access().registerWidget(CMD.CTRL_MAPRF_LOG,this);
			task = TaskManager.callLater( onTimer, TaskManager.DELAY_20SEC+TaskManager.DELAY_5SEC);
			onTimer();
		}
		
		public function register(f:Function):void
		{
			delegate = f;
			if (lines) {
				delegate(lines);						
				lines = null;
			}
		}
		public function put(p:Package):void
		{
			if (delegate is Function) {
				delegate([getLine(p)]);
			} else {
				if(!lines)
					lines = [];
				lines.push(getLine(p));
			}
		}
		private function onTimer():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_GET_MAPRF_LOG,	null,1,[30] ));
			task.repeat();
		}
		private function getLine(p:Package):Array
		{
			if (!rfd) {
				
				//rfd = [	loc("rfd_not_recognized"),"RDD", "RSD1", "RGD", "RMD1", "RBR1","","", "RIPR1","", "RDD3"];
				///FIXME: Debug value! Remove it now! Убрать когда нибудь...
				/*rfd = [	
					loc("rfd_not_recognized")
					,loc("rfd_gerkon")
					, loc("rfd_smoke")
					, loc("rfd_glass_break")
					, loc("rfd_volume")
					, loc("rfd_rftrinket")
					,""
					,""
					, loc("rfd_ipr")
					,""
					, loc("rfd_gerkon_rdd3")];*/
				rfd = ClientArrays.aSensorTypeNames.slice();
				
				alarms_p4 = [
					[
						loc("sensor_alarm") +" - " + loc("out_sensor_main_zone").toLowerCase(),
						loc("sensor_alarm") +" - " + loc("out_sensor_additional_wire").toLowerCase(),
						loc("sensor_alarm") +" - " + loc("out_sensor_tamper").toLowerCase(),
						loc("log_alarm_battery_low"),
						loc("out_sensor_autotest_fail")
					],[
						loc("g_button") + " 1",
						loc("g_button") + " 2",
						loc("g_button") + " 3",
					]
				];
				alarms_p5 = [
					[
						loc("his_revert") +" - " + loc("out_sensor_main_zone").toLowerCase(),
						loc("his_revert") +" - " + loc("out_sensor_additional_wire").toLowerCase(),
						loc("his_revert") +" - " + loc("out_sensor_tamper").toLowerCase(),
						loc("log_alarm_battery_ok"),
						loc("log_alarm_autotest")
					],[
					]
				];
			}
			
			var type:int = p.getParamInt(1);
			var resource:int = p.getParamInt(3)-1;
			var a:Array = [++index];
			a.push( UTIL.getHistoryDateStamp() );
			
			a.push( rfd[type] );
			a.push( p.getParam(2) );
			
			var s:String = "";
			for (var i:int=0; i<8; i++) {
				if (UTIL.isBit(i,p.getParamInt(4))) {
					if (s.length > 0)
						s+=", ";
					s += alarms_p4[resource][i];
				}
			}
			for (i=0; i<8; i++) {
				if (UTIL.isBit(i,p.getParamInt(5))) {
					if (s.length > 0)
						s+=", ";
					s += alarms_p5[resource][i];
				}
			}
			a.push( s );
			var sig:int = UTIL.toSigned(p.getParamInt(6),1 )
			a.push( sig == 0? "":sig );
			sig = UTIL.toSigned(p.getParamInt(7),1 )
			a.push( sig == 0? "":sig );
			
			return a;
			
			/**"Команда CTRL_MAPRF_LOG - Журнал событий
			 
			 Параметр 1 - Радиодатчик или радиобрелок, тип, 0x00 - не определен, 0x01 - RDD, 0x02 - RSD1, 0x03 - RGD, 0x04 - RMD1, 0x05 - RBR1, 0x08 - RIPR1, 0x0A - RDD3
			 Параметр 2 - Номер радиодатчика или радиобрелока
			 Параметр 3 - Ресурс, 1-радиодатчик, 2 брелок - другие события (резерв)
			 Параметр 4 - Событие, Битовое поле,
			 ....для Ресурс=1:
			 ....Бит 0 = 1 - Тревога - основная зона,
			 ....Бит 1 = 1 - Тревога - дополнительный шлейф,
			 ....Бит 2 = 1 - Тревога - тамперный контакт,
			 ....Бит 3 = 1 - Разряд элемента питания,
			 ....Бит 4 = 1 - Автотест не прошел,
			 ....Бит 5 =  - резерв
			 ....Бит 6 =  - резерв
			 ....Бит 7 =  - резерв
			 ....для Ресурс=2
			 ....Бит 0 = 1 - Кнопка 1
			 ....Бит 1 = 1 - Кнопка 2
			 ....Бит 2 = 1 - Кнопка 3
			 ....Бит 3..7 - Резерв
			 Параметр 5 - Событие, Битовое поле,
			 ....для Ресурс=1:
			 ....Бит 0 = 1 - Восстановление - основная зона,
			 ....Бит 1 = 1 - Восстановление - дополнительный шлейф,
			 ....Бит 2 = 1 - Восстановление - тамперный контакт,
			 ....Бит 3 = 1 - Элемент питания в норме,
			 ....Бит 4 = 1 -  Автотест,
			 ....Бит 5 = - резерв
			 ....Бит 6 = - резерв
			 ....Бит 7 = - резерв
			 ........для Ресурс=2
			 ....Бит 0..7 = - резерв
			 Параметр 6 - Ослабление сигнала, антенна 1, -дБм
			 Параметр 7 - Ослабление сигнала, антенна 2, -дБм"												*/
		}
	}
}