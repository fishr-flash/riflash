package components.screens.ui
{
	import components.abstract.servants.TaskManager;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptVerInfo;
	import components.screens.opt.OptVerInfoWiFi;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	
	public class UIVerInfoTrakker extends UIVersion
	{
		private var infos:Vector.<OptVerInfo>;
		private var infoWiFi:OptVerInfoWiFi;
		private var task:ITask;
		private var task30:ITask;
		
		public function UIVerInfoTrakker()
		{
			super(3,8);
			
			height = 530;
			
			starterCMD = [CMD.VER_INFO1,CMD.WIFI_GET_NET];
		}
		override public function close():void
		{
			super.close();
			
			if (task)
				task.kill();
			task = null;
			if (task30)
				task30.kill();
			task30 = null;
		}
		override public function put(p:Package):void
		{
			var len:int, i:int;
			switch(p.cmd) {
				case CMD.WIFI_GET_NET:
					if (!infoWiFi) {
						drawSeparator();
						
						infoWiFi = new OptVerInfoWiFi(true);
						addChild( infoWiFi );
						infoWiFi.x = PAGE.CONTENT_LEFT_SHIFT;
						infoWiFi.y = globalY;
					}
					
					infoWiFi.putData(p);
					if (!task30) {
						task30 = TaskManager.callLater( onTick, TaskManager.DELAY_2SEC*15 );
						loadComplete();
					} else
						task30.repeat();
					break;
				case CMD.VER_INFO1:
					
					var vinfo:Array = OPERATOR.dataModel.getData( CMD.VER_INFO )[0];
					getField( CMD.VER_INFO,1 ).setCellInfo( vinfo[0] );
					getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] + " "+DS.getCommit() );
					
					var vinfo1:Array = p.getStructure().slice();
					//getField( p.cmd ,1 ).setCellInfo( vinfo1[0] );
					//getField( p.cmd ,2 ).setCellInfo( vinfo1[1] );
					//getField( p.cmd ,3 ).setCellInfo( vinfo1[2] );
					getField( p.cmd ,4 ).setCellInfo( vinfo1[3] );
					
					len = p.length;
					if (!infos) {
						var opt:OptVerInfo;
						infos = new Vector.<OptVerInfo>;
						for( i=0; i<len; ++i ) {
							opt = new OptVerInfo(i+1);
							addChild( opt );
							opt.y = globalY;//199+(i)*opt.getHeight();
							globalY += opt.getHeight();
							opt.x = globalX;
							opt.putRawData( p.getStructure(i+1) );
							infos.push(opt);
						}
					} else {
						for( i=0; i<len; ++i ) {
							infos[i].putRawData( p.getStructure(i+1) );
						}
					}
					onTick();
					break;
				case CMD.GSM_SIG_LEV:
					len = p.length;
					for( i=0; i<len; ++i ) {
						if( infos[i] != null && p.getStructure(i+1) is Array )
							infos[i].putState( p.getStructure(i+1) );
					}
					
					if (!task)
						task = TaskManager.callLater( onTick, TaskManager.DELAY_2SEC );
					else
						task.repeat();
					break;
			}
		}
		private function onTick():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.GSM_SIG_LEV, put));
		}
		private function onTick30():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.WIFI_GET_NET, put));
		}
	}
}