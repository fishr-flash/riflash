package foundation.functions
{
	import components.abstract.LogWidget;
	import components.abstract.StateWidget;
	import components.abstract.servants.AutoUpdateNinja;
	import components.static.DS;

	// Voyager
	public function launchServices():void
	{
		AutoUpdateNinja.access().getList();
		
		
		if (DS.isDevice(DS.RDK)) {
			LogWidget.access().init();
			StateWidget.access().init();
		}
	}
}