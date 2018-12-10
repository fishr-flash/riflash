package components.screens.page
{
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.offline.DataEngine;
	import components.events.GUIEvents;
	import components.gui.FileBrowser;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.models.OfflineConfigParser;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SHA256;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class ConfigLoaderK1 extends UIComponent implements IServiceFrame
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
		
		private var history:String;
		private var isblock:Boolean=false;
		
		public function ConfigLoaderK1()
		{
			super();
			
			btns = new Vector.<TextButton>;
			btns.push( addb( loc("ui_service_get_cfg_from_device"), START, 0 ) );
			btns.push( addb( loc("ui_service_save_cfg_to_file"), SAVE, 0, 230) );
			btns.push( addb( loc("ui_service_load_cfg_from_file"), LOAD, 22 ) );
			btns.push( addb( loc("g_interrupt"), STOP, 56, 120 ) );
			btns.push( addb( loc("ui_service_load_form_file_to_device"), TODEVICE, 22, 230 ) );
			
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
			tFileName.x = 450;
			tFileName.y = 23;
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 121-61;
			sepanchor = sep.y;
			
			height = 100;
		}
		public function put(p:Package):void
		{
			counter++;
			progress();
			
			var a:Array;
			var len:int, i:int;
			
			switch(p.cmd) {
				case CMD.OP_AH_AUTOTEST_HOURS:
				case CMD.OP_AM_AUTOTEST_MINUTES:
					a = (p.getValidStructure()[0] as String).match(/\d{2}/g);
					len = a.length;
					for (i=0; i<len; i++) {
						history += p.cmd+","+(i+1)+","+a[i]+"\n";
					}
					break;
				case CMD.OP_D_LINK_CHANNEL:
					a = (p.getValidStructure()[0] as String).match(/\d{3}/g);
					len = a.length;
					for (i=0; i<len; i++) {
						history += p.cmd+","+(i+1)+","+a[i]+"\n";
					}
					break;
				case CMD.OP_z_ZONES:
					a = (p.getValidStructure()[0] as String).match(/\d{8}/g);
					len = a.length;
					for (i=0; i<len; i++) {
						history += p.cmd+","+(i+1)+","+(a[i] as String).slice(1)+"\n";
					}
					break;
				case CMD.OP_P2_IMEI:
					history += p.cmd+","+p.structure+","+int(p.getValidStructure()[0])+"\n";
					break;
				case CMD.OP_SM_SMS:
					history += p.cmd+","+ UTIL.fz((p.structure).toString(16),2)+","+p.getValidStructure()[0]+"\n";
					break;
				default:
					history += p.cmd+","+p.structure+","+p.getValidStructure()[0]+"\n";
					break;
			}
			
			if (counter == total) {
				toNormal();
				btns[1].disabled = false;
				tFileName.text = "";
				this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE ));
				this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
			}
		}
		
		private function onClick(id:int):void
		{
			var i:int, len:int;
			switch(id) {
				case START:

					this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
					
					total = 0;
					counter = 0;
					history = "";
					/*
					// general
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_o_OBJECT, put, 1) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_FMR_MASTERKEY, put, 1) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_P2_IMEI, put) );
					// system
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AH_AUTOTEST_HOURS, put) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AM_AUTOTEST_MINUTES, put) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AN_AUTOTEST_COUNT, put, 1) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AA_ADDITIONAL_AUTOTEST, put, 1) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_PO_POWER, put) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_r_HISTORY_EVENT_RESTART, put, 1) );
					// engin
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 1) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 2) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 3) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 4) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 5) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_E_USE_ENGIN_NUMB, put, 1 ) );
					// gprs sim
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GC_GPRS_NUM, put, 2 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GN_GPRS_APN, put, 2 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GU_GPRS_APN_USER, put, 2 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GP_GPRS_APN_PASS, put, 2 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GS_SERVER_ADR, put, 1 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GG_SERVER_PORT, put, 1 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GI_SERVER_PASS, put, 1 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GS_SERVER_ADR, put, 2 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GG_SERVER_PORT, put, 2 ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GI_SERVER_PASS, put, 2 ) ); 
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GT_GRPS_TRY, put ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_P_GPRS_COMPR, put ) );
					// link ch
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 1) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 2) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 3) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 4) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 5) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 6) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 7) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 8) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_digt_TIME_DIGIT_CALL, put) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GA_LINK_CHANNEL_ONLINE, put) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_DO_CH_DIRECTION_TYPE, put) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 1) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 2) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 3) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 4) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 5) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 6) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 7) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 8) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_D_LINK_CHANNEL, put) );
					// alarm key
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_z_ZONES, put) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_C_AKARM_KEY, put) );
					// sms					
					var SMS_REQUEST:Array = [4,5,6,7,13,14,15,19,20,25,26,59];
					for (i=0; i<12; i++) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_SM_SMS, put, SMS_REQUEST[i] ) );
					}
					*/
					
					// general
				//	firecmd( CMD.OP_o_OBJECT, 1);
				//	firecmd( CMD.OP_FMR_MASTERKEY, 1);
					firecmd( CMD.OP_P2_IMEI);
					// system
					firecmd( CMD.OP_AH_AUTOTEST_HOURS);
					firecmd( CMD.OP_AM_AUTOTEST_MINUTES);
					firecmd( CMD.OP_AN_AUTOTEST_COUNT, 1);
					firecmd( CMD.OP_AA_ADDITIONAL_AUTOTEST, 1);
					firecmd( CMD.OP_PO_POWER);
					firecmd( CMD.OP_r_HISTORY_EVENT_RESTART, 1);
					// engin
					firecmd( CMD.OP_j_ENGIN_NUMB, 1);
					firecmd( CMD.OP_j_ENGIN_NUMB, 2);
					firecmd( CMD.OP_j_ENGIN_NUMB, 3);
					firecmd( CMD.OP_j_ENGIN_NUMB, 4);
					firecmd( CMD.OP_j_ENGIN_NUMB, 5);
					firecmd( CMD.OP_E_USE_ENGIN_NUMB, 1 );
					// gprs sim
					firecmd( CMD.OP_GC_GPRS_NUM, 2 );
					firecmd( CMD.OP_GN_GPRS_APN, 2 );
					firecmd( CMD.OP_GU_GPRS_APN_USER, 2 );
					firecmd( CMD.OP_GP_GPRS_APN_PASS, 2 );
					firecmd( CMD.OP_GS_SERVER_ADR, 1 );
					firecmd( CMD.OP_GG_SERVER_PORT, 1 );
					firecmd( CMD.OP_GI_SERVER_PASS, 1 );
					firecmd( CMD.OP_GS_SERVER_ADR, 2 );
					firecmd( CMD.OP_GG_SERVER_PORT, 2 );
					firecmd( CMD.OP_GI_SERVER_PASS, 2 ); 
					firecmd( CMD.OP_GT_GRPS_TRY );
					firecmd( CMD.OP_P_GPRS_COMPR );
					// link ch
					firecmd( CMD.OP_h_CH_TEL, 1);
					firecmd( CMD.OP_h_CH_TEL, 2);
					firecmd( CMD.OP_h_CH_TEL, 3);
					firecmd( CMD.OP_h_CH_TEL, 4);
					firecmd( CMD.OP_h_CH_TEL, 5);
					firecmd( CMD.OP_h_CH_TEL, 6);
					firecmd( CMD.OP_h_CH_TEL, 7);
					firecmd( CMD.OP_h_CH_TEL, 8);
					firecmd( CMD.OP_digt_TIME_DIGIT_CALL);
					firecmd( CMD.OP_GA_LINK_CHANNEL_ONLINE);
					firecmd( CMD.OP_DO_CH_DIRECTION_TYPE);
					firecmd( CMD.OP_AND_CH_COM_LINK, 1);
					firecmd( CMD.OP_AND_CH_COM_LINK, 2);
					firecmd( CMD.OP_AND_CH_COM_LINK, 3);
					firecmd( CMD.OP_AND_CH_COM_LINK, 4);
					firecmd( CMD.OP_AND_CH_COM_LINK, 5);
					firecmd( CMD.OP_AND_CH_COM_LINK, 6);
					firecmd( CMD.OP_AND_CH_COM_LINK, 7);
					firecmd( CMD.OP_AND_CH_COM_LINK, 8);
					firecmd( CMD.OP_D_LINK_CHANNEL);
					// alarm key
					firecmd( CMD.OP_z_ZONES);
					firecmd( CMD.OP_C_AKARM_KEY);
					// sms					
					var SMS_REQUEST:Array = [4,5,6,7,13,14,15,19,20,25,26,59];
					for (i=0; i<12; i++) {
						firecmd( CMD.OP_SM_SMS, SMS_REQUEST[i] );
					}
					
					progress();
					
					prepareLoad();
					
					break;
				case STOP:
					btns[0].disabled = false;
					btns[2].disabled = false;
					btns[4].disabled = !confdata;
					RequestAssembler.getInstance().clearStackLater();
					this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE ));
					pBar.label = loc("ui_service_stopped");
					break;
				case SAVE:
					if (!de)
						de = new DataEngine;
					FileBrowser.getInstance().save( SHA256.encrypt(history), de.getExtension() );
					break;
				case LOAD:
					FileBrowser.getInstance().open( onGotFile, FileBrowser.type( "RITM Config file (*.rcf)", "*.rcf" ));
					break;
				case TODEVICE:
					///FIXME: Debug value! Remove it now! не работает
					var pp:PopUp = PopUp.getInstance();
					pp.construct( PopUp.wrapHeader("sys_attention"), 
						PopUp.wrapMessage(loc("ui_service_when_load_cfg_history_delete")), 
						PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete] );
					pp.open();
					
					
					break;
			}
		}
		private function progress():void
		{
			if (btns[0].disabled) {
				pBar.setProgress( counter, total );
				pBar.label = loc("fw_loaded")+Math.round(counter/total*100)+"%";
			}
		}
		private function firecmd(cmd:int, str:int=0 ):void 
		{
			RequestAssembler.getInstance().fireEvent( new Request( cmd, put, str ) );
			total++;
		}
		public function close():void
		{
		}
		
		public function init():void
		{
			toNormal();
			tFileName.text = "";
		}
		
		public function block(b:Boolean):void
		{
			if( isblock != b ) {
				isblock = b;
				btns[0].disabled = isblock;
				btns[1].disabled = true;
				btns[2].disabled = isblock;
				btns[3].disabled = isblock;
				btns[4].disabled = isblock || (!confdata || confdata.length == 0);
			}
		}
		public function getLoadSequence():Array
		{
			return null;
		}
		public function isLast():void
		{
		}
		
		private function toNormal():void
		{
			btns[0].disabled = false;
			btns[1].disabled = true;
			btns[2].disabled = false;
			btns[3].visible = false;
			btns[4].disabled = true;
			
			pBar.visible = false;
			sep.y = sepanchor;
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
		private function addb(title:String, id:int, ypos:int, xpos:int=0):TextButton
		{
			var b:TextButton = new TextButton;
			addChild( b );
			b.setUp( title, onClick, id );
			b.y = ypos;
			b.x = xpos;
			return b;
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
		private function getLoadList(b:ByteArray):Array
		{
			var s:String = "";
			try {
				s = b.readUTFBytes(b.length);				
			} catch(error:Error) {
				dtrace(error.message);
				return [];
			}
			var a:Array = s.match(/\d+\,[\dA-Fa-f]+\,.*/g);
			return a;
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
			}
		}
		
		private function doDelete():void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
			
			if (confdata) {
				counter = 0;
				total = confdata.length;
				
				prepareLoad();
				btns[3].disabled = true;
				pBar.label = loc("his_history_delete_inprogress")+"...";
				
				//doDelete();
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_FH_HISTORY_RECORD, onDelete ) );
				RequestAssembler.getInstance().doPing(false);
				CLIENT.NOT_REQUEST_WHILE_IDLE = true;
			}
		}
		private function onDelete(p:Package):void
		{
			CLIENT.NOT_REQUEST_WHILE_IDLE = false;
			
			var len:int = confdata.length;
			var a:Array;
			for (var i:int=0; i<len; i++) {
				a = (confdata[i] as String).split(",");
				if (a[0] == CMD.OP_SM_SMS)
					RequestAssembler.getInstance().fireEvent( new Request( a[0], putload, int("0x"+a[1]), [a[2]] ));
				else
					RequestAssembler.getInstance().fireEvent( new Request( a[0], putload, int(a[1]), [a[2]] ));
			}
		}
	}
}