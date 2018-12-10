package foundation.functions
{
	import components.abstract.functions.dtrace;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.system.CONST;
	
	import foundation.Founder;

	public function loadSystemCommands( p:Package ):void
	{
		var value:String = String(p.getStructure()[0]);
		var a:Array = String(p.getStructure()[0]).split(" ");
		for (var i:int=0; i<3; i++) {
			var sa:String = (a[i] as String).slice(3,6);
			var sb:String = (a[i] as String).slice(1,3) + (a[i] as String).slice(6);
			if (sb != "0000") {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.OP_z_ZONES,null, i+1, ["00"+sa+"00"] ) );
			}
		}
		
		dtrace( "SERVER.VER_FULL <b>" + SERVER.VER_FULL+"</b>"+ " CLIENT_TARGET_DEVICE <b>"+CONST.VERSION+"</b>" );
		
		var founder:Founder = Founder.app;
		founder.menu( getMenu() );
		founder.load();
	}
}