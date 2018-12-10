package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.MFlexListSelectable;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Indent;
	import components.interfaces.IFormString;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.SavePerformer;
	
	public class UIWiFiConnect extends UI_BaseComponent implements IResizeDependant
	{
		private const DISCONNECT:int = 1;
		private const CONNECT_AND_REMEMBER:int = 2;
		
		private var bConnect:TextButton;
		private var bDisconnect:TextButton;
		private var g:GroupOperator;
		private var task:ITask;
		private var taskESP:ITask;
		private var lastSSID:String;
		private var flist:MFlexListSelectable;
		
		private var overrideFirstSSID:String;
		
		public function UIWiFiConnect()
		{
			super();
			
			toplevel = false;
			
			globalFocusGroup = TabOperator.GROUP_BUTTONS + UIWifiMenu.S_WIFI_CONNECT*1000 + 100;
			
			addui( new FSShadow, CMD.ESP_CONNECT_NET, "2", null, 1 );
			addui( new FSShadow, CMD.ESP_CONNECT_NET, "1", null, 2 );
			
			var header:Header;
			if (DS.isK14s)
				header = new Header( [{label:loc("ui_wifi_ssid"),xpos:50},{label:loc("g_pass"), xpos:220, width:60},
					{label:loc("g_show_pass"), xpos:403, align:"center", width:210}], {size:12} );
			else
				header = new Header( [{label:loc("ui_wifi_ssid"),xpos:50},{label:loc("g_pass"), xpos:220, width:60},
					{label:loc("ui_wifi_autoconnect"), xpos:430, width:210}], {size:12} );
			
			addChild( header );
			header.x = globalX;
			header.y = 15;
			
			globalY += 40;
			
			flist = new MFlexListSelectable(OptWiFiLine);
			addChild( flist );
			flist.width = 550;
			flist.x = globalX;
			flist.y = globalY;
			flist.addEventListener( GUIEvents.EVOKE_READY, onSelect );
			
			g = new GroupOperator;
			
			g.add("b",drawSeparator(574));
			
			if (!DS.isK14s) {
			
				bConnect = new TextButton;
				addChild( bConnect );
				bConnect.x = globalX;
				bConnect.y = globalY;
				bConnect.setUp( loc("ui_wifi_do_connect"), onClick, 1 );
				g.add("b",bConnect);
				g.add("d",bConnect);
				bConnect.focusgroup = globalFocusGroup;
			}
			
			FLAG_SAVABLE = false;
			
			if (DS.isK14s) {
				addui( new FSCheckBox, 0, "", onShowPass, 1 ).x = globalX + 410+67;
				attuneElement( 0 );
				getLastElement().y = 50;
			} else {
				addui( new FSCheckBox, 0, loc("g_show_pass"), onShowPass, 1 ).x = globalX + 207;
				attuneElement( 186 );
				g.add("b",getLastElement());
				getLastElement().focusgroup = globalFocusGroup;
			
				var i:Indent = new Indent(38);
				addChild( i );
				i.x = globalX;
				i.y = globalY;
				g.add("b",i);
				
				var s:SimpleTextField = new SimpleTextField(
					loc("ui_wifi_use_wpa2"), 500);
				addChild( s );
				s.setSimpleFormat("left", 5 );
				s.x = globalX + 15;
				s.y = globalY;
				g.add("b",s);
				globalY += 50;
				
				g.add("b",drawSeparator(574));
			}
				
			addui( new FSSimple, CMD.ESP_GET_NET, loc("ui_wifi_connected"), null, 1 );
			attuneElement( 140, 400, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			
			if (!DS.isK14s) {
				bDisconnect = new TextButton;
				addChild( bDisconnect );
				bDisconnect.x = globalX;
				bDisconnect.y = globalY;
				bDisconnect.setUp( loc("g_disconnect"), onClick, 2 );
				
				g.add("1", [getLastElement(), bDisconnect] );
				g.add("b", [getLastElement(), bDisconnect] );
				
				bDisconnect.focusgroup = globalFocusGroup;
			}

			g.visible("1", false);
			
			starterCMD = [CMD.ESP_SET_NET, CMD.ESP_GET_NET];
		}
		override public function open():void
		{
			super.open();
			lastSSID = null;
			ResizeWatcher.addDependent(this);
		//	var f:IFormString = getField( CMD.ESP_SET_NET, 2);
		//	(f as FormString).displayAsPassword( true )
			getField(0,1).setCellInfo(0);
			onShowPass();
			//bConnect.disabled = true;
			g.disabled("d",true);
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
			if (taskESP)
				taskESP.kill();
			taskESP = null;
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.ESP_SET_NET:
					flist.put(p);
					ResizeWatcher.doResizeMe(this);
					break;
				case CMD.ESP_GET_NET:
					distribute(p.getStructure(), p.cmd );
					g.visible("1",p.getStructure()[0] != "");
					if (lastSSID is String) {	// последний ssid не null только если была попытка коннекта или дисконнекта 
												// когда значение в GET_NET поменяется надо прекратить спам	
						if (lastSSID != p.getStructure()[0])
							task.stop();
						else
							task.repeat();
					}
					if (overrideFirstSSID is String) {	// если был переход 
						var opt:OptWiFiLine = flist.getLine(0) as OptWiFiLine;
						if (opt)
							opt.setSSID(overrideFirstSSID);
						overrideFirstSSID = null;
					}
					if ( !DS.isVgr ) {
						if (!taskESP)
							taskESP = TaskManager.callLater( onTimer, TaskManager.DELAY_5SEC );
						else
							taskESP.repeat();
					}
					break;
			}
		}
		public function fillFirstWifi(ssid:String):void
		{
			overrideFirstSSID = ssid; 
		}
		private function onSelect(e:Event):void
		{
			//bConnect.disabled = false;
			g.disabled("d",false);
		}
		private function onShowPass():void
		{
			if (flist)
				flist.putEvery( int(getField(0,1).getCellInfo())==0 );
		}
		private function onClick(n:int):void
		{
			var f:IFormString;
			switch(n) {
				case 1:
					var opt:OptWiFiLine = flist.getSelected() as OptWiFiLine;
					if (!opt && flist.length == 1 )
						opt = flist.getLine(0) as OptWiFiLine;
					
					if (opt) {
						opt.alwaysReconnect();
						getField( CMD.ESP_CONNECT_NET, 1 ).setCellInfo(CONNECT_AND_REMEMBER);
							
						f = getField( CMD.ESP_CONNECT_NET, 2 );
						f.setCellInfo(opt.getStructure());
						remember(f);
						
						if (!task)
							task = TaskManager.callLater( onTimer, TaskManager.DELAY_2SEC );
						else
							task.repeat();
						lastSSID = String(getField(CMD.ESP_GET_NET,1).getCellInfo());
						SavePerformer.save();
						
						initShutDownSequence();
					}
					break;
				case 2:
					getField( CMD.ESP_CONNECT_NET, 1 ).setCellInfo(DISCONNECT);
					f = getField( CMD.ESP_CONNECT_NET, 2 );
					f.setCellInfo(0);
					remember(f);
					if (!task)
						task = TaskManager.callLater( onTimer, TaskManager.DELAY_2SEC );
					else
						task.repeat();
					lastSSID = String(getField(CMD.ESP_GET_NET,1).getCellInfo());
					SavePerformer.save();
					
					initShutDownSequence();
					
					break;
			}
		}
		private function initShutDownSequence():void
		{
			loadStart();
			blockNavi = true;
			TaskManager.callLater( SocketProcessor.getInstance().disconnect, TaskManager.DELAY_1SEC*2 );
		}
		private function onTimer():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.ESP_GET_NET,put));
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			flist.height = h - 280;
			if (flist.height > flist.length*30)
				flist.height = flist.length*30;
			g.movey("b", flist.height + 70 );
		}
	}
}
import components.abstract.servants.TabOperator;
import components.basement.OptionListBlock;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FSShadow;
import components.gui.fields.FormString;
import components.interfaces.IFlexListItem;
import components.interfaces.IFocusable;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;
import components.static.DS;

