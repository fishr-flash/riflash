package components.screens.ui
{
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.screens.opt.OptEnergyModeDebug;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIEModeDebug extends UI_BaseComponent
	{
		private var bApply:TextButton;
		private var opt1:OptEnergyModeDebug;
		private var opt2:OptEnergyModeDebug;
		private var assemblege:Array;
		
		public function UIEModeDebug()
		{
			super();
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, "Номер режима", black, 1 );
			
			bApply = new TextButton;
			addChild( bApply );
			bApply.x = 350;
			bApply.y = getLastElement().y;
			bApply.setUp( "Apply", call );
			
			opt1 = new OptEnergyModeDebug( 11 );
			addChild( opt1 );
			opt1.x = globalX;
			opt1.y = globalY;
			
			opt2 = new OptEnergyModeDebug( 12 );
			addChild( opt2 );
			opt2.x = globalX + 370;
			opt2.y = globalY;
			
			if ( DS.isDevice(DS.V5) || DS.isDevice(DS.V6)  ) {
				starterCMD = [CMD.VR_WORKMODE_SET,CMD.VR_WORKMODE_START,CMD.VR_WORKMODE_MOVE,
					CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR,
					CMD.VR_WORKMODE_SCHEDULE ];
			} else {
				starterCMD = [CMD.VR_WORKMODE_SET,CMD.VR_WORKMODE_ENGINE_START,CMD.VR_WORKMODE_ENGINE_RUNS,
					CMD.VR_WORKMODE_ENGINE_STOP, CMD.VR_WORKMODE_START, CMD.VR_WORKMODE_MOVE,
					CMD.VR_WORKMODE_STOP, CMD.VR_WORKMODE_PARK, CMD.VR_WORKMODE_REGULAR,
					CMD.VR_WORKMODE_SCHEDULE ];
			}
			
			assemblege = [];
		}
		override public function put(p:Package):void
		{
			assemblege[p.cmd] = p.data;
			if (p.cmd == CMD.VR_WORKMODE_SCHEDULE)
				loadComplete();
		}
		private function call():void
		{
			var mode:int = int( getField(0,1).getCellInfo() ); 
			if (mode > 0 && mode < 7) {
				var str2:int = mode*2;
				var str1:int = str2-1;
				
				opt1.putAssemblege( assemblege, str1 );
				opt2.putAssemblege( assemblege, str2 );
			}
		}
		private function black():void	{}
	}
}