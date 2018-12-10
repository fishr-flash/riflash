package components.gui.fields
{
	import flash.events.MouseEvent;
	
	import components.gui.fields.lowlevel.MCalendar;
	import components.system.UTIL;
	
	public class FSDate extends FormString
	{
		private var calendar:MCalendar;
		
		public function FSDate()
		{
			super();
				
			tName.borderColor = 0x696969;
			tName.border = true;
			tName.selectable = false;
			
			calendar = new MCalendar;
		}
		override protected function configureListeners():void
		{
			super.configureListeners();
			tName.addEventListener(MouseEvent.CLICK, onClick );
		}
		private function onClick(e:MouseEvent):void
		{
			calendar.open(this, onSelect);
		}
		private function onSelect(d:Date):void
		{
			setCellInfo( dateToString(d) );
		}
		override public function setCellInfo(value:Object):void
		{
			var txt:String = "";
			if (value is String)
				txt = value as String;
			else if (value is Date) {
				txt = dateToString(value as Date);
				calendar.setDate(value as Date);
			}
			
			super.setCellInfo(txt);
		}
		override public function getCellInfo():Object
		{
			return calendar.getDate().time/1000;
		}
		private function dateToString(d:Date):String
		{
			return UTIL.fz(d.date,2) + "." + UTIL.fz(d.month+1,2) + "."+ d.fullYear + " " + UTIL.fz(d.hours,2)+ ":"+ UTIL.fz(d.minutes,2)+ ":"+ UTIL.fz(d.seconds,2);
		}
	}
}