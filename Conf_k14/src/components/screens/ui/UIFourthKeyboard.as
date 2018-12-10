package components.screens.ui
{
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.screens.opt.OptFKeyboard;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIFourthKeyboard extends UI_BaseComponent
	{

		private var opt:OptFKeyboard;
		public function UIFourthKeyboard()
		{
			//TODO: implement function
			super();
			
			
			init();
		}
		
		private function init():void
		{
			
			opt = new OptFKeyboard( false );
			
			
			
			
			
			addChild( opt );
			//opt.visible = false;
			
			starterCMD = [ CMD.RF_KEY ];
			
			if( DS.isDevice( DS.K14K ) || DS.isDevice( DS.K14KW ) ) starterRefine( CMD.LED_IND );
			
			
			
		}	
		
		
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.RF_KEY:
					const countStrct:int = p.data.length;
					var fake:Package = new Package();
					fake.structure = countStrct;
					fake.data = [ p.getStructure( countStrct ) ] ;
					
					opt.putData( fake );
					
					break;
				case CMD.LED_IND:
					opt.putModeData( p );
					break;
				default:
					break;
			}
			
			loadComplete();
		}
		
	}
}