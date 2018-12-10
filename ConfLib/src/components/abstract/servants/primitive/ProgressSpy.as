package components.abstract.servants.primitive
{
	public class ProgressSpy
	{
		private var delegate:Function;
		public function ProgressSpy(f:Function)
		{
			delegate = f;
		}
		public function report(param:Object):void
		{
			delegate(param);
		}
	}
}