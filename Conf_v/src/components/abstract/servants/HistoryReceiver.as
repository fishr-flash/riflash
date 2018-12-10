package components.abstract.servants
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.utils.ByteArray;
	
	import components.abstract.functions.loc;
	import components.abstract.gearboxes.HistoryBox;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.ILoadAni;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class HistoryReceiver implements IWidget
	{
		public static const DATE:int=0;
		public static const INDEX:int=1;
		
		private static var inst:HistoryReceiver;
		public static function access():HistoryReceiver
		{
			if(!inst)
				inst = new HistoryReceiver;
			return inst;
		}
		
		private var gearbox:HistoryBox;
		
		public function HistoryReceiver()
		{
			gearbox = HistoryBox.access();
			
			vReleaseDate = new Date();
			vReleaseDate.setUTCFullYear(2012,0,1);
			vReleaseDate.setUTCHours(0,0,1);
			
			WidgetMaster.access().registerWidget(CMD.SEND_SELECT_HISTORY_INDEX,this);
			WidgetMaster.access().registerWidget(CMD.SEND_RUBBER_HISTORY_SERVER,this);
			WidgetMaster.access().registerWidget(CMD.SEND_SELECT_HISTORY,this);
			
			patchReceiver = new HistoryPatchReceiver;
		}
		
		private var index_start:uint;
		private var index_end:uint;
		private var total:int;
		private var lines:Array;
		private var fDisableExport:Function;
		private var task:ITask;
		private var vReleaseDate:Date;
		private var servant:HistoryTableServant;
		private var jsonserv:HEAntifreezeJSON;
		private var totalgot:int;
		private var patchReceiver:HistoryPatchReceiver;
		
		public function start(hi:String, low:String, type:int, disableExport:Function):void
		{
			var success:Boolean;
			var hi_sec:int = int(hi);
			var lo_sec:int = int(low);
			switch(type) {
				case DATE:
					if (hi.length > 0 && low.length > 0 ) {
						/*var dhi:Date = new Date("20"+hi.slice(4,6),hi.slice(2,4),hi.slice(0,2),hi.slice(6,8),hi.slice(8,10),hi.slice(10,12));
						var dlow:Date = new Date("20"+low.slice(4,6),low.slice(2,4),low.slice(0,2),low.slice(6,8),low.slice(8,10),low.slice(10,12));*/
						
						if( hi_sec > vReleaseDate.time/1000 && lo_sec > vReleaseDate.time/1000 ) {
							
							if (lo_sec < hi_sec)
								RequestAssembler.getInstance().fireEvent( new Request(CMD.SELECT_HISTORY_BY,null, 1, [ lo_sec,hi_sec,type]));
							else
								RequestAssembler.getInstance().fireEvent( new Request(CMD.SELECT_HISTORY_BY,null, 1, [hi_sec,lo_sec,type]));
							success = true;
						}
					}
					break;
				case INDEX:
					if (lo_sec < hi_sec)
						RequestAssembler.getInstance().fireEvent( new Request(CMD.SELECT_HISTORY_BY,null, 1, [lo_sec,hi_sec,type]));
					else
						RequestAssembler.getInstance().fireEvent( new Request(CMD.SELECT_HISTORY_BY,null, 1, [hi_sec,lo_sec,type]));
					success = true;
					break;
			}
			
			if (success) {
				fDisableExport = disableExport;
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
					{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:"", getLink:link, getButtonArgs:{title:loc("g_cancel"),callback:stopDeviceTransmission}} );
				
				if(!task)
					task = TaskManager.callLater( stop, TaskManager.DELAY_10SEC*6 );
				else
					task.repeat();
				
				servant = HistoryTableServant.access();
				if (!jsonserv)
					jsonserv = new HEAntifreezeJSON;
			}
		}
		
		public function put(p:Package):void
		{
			/**	Команда SEND_SELECT_HISTORY_INDEX - прибор отправляет выбранные индексы начала и конца истории, по которым можно судить о количестве передаваемых записей.
			 Параметр 1 - Индекс начала выбранной для передачи истории;
			 Параметр 2 - Индекс конца выбранной для передачи истории;
			 Параметр 3 - Количество записей истории, которые будут отправлены из прибора.
			 *Вояджер отправляет историю командой SEND_RUBBER_HISTORY_SERVER(1454) в Ritm-bin2 NO ACK протоколе (без сжатия?). Программа конфигурации сама контролирует количество и правильность переданной истории через индексы.*/													
			
			/**	Команда SELECT_HISTORY_BY - выбрать и получить от прибора историю по выбранным дате и времени или индексам - запрос к прибору от сервера или программы конфигурации
			 
			 Если параметр 3 = 0:
			 Параметр 1 - Дата и время в POSIX формате, с которого необходимо получить историю.
			 Параметр 2 - Дата и время в POSIX формате, до которого необходимо получить историю.
			 Если параметр 3 = 1:
			 Параметр 1 - индекс, с которого необходимо получить историю.
			 Параметр 2 - индекс, до которого необходимо получить историю */
			
			if( patchReceiver.working )
				patchReceiver.put(p);
			else {
				switch(p.cmd) {
					case CMD.SEND_SELECT_HISTORY_INDEX:
						index_start = p.getParamInt(1);
						index_end = p.getParamInt(2);
						total = p.getParamInt(3);
						
						if (index_start == 0xffffffff && index_end == 0xffffffff ) {	// значит запрошены невалидные данные
							GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
							task.stop();
						} else if (index_start == 0 && index_end == 0 && total == 0) {	// значит прибор перегружен, но работает над задачей
							task.repeat();
						} else {
							task.repeat();
							lines = [];
							jsonserv.init(servant.getHeaderLocale());
							totalgot = 0;
						}
						break;
					case CMD.SEND_RUBBER_HISTORY_SERVER:
					case CMD.SEND_SELECT_HISTORY:
						
						if (lines && linkTarget) {
							var startindex:int = lines.length;	// при запросе нескольких пакетов, сдвиг чтобы не перезаписать уже принятые записи
							var index:int = startindex;
							var len:int = p.data.length;
							var packettotal:int = len/gearbox.HIS_BLOCK_SIZE_BYTE;	// всего записей в этой посылке
							var trans:Array = [];
							for (var i:int=0; i<len; i++) {
								if( !trans[index] )
									trans[index] = [];
								(trans[index] as Array).push( p.data[i] );
								index++;
								if( index == packettotal )
									index = 0;
							}
							totalgot += trans.length;
							jsonserv.add( servant.getContent(trans) );
							
							linkTarget.goto( totalgot/(total+1)*100 ); 
							if (total == totalgot) {
								requestGasps();
								//GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
								task.stop();
							} else
								task.repeat();
						}
						break;
				}
			}
		}
		public function getBytes():ByteArray
		{
			return jsonserv.getBytes();
		}
		public function isExportButtonDisabled():Boolean
		{
			return !(lines && lines.length > 0);
		}
		public function getFields():Array
		{
			return lines;
		}
		private var linkTarget:ILoadAni;
		private function link(i:ILoadAni):void
		{
			if (!linkTarget) {
				linkTarget = i;
				linkTarget.goto(0);
			} else {
				linkTarget = null;
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
				fDisableExport(false);
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
				
				if (patchReceiver.list.length > 0) {
					var pw:PopUp = PopUp.getInstance();
					pw.construct( PopUp.wrapHeader("sys_attention"),PopUp.wrapMessage(loc("his_read_fail") + " " + patchReceiver.list),
						PopUp.BUTTON_OK | PopUp.BUTTON_YES, 
						[function():void
						{
							
							var copy:String = patchReceiver.list;
							Clipboard.generalClipboard.clear();
							var r:Boolean;
							while (true) {
								r = Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, copy);
								if (r) {
									//Balloon.access().shownote("g_info_copied_to_clip");
									break;
								}
							}
							
						},function():void{pw.close()}],
						[loc("g_copy_to_clip"),loc("g_close")] );
					pw.open();
				}
					//Balloon.access().show( loc("sys_attention"), loc("his_read_fail") + " " + patchReceiver.list );
			}
		}
		private function stop():void
		{
			task.stop();
			linkTarget.halt();
			linkTarget = null;
			fDisableExport(false);
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
		}
		private function requestGasps():void
		{
			patchReceiver.init(gearbox,servant);
			patchReceiver.start(jsonserv.getGasps(),patchComplete);
		}
		private function patchComplete():void
		{
			linkTarget.goto( totalgot/total*100 );
		}
		private function stopDeviceTransmission():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.SEND_SELECT_HISTORY_BREAK,null, 1, [0xff]));
			stop();
		}
	}
}