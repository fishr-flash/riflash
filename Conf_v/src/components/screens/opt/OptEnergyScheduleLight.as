package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.VoyagerBot;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	import su.fishr.utils.Dumper;
	
	public class OptEnergyScheduleLight extends OptEnergySchedule
	{
		public function OptEnergyScheduleLight(label:String, s:int, shift:int, fshift:int, a:IDataAdapter=null)
		{
			super(label, s, shift, fshift, a);
		}
		
		public function adaptTimeZoneLight(value:Object ):void
		{
			
			
			 
			
			const fieldID:String = value.struct;
			
			const struct:int = int( fieldID ) / 4;
			var t:Object = value.data[operatingCMD][ fieldID ];
			var a:Array = []; 
			for (var key:String in t) {
				a[int(key)-1] = t[key];
			}
			
			
			var hour:int = a[7];
			const minInHour:int = 60;
			const diffMinutes:int = 10;
			
			if( value.gpsCorrect )
			{
				hour = ( ( a[ 7 ] * minInHour ) + a[ 8 ] + diffMinutes ) / minInHour; 
			}
			
			var day:int;
			
			if (hour + VoyagerBot.TIME_ZONE < 0) {
				day = a[6];
				a.splice( 6,1);
				a.splice(0,0,day);
			} else if (hour + VoyagerBot.TIME_ZONE > 23) {
				day = a[0];
				a.splice( 0,1);
				a.splice(6,0,day);
			}
			
			RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, null,int( fieldID ), a));
		}
	}
}