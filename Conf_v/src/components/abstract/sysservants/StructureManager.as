package components.abstract.sysservants
{
	import spark.primitives.Rect;
	
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;

	public class StructureManager
	{
		private static var inst:StructureManager;
		public static function access():StructureManager
		{
			if(!inst)
				inst = new StructureManager;
			return inst;
		}
		
		public function StructureManager()
		{
			
		}
		
		public function launch():void
		{
			var r:int = DS.release;
			switch(DS.alias) {
				case DS.V2:
					if (r >= 38 && !OPERATOR.getData(CMD.EGTS_CNT_STAT_COUNT) )
						RequestAssembler.getInstance().fireEvent(new Request(CMD.EGTS_CNT_STAT_COUNT, put ));
					break;
				default:
					break;
			}
		}
		private function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.EGTS_CNT_STAT_COUNT:
					OPERATOR.getSchema( CMD.EGTS_CNT_STAT_VALUE ).StructCount = p.getParamInt(1);
					break;
			}
		}
	}
}