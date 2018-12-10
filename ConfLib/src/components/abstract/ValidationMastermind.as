package components.abstract
{
	import components.interfaces.IValidator;

	public class ValidationMastermind
	{
		// Объект контролирующий всех ботов валидации, нужен для сброса накопленной информации ботами, при уходе со страницы
		
		private static var validators:Vector.<IValidator>;
		public static function add(v:IValidator):void
		{
			if (!validators)
				validators = new Vector.<IValidator>;
			var len:int = validators.length;
			for (var i:int=0; i<len; ++i) {
				if (validators[i] == i)
					return;
			}
			validators.push( v );
		}
		public static function reset():void
		{
			if (validators) {
				var len:int = validators.length;
				for (var i:int=0; i<len; ++i) {
					validators[i].reset();
				}
			}
		}
	}
}