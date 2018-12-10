package foundation.functions
{
	import components.abstract.servants.AutoUpdateNinja;

	// K14
	public function launchServices():void
	{
		AutoUpdateNinja.access().getList();
		
		
	}
}