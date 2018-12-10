package components.abstract.functions
{
	import components.gui.DevConsole;

	public function dtrace(msg:String):void
	{
		trace(msg);
		DevConsole.write( msg, DevConsole.ERROR );
	}	
}