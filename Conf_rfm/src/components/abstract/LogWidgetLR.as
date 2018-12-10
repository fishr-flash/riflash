package components.abstract
{
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class LogWidgetLR implements IWidget
	{
		private static var inst:LogWidgetLR;
		public static function access():LogWidgetLR
		{
			if(!inst)
				inst = new LogWidgetLR;
				
			return inst;
		}
		
		private var lines:Array
		private var delegate:Function;
		private var task:ITask;
		
		private var rfd:Array;
		private var alarms_p4:Array;
		private var alarms_p5:Array;
		private var index:int;
		
		public function LogWidgetLR()
		{
		}
		
		public function init():void
		{
			
			WidgetMaster.access().registerWidget(CMD.LR_SEND_LOG,this);
			task = TaskManager.callLater( onTimer, TaskManager.DELAY_20SEC+TaskManager.DELAY_5SEC);
			onTimer();
			
		}
		
		public function register(f:Function):void
		{
			delegate = f;
			init();
			if (lines) {
				delegate(lines);						
				lines = null;
			}
			
		}
		
		public function unregister():void
		{
			WidgetMaster.access().unregisterWidget(CMD.LR_SEND_LOG);
			task.kill();
			task = null;
			
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
			RequestAssembler.getInstance().fireEvent( new Request( CMD.LR_GET_LOG,	null,1,[30] ));
			if( task )task.repeat();
		}
		private function getLine(p:Package):Array
		{
			
			
			var type:int = p.getParamInt(1);
			var resource:int = p.getParamInt(3)-1;
			var a:Array = [++index];
			a.push( UTIL.getHistoryDateStamp() );
			
			a = a.concat( [ p.data[ 0 ][ 0 ], p.data[ 0 ][ 1 ], p.data[ 0 ][ 2 ], p.data[ 0 ][ 3 ] ] );
			
			return a;
			
										
			/**
			 * LR_SEND_LOG	4031	1	4	ro,d,1	ro,d,1	ro,s,20	ro,s,63						
				"
				Параметр 1 - Тип устройства
				Параметр 2 - Адрес устройства
				Параметр 3 - Текст сообщения (Событие)
				Параметр 4 - Дополнительные параметры
				
				DATA0 - тип сообщения [7..6], 00-автотест, 11-тревога
				DATA0 - резерв [5..0]
				DATA1 - номер батареи, от которой питаемся [7]  (0..1) 0-основная, 1-резервная
				DATA1 - номер батареи [6] (0..1) 0-основная, 1-резервная
				DATA1 - передаем напряжение батареи [5..0] (0,0..6,3)В
				DATA2 - передаем уровень приема радиосигнала (RSSI) (int8)"													
			 */
		}
	}
}