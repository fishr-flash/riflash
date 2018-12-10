package components.abstract.basement
{
	import components.abstract.ValidationMastermind;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IValidator;
	
	public class ValidationBot implements IValidator
	{
		public function ValidationBot()
		{
			ValidationMastermind.add(this);
		}
		
		public function isValid(f:FormEmpty):Boolean
		{
			return false;
		}
		
		public function added():void
		{
		}
		
		public function reset():void
		{
		}
	}
}