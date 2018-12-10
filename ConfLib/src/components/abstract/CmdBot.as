package components.abstract
{
	import components.interfaces.ICommandOperator;

	public class CmdBot implements ICommandOperator
	{
		public function after(cmd:int, f:Function):Object
		{
			return null;
		}
	}
}