package components.abstract.servants
{
	import components.events.RFSensorEvents;
	import components.interfaces.IDataAdapter;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.RF_STATE;
	
	import flash.events.EventDispatcher;

	public class RFSensorServant extends EventDispatcher
	{
		public static var PERIOD_OF_TRANSMISSION_ALARM:int;
		public static var LAST_VALID_PARTITION:int;	// последний выбранный партишен
		public static var PARTITION_LIST:Array;		// массив партишенов для комбобокса
		public static var MAX_SENSORS:int;			// общее максимальное количество датчиков на приборе
		public static var WAIT_FOR_STATE:Boolean;	// после любого действия основанного на стейте надо дождатья ответа от прибора, нужно блокировать все кнопки
		
		public static function getFirstFreeZone(struct:int):int
		{
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			var isFree:Boolean = true;
			for( var i:int=1; i < 100; ++i ) {
				isFree = true;
				for( var s:String in a) {
					if( (a[s][0] == 1 || a[s][0] == 2 || statusMem[s] == RF_STATE.DELETED) && a[s][1] == i && int(s)+1 != struct )
						isFree = false;
				}
				if(isFree)
					return i;
			}
			return 99;
		}
		
		private static var statusMem:Vector.<int> = new Vector.<int>(32);		// массив хранящихся статусов
		private static var zoneMem:Vector.<int> = new Vector.<int>(32);			// массив зон
		private static var lost:Vector.<Boolean> = new Vector.<Boolean>(32);	// массив потеряных датчиков
		public static function systemRebuild():void
		{	// после создания радиоситемы нелья восстанавливать датчики, надо удалить всю информацию об удаленных датчиках
			var len:int = statusMem.length;
			for (var i:int=0; i<len; ++i) {
				if ( statusMem[i] == RF_STATE.DELETED )
					statusMem[i] = RF_STATE.NO;
			}
		}
		public static function setLost(s:int, value:Boolean):void
		{
			lost[s-1] = value;
		}
		public static function getLost(s:int):Boolean
		{
			return lost[s-1];
		}
		public static function setState(s:int, state:int):void
		{
			if (s > 0) {
				statusMem[s-1] = state;
				
				switch (state) {
					case RF_STATE.SUCCESS:
						if (zoneMem[s-1] > 0)
							break;
					case RF_STATE.ADDING:
						// при добавлении надо скидывать все ненужные статусы в дефолт
						var len:int = statusMem.length;
						for (var i:int=0; i<len; ++i) {
							if ( i != s-1 && isUselessStatus( statusMem[i] ) )
								statusMem[i] = 0;
						}
						zoneMem[s-1] = getFirstFreeZone(s);
						break;
				}
			}
			
			function isUselessStatus(_state:int):Boolean
			{
				switch (_state) {
					case RF_STATE.ALREADYEXIST:
					case RF_STATE.CANCELED:
					case RF_STATE.CANNOTADD:
					case RF_STATE.ERROR:
					case RF_STATE.NOTFOUND:
					case RF_STATE.RESTORE_IMPOSSIBLE:
						return true;
						break;
				}
				return false;
			}
		}
		public static function getState(s:int):int
		{
			return statusMem[s-1];
		}
		public static function setZone(s:int, value:int):void
		{
			zoneMem[s-1] = value;
		}
		public static function getZone(s:int):int
		{
			return zoneMem[s-1];
		}
		
		private static var inst:RFSensorServant;
		public static function getInst():RFSensorServant
		{
			if (!inst)
				inst = new RFSensorServant;
			return inst;
		}
		public function fire(stype:int, ftype:int, struc:int):void
		{
			this.dispatchEvent( new RFSensorEvents(stype, ftype, struc) );
		}
		
		private var adapter:SensorTypeAdapter;
		public function getSensorTypeAdapter():IDataAdapter
		{
			if (!adapter)
				adapter = new SensorTypeAdapter;
			return adapter;
		}
	}
}
import components.abstract.ClientArrays;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class SensorTypeAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return ClientArrays.aSensorTypeNames[ value ];
	}
	
	public function perform(field:IFormString):void	{	}
	public function change(value:Object):Object 	{ return value	}
	public function recover(value:Object):Object
	{
		var len:int = ClientArrays.aSensorTypeNames.length;
		for (var i:int=0; i<len; ++i) {
			if( ClientArrays.aSensorTypeNames[i] == value )
				return i; 
		}
		return 0;
	}
}