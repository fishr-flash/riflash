package components.abstract.gearboxes
{
	public class HistoryBox
	{
		private static var inst:HistoryBox;
		public static function access():HistoryBox
		{
			if(!inst)
				inst = new HistoryBox;
			return inst;
		}
		
		public const HIS_CMD_BLOCK_SIZE_BYTE:int=128;
		public var HIS_LAST_INDEX_N1:uint;
		public var HIS_FIRST_INDEX_N2:Number;
		public var HIS_BLOCK_SIZE_BYTE:int;
		public var HIST_INDEX_IN_FIRST_BLOCK:int; 
	}
}