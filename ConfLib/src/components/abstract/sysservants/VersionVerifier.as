package components.abstract.sysservants
{
	import components.abstract.functions.dtrace;
	import components.gui.PopUp;
	import components.protocol.statics.CLIENT;

	public class VersionVerifier
	{
		public var VER_FULL:String;
		public var HARDWARE_VER:String;
		public var READABLE_VER:String;
		public var VER_SOFTWARE:String;
		
		public var VERSION_MISMATCH:Boolean;
		
		public function verify(verinfo:Array, app:String, level:int, software:Object):void
		{
			var popup:PopUp = PopUp.getInstance();
			
			var fullversion:String = verinfo[0][1];//p.getStructure(1)[1];
			var releasever:String = "";
			VER_FULL = fullversion;
			var arr:Array = fullversion.split( "." );
			var ver:String="";
			if ( arr && arr[0] is String && arr[2] is String) {
				ver = arr[0];
				releasever = arr[2];
			}
			
			VER_SOFTWARE = verinfo[1][0];
			
			
			
			if (ver == app || CLIENT.SKIP_HARDWARE_VERSION_CHECK== 1) {
			
				
				if (verinfo.length == 1) {
					if( CLIENT.SKIP_LEVEL_CHECK != 1 ) {
						popup.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("sys_mismatch_update_device"), PopUp.BUTTON_OK );
						popup.open();
						VERSION_MISMATCH = true;
//	loadService();
						return;
					}
				} else {				
					if ( !passRelease(software, releasever) ) {
						var show:Boolean = true;
						if (CLIENT.SKIP_SOFTWARE_VERSION_CHECK == 1)
							show = false;
						
						
						if (show) {
							popup.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("sys_client_ver_mismatch"), PopUp.BUTTON_OK );
							popup.open();
						}
					}
				}
			} else {
				popup.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("sys_device_not_recognized"), PopUp.BUTTON_OK );
				VERSION_MISMATCH = true;
				popup.open();
//loadService();
				return;
			}
		}
		private function passRelease(target:Object, releasever:String):Boolean
		{
			if (target is Boolean)
				return target;
			var r:String = String(target);
			
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
	}
}