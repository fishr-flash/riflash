package components.abstract.servants
{
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;

	public class RPartServant
	{
		private static var inst:RPartServant;
		public static function access():RPartServant
		{
			if(!inst)
				inst = new RPartServant;
			return inst;
		}
		public function active():Boolean
		{
			var a:Array = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
			return a is Array;
		}
		public function isFire(value:Object):Boolean
		{
			var num:int = int(value);
			var a:Array;
			if (DS.isfam( DS.K5 )) {
				a = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
				if (a && a[num-1])
					return (a[num-1][5] > 0);
				return false;
			} else if (DS.isfam(DS.K9)) {
				a = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
				if (a && a[num-1])
					return (a[num-1][5] > 0);
				return false;
			}
			return false;
		}
		public function isUtility(value:Object):Boolean
		{
			var num:int = int(value);
			var a:Array;
			if (DS.isfam( DS.K5 )) {
				a = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
				if (a && a[num-1])
					return (a[num-1][4] > 0 || a[num-1][5] > 0);
				return false;
			} else if (DS.isfam(DS.K9)) {
				a = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
				if (a && a[num-1])
					return (a[num-1][4] > 0 || a[num-1][5] > 0);
				return false;
			}
			return false;
		}
		public function getExitDelay(arrayindex:Object):int
		{	
			var num:int = int(arrayindex);
			var a:Array = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
			if (a && a[num])
				return a[num][6];
			return 999;
		}
	}
}