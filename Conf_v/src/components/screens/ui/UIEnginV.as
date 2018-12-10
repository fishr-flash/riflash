package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.screens.opt.OptEngineNumb;
	import components.static.CMD;
	
	public class UIEnginV extends UI_BaseComponent
	{
		private var screens:Vector.<OptEngineNumb>;
		public function UIEnginV()
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
			(getLastElement() as FormString).leading = 0;
			attuneElement( 258,NaN, FormString.F_MULTYLINE );
			
			starterCMD = [CMD.ENGIN_NUMB,CMD.ENGIN_ALL];
			width = 300;
			height = 290;
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