package components.abstract
{
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.CONST;

	public final class VoyagerBot	// 15 VOYAGER
	{
		public static const PARAM_AKB:int=48;
		
		private var returnStatus:Function;
		
		private static var inst:VoyagerBot;
		public static function getInstance():VoyagerBot
		{
			if (!inst)
				inst = new VoyagerBot;
			return inst;
		}
		public function askSensorAKBstatus(f:Function):void
		{
			returnStatus = f;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_VOLTAGE_SENSOR, put));
		}
		public function askHistoryAKBstatus(f:Function):void
		{
			returnStatus = f;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.HISTORY_SELECT_PAR, put));
		}
		private function put(p:Package):void
		{
			var enabled:Boolean;
			switch(p.cmd) {
				case CMD.HISTORY_SELECT_PAR:
					enabled = isHistoryEnabled();
					break;
				case CMD.VR_VOLTAGE_SENSOR:
					enabled = isSensorEnabled();
					break;
			}
			returnStatus(enabled);
			
			function isSensorEnabled():Boolean
			{
				if ( p.getStructure()[1] == 1 )
					return true;
				return false;
			}
			function isHistoryEnabled():Boolean
			{
				var a:Array = p.getStructure();
				for(var i:int=0; i<32; ++i) {
					for(var k:int=0; k<8; ++k) {
						if(i*8+k == PARAM_AKB)
							return Boolean((a[i] & (1 << k)) > 0 );
					}
				}
				return false;
			}
		}
		
		// Проверяет подключенную версию вояджера и возвраащет есть ли двигатель или нет
		public static function isEngine():Boolean
		{
			if ( CONST.PRESET_NUM == 2 || CONST.PRESET_NUM == 4)
				return true;
			return false;
		}
		public static function getHistoryDeleteTimeOut():int
		{
			return 60000;
		}
	}
}