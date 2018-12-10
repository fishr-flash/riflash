package components.screens.ui
{
	import flash.utils.ByteArray;
	
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	
	import components.abstract.GroupOperator;
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.XLSServant;
	import components.basement.UI_BaseComponent;
	import components.gui.FileBrowser;
	import components.gui.PopUp;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.PAGE;
	
	public class UIHistory extends UI_BaseComponent implements IResizeDependant
	{
		private const amount:int = CLIENT.HISTORY_LINES_PER_PAGE;
		private const F_FORWARD:int = 1;
		private const F_BACK:int = 2;
		private const F_CLEAR:int = 3;
		private const F_REFRESH:int = 4;
		private const F_SAVE_SESSION:int = 5;
		
		private var FIRST_RECORD_INDEX:int;
		private var dp:Array;
		private var parser:HistoryParser;
		private var table:DataGrid;
		private var page:int;
		private var bBack:TextButton;
		private var bForward:TextButton;
		private var bClearHistory:TextButton;
		private var bSaveHistory:TextButton;
		private var bRefresh:TextButton;
		private var go:GroupOperator;
		private var requested:int;
		private var colwidth:Array;
		private var precalculatedwidth:int;
		private var his_export_counter:int;
		
		private const header:Array = [
			loc("his_k5_num"),
			loc("his_k5_time"),
			loc("his_k1_obj_num"),
			loc("his_k5_code"),
			loc("his_k5_alarm_restore"),
			loc("his_k5_event"),
			loc("his_k1_wire"),
			loc("his_k5_package"),
			loc("his_k5_crc"),
			loc("his_direction"),
			loc("his_transfered")
		]
		
		public function UIHistory()
		{
			super();
			
			globalX = PAGE.SEPARATOR_SHIFT;
			
			table = new DataGrid;
			table.draggableColumns = false;
			addChild( table );
			table.x = globalX;
			table.y = globalY;
			table.width = 900;
			table.height = 500;
			
			colwidth = [55,	0, 75, 40, 0, 0, 0, 125, 35, 0, 65];
			var col:Array = [];
			var len:int = header.length;
			for (var i:int=0; i<len; i++) {
				col.push( getDG(header[i]) );
			}
			table.columns = col;
			
			len = colwidth.length;
			for ( i=0; i<len; i++) {
				precalculatedwidth += colwidth[i];				
			}
			
			globalY += table.height + 10;
			
			go = new GroupOperator;
			
			bBack = new TextButton;
			addChild( bBack );
			bBack.x = globalX;
			bBack.y = globalY;
			bBack.setUp(loc("his_k1_back"), onClick, F_FORWARD );
			
			bForward = new TextButton;
			addChild( bForward );
			bForward.x = globalX + 100;
			bForward.y = globalY;
			bForward.setUp(loc("his_k1_forward"), onClick, F_BACK );
			
			bClearHistory = new TextButton;
			addChild( bClearHistory );
			bClearHistory.x = globalX + 200;
			bClearHistory.y = globalY;
			bClearHistory.setUp(loc("his_clear_history"), onClick, F_CLEAR );
			
			bRefresh = new TextButton;
			addChild( bRefresh );
			bRefresh.x = globalX + 380;
			bRefresh.y = globalY;
			bRefresh.setUp(loc("g_update"), onClick, F_REFRESH);
			
			bSaveHistory = new TextButton;
			addChild( bSaveHistory );
			bSaveHistory.x = globalX + 500;
			bSaveHistory.y = globalY;
			bSaveHistory.setUp(loc("his_k1_save_viewed"), onClick, F_SAVE_SESSION);
			
			parser = new HistoryParser;
			
			go.add("b", [bBack, bForward, bClearHistory, bRefresh, bSaveHistory] );
			dp = new Array;
			
			popup = PopUp.getInstance();
			
			width = 920;
			
			//var ir:MItemRenderer = new MItemRenderer;
			
			var c:ClassFactory = new ClassFactory(); 	//
			c.properties = {dataField: loc("g_number")};	// setting the custom 
			c.generator = MItemRenderer;
			
			var af:Object = table.itemRenderer;
			table.itemRenderer = c;
			
			function getDG(s:String, w:int=0):DataGridColumn
			{
				var c:DataGridColumn = new DataGridColumn(s);
				c.sortable = false;
				return c;
			}
		}
		override public function open():void
		{
			super.open();

			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_D_LINK_CHANNEL, put) );
			
			ResizeWatcher.addDependent(this);
			if (!dp[page])
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_FP_HISTORY_INDEX, put) );
			else {
				launchNewPage();
				loadComplete();
			}
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OP_D_LINK_CHANNEL:
					var ch:Array = (p.getStructure()[0] as String).split(" ");
					parser.activeChannels = 0;
					for (var i:int=0; i<8; i++) {
						if (ch[i] == i.toString()+"00")
							break;
						parser.activeChannels++; 
					}
					break;
				case CMD.OP_FP_HISTORY_INDEX:
					var a:Array = (p.getStructure()[0] as String).split(" ");
					FIRST_RECORD_INDEX = int("0x"+(a[0] as String).slice(1));
					engageReadingHistory();
					break;
				case CMD.OP_fer_HISTORY_RECORD:
					if (!dp[page])
						dp[page] = [];
					var o:Object = parser.put(p);
					if (o)
						dp[page].push( o );
					requested--;
					if (requested == 0) {
						table.dataProvider = dp[page];
						loadComplete();
						blockNavi = false;
					}
					break;
			}
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			table.height = h - 50;
			var ch:int = table.height + 20;
			go.movey( "b", ch );
			
			var cw:int = w - 23;
			
			table.width = cw > 900 ? cw : 900;
			rescaleTable();
		}
		private function rescaleTable():void
		{
			var w:int = table.width - precalculatedwidth;
			var len:int = table.columns.length;
			var cellwidth:int = w/(len-6);
			
			for (var i:int=0; i<len; i++) {
				if (colwidth[i] > 0 )
					table.columns[i].width = colwidth[i];
				else
					table.columns[i].width = cellwidth;
			}
		}
		private function onClick(value:int):void
		{
			switch(value) {
				case F_BACK:
					if (page > 0)
						page--;
					launchNewPage();
					break;
				case F_FORWARD:
					page++;
					launchNewPage();
					break;
				case F_CLEAR:
					popup.construct( PopUp.wrapHeader(LOC.loc("sys_attention")), PopUp.wrapMessage(LOC.loc("his_do_delete")), 
						PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doDelete]);
					popup.open();
					break;
				case F_REFRESH:
					dp = [];
					page = 0;
					loadStart();
					blockNavi = true;
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_FP_HISTORY_INDEX, put) );
					break;
				case F_SAVE_SESSION:
					var date:Date = new Date;
					var filename:String = "history_export_"+SERVER.VER_FULL+"_"+date.date+int(date.month+1)+date.fullYear;

					his_export_counter = 0;
					var book:Object = {};
					var len:int = dp.length;
					for (var i:int=0; i<len; i++) {
						getFormatedPage(dp[i], book);
					}
					
					 
					var bytes:ByteArray = (new XLSServant).compile(header,book);
					filename += ".xlsx";
					FileBrowser.getInstance().save(bytes, filename);
					break;
			}
		}
		
		private function getFormatedPage(a:Array, pages:Object):void
		{
			var len:int = a.length;
			var hlen:int = header.length;
			var o:Object;
			for (var i:int=0; i<len; i++) {
				o = {};
				for (var j:int=0; j<hlen; j++) {
					o[j] = getString( a[i][header[j]] );
				}
				pages[his_export_counter] = o;
				his_export_counter++;
			}
			
			function getString(s:String):String
			{
				var res:String = s.replace(/<[^>]*>/g,"");
				return res;
			}
		}
		private function doDelete():void
		{
			loadStart();
			blockNavi = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_FH_HISTORY_RECORD, onDelete ) );
			RequestAssembler.getInstance().doPing(false);
			CLIENT.NOT_REQUEST_WHILE_IDLE = true;
		}
		private function onDelete(p:Package):void
		{
			CLIENT.NOT_REQUEST_WHILE_IDLE = false;
			loadComplete();
			blockNavi = false;
			page = 0;
			dp = new Array;
			launchNewPage();
		}
		private function launchNewPage():void
		{
			if (!dp[page]) {
				
				loadStart();
				blockNavi = true;
				
				engageReadingHistory();
				
			} else
				table.dataProvider = dp[page];
		}
		private function engageReadingHistory():void
		{
			var str:int;
			for (requested=0; requested<amount; requested++) {
				str = FIRST_RECORD_INDEX-(page*amount)-requested;
				if (str < 0)
					str += 0xffff+1;
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_fer_HISTORY_RECORD, put, str) );
			}
		}
	}
}
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.Container;
import mx.core.UIComponent;

