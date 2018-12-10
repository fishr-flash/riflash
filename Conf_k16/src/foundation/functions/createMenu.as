package foundation.functions
{
	import components.system.CONST;
	
	import foundation.Founder;

	public function createMenu():void
	{
		CONST.initHardwareConst();
		
		var founder:Founder = Founder.app;
		founder.menu( getMenu() );
	}
}

