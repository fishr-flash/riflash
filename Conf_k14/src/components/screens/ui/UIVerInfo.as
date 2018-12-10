package components.screens.ui
{
	import components.abstract.servants.TaskManager;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptBatLevel;
	import components.screens.opt.OptVerInfo;
	import components.static.CMD;
	import components.static.PAGE;
	
	public class UIVerInfo extends UIVersion
	{
		private var infos:Vector.<OptVerInfo>;
		private var counter:int;
		private var task:ITask;

		private var optBatLevel:OptBatLevel;
		
		
		public function UIVerInfo()
		{
			super(7,15);
			
			height = 840;
			width = 430;
			
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
		}
		override public function open():void
		{
			super.open();
			
			if (!task)
				task = TaskManager.callLater(onRequestSignal,TaskManager.DELAY_2SEC);
			else
				task.repeat();
		}
		override public function put(p:Package):void
		{
			super.put(p);
			var len:int = p.length;
			var i:int;
			switch(p.cmd) {
				case CMD.VER_INFO1:
					var opt:OptVerInfo;
					if (!infos) {
						infos = new Vector.<OptVerInfo>;
						for( i=0; i<len; ++i ) {
							opt = new OptVerInfo(i+1);
							addChild( opt );
							opt.y = globalY+i*opt.getHeight();
							opt.x = PAGE.CONTENT_LEFT_SHIFT;
							infos.push(opt);
						}
						
						optBatLevel = new OptBatLevel();
						this.addChild( optBatLevel );
						optBatLevel.y = opt.y + opt.getHeight();
						optBatLevel.x = PAGE.CONTENT_LEFT_SHIFT;
					}
					for( i=0; i<len; ++i ) {
						infos[i].putRawData( p.getStructure(i+1) );
					}
					
					
					
					loadComplete();
					break;
				case CMD.GSM_SIG_LEV:
					for( i=0; i<len; ++i ) {
						if( infos[i] != null && p.getStructure(i+1) is Array )
							infos[i].putState( p.getStructure(i+1) );
					}
					
					if( task )task.repeat();
					
					break;
				case CMD.BATTERY_LEVEL:
					
					if( optBatLevel )optBatLevel.putData( p );
					break;
			}
		}
		private function onRequestSignal():void
		{
			if( task )
			{
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GSM_SIG_LEV,put));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.BATTERY_LEVEL,put));
			}
			if (counter > 3) {
				counter = 0;
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO1,put));
			} else
				counter++;
		}
	}
}