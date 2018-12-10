package foundation.functions
{
	import components.abstract.LOC;
	import components.abstract.Warning;
	import components.abstract.functions.dtrace;
	import components.gui.PopUp;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.DS;
	import components.static.MISC;
	import components.system.CONST;
	
	import foundation.Founder;
	
	public function processVersion( p:Package ):void
	{
		var founder:Founder = Founder.app;
		if ( !(p.error) ) {
			MISC.VERSION_MISMATCH = false;
			
			var popup:PopUp = PopUp.getInstance();
			popup.close();
			
			var fullversion:String = p.getStructure(1)[1];
			var releasever:String = "";
			SERVER.VER_FULL = fullversion;
			var arr:Array = fullversion.split( "." );
			var ver:String="";
			if ( arr && arr[0] is String && arr[2] is String) {
				ver = arr[0];
				releasever = arr[2];
			}
			
			if (!CONST.DEBUG) {	// отключаем дебаговые переменные
				CLIENT.AUTO_SELECT_PAGE = -1;
				CLIENT.HISTORY_LINES_PER_PAGE = 20;
				CLIENT.DELETE_HISTORY = 1;
			}
			
			SERVER.VER_SOFTWARE = p.getStructure(2)[0];
			
			dtrace( "SERVER.VER_FULL <b>" + SERVER.VER_FULL+"</b>"+ " CLIENT_TARGET_DEVICE <b>"+CONST.VERSION+"</b>" );
			dtrace( "SERVER.VER_SOFTWARE<b> " + SERVER.VER_SOFTWARE+"</b>" );
			
			var param:Object = {
				"SERVER.VER_FULL":SERVER.VER_FULL,
				"SERVER.VER_SOFTWARE":SERVER.VER_SOFTWARE,
				"CONST.RELEASE_VER":CONST.RELEASE
			}
				
			var pass:Boolean = true;
			if ( isValidVersion(ver) || CLIENT.SKIP_HARDWARE_VERSION_CHECK== 1) {
				
				SERVER.VER = CONST.VERSION;
				SERVER.HARDWARE_VER = arr[1];
				SERVER.READABLE_VER = p.getStructure(1)[0];
				CONST.initHardwareConst();
				
				param["SERVER.VER"] = SERVER.VER;
				param["SERVER.HARDWARE_VER"] = SERVER.HARDWARE_VER;
				param["SERVER.READABLE_VER"] = SERVER.READABLE_VER;
				
				if ( passLocalRules() || CLIENT.SKIP_LEVEL_CHECK == 1) {
					
					founder.menu( getMenu() );
					
					// не попал по релизу, возникает предупреждение
					if ( !passRelease() ) {
						var show:Boolean = true;
						if (CLIENT.SKIP_SOFTWARE_VERSION_CHECK == 1)
							show = false;
						else
							pass = !CONST.STRICT;
						
						if (show) {
							popup.construct( PopUp.wrapHeader(LOC.loc("sys_attention")), PopUp.wrapMessage(LOC.loc("sys_client_ver_mismatch")), PopUp.BUTTON_OK );
							popup.open();
						}
					}
				} else
					pass = false;
			} else
				pass = false;
			
			if (pass) {
				Warning.show( LOC.loc("sys_connected")+" "+DS.name+" (" + fullversion+")", Warning.TYPE_SUCCESS, Warning.STATUS_DEVICE );
				founder.load();
			} else {
				load();
			}
		}
		
		function passRelease():Boolean
		{
			if (CONST.RELEASE is Boolean)
				return Boolean(CONST.RELEASE);
			
			var r:String = String(CONST.RELEASE);
			if ( r.length > 3 ) {
				var rd:int = int(r.slice(0,3));
				var ru:int = int(r.slice(4,7));
				if ( rd <= int(releasever) && ru >= int(releasever) )
 					return true;
				dtrace( "process version error: server.release out of range " +releasever + " ("+r+")" );
			} else {
				if ( int(releasever) == int(r))
					return true;
				dtrace( "process version error: client.release " + r+ " != server.release "+ releasever );
			}
			return false;
		}
		function load(onlyservice:Boolean=false):void
		{
			MISC.VERSION_MISMATCH = true;
			founder.menu(CONST.MENU_UNDEFINED);
			RequestAssembler.getInstance().clearStackLater();
			
			popup.construct( PopUp.wrapHeader(LOC.loc("sys_attention")), PopUp.wrapMessage(LOC.loc("sys_device_not_recognized")), PopUp.BUTTON_OK );
			popup.open();
			Warning.show( LOC.loc("sys_connected_unknown_device")+ " (" + fullversion +")", Warning.TYPE_SUCCESS, Warning.STATUS_DEVICE );
			
			founder.initMenuSelection();
		}
		function isValidVersion(v:String):Boolean
		{
			var a:Array = CONST.VERSION.split("_and_");
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if (v == a[i])
					return true;
			}
			return false;
		}
	}
}