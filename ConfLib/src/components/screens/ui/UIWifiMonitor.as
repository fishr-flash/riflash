package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.Balloon;
	import components.gui.MFlexTable;
	import components.gui.PopMenu;
	import components.gui.triggers.TextButtonAdv;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class UIWifiMonitor extends UI_BaseComponent implements IResizeDependant
	{
		private var ftable:MFlexTable;
		private var widget:WifiWidget;
		private var watingtimer:ITask;
		private static var fGotoConnect:Function;
		
		public function UIWifiMonitor(f:Function)
		{
			super();
			
			toplevel = false;
			
			fGotoConnect = f;
			
			ftable = new MFlexTable(new TableAdapter);
			addChild( ftable );
			ftable.y = globalY;
			ftable.x = globalX-20;
			ftable.headers = [loc("ui_wifi_ssid"), loc("ui_wifi_mac"), loc("ui_wifi_security"), loc("ui_wifi_signal_level")];
			
			widget = new WifiWidget(put);
			
			starterCMD = CMD.ESP_INFO;
		}
		override public function open():void
		{
			super.open();
			widget.active(true);
			loadComplete();
			
			ResizeWatcher.addDependent(this);
			
			RequestAssembler.getInstance().fireEvent(new Request(CMD.ESP_GET_NET_LIST, null, 1, [1]));
			
			if (!watingtimer)
				watingtimer = TaskManager.callLater( doBalloon, TaskManager.DELAY_3SEC );
			else
				watingtimer.repeat();
		}
		override public function close():void
		{
			super.close();
			widget.active(false);
			killtimer();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.ESP_INFO:
					if ( p.getStructure(3)[0] == "" || p.getStructure(3)[0] == "00:00:00:00:00:00" ) {
						killtimer();
						Balloon.access().show("ui_wifi_disconnected", "ui_wifi_page_not_update" );
					}
					break;
				case CMD.ESP_NET_LIST:
					killtimer();
					
					var len:int = p.length;
					for (var i:int=0; i<len; i++) {
						if (p.getStructure(i+1)[0] == 1) {
							ftable.clearlist();
							break;
						}
					}
					ftable.add(p);
					ResizeWatcher.doResizeMe(this);
					break;
			}
		}	
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			ftable.height = h - 30;
			ftable.width = w - 60;
		}
		private function doBalloon():void
		{
			Balloon.access().showplain(loc("g_please_wait")+"...", "ui_wifi_gather_info_takes_time" );
		}
		private function killtimer():void
		{
			if(watingtimer)
				watingtimer.kill();
			watingtimer = null;
		}
		
		public static function callPopUp(value:Object):void
		{
			var b:TextButtonAdv = new TextButtonAdv;
			b.setUp( loc("wifi_connect_to") + " "+String(value), fGotoConnect, value); 
			
			PopMenu.access().open([b]);
		}
	}
}
import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridItemRenderer;
import mx.core.ClassFactory;

import components.abstract.functions.loc;
import components.abstract.servants.TaskManager;
import components.abstract.servants.WidgetMaster;
import components.interfaces.IMTableAdapter;
import components.interfaces.ITask;
import components.interfaces.IWidget;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.screens.ui.UIWifiMonitor;
import components.static.CMD;
import components.static.COLOR;
import components.system.UTIL;

class WifiWidget implements IWidget
{
	private var delegate:Function;
	private var task:ITask;
	
	public function WifiWidget(f:Function)
	{
		delegate = f;
	}
	public function put(p:Package):void
	{
		delegate(p);
	}
	public function active(b:Boolean):void
	{
		if (b) {
			if (!task)
				task = TaskManager.callLater(proceed, TaskManager.DELAY_10SEC*2 );
			else
				task.repeat();
			WidgetMaster.access().registerWidget( CMD.ESP_NET_LIST, this );
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.ESP_GET_NET_LIST,null,1,[1]));
		} else {
			WidgetMaster.access().unregisterWidget( CMD.ESP_NET_LIST );
			if (task)
				task.kill();
			task = null;
		}
	}
	private function proceed():void
	{
		RequestAssembler.getInstance().fireEvent( new Request(CMD.ESP_GET_NET_LIST,null,1,[1]));
		task.repeat();
	}
}
class TableAdapter implements IMTableAdapter
{
	public function adapt(a:Array, n:int):Array
	{
		var sec:String;
		switch(int(a[4])) {
			case 1:
				sec = "WEP";
				break;
			case 2:
				sec = "WPA";
				break;
			case 3:
				sec = "WPA2";
				break;
			case 4:
				sec = "WAP/WPA2";
				break;
			default:
				sec = loc("g_no");
				break;
		}
		
		return [a[3],a[2],sec,UTIL.toSigned(int(a[5]),1) + " "+loc("measure_power")];
	}
	
	public function getRowColor(rowIndex:int, sourceColor:uint):uint
	{
		return 0;
	}
	public function get isAdapt():Boolean
	{
		return true;
	}
	public function get isRowColor():Boolean
	{
		return false;
	}
	public function assignCellRenderer(c:DataGridColumn):void
	{
		if (c.dataField == "SSID")
			c.itemRenderer = new ClassFactory(ClickableItemRenderer);
	}
	public function get isCellRenderer():Boolean
	{
		return true;
	}
}

class ClickableItemRenderer extends DataGridItemRenderer
{
	private var callback:Function;
	private var ssid:String;
	
	public function ClickableItemRenderer():void
	{
		super();
		
		addEventListener( MouseEvent.CLICK, onClick );
	}
	override public function set text(value:String):void
	{
		ssid = value;
		htmlText = "<textformat blockindent='8'><u>"+UTIL.wrapHtml(value, COLOR.MENU_ITEM_BLUE)+"<\u><\textformat>"
	}
	private function onClick(e:Event):void
	{
		UIWifiMonitor.callPopUp(ssid);
	}
	override public function set height(value:Number):void
	{
		super.height = value + 3;
	}
	override public function set y(value:Number):void
	{
		super.y = value;
	}
}