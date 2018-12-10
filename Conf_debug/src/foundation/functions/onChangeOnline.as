package foundation.functions
{
	import components.abstract.Warning;
	import components.abstract.resources.RES;
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
			
			founder.setPageLabel( "Выберите страницу" );
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onFlag_WAIT_FOR_STATE, {"getFlagStatus":false} );
			Warning.show( RES.CONNECTED+" "+SERVER.READABLE_VER+" (" + SERVER.VER_FULL+")", Warning.TYPE_SUCCESS, Warning.STATUS_DEVICE );
			founder.menu(CONST.MENU);
			founder.initMenuSelection();
			//SERVER.ADDRESS = 0xFC;
			SERVER.ADDRESS_TOP = 0xFC; 
			
		} else {
			if (!CLIENT.IS_WRITING_FIRMWARE)
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onNeedClearQueue );
			//RequestAssembler.getInstance().clearStack();
			
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
			founder.setPageLabel( "Прибор недоступен" );
			Warning.show( "TCP/IP: Соединение прервано", Warning.TYPE_ERROR, Warning.STATUS_CONNECTION );
			founder.MENU_READY = false;
			PopUp.getInstance().releaseOfflineMsg();
		}
	}
}