package components.screens.ui
{
	import mx.graphics.Stroke;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.gui.MFlexTable;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIControlDevice extends UI_BaseComponent implements IWidget, IResizeDependant
	{
		public static const FILTER_NO:int=0;
		public static const FILTER_IMEI:int=1;
		public static const FILTER_MAC:int=2;
		public static const FILTER_IP:int=3;
		
		private var ftable:MFlexTable;
		private var fields:Vector.<IFormString>;
		private var spam:ITask;
		private var flist:Array;
		private var go:GroupOperator;
		private var filter_hidden:int;	// y когда фильтр скрыт
		private var filter_visible:int;	// y когда фильтр виден
		private var list_delta:int;		// разница высоты, на которую надо увеличить лист когда координаты скрыты
		
		public function UIControlDevice()
		{
			super();
			
			addui( new FormString, 0, loc("ctrl_allow_cmd"), null, 1 );
			attuneElement( 500 );
			
			/** "Команда CTRL_FILTER_CMD - фильтр команд управления
			Параметр 1 - Вид фильтра, 0-фильтр отключен, 1-фильтр по IMEI, 2-фильтр по MAC-адресу, 3-фильтр по IP-адресу;
			Параметр 2 - IMEI, по которому фильтруются команды управления;
			Параметр 3 - МАС адрес, по которому фильтруются команды управления;
			Параметр 4 - IP адрес, по которому фильтруются команды управления."												*/
			
			var w1:int = 399;
			var w2:int = 150;
			
			fields = new Vector.<IFormString>;
			
			var l:Array = UTIL.getComboBoxList( [[0, loc("ctrl_filter_off")],[1, loc("g_imei")],[2, loc("lan_mac_adress")],[3, loc("lan_ipadr")]] );
			addui( new FSComboBox, CMD.CTRL_FILTER_CMD, loc("ctrl_filter_cmd"), onLogic, 1, l );
			attuneElement( w1, w2, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			fields.push( getLastElement() );
			
			globalY += 3;
			filter_hidden = globalY;
			
			addui( new FSSimple, CMD.CTRL_FILTER_CMD, loc("ctrl_filter_value"), onChangeFilter, 2 );
			attuneElement( w1, w2 );
			globalY = filter_hidden;
			fields.push( getLastElement() );
			
			addui( new FSSimple, CMD.CTRL_FILTER_CMD, loc("ctrl_filter_value"), onChangeFilter, 3 );
			attuneElement( w1, w2 );
			globalY = filter_hidden;
			fields.push( getLastElement() );
			
			addui( new FSSimple, CMD.CTRL_FILTER_CMD, loc("ctrl_filter_value"), onChangeFilter, 4 );
			attuneElement( w1, w2 );
			fields.push( getLastElement() );
			
			filter_visible = globalY;
			
			go = new GroupOperator;
			
			go.add("bottom", drawSeparator(590) );
			
			ftable = new MFlexTable(new TAdapter);
			ftable.headers = [loc("ctrl_device"), loc("g_imei"), loc("lan_mac_adress"), loc("lan_ipadr")];
			addChild( ftable );
			ftable.x = globalX;
			ftable.y = globalY;
			ftable.width = 550;
			go.add("bottom",ftable);
			
			flist = new Array;
			
			Observer.access().register( setFilter );
			
			starterCMD = CMD.CTRL_FILTER_CMD;
		}
		override public function open():void
		{
			super.open();
			
			ResizeWatcher.addDependent(this);
			WidgetMaster.access().registerWidget(CMD.CTRL_STT_ID_VISIBLE,this);
		}
		override public function close():void
		{
			super.close();
			RequestAssembler.getInstance().fireEvent(new Request(CMD.CTRL_GET_STT_ID_VISIBLE,null,1,[0]));
			ftable.clearlist();
			flist.length = 0;
			if (spam)
				spam.kill();
			spam = null;
			
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.CTRL_FILTER_CMD:
					pdistribute(p);
					onLogic(null);
					loadComplete();
					send();
					break;
				case CMD.CTRL_STT_ID_VISIBLE:
					var isunique:Boolean = false;
					var len:int = p.length;
					for (var i:int=0; i<len; i++) {
						if ( isNotModul(p.data[i]) && isUnique(p.data[i]) ) {
							flist.push( (p.data[i] as Array) );
							isunique = true;
						}
					}
					if (isunique) {
						ftable.clearlist();
						ftable.put(flist);

						selectLineByFilter();
					}
					
					if (this.visible) {
						if(!spam) { 
							spam = TaskManager.callLater( send, TaskManager.DELAY_1SEC*25 );
						} else {
							if (!spam.running())
								spam.repeat();
						}
					}
					break;
			}
		}
		private function getFilter():String
		{
			var n:int = int(fields[0].getCellInfo());
			if (n > 0)
				return String(fields[n].getCellInfo());
			return "";
		}
		private function selectLineByFilter():void
		{
			var filter:String = getFilter();
			// Параметр 1 - Вид фильтра, 0-фильтр отключен, 1-фильтр по IMEI, 2-фильтр по MAC-адресу, 3-фильтр по IP-адресу;
			// чтобы соответвовать массиву с фильтрами надо увеличить на 1
			var type:int = int(getField(CMD.CTRL_FILTER_CMD,1).getCellInfo())+1;	 
			
			if (filter == "" || type < 2)
				ftable.selectedIndices = [];
			else {
				var len:int = flist.length;
				var found:Boolean=false;
				for (var i:int=0; i<len; i++) {
					if (filter == flist[i][type]) {
						found = true;
						break;
					}
				}
				
				if (found)
					ftable.selectedIndices = [i];
				else
					ftable.selectedIndices = [];
			}
		}
		private function onChangeFilter(t:IFormString):void
		{
			selectLineByFilter();
			if (t)
				remember(t);
		}
		private function setFilter(imei:String, mac:String, ip:String, choose:int=0):void
		{
			fields[0].setCellInfo(choose);
			fields[1].setCellInfo(imei);
			fields[2].setCellInfo(mac);
			fields[3].setCellInfo(ip);
			onLogic(fields[0]);
		}
		private function send():void
		{
			RequestAssembler.getInstance().fireEvent(new Request(CMD.CTRL_GET_STT_ID_VISIBLE,null,1,[1]));
		}
		private function onLogic(t:IFormString):void
		{
			var value:int = int(fields[0].getCellInfo());
			switch(value) {
				case 1:
				case 2:
				case 3:
					//fields[1].disabled = false;
					fields[1].visible = value == 1;
					fields[2].visible = value == 2;
					fields[3].visible = value == 3;
					go.movey("bottom",filter_visible);
					list_delta = 0;
					break;
				default:
					//fields[1].disabled = true;
					go.movey("bottom",filter_hidden);
					fields[1].visible = false;
					fields[2].visible = false;
					fields[3].visible = false;
					list_delta = filter_visible - filter_hidden;
					break;
			}
			ResizeWatcher.doResizeMe(this);
			if (t)
				remember(t);
		}
		private function isUnique(a:Array):Boolean
		{
			var len:int = flist.length;
			for (var i:int=0; i<len; i++) {
				if ( flist[i][0] == a[0] && flist[i][1] == a[1] && flist[i][2] == a[2] && flist[i][3] == a[3] )
					return false;
			}
			return true;
		}
		private function isNotModul(a:Array):Boolean
		{
			var txt:String = a[1];
			if( txt.search(/(M-R1)|(M-S1)|(M-T1)/) > -1 )
				return false;
			return true
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			ftable.height = h - (150 - list_delta);
		}
	}
}
import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridItemRenderer;
import mx.core.ClassFactory;