class OptWiFiLine extends OptionListBlock implements IFlexListItem
{
	public function OptWiFiLine(s:int)
	{
		super();
		
		structureID = s;
		globalFocusGroup = 13010;
		
		FLAG_VERTICAL_PLACEMENT = false;
		addui( new FormString, CMD.ESP_SET_NET, "", null, 1, null, "", 32 );
		attuneElement(NaN,NaN,FormString.F_EDITABLE);
		addui( new FormString, CMD.ESP_SET_NET, "", null, 2, null, "", 32 ).x = globalX + 210;
		attuneElement(NaN,NaN,FormString.F_EDITABLE);
		(getLastElement() as FormString).displayAsPassword( true )
		FLAG_VERTICAL_PLACEMENT = true;
		if (DS.isK14s)
			addui( new FSShadow, CMD.ESP_SET_NET, "", null, 3 ).x = globalX + 520 - 43;
		else
			addui( new FSCheckBox, CMD.ESP_SET_NET, "", null, 3 ).x = globalX + 520 - 43;
		attuneElement(0);
		
		SELECTION_Y_SHIFT = -1;
		
		drawSelection(510);
	}
	public function alwaysReconnect():void
	{
		var f:IFormString = getField( CMD.ESP_SET_NET, 3);
		getField( CMD.ESP_SET_NET, 3);
		f.setCellInfo(1);
		remember(f);
	}
	public function change(p:Package):void
	{
		
	}
	public function setSSID(value:String):void
	{
		getField(CMD.ESP_SET_NET,1).setCellInfo(value);
		getField(CMD.ESP_SET_NET,2).setCellInfo("");
		TabOperator.getInst().iNeedFocus( getField(CMD.ESP_SET_NET,2) as IFocusable );
		remember( getField(CMD.ESP_SET_NET,1) );
	}
	public function extract():Array
	{
		return [structureID, getField(CMD.ESP_SET_NET,1).getCellInfo()];
	}
	public function isSelected():Boolean
	{
		return selection.visible;
	}
	public function kill():void
	{
		
	}
	public function put(p:Package):void
	{
		pdistribute(p);
	}
	public function putRaw(value:Object):void
	{
		var b:Boolean = Boolean(value);
		
		var f:IFormString = getField( CMD.ESP_SET_NET, 2);
		(f as FormString).displayAsPassword( b )
	}
	public function set selectLine(b:Boolean):void
	{
		selection.visible = b;
	}
}