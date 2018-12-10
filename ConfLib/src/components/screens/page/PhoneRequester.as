package components.screens.page
{
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;

	public class PhoneRequester extends UIComponent implements IServiceFrame
	{
		private var sep:Separator;
		private var bRun:TextButton;
		private var fsText:FSSimple;
		private var isblock:Boolean;
		private var task:ITask;
		
		public function PhoneRequester()
		{
			fsText = new FSSimple;
			fsText.setUp( onChange );
			fsText.setName( loc("service_get_sim_tel_and_send") );
			fsText.setWidth( 400 );
			fsText.setCellWidth( 250 );
			fsText.restrict("+0-9", 20 );
			fsText.attune( FSSimple.F_MULTYLINE );
			addChild( fsText );
			fsText.y = 5;
			
			bRun = new TextButton;
			addChild( bRun );
			bRun.x = 670;
			bRun.y = 5;
			bRun.setUp( loc("g_runcmd"), onRun );
			
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 38+9+5;
		}
		override public function get height():Number
		{
			return 59+13;
		}
		override public function get width():Number
		{
			return bRun.getWidth() + bRun.x + 40;
		}
		public function close():void
		{
			if (task)
				task.kill();
			task = null;
		}
		public function getLoadSequence():Array
		{
			return null;
		}
		public function init():void
		{
			if( String(fsText.getCellInfo()).length == 0)
				fsText.setCellInfo("+7")
			if( !CLIENT.IS_WRITING_FIRMWARE )
				isblock = false;
			block(isblock);
			onChange();
		}
		public function isLast():void
		{
			sep.visible = false;
		}
		public function put(p:Package):void
		{
		}
		
		public function block(b:Boolean):void
		{
			isblock = b;
			bRun.disabled = b || String(fsText.getCellInfo()).length < 3;
		}
		private function onChange():void
		{
			bRun.disabled = String(fsText.getCellInfo()).length < 3 || isblock;
		}
		private function onRun():void
		{
			if (String(fsText.getCellInfo()).length >= 3) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_PHONE_OVER_SMS, null, 1, [fsText.getCellInfo(), generate()]));
				if (!task)
					task = TaskManager.callLater( onRelease, TaskManager.DELAY_5SEC );
				else
					task.repeat();
				bRun.disabled = true;
			}
		}
		private function onRelease():void
		{
			block(isblock);
		}
		private function generate():String
		{
			var s:String = "";
			while(s.length < 6)
				s += int(Math.random()*10);
			return s;
		}
	}
}