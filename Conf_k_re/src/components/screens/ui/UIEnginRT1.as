package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.opt.OptREngineNumb;
	import components.static.CMD;
	
	public class UIEnginRT1 extends UI_BaseComponent
	{
		private var screens:Vector.<OptREngineNumb>;
		
		public function UIEnginRT1()
		{
			super();
			
			screens = new Vector.<OptREngineNumb>;
			var opt:OptREngineNumb;
			for(var i:int=0; i<5; ++i) {
				opt = new OptREngineNumb(i+1);
				addChild( opt );
				opt.y = globalY;
				opt.x = globalX;
				globalY += opt.getHeight();
				screens.push( opt); 
			}
			drawSeparator(311);
			createUIElement( new FSCheckBox, CMD.ENGIN_ALL, loc("ui_engin_allow_config_from_anytel"),onBlock,1 );
		//	(getLastElement() as FormString).leading = 0;
			attuneElement( 258,NaN, FormString.F_MULTYLINE );
			
			starterCMD = [CMD.K5_EPHONE,CMD.ENGIN_ALL];
			width = 300;
			height = 290;
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.K5_EPHONE:
					for(var i:int=0; i<5; ++i) {
						screens[i].putRawData( p.getStructure(i+1) );
					}
					break;
				case CMD.ENGIN_ALL:
					pdistribute(p);
					onBlock(null);
					loadComplete();
					break;
			}
		}
		private function onBlock(t:IFormString):void
		{
			var d:Boolean = getField(CMD.ENGIN_ALL,1).getCellInfo() == 1;
			var len:int = screens.length;
			for (var i:int=0; i<len; i++) {
				screens[i].disabled = d;
			}
			if(t)
				remember(t);
		}
	}
}