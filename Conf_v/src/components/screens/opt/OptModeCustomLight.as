package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.TimeZoneAdapter;
	import components.abstract.functions.loc;
	import components.interfaces.IDataAdapter;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class OptModeCustomLight extends OptModeRoot
	{
		private var sched1:OptEnergyScheduleLight;
		private var sched2:OptEnergyScheduleLight;
		private var sched3:OptEnergyScheduleLight;
		private var sched4:OptEnergyScheduleLight;
		
		public function OptModeCustomLight(s:int)
		{
			super(s);
			
			var isEven:Boolean = UTIL.isEven(s);
			var xplace:int = 400;
			var fieldShift:int = 180;
			var a:IDataAdapter = new TimeZoneAdapter;
			
			sched1 = new OptEnergyScheduleLight(isEven?"":loc("vem_schedule")+" 1", getStructure(), fieldShift, xplace, a);
			addChild( sched1 );
			sched1.x = globalX;
			sched1.y = globalY;
			globalY += 33;
			sched1.addEventListener( Event.CHANGE, onShedChange );
			
			sched2 = new OptEnergyScheduleLight(isEven?"":loc("vem_schedule")+" 2", getStructure()+ 12, fieldShift, xplace, a);
			addChild( sched2 );
			sched2.x = globalX;
			sched2.y = globalY;
			globalY += 33;
			sched2.addEventListener( Event.CHANGE, onShedChange );
			
			sched3 = new OptEnergyScheduleLight(isEven?"":loc("vem_schedule")+" 3", getStructure() + 24, fieldShift, xplace, a);
			addChild( sched3 );
			sched3.x = globalX;
			sched3.y = globalY;
			globalY += 33;
			sched3.addEventListener( Event.CHANGE, onShedChange );
			
			sched4 = new OptEnergyScheduleLight(isEven?"":loc("vem_schedule")+" 4", getStructure() + 36, fieldShift, xplace, a);
			addChild( sched4 );
			sched4.x = globalX;
			sched4.y = globalY;
			globalY += 50;
			sched4.addEventListener( Event.CHANGE, onShedChange );
			
			this.complexHeight = globalY;
		}
		override public function putAssemblege(a:Array):void
		{
			LOADING = true;
			
			var re01:Array = [new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),new RegExp(/[01]/),re_hours,re_minutes];
			var re012:Array = [new RegExp(/[012]/),re_hours,re_minutes];
			var re034:Array = [new RegExp(/[034]/),re_hours,re_minutes];
			
			compare(CMD.VR_WORKMODE_SET, a );
			
			compare(CMD.VR_WORKMODE_ENGINE_START, a );
			compare(CMD.VR_WORKMODE_ENGINE_RUNS, a );
			compare(CMD.VR_WORKMODE_ENGINE_STOP, a );
			
			compare(CMD.VR_WORKMODE_START, a );
			compare(CMD.VR_WORKMODE_MOVE, a );
			compare(CMD.VR_WORKMODE_STOP, a );
			compare(CMD.VR_WORKMODE_PARK, a );
			
			compare(CMD.VR_WORKMODE_REGULAR, a );
			
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID);
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID+12);
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID+24);
			compareSoft(CMD.VR_WORKMODE_SCHEDULE, a, re01, structureID+36);
			
			sched1.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1] );
			sched2.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1+12] );
			sched3.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1+24] );
			sched4.putRawData( a[CMD.VR_WORKMODE_SCHEDULE][structureID-1+36] );
			
			LOADING = false;
		}
		override public function adaptTimeZone(obj:Object):void
		{
			
			
			switch(obj.struct) {
				case sched1.getStructure():
					sched1.adaptTimeZoneLight(obj);
					break;
				case sched2.getStructure():
					sched1.adaptTimeZoneLight(obj);
					break;
				case sched3.getStructure():
					sched1.adaptTimeZoneLight(obj);
					break;
				case sched4.getStructure():
					sched1.adaptTimeZoneLight(obj);
					break;
			}
		}
		private function onShedChange(e:Event):void
		{
			this.dispatchEvent( new Event( Event.CHANGE));
		}
		public function dispatchChange():void
		{
			sched1.dispatchChange();
			sched2.dispatchChange();
			sched3.dispatchChange();
			sched4.dispatchChange();
		}
	}
}