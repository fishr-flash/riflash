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
	
	public class OptEnergySchedule extends OptionsBlock
	{
		private var cshift:int;
		private var _disabled:Boolean;
		
		public function OptEnergySchedule(label:String,s:int, shift:int, fshift:int, a:IDataAdapter=null)
		{
			super();
			operatingCMD = CMD.VR_WORKMODE_SCHEDULE;
			structureID = s;
			globalFocusGroup = 500+100*s;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			cshift = shift;
			
//			FLAG_SAVABLE = false;
			createUIElement( new FSCheckBox, operatingCMD, label, call, 1 );
			attuneElement( shift );
			createUIElement( new FSCheckBox, operatingCMD, "", call, 2 ).x = placeX();
			attuneElement( 0 );
			createUIElement( new FSCheckBox, operatingCMD, "", call, 3 ).x = placeX();
			attuneElement( 0 );
			createUIElement( new FSCheckBox, operatingCMD, "", call, 4 ).x = placeX();
			attuneElement( 0 );
			createUIElement( new FSCheckBox, operatingCMD, "", call, 5 ).x = placeX();
			attuneElement( 0 );
			createUIElement( new FSCheckBox, operatingCMD, "", call, 6 ).x = placeX();
			attuneElement( 0 );
			createUIElement( new FSCheckBox, operatingCMD, "", call, 7 ).x = placeX();
			attuneElement( 0 );
		//	FLAG_SAVABLE = true;
			
//			createUIElement( new FSShadow, operatingCMD, "", null, 1 );
//			createUIElement( new FSShadow, operatingCMD, "", null, 2 );
//			createUIElement( new FSShadow, operatingCMD, "", null, 3 );
//			createUIElement( new FSShadow, operatingCMD, "", null, 4 );
//			createUIElement( new FSShadow, operatingCMD, "", null, 5 );
//			createUIElement( new FSShadow, operatingCMD, "", null, 6 );
//			createUIElement( new FSShadow, operatingCMD, "", null, 7 );
			
			
			createUIElement( new FormString, operatingCMD, "", call, 8, null, "0-9", 2, new RegExp(RegExpCollection.COMPLETE_HOURS) ).x = fshift;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			if (a) {
				getLastElement().setAdapter(a);	// доабвляет адаптер
				//VoyagerBot.add( getLastElement() );	// добавляет поле с адаптером в спец массив, для более удобного управления полями
			}
			createUIElement( new FormString, 0, loc("time_hour_s"), null, 8 ).x = fshift+32;
			attuneElement( 30, NaN, FormString.F_NOTSELECTABLE );

			createUIElement( new FormString, operatingCMD, "", call, 9, null, "0-9", 2, new RegExp(RegExpCollection.COMPLETE_MINUTES) ).x = fshift + 63;
			attuneElement( 30, NaN, FormString.F_EDITABLE );
			createUIElement( new FormString, 0, loc("time_min_s"), null, 9 ).x = fshift + 96;
			attuneElement( 30, NaN, FormString.F_NOTSELECTABLE );
			
			globalY += 15;
			cshift = shift;
			createUIElement( new FormString, 0, loc("date_mo_s"), null, 1 ).x = shift - 3;
			createUIElement( new FormString, 0, loc("date_tu_s"), null, 2 ).x = placeX() - 3;
			createUIElement( new FormString, 0, loc("date_we_s"), null, 3 ).x = placeX() - 3;
			createUIElement( new FormString, 0, loc("date_th_s"), null, 4 ).x = placeX() - 3;
			createUIElement( new FormString, 0, loc("date_fr_s"), null, 5 ).x = placeX() - 3;
			createUIElement( new FormString, 0, loc("date_sa_s"), null, 6 ).x = placeX() - 3;
			createUIElement( new FormString, 0, loc("date_su_s"), null, 7 ).x = placeX() - 3;
		}
		override public function putRawData(a:Array):void
		{
			
			var day:int;
			
			var adapted:Array = a.slice();
			if (a[7] + VoyagerBot.TIME_ZONE < 0) {
				day = adapted[0];
				adapted.splice( 0,1);
				adapted.splice(6,0,day);
				
			} else if (a[7] + VoyagerBot.TIME_ZONE > 23) {
				day = adapted[6];
				adapted.splice( 6,1);
				adapted.splice(0,0,day);
			}
			
			distribute( adapted, operatingCMD );
		}
		
		public function putSmart(a:Array):void
		{
			var valid:Boolean = true;
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if( getField( operatingCMD, i+1 ).getCellInfo() != a[0] ) {
					valid = false;
					break;
				}
			}
			if (!valid) {
				distribute( a, operatingCMD );
				remember( getField( operatingCMD, 1 ) );
			}
		}
		public function set disabled(b:Boolean):void
		{
			_disabled = b;
			
			getField( operatingCMD, 1 ).disabled = b;
			getField( operatingCMD, 2 ).disabled = b;
			getField( operatingCMD, 3 ).disabled = b;
			getField( operatingCMD, 4 ).disabled = b;
			getField( operatingCMD, 5 ).disabled = b;
			getField( operatingCMD, 6 ).disabled = b;
			getField( operatingCMD, 7 ).disabled = b;
			getField( operatingCMD, 8 ).disabled = b;
			getField( operatingCMD, 9 ).disabled = b;
			
			getField( 0, 1 ).disabled = b;
			getField( 0, 2 ).disabled = b;
			getField( 0, 3 ).disabled = b;
			getField( 0, 4 ).disabled = b;
			getField( 0, 5 ).disabled = b;
			getField( 0, 6 ).disabled = b;
			getField( 0, 7 ).disabled = b;
			getField( 0, 8 ).disabled = b;
			getField( 0, 9 ).disabled = b;
		}
		public function get disabled():Boolean
		{
			return _disabled;
		}
		
		public function adaptTimeZone(value:Object):void
		{
			
			var t:Object = value[operatingCMD][getStructure()];
			var a:Array = []; 
			for (var key:String in t) {
				a[int(key)-1] = t[key];
			}
			
			var hour:int = a[7];
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
			trace( a );
			RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, null, getStructure(), a));
		}
		public function dispatchChange():void
		{
			SavePerformer.remember( getStructure(), getField(operatingCMD,1) );
		}
		private function placeX():int
		{
			cshift += 25;
			return cshift;
		}
		private function call(t:IFormString):void
		{
			if ( t.valid )
				this.dispatchEvent( new Event(Event.CHANGE) );
			SavePerformer.remember( getStructure(), t );
		}
	}
}