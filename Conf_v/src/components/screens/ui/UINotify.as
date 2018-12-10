package components.screens.ui
{
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.screens.opt.OptNotify;
	import components.static.CMD;
	import components.system.Library;
	
	public class UINotify extends UI_BaseComponent
	{
		private var opts:Vector.<OptNotify>;
		
		public function UINotify()
		{
			super();
			
			var len:int = 3;
			var icons:Array = [Library.v_call1, Library.v_call2, Library.v_alarm];
			
			globalY += 10;
			
			opts = new Vector.<OptNotify>(len);
			for (var i:int=0; i<len; ++i) {
				opts[i] = new OptNotify(i+1, icons[i] );
				addChild( opts[i] );
				opts[i].x = globalX;
				opts[i].y = globalY;
				globalY += 40;
			}
			
			drawSeparator(745);
			
			
			starterCMD = [CMD.VR_NOTIFICATION ];
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VR_NOTIFICATION:
					var len:int = opts.length;
					for (var i:int=0; i<len; ++i) {
						opts[i].putData(p);
					}
					loadComplete();
					break;
				
			}
		}
	}
}