import components.abstract.functions.loc;
import components.gui.PopMenu;
import components.gui.triggers.TextButtonAdv;
import components.interfaces.IMTableAdapter;
import components.screens.ui.UIControlDevice;
import components.static.COLOR;
import components.system.UTIL;

class Observer
{
	private static var inst:Observer;
	public static function access():Observer
	{
		if(!inst)
			inst = new Observer;
		return inst;
	}
	
	private var callback:Function;
	
	public function register(f:Function):void
	{
		callback = f;
	}
	public function process(imei:String, mac:String, ip:String, value:String ):void
	{
		var a:Array = [];
		var b:TextButtonAdv = new TextButtonAdv;
		var selection:int=0;
		if ( imei == value)
			selection = UIControlDevice.FILTER_IMEI;
		else if ( mac == value)
			selection = UIControlDevice.FILTER_MAC;
		else if ( ip == value)
			selection = UIControlDevice.FILTER_IP;
		
		b.setUp( loc("ctrl_set_filter"), send, {imei:imei,mac:mac,ip:ip,selection:selection} );
		a.push( b );
		
		PopMenu.access().open( a );
	}
	private function send(value:Object):void
	{
		callback(value.imei,value.mac,value.ip,value.selection);
	}
}
class TAdapter implements IMTableAdapter
{
	public function adapt(a:Array, n:int):Array
	{
		return a.slice(1);
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
		if (c.dataField != loc("ctrl_device"))
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
	private var celldata:String;
	
	public function ClickableItemRenderer():void
	{
		super();
		
		addEventListener( MouseEvent.CLICK, onClick );
		this.backgroundColor = COLOR.BLUE;
	}
	override public function set text(value:String):void
	{
		if (String(value) == data[loc("g_imei")] || String(value) == data[loc("lan_mac_adress")] || String(value) == data[loc("lan_ipadr")] ) { 
			celldata = value;
			htmlText = "<textformat blockindent='8'><u>"+UTIL.wrapHtml(value, COLOR.MENU_ITEM_BLUE)+"<\u><\textformat>";
		} else
			super.text = value;
	}
	private function onClick(e:Event):void
	{
		Observer.access().process( data[loc("g_imei")], data[loc("lan_mac_adress")], data[loc("lan_ipadr")], celldata );
	}
	override public function set height(value:Number):void
	{
		super.height = value + 4;
	}
	override public function set y(value:Number):void
	{
		super.y = value-1;
	}
}