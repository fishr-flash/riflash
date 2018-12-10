package components.screens.ui
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.gui.Balloon;
	import components.gui.fields.FSButton;
	import components.gui.triggers.TextButton;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptWiFi;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIVerInfo extends UIVersion
	{
		private var opts:Vector.<OptWiFi>;
		private var task:ITask;
		private var bLink:TextButton;
		
		public function UIVerInfo()
		{
			super(3);
			
			addui( new FSButton, CMD.RITM_LINK_ID, loc("ritm_link"), onClick, 1 );
			attuneElement( shift );

			var sepw:int = 420;
			drawSeparator(sepw);
			
			opts = new Vector.<OptWiFi>(3);
			
			for (var i:int=0; i<3; i++) {
				opts[i] = new OptWiFi(i+1,shift);
				addChild( opts[i] );
				opts[i].x = globalX;
				opts[i].y = globalY;
				globalY += opts[i].complexHeight;
			}
			
			starterCMD = [CMD.RITM_LINK_ID, CMD.ESP_INFO];
		}
		override public function put(p:Package):void
		{
			var data:Array;
			switch (p.cmd) {
				case CMD.RITM_LINK_ID:
					pdistribute(p);
					break;
				case CMD.ESP_INFO:
					for (var i:int=0; i<3; i++) {
						opts[i].putData(p);
					}
					
					getField( CMD.VER_INFO,1 ).setCellInfo( DS.name);
					getField( CMD.VER_INFO,2 ).setCellInfo( DS.getFullVersion() + " "+DS.getCommit());
					
					loadComplete();
					
					if (this.visible) {
						if (!task)
							task = TaskManager.callLater(request, TaskManager.DELAY_1SEC*5 );
						else
							task.repeat();
					}
					break;
			}
		}
		override public function close():void
		{
			super.close();
			
			if (task)
				task.kill();
			task = null;
		}
		private function request():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.ESP_INFO,put));
		}
		private function onClick():void
		{
			var s:String = String(getField(CMD.RITM_LINK_ID,1).getCellInfo());
			Clipboard.generalClipboard.clear();
			var result:Boolean = Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, s);
			
			if (result)
				Balloon.access().shownote( loc("ritm_link") + " "+ loc("options_in_buffer") );
			else
				Balloon.access().shownote( loc("sys_error_happens") );
		}
	}
}