package components.abstract.functions
{
	import components.gui.DevConsole;
	
	public function bugtrace(msg:String):void
	{
		trace("BUGTRACE: "+msg);
		DevConsole.write( msg, DevConsole.BUG );
	}	
}