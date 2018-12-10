package components.abstract
{
	import flash.events.Event;
	
	import components.abstract.basement.ValidationBot;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IValidator;

	public class TimeValidationBot extends ValidationBot implements IValidator
	{
		public static const DAYS:int=0;
		public static const HOURS:int=1;
		public static const MINUTES:int=2;
		
		private var fields:Vector.<Item>;
		public var minTime:int;
		private var _valid:Boolean;
		private var init:Boolean = false;
		private var counter:int;
		/** Минимальное значние в минутах */
		public function TimeValidationBot(min:int)
		{
			minTime = min;
			super();
		}
		public function add(f:FormEmpty, type:int):void
		{	// добавить тип содержащегося времени и поле в которм это время содержится
			f.vbot = this;
			f.addEventListener( Event.CHANGE, onChange );
			if (!fields)
				fields = new Vector.<Item>;
			fields.push( new Item(f,type));
		}
		override public function isValid(f:FormEmpty):Boolean
		{
			validate();
			return _valid;
		}
		override public function added():void
		{
			counter++;
			if (counter == fields.length && !init) {
				init = true;
				var len:int = fields.length;
				for (var i:int=0; i<len; ++i) {
					fields[i].validate();
				}
			}
		}
		override public function reset():void
		{
			counter = 0;
			init = false;
		}
		private function onChange(e:Event):void
		{
			validate();
			
			var len:int = fields.length;
			for (var i:int=0; i<len; ++i) {
				//fields[i].valid = _valid;
				fields[i].validate();
			}
		}
		private function validate():void
		{
			var len:int = fields.length;
			var value:int = 0;
			_valid = false;
			if ( isEveryFieldFilled() ) {
				for (var i:int=0; i<len; ++i) {
					value += fields[i].getMinutes();
					if (value >= minTime) {
						_valid = true;
						break;
					}
				}
			} else
				_valid = true;
		}
		private function isEveryFieldFilled():Boolean
		{	//	проверка все ли поля уже заполнены, чтобы невалидное поле не выкидывало сохранялку
			var len:int = fields.length;
			for (var i:int=0; i<len; ++i) {
				if (fields[i].blank())
					return false;
			}
			return true;
		}
	}
}
import components.abstract.TimeValidationBot;
import components.gui.fields.FormEmpty;

class Item 
{
	private var field:FormEmpty;
	private var type:int;
	
	public function Item(f:FormEmpty, t:int)
	{
		field = f;
		type = t;
	}
	public function getMinutes():int
	{
		var value:int = int(field.getCellInfo());
		switch(type) {
			case TimeValidationBot.DAYS:
				value *= 24;
			case TimeValidationBot.HOURS:
				value *= 60;
		}
		return value;
	}
	
	public function validate():void
	{
		field.isValid();
	}
	public function blank():Boolean
	{
		return field.blank;
	}
	/*public function set valid(b:Boolean):void
	{
		if (b) {
			field.isValid();
		} else
			field.valid = false;
	}*/
	public function isEqual(f:FormEmpty):Boolean
	{
		return Boolean(field == f);
	}
}