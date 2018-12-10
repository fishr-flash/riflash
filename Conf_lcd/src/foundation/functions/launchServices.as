package foundation.functions
{
	import components.abstract.servants.AutoUpdateNinja;

	// Voyager
	public function launchServices():void
	{
		AutoUpdateNinja.access().getList();
	}
}