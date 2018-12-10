package foundation.functions
{
	import components.abstract.Warning;
	import components.abstract.functions.dtrace;
	import components.abstract.resources.RES;
	import components.gui.PopUp;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.COLOR;
	import components.static.MISC;
	import components.system.CONST;
	import components.system.UTIL;
	
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
			
			if (!CONST.DEBUG)
				CLIENT.AUTO_SELECT_PAGE = -1;
			
			var tdevice:String = "";
			if (p.length > 1) {
				SERVER.VER_SOFTWARE = p.getStructure(2)[0];
				tdevice = releasever + "." + (p.getStructure(2)[0] as String).slice(0,3);
				//tdevice = (p.getStructure(2)[0] as String).slice(0,7);
				var fl:Array = (p.getStructure(2)[1] as String).split(".");
				if (fl && fl[0] is String)
					SERVER.VER_LEVEL = int(fl[0]);
			} else {	// если структура одна, номер релизной прошивки прибора nnn.nnn.RRR становиться уровнем клиента
				SERVER.VER_LEVEL = arr[2];
				tdevice = "";
			}
			
			dtrace( "SERVER.VER " + SERVER.VER );
			dtrace( "SERVER.VER_FULL <b>" + SERVER.VER_FULL+"</b>"+ " CLIENT_TARGET_DEVICE <b>"+CONST.VERSION+"</b>" );
			dtrace( "SERVER.VER_SOFTWARE<b> " + SERVER.VER_SOFTWARE+"</b>" );
			dtrace( "SERVER.VER_LEVEL <b>" + SERVER.VER_LEVEL+"</b>"+ " CLIENT_LEVEL <b>"+CONST.LEVEL+"</b>" );
			dtrace( "CALC VERSION<b> " + tdevice + "</b> CLIENT_TARGET <b>"+CONST.TARGET_SOFTWARE+"</b>" );
			
			var param:Object = {
				"SERVER.VER":SERVER.VER,
					"SERVER.VER_FULL":SERVER.VER_FULL,
					"SERVER.VER_LEVEL":SERVER.VER_LEVEL,
					"SERVER.VER_SOFTWARE":SERVER.VER_SOFTWARE,
					"CONST.TARGET_SOFTWARE":CONST.TARGET_SOFTWARE
			}
			if (ver == CONST.VERSION || CLIENT.SKIP_HARDWARE_VERSION_CHECK== 1) {
				
				SERVER.VER = CONST.VERSION;
				SERVER.HARDWARE_VER = arr[1];
				SERVER.READABLE_VER = arr[0];
				CONST.initHardwareConst();
				
				if (p.length == 1) {
					if( !isValidLevel(SERVER.VER_LEVEL) && CLIENT.SKIP_LEVEL_CHECK != 1 ) {
						popup.construct( PopUp.wrapHeader(RES.ATTENTION), PopUp.wrapMessage(RES.CLIENT_MSMATCH_UPDATESERVER), PopUp.BUTTON_OK );
						MISC.VERSION_MISMATCH = true;
						loadService();
						return;
					} else
						founder.menu(CONST.MENU);
				} else {				
					if (SERVER.VER_LEVEL == CONST.LEVEL || CLIENT.SKIP_LEVEL_CHECK == 1) {
						
						founder.menu(CONST.MENU);
						if (CONST.TARGET_SOFTWARE != tdevice ) {
							var show:Boolean = true;
							if (CLIENT.SKIP_SOFTWARE_VERSION_CHECK == 1)
								show = false;
							
							if (show) {
								popup.construct( PopUp.wrapHeader(RES.ATTENTION), PopUp.wrapMessage(RES.CLIENT_VER_MISMATCH), PopUp.BUTTON_OK );
								popup.open();
							}
						}
					} else {
						if (SERVER.VER_LEVEL < CONST.LEVEL)
							popup.construct( PopUp.wrapHeader(RES.ATTENTION), PopUp.wrapMessage(RES.CLIENT_MSMATCH_UPDATESERVER), PopUp.BUTTON_OK );
						else
							popup.construct( PopUp.wrapHeader(RES.ATTENTION), PopUp.wrapMessage(RES.CLIENT_MSMATCH_UPDATECLIENT), PopUp.BUTTON_OK );
						MISC.VERSION_MISMATCH = true;
						loadService();
						return;
					}
				}
			} else {
				popup.construct( PopUp.wrapHeader(RES.ATTENTION), PopUp.wrapMessage(RES.SERVER_VER_NOT_RECOGNIZED), PopUp.BUTTON_OK );
				MISC.VERSION_MISMATCH = true;
				loadService();
				return;
			}
			Warning.show( RES.CONNECTED+" "+SERVER.READABLE_VER+" (" + fullversion+")", Warning.TYPE_SUCCESS, Warning.STATUS_DEVICE );
			founder.load();
			
			function isValidLevel(value:int):Boolean
			{
				var params:Object = {
					"CONST.TARGET_SOFTWARE":CONST.TARGET_SOFTWARE
				}
				
				
				if (CONST.TARGET_SOFTWARE is String)
					return CONST.TARGET_SOFTWARE == value;
				if (CONST.TARGET_SOFTWARE is Array) {
					var len:int = (CONST.TARGET_SOFTWARE as Array).length;
					for (var i:int=0; i<len; ++i) {
						if( int((CONST.TARGET_SOFTWARE as Array)[i]) == value )
							return true;
					}
				}
				return false;
			}
			function loadService():void
			{
				popup.open();
				
				founder.menu(CONST.MENU_UNDEFINED);
				RequestAssembler.getInstance().clearStackLater();
				
				SERVER.VER = RES.UNDEFINED;
				SERVER.READABLE_VER = RES.UNKNOWN_SERVER;
				Warning.show( RES.CONNECTED_TO_UNKNOWN_SERVER+ " (" + fullversion +")", Warning.TYPE_SUCCESS, Warning.STATUS_DEVICE );
				founder.initMenuSelection();
			}
		}
	}
}