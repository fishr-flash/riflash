package components.gui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	import mx.core.IVisualElement;
	
	import spark.components.Panel;
	
	import components.abstract.CmdBot;
	import components.abstract.RegExpCollection;
	import components.abstract.StandDataEngine;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.offline.OfflineTaskManager;
	import components.abstract.servants.CMDExportBot;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.MISC;
	
	public class LocalConfig extends Panel
	{
		private var config_ip:FSSimple;
		private var config_port:FSSimple;
		private var config_log:TextButton;
		private var config_export:TextButton;
		private var config_console:TextButton;
		private var config_hold:TextButton;
		private var bClose:TextButton;
		private var config_skip_hardware_version:FSCheckBox;
		private var config_skip_software_version:FSCheckBox;
		private var config_skip_level:FSCheckBox;
		private var config_history_lines:FSSimple;
		private var config_auto_select:FSSimple;
		private var config_global_timer:FSSimple;
		private var config_holdtime:FSSimple;
		private var config_delete_history:FSCheckBox;
		private var config_adressList:FSComboBox;
		
		private var manager:OfflineTaskManager;
		private var EXPORT_READY:Boolean=false;
		private var EXPORT_READ:String = loc("misc_read_cmds_for_export");
		private var EXPORT_SAVE:String = loc("misc_save_read_cmds");
		
		public function LocalConfig()
		{
			super();
			
			title = loc("g_settings");
			
			construct();
		}
		private function construct():void
		{
			config_ip = new FSSimple;
			add( config_ip );
			config_ip.setName( "IP adr" );
			config_ip.setFieldLocation( 65);
			config_ip.setCellWidth(150);
			config_ip.rule = /^(([a-zA-Z|\.]{3,})|((\d{1,3}\.){3}(\d{1,3})))$/;
			config_ip.setUp( changeConnectIP );
			
			config_port = new FSSimple;
			add( config_port );
			config_port.setName( "Port" );
			config_port.setFieldLocation( 65 );
			config_port.setCellWidth(150);
			config_port.setUp( changeConnectPort );
			
			config_adressList = new FSComboBox;
			add( config_adressList );
			config_adressList.setName( "Adrs" );
			config_adressList.setWidth( 65 );
			config_adressList.setCellWidth(150);
			config_adressList.setUp( collectIPs );
			config_adressList.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			config_log = new TextButton;
			add( config_log );
			config_log.setUp( "Reconnect", reconnect );
			
			config_export = new TextButton;
			add( config_export );
			config_export.setUp( EXPORT_READ, export );
			
			config_console = new TextButton;
			add( config_console );
			config_console.setUp( "Console", console );
			
			config_hold = new TextButton;
			add( config_hold );
			config_hold.setUp( "Hold conn", hold );
			
			config_holdtime = new FSSimple;
			add( config_holdtime );
			config_holdtime.restrict("0-9",3);
			config_holdtime.setName( "Hold in mins" );
			config_holdtime.setFieldLocation( 30);
			config_holdtime.setCellWidth(150);
			
			shift();
			
			config_skip_hardware_version = new FSCheckBox;
			add( config_skip_hardware_version );
			config_skip_hardware_version.setName( "Ignore app" );
			config_skip_hardware_version.leading = 0;
			config_skip_hardware_version.setWidth( 203 );
			//config_skip_hardware_version.attune( FormString.F_MULTYLINE );
			config_skip_hardware_version.setUp( changeSkipHVersion );
			
			config_skip_software_version = new FSCheckBox;
			add( config_skip_software_version );
			config_skip_software_version.setName( "Ignore release" );
			config_skip_software_version.leading = 0;
			config_skip_software_version.setWidth( 203 );
			//config_skip_software_version.attune( FormString.F_MULTYLINE );
			config_skip_software_version.setUp( changeSkipSVersion );
			
			config_skip_level = new FSCheckBox;
			add( config_skip_level );
			config_skip_level.setName( "Ignore level" );
			config_skip_level.leading = 0;
			config_skip_level.setWidth( 203 );
			//config_skip_level.attune( FormString.F_MULTYLINE );
			config_skip_level.setUp( changeSkipLevel);
			
			config_delete_history = new FSCheckBox;
			add( config_delete_history );
			config_delete_history.setName( "Remove history\ron linkch" );
			config_delete_history.leading = 0;
			config_delete_history.setWidth( 203 );
			config_delete_history.attune( FormString.F_MULTYLINE );
			config_delete_history.setUp( changeHistoryDelete);
			
			config_history_lines = new FSSimple;
			add( config_history_lines );
			config_history_lines.setName( "History lines amnt\r(need restart)" );
			config_history_lines.leading = 0;
			config_history_lines.attune( FSSimple.F_MULTYLINE );
			config_history_lines.setCellWidth( 40 );
			config_history_lines.setFieldLocation( 175 );
			config_history_lines.setUp( changeHistoryLine );
			
			config_auto_select = new FSSimple;
			add( config_auto_select );
			config_auto_select.setName( "Autopage (list\rin console .getpages)" );
			config_auto_select.leading = 0;
			config_auto_select.attune( FSSimple.F_MULTYLINE );
			config_auto_select.setCellWidth( 40 );
			config_auto_select.setFieldLocation( 175 );
			config_auto_select.setUp( changeAutoSelect );
			
			config_global_timer = new FSSimple;
			add( config_global_timer );
			config_global_timer.setName( "Spamtimer (1sec=10)\r(Need restart)" );
			config_global_timer.leading = 0;
			config_global_timer.attune( FSSimple.F_MULTYLINE );
			config_global_timer.setCellWidth( 40 );
			config_global_timer.setFieldLocation( 175 );
			config_global_timer.setUp( changeGlobalSpamTimer);
			
			bClose = new TextButton;
			addElement( bClose );
			bClose.setUp( "Close", closeConfig );
			bClose.x = 171;
			bClose.y =  -31;
			
			this.height = globaly + 40; //config_global_timer.getHeight() + config_global_timer.y + 40;
			this.width = 228+10;
			
			manager = new OfflineTaskManager( new CmdBot, new StandDataEngine);
			
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onConnect );
		}
		public function open():void 
		{
			config_ip.setCellInfo( CLIENT.CONNECT_IP );
			config_port.setCellInfo( String(CLIENT.CONNECT_PORT) );
			
			config_skip_hardware_version.setCellInfo( String(CLIENT.SKIP_HARDWARE_VERSION_CHECK) );
			config_skip_software_version.setCellInfo( String(CLIENT.SKIP_SOFTWARE_VERSION_CHECK) );
			config_skip_level.setCellInfo( String(CLIENT.SKIP_LEVEL_CHECK) );
			
			config_history_lines.setCellInfo( String(CLIENT.HISTORY_LINES_PER_PAGE) );
			config_global_timer.setCellInfo( String(CLIENT.TIMER_EVENT_SPAM/100) );
			config_auto_select.setCellInfo( String(CLIENT.AUTO_SELECT_PAGE) );
			config_delete_history.setCellInfo( String(CLIENT.DELETE_HISTORY) );
			
			var generalSo:SharedObject = SharedObject.getLocal( "RITM", "/" );
			var list:Array = generalSo.data["iplist"];
			if (list)
				config_adressList.setList( list );
			
			this.addEventListener(MouseEvent.ROLL_OUT, onClose );
			
			this.visible = true;
		}
		private function changeHistoryLine():void
		{
			var num:int = int(config_history_lines.getCellInfo());
			if(num > 0 ) {
				var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
				so.data["history_line_per_page"] = num;
				flush(so);
				CLIENT.HISTORY_LINES_PER_PAGE = num;
			}
		}
		private function changeAutoSelect():void
		{
			var num:int = int(config_auto_select.getCellInfo());
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data["auto_select_page"] = num;
			flush(so);
			CLIENT.AUTO_SELECT_PAGE = num;
		}
		private function changeGlobalSpamTimer():void
		{
			var num:int = int(config_global_timer.getCellInfo());
			if(num > 0 ) {
				var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
				so.data["global_spam_timer"] = num;
				flush(so);
				CLIENT.TIMER_EVENT_SPAM = num*100;
			}
		}
		private function changeSkipHVersion():void
		{
			var num:int = int(config_skip_hardware_version.getCellInfo());
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data["skip_hardware_version_check"] = num;
			flush(so);
			CLIENT.SKIP_HARDWARE_VERSION_CHECK = num;
		}
		private function changeSkipSVersion():void
		{
			var num:int = int(config_skip_software_version.getCellInfo());
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data["skip_software_version_check"] = num;
			flush(so);
			CLIENT.SKIP_SOFTWARE_VERSION_CHECK = num;
		}
		private function changeSkipLevel():void
		{
			var num:int = int(config_skip_level.getCellInfo());
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data["skip_level_check"] = num;
			flush(so);
			CLIENT.SKIP_LEVEL_CHECK = num;
		}
		private function console():void
		{
			DevConsole.inst.visible = !DevConsole.inst.visible; 
		}
		private function hold():void
		{
			var time:int = int(config_holdtime.getCellInfo());
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HOLD_CONNECTION, null, 1, [time] ));
		}
		private function export():void
		{
			if (!EXPORT_READY) {
				//var a:Array = CMDExportBot.getList();
				trace("LocalConfig.export()");
				manager.addEventListener( Event.COMPLETE, onExportComplete )
				manager.newSession();
				manager.saveOnlineListToFile(CMDExportBot.getList());
				config_export.disabled = true;
			} else {
				FileBrowser.getInstance().save( manager.saveListToFile( CMDExportBot.getList() ), manager.getExtension() );
			}
		}
		private function onExportComplete(e:Event):void
		{
			config_export.disabled = false;
			manager.removeEventListener( Event.COMPLETE, onExportComplete )
			EXPORT_READY = true;
			config_export.setName( EXPORT_SAVE ); 
		}
		private function changeConnectIP():void 
		{
			const expresson:RegExp = /^(([a-zA-Z|\.]{3,})|((\d{1,3}\.){3}(\d{1,3})))$/; 
			if( String( config_ip.getCellInfo() ).search( expresson ) == -1 )
					return;
			
			CLIENT.CONNECT_IP = config_ip.getCellInfo() as String;
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data["ip"] = CLIENT.CONNECT_IP;
			flush(so);
			
			SocketProcessor.getInstance().reConnect();
		}
		private function changeConnectPort():void 
		{
			var port:uint = uint(config_port.getCellInfo());
			if( port > 0xFFFF ) {
				port = 0xFFFF;
				config_port.setCellInfo( String(port) );
			}
			CLIENT.CONNECT_PORT = port;
			
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data["port"] = CLIENT.CONNECT_PORT;
			flush(so);
			
			SocketProcessor.getInstance().reConnect();
		}
		private function collectIPs():void
		{
			var line:String = config_adressList.getCellInfo().toString();
			var a:Array = line.split(":");
			config_ip.setCellInfo( a[0] );
			config_port.setCellInfo( a[1] );
			changeConnectIP();
			changeConnectPort();
		}
		private function onConnect(e:SystemEvents):void
		{
			if (e.isConneted()) {
				var generalSo:SharedObject = SharedObject.getLocal( "RITM", "/" );
				var list:Array = generalSo.data["iplist"];
				var line:String = CLIENT.CONNECT_IP+":"+CLIENT.CONNECT_PORT;
				
				if (!list) {
					list = new Array;
					list.push( {label:line, data:line} );
				} else {
					var len:int = list.length;
					var unique:Boolean=true;
					for (var i:int=0; i<len; ++i) {
						if (list[i].label == line) {
							unique = false;
							if(i>0){
								list.splice(i,1);
								list.unshift( {label:line, data:line} );
							}
							break;
						}
					}
					if (unique) {
						list.unshift( {label:line, data:line} );
						if (list.length > 20)
							list.length = 20;
					}
				}
				config_adressList.setList( list );
				config_adressList.setCellInfo( line );
				generalSo.data["iplist"] = list;
				flush(generalSo);
			} else {
				EXPORT_READY = false;
				config_export.setName( EXPORT_READ );
				config_export.disabled = false;
			}
		}
		private function changeHistoryDelete():void
		{
			var num:int = int(config_delete_history.getCellInfo());
			var so:SharedObject = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			so.data["delete_history"] = num;
			flush(so);
			CLIENT.DELETE_HISTORY = num;
		}
		public static function getConfig():Array
		{
			
			
			return [ (0x23 + SERVER.REQUEST_READ)*2643 ];
		}
		private function reconnect():void
		{
			SocketProcessor.getInstance().reConnect();
			closeConfig();
		}
		private function onClose(ev:Event):void
		{
			if (MISC.DEBUG_HIDEMENU_ON_CLICK == 1)
				closeConfig();
		}
		private function closeConfig():void
		{
			this.removeEventListener(MouseEvent.ROLL_OUT, onClose );
			this.visible = false;
		}
		private var globaly:int = 5;
		private function shift():void
		{
			globaly += 10;
		}
		private function add(e:IVisualElement):void
		{
			addElement(e);
			e.y = globaly;
			e.x = 5;
			if (e is FSSimple)
				globaly += 30;
			else if (e is FSCheckBox || e is FSComboBox)
				globaly += 35;
			else
				globaly += 20;
		}
		private function flush(so:SharedObject):void
		{
			try {
				so.flush();
			} catch(error:Error) {
				dtrace("Error: flush shared object at LocalConfig");
			}
		}
	}
}