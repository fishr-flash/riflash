package components.abstract.servants
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;

	public class UniqueValidator
	{
		public var disabled:Boolean = false;
		
		private var fields:Vector.<IFormString>;
		private var except:Vector.<Object>;
		
		public function UniqueValidator()
		{
			fields = new Vector.<IFormString>;
			except = new Vector.<Object>;
		}
		public function register(f:IFormString):void
		{
			var unique:Boolean = true;
			var len:int = fields.length;
			for (var i:int=0; i<len; i++) {
				if (f == fields[i]) {
					unique = false;
					break;
				}
			}
			if (unique) {
				fields.push( f );
				(f as EventDispatcher).addEventListener(Event.CHANGE,validate);
			}
		}
		public function registerException(o:Object):void
		{	//	 можно добавить любое число которе будет запрещено к вводу
			var unique:Boolean = true;
			var len:int = except.length;
			for (var i:int=0; i<len; i++) {
				if (o == except[i]) {
					unique = false;
					break;
				}
			}
			if (unique)
				except.push( o );
		}
		public function clearExceptions():void
		{
			except.length = 0;
		}
		public function isValid(o:Object):Boolean
		{	// проверить валидно ли число
			if (disabled)
				return true;
			
			var len:int = fields.length;
			for (var i:int=0; i<len; i++) {
				if( fields[i].getCellInfo() == o )
					return false;
			}
			len = except.length;
			for (i=0; i<len; i++) {
				if (except[i] == o) {
					return false;
				}
			}
			return true;
		}
		public function unregister(f:IFormString):void
		{
			var len:int = fields.length;
			for (var i:int=0; i<len; i++) {
				if (f == fields[i]) {
					(f as EventDispatcher).removeEventListener(Event.CHANGE,validate);
					fields.splice(i,1);
					break;
				}
			}
		}
		public function clear():void
		{
			var len:int = fields.length;
			for (var i:int=0; i<len; i++) {
				(fields[i] as EventDispatcher).removeEventListener(Event.CHANGE,validate);
			}
			fields.length = 0;
		}
		public function revalidate():void
		{
			validate(null);
		}
		private function validate(e:Event):void
		{
			if (disabled)
				return;
			
			var len:int = fields.length;
			for (var i:int=0; i<len; i++) {
				if( !foundClone(i) ) {
					(fields[i] as FormString).forceValid = 0;
					fields[i].isValid();
				}
			}
		}
		private function foundClone(n:int):Boolean
		{
			var len:int = fields.length;
			for (var i:int=0; i<len; i++) {
				if( n != i ) {
					if( fields[n].getCellInfo() == fields[i].getCellInfo() ) {
						(fields[n] as FormString).forceValid = 2;
						(fields[i] as FormString).forceValid = 2;
						(fields[n] as FormString).isValid();
						(fields[i] as FormString).isValid();
						//trace( fields[n].getCellInfo() + " = " + fields[i].getCellInfo() );
						return true;
					}
				}
			}
			len = except.length;
			for (i=0; i<len; i++) {
				if (except[i] == fields[n].getCellInfo()) {
					(fields[n] as FormString).forceValid = 2;
					(fields[n] as FormString).isValid();
					//trace(" invalid single " + OPERATOR.getSchema(fields[n].cmd).Name + fields[n].param )
					return true;
				}
			}
			return false;
		}
	}
}