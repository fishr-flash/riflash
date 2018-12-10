package components.abstract
{
	import components.abstract.functions.loc;
	import components.static.COLOR;
	
	import su.fishr.utils.searcPropValueInArr;

	public class LR_AL_KEY_STATES
	{
		public static const IDLE:int = -1;
		public static const NO_ADD:int = 0;
		public static const ADDING:int = 1;
		public static const ADDED_SUCCESS:int = 2;
		public static const ADDRESS_BUSY:int = 3;
		public static const ADD_FAIL:int = 4;
		public static const DELETE_SUCCESS:int = 5;
		public static const DELETE_FAIL:int = 6;
		public static const RESTORE_SUCCESS:int = 7;
		public static const RESTORE_FAIL:int = 8;
		public static const OPERATION_BREAK:int = 9;
		public static const CREATE_AT_BUTTON:int = 10;
		public static const RECREATE_AT_BUTTON:int = 11;
		
		private static var last_state:int;
		
		private static const STATES_LINE:Array =
			[
				{ code:0, state_loc:"rfd_no_add", color: COLOR.RED_DARK},
				{ code:1, state_loc:"g_adding", color:COLOR.CIAN },
				{ code:2, state_loc:"rfd_added_success", color:COLOR.CIAN},
				{ code:3, state_loc:"rfd_address_busy", color:COLOR.RED_DARK },
				{ code:4, state_loc:"rfd_add_fail", color:COLOR.RED_DARK },
				{ code:5, state_loc:"rfd_delete_success", color:COLOR.RED_DARK },
				{ code:6, state_loc:"rfd_delete_fail", color:COLOR.RED_DARK },
				{ code:7, state_loc:"rfd_restore_success", color:COLOR.CIAN },
				{ code:8, state_loc:"rfd_restore_fail", color:COLOR.RED_DARK },
				{ code:9, state_loc:"add_cancelled", color:COLOR.RED_DARK },
				{ code:10, state_loc:"create_at_button", color:COLOR.RED_DARK },
				{ code:11, state_loc:"recreate_at_button", color:COLOR.CIAN }
				
			];
		
		public static function getLoc( value:int ):String
		{
			if( value == LR_AL_KEY_STATES.IDLE ) return "";
			
			const index:int = searcPropValueInArr( "code", value, LR_AL_KEY_STATES.STATES_LINE );
			
			return loc( LR_AL_KEY_STATES.STATES_LINE[ index ].state_loc );
				
		}
		
		
		public static function getColor( value:int ):int
		{
			if( value == LR_AL_KEY_STATES.IDLE ) return 0;
			
			const index:int = searcPropValueInArr( "code", value, LR_AL_KEY_STATES.STATES_LINE );
			return LR_AL_KEY_STATES.STATES_LINE[ index ].color;
		}
		
		
	}
}