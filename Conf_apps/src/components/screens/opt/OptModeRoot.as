package components.screens.opt
{
	import components.basement.OptionsBlock;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.resources.EnergyModeDefaults;
	import components.static.CMD;
	
	public class OptModeRoot extends OptionsBlock
	{
		protected var LOADING:Boolean = false;
		
		protected const re_start_stop:RegExp = /^(0|1|2)$/g;
		protected const re_move_park:RegExp = /^(0|3|4)$/g;
		protected const re_regular:RegExp = /^(0|3)$/g;
		protected const re_days:RegExp = /^(\d?\d)$/g;
		protected const re_hours:RegExp = /^(0?\d|[0-1]\d|2[0-3])$/g;
		protected const re_minutes:RegExp = /^([0-5]\d|0?\d)$/g;
		
		public function OptModeRoot(s:int)
		{
			super();
			structureID = s;
			
			globalFocusGroup = 100*s;
		}
		public function putAssemblege(a:Array):void
		{
			LOADING = true;
			
			compare(CMD.VR_WORKMODE_SET, a );
			
			compare(CMD.VR_WORKMODE_ENGINE_START, a);
			compare(CMD.VR_WORKMODE_ENGINE_RUNS, a);
			compare(CMD.VR_WORKMODE_ENGINE_STOP, a);
			
			compare(CMD.VR_WORKMODE_START, a);
			compare(CMD.VR_WORKMODE_MOVE, a );
			compare(CMD.VR_WORKMODE_STOP, a);
			compare(CMD.VR_WORKMODE_PARK, a );
			compare(CMD.VR_WORKMODE_REGULAR, a );
			
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID);
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID+12);
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID+24);
			compare(CMD.VR_WORKMODE_SCHEDULE, a ,structureID+36);
			
			LOADING = false;
		}
		public function rename(arg:Object):void {};
		public function adaptTimeZone(obj:Object):void {};
		/** Отсылает дефолты на прибор в случае несоответствия */
		protected function compare(cmd:int, dataCome:Array, s:int=0):void
		{
			// Если такой команды не существует - не надо сравнивать
			if( !dataCome[cmd] )
				return;
			
			var str:int = structureID;
			if (s>0)
				str = s;
			
			var dataShould:Array = EnergyModeDefaults.getData(cmd, str);
			
			var valid:Boolean = true;
			var len:int = dataShould.length;
			for (var i:int=0; i<len; ++i) {
				if( dataCome[cmd][str-1][i] != dataShould[i] ) {
					valid = false;
					break;
				}
			}
			if (!valid)
				RequestAssembler.getInstance().fireEvent( new Request(cmd,null,str,dataShould));
		}
		/** Подменяет дефолт и в исходном массиве и отсылает на прибор */
		protected function compareSoft(cmd:int, dataCome:Array, reg:Array, s:int=0):void
		{
			var str:int = structureID;
			if (s>0)
				str = s;
			
			var dataShould:Array = EnergyModeDefaults.getData(cmd, str);
			
			var txt:String;
			var target:Array = dataCome[cmd][str-1];
			
			var valid:Boolean = true;
			var len:int = reg.length;
			for (var i:int=0; i<len; ++i) {
				txt = String(dataCome[cmd][str-1][i]);
				if( txt.search( (reg[i] as RegExp) ) != 0 ) {
					valid = false;
					break;
				}
			}
			if (!valid) {
				dataCome[cmd][str-1] = dataShould;
				RequestAssembler.getInstance().fireEvent( new Request(cmd,null,str,dataShould));
			}
		}
	}
}