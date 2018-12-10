package components.resources
{
	import components.static.CMD;
	import components.system.CONST;

	public class EnergyModeDefaults
	{
		private static var defaults:Object;
		private static var defaultsV2:Object;
		private static var defaultsV5:Object;
		private static var defaultsV6:Object;
		
		public static function getData(cmd:int, struc:int):Array
		{
			if (!defaults) {
				
				var s:int = 0;
				var o:Object;
				init();
				
				/** РЕЖИМ 1	*** V2, V3, V4, V5, V6 	*******************/
				
				s = 1;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [4,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 2;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [4,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 2	* Онлайн в движении ** V2, V4 *******************/
				
				s = 3;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [4,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 4;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [4,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 3	* Онлайн с энергосбережением **	V4 *******************/
				
				s = 5;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [4,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 6;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,3,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 4	*** 					V4 ****************/		
				
				s = 7;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [4,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 8;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,1,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];		
				
				/** РЕЖИМ 5	* МАЯК ** V2, V3, V4, V5, V6 	*******************/	
				
				s = 9;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,3,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 10;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,1,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 6	*** V2, V4	*******************/	
				
				s = 11;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [2,0,10];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [3,0,10];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [2,0,10];
				
				o[CMD.VR_WORKMODE_START][s] = [2,0,10];
				o[CMD.VR_WORKMODE_MOVE][s] = [3,0,10];
				o[CMD.VR_WORKMODE_STOP][s] = [2,0,10];
				o[CMD.VR_WORKMODE_PARK][s] = [3,1,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,3,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 12;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [2,0,10];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [3,0,10];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [2,0,10];
				
				o[CMD.VR_WORKMODE_START][s] = [2,0,10];
				o[CMD.VR_WORKMODE_MOVE][s] = [3,0,10];
				o[CMD.VR_WORKMODE_STOP][s] = [2,0,10];
				o[CMD.VR_WORKMODE_PARK][s] = [3,1,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,8,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				defaults = o;
/** V2	***************************************************************************/
				/** РЕЖИМ 2	* Онлайн в движении ** V2		 	*******************/
				
				init();
				
				s = 3;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [4,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 4;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [4,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				
				/** РЕЖИМ 3	* Онлайн с энергосбережением **	V2 *******************/
				
				s = 5;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [4,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 6;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [4,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				defaultsV2 = o;
				
/** V5	***************************************************************************/
				/** РЕЖИМ 2	* Онлайн в движении ** V3, V5, V6 	*******************/
				
				// 0 – нет, 1 – однократно, 2 – однократно через;
				// 0 – нет, 3 – регулярно с интервалом, 4 – постоянно;
				
				init();
				
				s = 3;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 4;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 3	* Онлайн с энергосбережением ** V3, V5, V6 	*******************/
				
				s = 5;
				
				// 0 – нет, 1 – однократно, 2 – однократно через;
				// 0 – нет, 3 – регулярно с интервалом, 4 – постоянно;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 6;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,3,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/*o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];*/
				
				/** РЕЖИМ 4	* ГРУЗ ** V5					*******************/
				
				// 0 – нет, 1 – однократно, 2 – однократно через;
				// 0 – нет, 3 – регулярно с интервалом, 4 – постоянно;
				
				s = 7;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [1,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [1,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,1,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 8;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [1,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [1,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,1,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 5	* МАЯК ** V5					*******************/	
				
				s = 9;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,1,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 10;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,1,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 6	* Собственный ** V3, V5, V6 	*******************/	
				
				s = 11;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [2,0,10];
				o[CMD.VR_WORKMODE_MOVE][s] = [3,0,10];
				o[CMD.VR_WORKMODE_STOP][s] = [2,0,10];
				o[CMD.VR_WORKMODE_PARK][s] = [3,1,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,3,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 12;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [2,0,10];
				o[CMD.VR_WORKMODE_MOVE][s] = [3,0,10];
				o[CMD.VR_WORKMODE_STOP][s] = [2,0,10];
				o[CMD.VR_WORKMODE_PARK][s] = [3,1,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,8,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				defaultsV5 = o;
				
/** V6	***********************************************************************/
				/** Онлайн с энергосбережением */
				
				init();
				
				s = 3;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 4;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [4,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** Онлайн в движении **/
				
				s = 5;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 6;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 4	*** Офлайн V3, V5, V6			****************/		
				
				s = 7;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [4,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [0,0,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 8;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,3,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				/** РЕЖИМ 5	* МАЯК ** V2, V3, V4, V5, V6 	*******************/	
				
				s = 9;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,0,3,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				s = 10;
				
				o[CMD.VR_WORKMODE_SET][s] = [0];
				
				o[CMD.VR_WORKMODE_ENGINE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_RUNS][s] = [0,0,0];
				o[CMD.VR_WORKMODE_ENGINE_STOP][s] = [0,0,0];
				
				o[CMD.VR_WORKMODE_START][s] = [0,0,0];
				o[CMD.VR_WORKMODE_MOVE][s] = [0,0,0];
				o[CMD.VR_WORKMODE_STOP][s] = [0,0,0];
				o[CMD.VR_WORKMODE_PARK][s] = [0,0,0];
				o[CMD.VR_WORKMODE_REGULAR][s] = [3,1,0,0];
				
				o[CMD.VR_WORKMODE_SCHEDULE][s] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+12] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+24] = [0,0,0,0,0,0,0,0,0];
				o[CMD.VR_WORKMODE_SCHEDULE][s+36] = [0,0,0,0,0,0,0,0,0];
				
				defaultsV6 = o;
			}
			
			var a:Array;
			
			switch(CONST.PRESET_NUM) {
				case 1:
				case 2:
					if (defaultsV2[cmd] && defaultsV2[cmd][struc])
						a = defaultsV2[cmd][struc];
					break;
				case 4:
					break;
				case 5:
					if (defaultsV5[cmd] && defaultsV5[cmd][struc])
						a = defaultsV5[cmd][struc];
					break;
				case 3:
				case 6:
					if (defaultsV6[cmd] && defaultsV6[cmd][struc]) {
						a = defaultsV6[cmd][struc];
						break;
					}
					if (defaultsV5[cmd] && defaultsV5[cmd][struc])
						a = defaultsV5[cmd][struc];
					break;
			}
			if (!a)
				return defaults[cmd][struc];	
			return a;
			
			function init():void
			{
				o = new Object;
				o[CMD.VR_WORKMODE_SET] = [];
				o[CMD.VR_WORKMODE_ENGINE_START] = [];
				o[CMD.VR_WORKMODE_ENGINE_RUNS] = [];
				o[CMD.VR_WORKMODE_ENGINE_STOP] = [];
				o[CMD.VR_WORKMODE_START] = [];
				o[CMD.VR_WORKMODE_MOVE] = [];
				o[CMD.VR_WORKMODE_STOP] = [];
				o[CMD.VR_WORKMODE_PARK] = [];
				o[CMD.VR_WORKMODE_REGULAR] = [];
				o[CMD.VR_WORKMODE_SCHEDULE] = [];
			}
		}
	}
}