package components.screens.page
{
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.offline.DataEngine;
	import components.abstract.servants.TaskManager;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.FileBrowser;
	import components.gui.SimpleTextField;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.models.OfflineConfigParser;
	import components.protocol.statics.SHA256;
	import components.screens.ui.UIHistory;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	
	public class SimpleConfigLoader extends UIComponent implements IServiceFrame
	{
		private var btns:Vector.<TextButton>;
		private var pBar:ProgressBar;
		private var lastsep:Separator;
		private var sep:Separator;
		private var sepanchor:int;
		private var counter:int;
		private var total:int;
		private var de:DataEngine;
		private var cmds:Array;
		private var tFileName:SimpleTextField;
		private var confdata:Array;
		
		private const START:int=1;
		private const STOP:int=2;
		private const SAVE:int=3;
		private const LOAD:int=4;
		private const TODEVICE:int=5;
		
		public function SimpleConfigLoader()
		{
			super();
			
			btns = new Vector.<TextButton>;
			btns.push( addb( loc("ui_service_get_cfg_from_device"), START, 0 ) );
			btns.push( addb( loc("ui_service_save_cfg_to_file"), SAVE, 0, 250) );
			btns.push( addb( loc("ui_service_load_cfg_from_file"), LOAD, 22 ) );
			btns.push( addb( loc("g_interrupt"), STOP, 56, 120 ) );
			btns.push( addb( loc("ui_service_load_form_file_to_device"), TODEVICE, 22, 250 ) );
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.y = 62
			pBar.x = 1;
			pBar.width = 100;
			pBar.height = 10;
			pBar.label = "";
			//	pBar.visible = false;
			pBar.mode = "manual";
			pBar.maximum = 100;
			pBar.minimum = 0;
			
			pBar.setProgress( 0, 50 );
			pBar.label = loc("fw_loaded")+"0%";
			
			tFileName = new SimpleTextField("", 550);
			addChild( tFileName );
			tFileName.x = 500;
			tFileName.y = 23;
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 121-61;
			sepanchor = sep.y;
		}
		public function block(b:Boolean):void
		{
		}
		
		public function close():void
		{
			RequestAssembler.getInstance().doPing(MISC.DEBUG_DO_PING==1);
		}
		
		public function getLoadSequence():Array
		{
			return null;
		}
		
		public function init():void
		{
			toNormal();
			tFileName.text = "";
		}
		
		public function isLast():void
		{
			sep.visible = false;
		}
		
		public function put(p:Package):void
		{
			counter++;
			progress();
			
			if (counter == total) {
				
				toNormal();
				btns[1].disabled = false;
				tFileName.text = "";
				this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE ));
				this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
			}
		}
		override public function get height():Number
		{
			if (btns[3].visible)
				return 133;
			return 80;
		}
		private function toNormal():void
		{
			btns[0].disabled = false;
			btns[1].disabled = true;
			btns[2].disabled = false;
			btns[4].disabled = true;
			btns[3].visible = false;
			
			pBar.visible = false;
			sep.y = sepanchor;
		}
		private function addb(title:String, id:int, ypos:int, xpos:int=0):TextButton
		{
			var b:TextButton = new TextButton;
			addChild( b );
			b.setUp( title, onClick, id );
			b.y = ypos;
			b.x = xpos;
			return b;
		}
		private function onClick(id:int):void
		{
			var i:int;
			switch(id) {
				case START:
					switch(DS.alias) {
						case DS.KLAN:
						case DS.A_ETH:
							cmds = [
								CMD.LAN_PART,
								CMD.OBJECT,
								CMD.LAN_ZONE,
								CMD.LAN_DHCP_SETTINGS,
								CMD.LAN_SNMP_SETTINGS,
								CMD.LAN_WEB_ENABLE,
								CMD.LAN_ICMP_ENABLE,
								CMD.LAN_SERVER_CONNECT,
								CMD.LAN_SET_UP
							];
							break;
						case DS.isfam( DS.K5 ):
							cmds = [
								CMD.K5_G_PHONE,
								CMD.K5_G_APN,
								CMD.K5_G_APN_LOG,
								CMD.K5_G_APN_PASS,
								CMD.K5_G_SRV_IP,
								CMD.K5_G_SRV_PORT,
								CMD.K5_G_SRV_PASS,
								CMD.K5_ADC_TRESH,
								CMD.K5_AWIRE_PART_CODE,
								CMD.K5_DIRECTIONS,
								CMD.K5_PART_PARAMS,
								CMD.K5_AWIRE_DELAY,
								CMD.K5_PART_DELAY,
								CMD.K5_AWIRE_TYPE,
								CMD.K5_APHONE,
								CMD.K5_EPHONE,
								CMD.K5_FAULT_CODE,
								CMD.K5_BIT_SWITCHES,
								CMD.OBJECT,
								/// сохранение/чтение мастер кода отключено по задаче
								/// https://megaplan.ritm.ru/task/1027228/card/
								//CMD.MASTER_CODE,
								CMD.DATE_TIME,
								CMD.GPRS_APN_BASE,
								CMD.GPRS_APN_AUTO,
								CMD.K5_DIG_TIME,
								CMD.K5_G_TRY_TIME,
								CMD.K5_AND_OR,
								CMD.K5_PART_EVCOUNT,
								CMD.K5_SYR_LEN,
								CMD.K5_SYR_PAR,
								CMD.K5_PART_OUT,
								CMD.K5_OUT_DRIVE,
								CMD.K5_SMS_TEXT,
								CMD.K5_MAIN_ATEST,
								CMD.K5_ADV_ATEST,
								CMD.K5_KEY_BLOCK,
								CMD.K5_TIME_CPW,
								CMD.K5_KBD_COUNT,
								CMD.K5_KBD_INDEX,
								CMD.K5_KBD_NUMOBJ,
								CMD.K5_KBD_KEY_CNT,
								CMD.K5_KBD_KEY,
								CMD.K5_KBD_MKEY,
								CMD.K5_TM_KEY_CNT,
								CMD.K5_TM_DELAY,
								CMD.K5_TM_KEY,
								CMD.CH_COM_GPRS_TIMEOUT_SERVER,
								CMD.GPRS_ENCRYPTION
							];
							if (DS.release >= 6) {
								cmds.push( CMD.READER_TM );
								cmds.push( CMD.PING_SET_TIME );
							}
							if( DS.isDevice( DS.A_BRD ) )
							{
								cmds.push( CMD.TELCO_CONTROL_LINE );
							}
							else
							{
								cmds.push( CMD.TM_KBD_ALARM_BEEP_ENABLE );
							}
							if(  DS.isfam( DS.K5, DS.A_BRD ) && int( DS.app ) != 6  && int( DS.app ) != 8 )
							{
								cmds.push( CMD.VOLTAGE_LIMITS );
								
							}
							if( !( DS.isDevice( DS.K5A ) && DS.release < 16  ) && !DS.isDevice( DS.A_BRD ) )
							{
								cmds.push( CMD.CPW_LIMITS );
								
								
							}
								
											
								
							break;
						case DS.K9:
						case DS.K9A:
						case DS.K9M:
						case DS.K9K:
						case DS.K1:
						case DS.K1M:
							cmds = [
								CMD.K5_G_PHONE,
								CMD.K5_G_APN,
								CMD.K5_G_APN_LOG,
								CMD.K5_G_APN_PASS,
								CMD.K5_G_SRV_IP,
								CMD.K5_G_SRV_PORT,
								CMD.K5_G_SRV_PASS,
								CMD.K5_APHONE,
								CMD.K5_EPHONE,
								CMD.K5_FAULT_CODE,
								CMD.OBJECT,
								/// отменена безусловная запись по задаче https://megaplan.ritm.ru/task/1064232/card/
								CMD.MASTER_CODE,
								CMD.DATE_TIME,
								CMD.GPRS_APN_BASE,
								CMD.GPRS_APN_AUTO,
								CMD.K5_DIG_TIME,
								CMD.K5_G_TRY_TIME,
								CMD.K5_AND_OR,
								CMD.K5_PART_EVCOUNT,
								CMD.K5_SYR_LEN,
								CMD.K5_SMS_TEXT,
								CMD.K5_KEY_BLOCK,
								CMD.K5_TIME_CPW,
								CMD.K9_PART_PARAMS,
								CMD.K9_BIT_SWITCHES,
								CMD.K9_BAT_EVENTS,
								CMD.K9_DIRECTIONS,
								CMD.K9_TM_LED_PART,
								CMD.K9_EXIT_PART,
								CMD.K9_PERIM_PART,
								CMD.K9_SIM_SWITCH,
								CMD.K9_LED_TEST,
								CMD.K9_IMEI_IDENT,
								CMD.K9_ADV_ATEST,
								CMD.K9_MAIN_ATEST,
								CMD.CH_COM_TIME_PARAM,
								CMD.READER_TM,
								CMD.SAVE_CID_TEMPERATURE,
								CMD.PING_SET_TIME
							]
							
							if ( !( DS.isDevice(DS.K1M) && DS.release < 10 ) ) 
								cmds.push( CMD.LIMITS_TEMP );
							
							
							if (DS.isfam(DS.K9)) {
								
								cmds.push( CMD.K5_OUT_DRIVE );
								cmds.push( CMD.K5_ADC_TRESH );
								cmds.push( CMD.K5_TM_KEY_CNT );
								cmds.push( CMD.K5_TM_KEY );
								cmds.push( CMD.K5_KBD_KEY_CNT );
								cmds.push( 	CMD.K5_KBD_KEY );
								cmds.push( 	CMD.K5_KBD_MKEY );
								cmds.push( 	CMD.PART_SET_TEST_LINK );
								cmds.push( 	CMD.K9_AWIRE_TYPE );
								cmds.push( 	CMD.SYR_PAR );
								cmds.push( 	CMD.BIT_SWITCHES );
								
								
								/// фильтр установлен по задаче https://megaplan.ritm.ru/task/1064232/card/#c438740
								if( DS.release === 18 )
									cmds.splice( cmds.indexOf( CMD.MASTER_CODE ), 1 );
							}
							
							if( DS.isDevice(DS.K1M) && DS.release > 18 ){
								cmds.splice( cmds.indexOf( CMD.MASTER_CODE ), 1 );
								cmds.push( 	CMD.AWIRE_CHANGE_DELAY );
							}
									
							
							
							
							break;
					}
					
					
					total = cmds.length;
					for (i=0; i<total; i++) {
						RequestAssembler.getInstance().fireEvent( new Request (cmds[i],put));
					}
					counter = 0;
					progress();
					
					prepareLoad();
					
					break;
				case STOP:
				btns[0].disabled = false;
				btns[2].disabled = false;
				btns[4].disabled = false;
				RequestAssembler.getInstance().clearStackLater();
				this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE ));
				pBar.label = loc("ui_service_stopped");
				blockNaviSilent = false;
				break;
				case SAVE:
				if (!de)
					de = new DataEngine;
				
				FileBrowser.getInstance().save( SHA256.encrypt( de.saveraw( cmds )), de.getExtension() );
				
				break;
				case LOAD:
				FileBrowser.getInstance().open( onGotFile, FileBrowser.type( "RITM Config file (*.rcf)", "*.rcf" ));
				break;
				case TODEVICE:
				counter = 0;
				total = confdata.length;
				
				prepareLoad();
				btns[3].disabled = true;
				switch(DS.alias) {
					case DS.KLAN:
					case DS.A_ETH:
						doLoadConf();
						break;
					case DS.isfam( DS.K5 ):
					case DS.K9:
					case DS.K9A:
					case DS.K9M:
					case DS.K9K:
					case DS.K1:
					case DS.K1M:
						blockNaviSilent = true;
						pBar.label = loc("his_history_delete_inprogress")+"...";
						RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear, 1 ,[UIHistory.HIS_DELETE] ));
						break;
				}
				break;
			}
		}
		private function doClear(p:Package):void
		{
			if (p.success) {
				TaskManager.callLater( sendHistoryRequest, 30000 );
				RequestAssembler.getInstance().doPing(false);
			} else {
				if( p.getStructure()[0] == 2 )
					doLoadConf();
				else
					TaskManager.callLater( sendHistoryRequest, TaskManager.DELAY_2SEC );
			}
		}
		private function sendHistoryRequest():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear ));
			RequestAssembler.getInstance().doPing(MISC.DEBUG_DO_PING==1);
		}
		private function doLoadConf():void
		{
			pBar.label = loc("service_prepairing_to_load")+"...";
			btns[3].disabled = false;
			for (var i:int=0; i<total; i++) {
				confdata[i].delegate = putload;
				RequestAssembler.getInstance().fireEvent( confdata[i] );
			}
		}
		private function prepareLoad():void
		{
			btns[0].disabled = true;
			btns[1].disabled = true;
			btns[2].disabled = true;
			btns[4].disabled = true;
			
			pBar.visible = true;
			btns[3].disabled = false;
			btns[3].visible = true;
			sep.y = sepanchor + 53;
			
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK ));
			this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
		}
		private function onGotFile(b:ByteArray, fr:FileReference):void
		{
			
			
			SHA256.decrypt(b);
			
			var len:int = fr.name.length;
			tFileName.htmlText = cutString(fr.name, len);//"Прошивка <b>"+fr.name+"</b> готова к загрузке";
			while (tFileName.numLines > 1) {
				len -= 5;
				tFileName.htmlText = cutString(fr.name, len);
			}
			function cutString(s:String, l:int):String
			{
				if (s.length > l)
					return s.slice(0,l-3) + "... .rcf";
				return s;
			}
			
			var o:OfflineConfigParser = new OfflineConfigParser;
			confdata = getLoadList(b);
			btns[4].disabled = !confdata || confdata.length == 0;
			
			
		}
		private function putload(p:Package):void
		{
			counter++;
			progress();
			
			if (counter == total) {
				toNormal();
				btns[4].disabled = false;
				this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE ));
				this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
				blockNaviSilent = false;
			}
		}
		private function getLoadList(b:ByteArray):Array
		{
			
			
			
				var xml:XML = new XML(b.readUTFBytes(b.length));	
				
				
				///https://megaplan.ritm.ru/task/1064232/card/#c438833
				if( XMLList( xml.CommandDataModel.( Name == 'MASTER_CODE')).length() &&
					( DS.isfam( DS.K9 ) && DS.release === 18 )
					|| ( DS.isfam( DS.K1 ) && DS.release > 18 )
				)
					delete( xml.CommandDataModel.( Name == 'MASTER_CODE')[ 0 ] );
					
				
				
			
			//var xml:XML = new XML(b.readUTFBytes(b.length));
			var o:OfflineConfigParser = new OfflineConfigParser;
			return o.assembleRequests(xml);
		}
		
		private function progress():void
		{
			if (btns[0].disabled) {
				pBar.setProgress( counter, total );
				pBar.label = loc("fw_loaded")+Math.round(counter/total*100)+"%";
			}
		}
		private function set blockNaviSilent(b:Boolean):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigationSilent, {"isBlock":b} );
		}
	}
}