import components.abstract.functions.loc;
import components.abstract.servants.CIDServant;
import components.protocol.Package;
import components.static.COLOR;
import components.system.UTIL;

class HistoryParser
{
	public var activeChannels:int;
	
	public function put(p:Package):Object
	{
		var s:String = p.getValidStructure()[0];

		if (s && s.slice(0,2) != "31") {
			
			var time:String = s.slice(9,17)+" "+ s.slice(0,8);
			var bitfield:int = int("0x"+s.slice(18,22));
			var cid:String = s.slice(23);
			
			var a:Array = [cid.slice(0,4),cid.slice(4,6),cid.slice(6,10), cid.slice(10,12),cid.slice(12,15) ]
			var cidcrc:String = calcCIDCRC(a);
			var resultcrc:String = cid.slice(15,16) == cidcrc ? loc("g_yes"):loc("g_no");
			
			var cidevent:String = CIDServant.getCIDName(int(cid.slice(7,10) + cid.charAt(6)) );
			var tw:String = cid.charAt(6) == "1" ? loc("his_alarm"):loc("his_revert");
			var sent:String = (bitfield & (1 << 15)) > 0 ? loc("g_no"):loc("g_yes");
			var wire:String = cid.slice( 12, 15 );
			var dir:String = "";
			
			var g:Object = {
				bit1:(bitfield & (1 << 8)),
				bit2:(bitfield & (1 << 9))
			}
			
			if (bitfield != 0xffff) {
				if ( (bitfield & (1 << 8)) == 0 || (bitfield & (1 << 9)) == 0 ) {
					dir = UTIL.wrapHtml( "GPRS " + (((bitfield & (1 << 8)) == 0) ? "IP1":"IP2") );
				} else {
					if ( (bitfield & 0x00FF) << 8 != 0xff ) {
						var ch:int = bitfield & 0xFF;
						for (var i:int=0; i<8; i++) {
							// если переданный канал связи по номеру меньше чем количество активных каналом связи - канал отмечается зеленым иначе красным 
							if ( !UTIL.isBit(i,ch) )
								dir += (i < activeChannels) ? UTIL.wrapHtml( (i+1).toString(), COLOR.GREEN, 12, true ): UTIL.wrapHtml( (i+1).toString(), COLOR.RED, 12, true );
						}
					}
				}
			}
			var res:Object = {};
			res[loc("his_k5_num")] = String(p.structure);
			res[loc("his_k1_wire")] = wire;
			res[loc("his_k5_alarm_restore")] = tw;
			res[loc("his_k5_time")] = time; 
			res[loc("his_k5_package")] = cid; 
			res[loc("his_k5_crc")] = resultcrc; 
			res[loc("his_k1_obj_num")] = a[0];
			res[loc("his_k5_code")] = cid.slice(7,10);
			res[loc("his_k5_event")] = cidevent;
			res[loc("his_transfered")] = sent;
			res[loc("his_direction")] = dir;
			
			return res;
		}
		return null;//{"Номер":p.structure};
	}
	private function charLength(num:int):int
	{
		return num*4;
	}
	private function calcCIDCRC(arr:Array):String
	{
		var hash:Object = {0:10, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, "B":11, "C":12, "D":13, "E":14, "F":15};
		var hash16:Object = {0:"F",1:"1", 2:"2", 3:"3", 4:"4", 5:"5", 6:"6", 7:"7", 8:"8", 9:"9",10:"A",11:"B",12:"C",13:"D",14:"E"};
		var summ:int;
		for(var key:String in arr) {
			var target:String = String(arr[key]).toLocaleUpperCase();
			for(var i:int=0; i<target.length; ++i) {
				summ += hash[target.charAt(i)];
			}
		}
		var crc:int = Math.ceil(summ/15)*15 - summ;
		return hash16[crc];
	}
}
class MItemRenderer extends Container
{
	public var dataField:String;
	private var _data:Object;
	private var t:TextField;
	private var ui:UIComponent;
	
	public function MItemRenderer()
	{
		ui = new UIComponent;
		addChild( ui );
		
		//ui.height
		t = new TextField;
		ui.addChild( t );
		var tf:TextFormat = new TextFormat;
		tf.align = TextFormatAlign.CENTER;
		tf.font = "Tahoma";
		t.defaultTextFormat = tf;
		t.selectable = false;
		
		t.height = 20;
		ui.height = 20;
		height = 20;
	}
	override public function set styleName(value:Object):void
	{
		if (value is DataGridColumn)
			dataField = value.dataField;
		super.styleName = value;
	}
	override public function get data():Object
	{
		return _data;
	}
	
	override public function set data(value:Object):void
	{
		if (value is DataGridColumn) {
			t.text = (value as DataGridColumn).dataField;
		} else {
			if (value && dataField && value[dataField] != null) {
				if (dataField == loc("his_direction"))
					t.htmlText = value[dataField];
				else
					t.text = value[dataField];
			}
		}
		
		_data = value;
		super.data = value;
	}
	override public function set height(value:Number):void
	{
		super.height = value;
	}
	override public function set explicitWidth(value:Number):void
	{
		super.explicitWidth = value;
		t.width = value;
	}
}