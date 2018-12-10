package foundation.functions
{
	import components.abstract.servants.AutoUpdateNinja;
	import components.abstract.servants.AutoUpdateNinjaBottom;
	import components.protocol.statics.SERVER;

	// K16
	public function launchServices():void
	{
		//DualUpdateNinja.access().getList();
		AutoUpdateNinja.access().getList();
		if (SERVER.DUAL_DEVICE)
			AutoUpdateNinjaBottom.access().getList();
	}
}