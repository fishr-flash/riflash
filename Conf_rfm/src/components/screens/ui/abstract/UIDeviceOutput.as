package components.screens.ui.abstract
{
	import flash.display.DisplayObject;
	
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.interfaces.IBaseComponent;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.MISC;
	import components.system.SavePerformer;
	
	public class UIDeviceOutput extends UI_BaseComponent implements IWidget
	{
		protected var opts:Vector.<IBaseComponent>;
		private var lastscreen:int;
		protected var lastcmd:int;
		
		public function UIDeviceOutput()
		{
			super();
			
			initNavi();
			navi.setUp( onChoose, 50 );
			
			var len:int = OPERATOR.dataModel.getData(CMD.CTRL_COUNT_OUT)[0][0];
			for (var i:int=0; i<len; i++) {
				navi.addButton( getButtonTitle(i+1), i, TabOperator.GROUP_BUTTONS + ((i+1) * 1000) );
			}
			opts = new Vector.<IBaseComponent>(len);
			
			manualResize();
		}
		override public function put(p:Package):void
		{
			
			
			switch(p.cmd) {
				
				case lastcmd:
					loadComplete();
					navi.selection = lastscreen;
					onChoose( lastscreen );
					WidgetMaster.access().registerWidget(CMD.CTRL_DOUT_SENSOR, this );
					send();
					
					break;
				default:
					
					
					var len:int = opts.length;
					for (var i:int=0; i<len; i++) {
						
						if( opts[i] )
							opts[i].put(p);
					}
					
			}
			
			manualResize();
		}
		override public function close():void
		{
			super.close();
			onChoose(-1);
			WidgetMaster.access().unregisterWidget(CMD.CTRL_DOUT_SENSOR );
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_GET_SENSOR,null,1,[0] ));
		}
		protected function getTitle():String
		{
			return "";
		}
		protected function getClass(str:int):IBaseComponent
		{
			return null;
		}
		protected function getSecondLabel(str:int):String
		{
			return getTitle()+" "+ str;
		}
		protected function getButtonTitle(str:int):String
		{
			return getTitle()+" "+str;
		}
		private function onChoose(n:int):void
		{
			SavePerformer.closePage();
			if (n>=0) {
				if (!opts[n]) {
					opts[n] = getClass(n+1);
					addChild( opts[n] as DisplayObject );
				}
				lastscreen = n;
				opts[n].open();
				
				var len:int = opts.length;
				for (var i:int=0; i<len; i++) {
					if (opts[i]) {
						opts[i].visible = n == i;
						if (n == i)
							changeSecondLabel( getSecondLabel(n+1) );
						else
							opts[i].close();
					}
				}
			}
			
			
			
			manualResize();
		}
		private function send():void
		{
			if (MISC.COPY_DEBUG && MISC.SPAM_DISABLED)
				return;
			runTask(send, TaskManager.DELAY_20SEC);
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_GET_SENSOR,null,1,[CLIENT.BIN2_RECEIVE_TIME] ));
		}
	}
}