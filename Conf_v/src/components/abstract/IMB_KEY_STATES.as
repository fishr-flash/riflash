package components.abstract
{
	import components.abstract.functions.loc;
	import components.static.COLOR;
	
	import su.fishr.utils.searcPropValueInArr;

	public class IMB_KEY_STATES
	{
		
		
		public static const STATE_ON:int = -0x01;
		public static const ALL_CANCEL:int = 0x00;
		public static const SEARCH_UP:int = 0x01;
		public static const ON_SEARCH:int = 0x02;
		public static const KEY_FOUND:int = 0x03;
		public static const TIME_OUT:int = 0x04;
		public static const DOUBLE_DETECTED:int = 0x05;
		public static const TABLE_IS_FULL:int = 0x06;
		
		private static var last_state:int;
		
		private static const STATES_LINE:Array =
			[
				
				{ code: STATE_ON, state_loc:"saved", color: COLOR.CIAN},
				{ code: ALL_CANCEL, state_loc:"add_cancelled", color: COLOR.RED_DARK},
				{ code: SEARCH_UP, state_loc:"g_adding", color:COLOR.CIAN },
				{ code: ON_SEARCH, state_loc:"g_adding", color:COLOR.CIAN},
				{ code: KEY_FOUND, state_loc:"rfd_added_success", color:COLOR.CIAN },
				{ code: TIME_OUT, state_loc:"time_out", color:COLOR.RED_DARK },
				{ code: DOUBLE_DETECTED, state_loc:"key_doubled", color:COLOR.RED_DARK },
				{ code: TABLE_IS_FULL, state_loc:"rfd_add_fail", color:COLOR.RED_DARK }
				
				
			];
		
		public static function getLoc( value:int, some:String = "" ):String
		{
			
			const index:int = searcPropValueInArr( "code", value, IMB_KEY_STATES.STATES_LINE );
			
			return loc( IMB_KEY_STATES.STATES_LINE[ index ].state_loc ) + some;
				
		}
		
		
		public static function getColor( value:int ):int
		{
			
			const index:int = searcPropValueInArr( "code", value, IMB_KEY_STATES.STATES_LINE );
			return IMB_KEY_STATES.STATES_LINE[ index ].color;
		}
		
		
	}
}