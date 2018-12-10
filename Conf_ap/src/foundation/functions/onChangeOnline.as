package foundation.functions
{
	import components.abstract.Warning;
	import components.abstract.functions.loc;
	import components.abstract.servants.OnlineObserver;
	import components.abstract.servants.WatchDog;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.CONST;
	
	import foundation.Founder;
	
	public function onChangeOnline( ev:SystemEvents ):void
	{
		var founder:Founder = Founder.app;
		
		if ( ev.isConneted() ) {
			if ( !OPERATOR.schemaExist() )
				OPERATOR.installSchema( founder.cmdDefault );
			
			if (!CONST.DEBUG) {
				CLIENT.SKIP_HARDWARE_VERSION_CHECK = 0;
				CLIENT.SKIP_SOFTWARE_VERSION_CHECK = 0;
				CLIENT.SKIP_LEVEL_CHECK = 0;
			}
			
			founder.setPageLabel( loc("sys_select_page") );
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onFlag_WAIT_FOR_STATE, {"getFlagStatus":false} );
			SERVER.ADDRESS = SERVER.ADDRESS_TOP;
			
			if (SERVER.REMOTE_TOKEN != null && !SERVER.REMOTE_TOKEN_PASSED) {
				new OnlineObserver();
				RequestAssembler.getInstance().fireEvent( 
					new Request( CMD.SEND_SECURITY_TOKEN, requestVerInfo,0,[SERVER.REMOTE_TOKEN],Request.SYSTEM, Request.PARAM_NONE, SERVER.REMOTE_ADDRESS ));
				SERVER.REMOTE_TOKEN_PASSED = true;
			} else {
				CLIENT.PROTOCOL_BINARY = false;
				if (MISC.DEBUG_K1_FAST_LOAD == 1)
					processVersion(null);
				else 
					requestVerInfo();
			}
		} else {
			if (!CLIENT.IS_WRITING_FIRMWARE)
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onNeedClearQueue );
			
			PopUp.getInstance().close();
			
			CLIENT.SYSTEM_LOADED = false;
			SERVER.REMOTE_TOKEN_PASSED = false;
			
			OPERATOR.clearDataModel();
			
			SERVER.BUF_SIZE_SEND = 0;
			SERVER.BUF_SIZE_RECEIVE = 0;
			SERVER.MAX_IND_CMDS = -1;
			
			SERVER.BOTTOM_BUF_SIZE_SEND = 0;
			SERVER.BOTTOM_BUF_SIZE_RECEIVE = 0;
			SERVER.BOTTOM_MAX_IND_CMDS = 1;
			
			SERVER.TOP_BUF_SIZE_SEND = 0;
			SERVER.TOP_BUF_SIZE_RECEIVE = 0;
			SERVER.TOP_MAX_IND_CMDS = 1;
			
			CLIENT.NO_CLONE_HUNT = false;
			
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
			founder.oBuilder.hideAllUI();
			founder.setPageLabel( loc("sys_device_unacceesible") );
			Warning.show( loc("sys_tcp_interrupted"), Warning.TYPE_ERROR, Warning.STATUS_CONNECTION );
			founder.MENU_READY = false;
			PopUp.getInstance().releaseOfflineMsg();
			
			MISC.VINTAGE_BOOTLOADER_ACTIVE = false;
	//		MISC.NEED_UPDATE = false;
			
			WatchDog.access().stop();
		}
	}
}