package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.screens.opt.OptEngineNumb;
	import components.static.CMD;
	
	public class UIEngin extends UI_BaseComponent
	{
		private var screens:Vector.<OptEngineNumb>;
		public function UIEngin()
		{
			super();

			screens = new Vector.<OptEngineNumb>;
			var opt:OptEngineNumb;
			for(var i:int=0; i<8; ++i) {
				opt = new OptEngineNumb(i+1);
				addChild( opt );
				opt.y = globalY;
				opt.x = globalX;
				globalY += opt.getHeight();
				screens.push( opt); 
			}
			globalY += 10;
			drawSeparator(311);
			createUIElement( new FSCheckBox, CMD.ENGIN_ALL, loc("ui_engin_allow_config_from_anytel"),null,1 );
			attuneElement( 258,NaN, FormString.F_MULTYLINE );
			
			FLAG_SAVABLE = false;
			globalY += 30;
			createUIElement( new FormString, 0, loc("ui_engin_list_empty"),null,1 );
			attuneElement( 400, NaN, FormString.F_MULTYLINE );
			
			starterCMD = [CMD.ENGIN_NUMB,CMD.ENGIN_ALL];
			width = 400;
			height = 390;
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.ENGIN_NUMB:
					for(var i:int=0; i<8; ++i) {
						screens[i].putRawData( p.getStructure(i+1) );
					}
					break;
				case CMD.ENGIN_ALL:
					getField( p.cmd, 1 ).setCellInfo( String(p.getStructure()) );
					loadComplete();
					break;
			}
		}
	}
}