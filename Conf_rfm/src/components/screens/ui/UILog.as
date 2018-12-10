package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.LogWidget;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.gui.FileBrowser;
	import components.gui.MFlexTable;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UILog extends UI_BaseComponent implements IResizeDependant
	{
		private var ftable:MFlexTable;
		private var hdata:Array;
		private var rfd:Array;
		private var alarms_p4:Array;
		private var alarms_p5:Array;
		private var index:int;
		private var btns:Vector.<TextButton>;
		private var go:GroupOperator;
		private var headers:Array;
		private var isFreezed:Boolean;
		
		public function UILog()
		{
			super();

			headers = [[loc("his_exp_index"),80], loc("log_date"),loc("log_sensor_or_trinket"), [loc("g_number"),60], 
				[loc("g_event"),250],loc("log_weakening")+" 1,"+loc("measure_power"),loc("log_weakening")+" 2,"+loc("measure_power") ];
			
			ftable = new MFlexTable();
			addChild( ftable );
			ftable.width = 900;
			ftable.height = 200;
			ftable.x = globalX;
			ftable.y = globalY;
			ftable.headers = headers;

			go = new GroupOperator;
			go.add("1",	drawSeparator(940));
			addButton( loc("evlog_clear"), globalX );
			addButton( loc("log_save_txt"), globalX + 200);
			addButton( loc("rfd_log_pause"), globalX + 420);
		}
		override public function open():void
		{
			super.open();
			
			isFreezed = false;
			btns[2].setName(loc("rfd_log_pause"));
			ResizeWatcher.addDependent(this);
			loadComplete();
			ftable.resize();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_GET_MAPRF_LOG,	null,1,[30],Request.SYSTEM ));
			LogWidget.access().register(write);
		}
		
		public function write(a:Array):void
		{
			if( !hdata )
				hdata = new Array;
			ftable.insertStack(a);
			hdata = a.concat(hdata);
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			ftable.height = h - 90;
			
			go.movey("1", h - 65 );
		}
		private function addButton(ttl:String, xpos:int):void
		{
			if (!btns)
				btns = new Vector.<TextButton>;
			var i:int = btns.length;
			btns.push( new TextButton );
			addChild( btns[i] );
			btns[i].x = xpos;
			btns[i].y = globalY;
			btns[i].setUp(ttl,onClick,i);
			go.add("1",btns[i] );
		}
		private function onClick(n:int):void
		{
			switch(n) {
				case 0:	// clear
					//RequestAssembler.getInstance().fireEvent(new Request(CMD.CTRL_MAPRF_LOG,put));
					ftable.clearlist();
					hdata = [];
					index = 0;
					break;
				case 1:	// save
					//RequestAssembler.getInstance().fireEvent(new Request(CMD.CTRL_MAPRF_LOG,put));
					
					if (hdata.length > 0) {
						
						var len:int = hdata.length;
						var s:String = "";
						
						for (var j:int=0; j<7; j++) {
							s += String(headers[j]).replace("\r","") +"\t";
						}
						s += "\r";
						for (var i:int=0; i<len; i++) {
							for (j=0; j<7; j++) {
								s += hdata[i][j] +"\t";
							}
							s += "\r";
						}
						FileBrowser.getInstance().save( s, "log_"+UTIL.getDataStringWod()+".txt" );
					}
				case 2:	// freeze
					if(isFreezed) {
						LogWidget.access().register(write);
						btns[2].setName(loc("rfd_log_pause"));
					} else {
						LogWidget.access().register(null);
						btns[2].setName(loc("rfd_log_unpause"));
					}
					isFreezed = !isFreezed;
					break;
			}
		}
	}
}