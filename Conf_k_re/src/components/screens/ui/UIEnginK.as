package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.opt.OptREngineNumb;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIEnginK extends UI_BaseComponent
	{
		private var screens:Vector.<OptREngineNumb>;
		private var fsSwitch:FSCheckBox;
		
		public function UIEnginK()
		{
			super();

			if (DS.isfam( DS.K5 )) {
				addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 1 );
				fsSwitch = addui( new FSCheckBox, CMD.K5_BIT_SWITCHES, loc("ui_engin_on"), onSwitch, 2 ) as FSCheckBox;
				attuneElement( 259 );
				(getLastElement() as FSCheckBox).bitnum = 5;
				addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 3 );
			} else {
				fsSwitch = addui( new FSCheckBox, CMD.K9_BIT_SWITCHES, loc("ui_engin_on"), onSwitch, 1 ) as FSCheckBox;
				attuneElement( 259 );
				(getLastElement() as FSCheckBox).bitnum = 5;
				addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 2 );
			}
			
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
			globalY += 10;
			
			if (DS.isfam( DS.K5 )) 
				starterCMD = [CMD.K5_EPHONE,CMD.K5_BIT_SWITCHES];
			else
				starterCMD = [CMD.K5_EPHONE,CMD.K9_BIT_SWITCHES];
			width = 400;
			height = 390;
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.K5_EPHONE:
					for(var i:int=0; i<5; ++i) {
						screens[i].putRawData( p.getStructure(i+1) );
					}
					break;
				case CMD.K5_BIT_SWITCHES:
				case CMD.K9_BIT_SWITCHES:
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					onSwitch(null);
					loadComplete();
					break;
			}
		}
		private function onSwitch(t:IFormString):void
		{
			var len:int = screens.length;
			for (var i:int=0; i<len; i++) {
				screens[i].disabled = !fsSwitch.selected;
			}
			if (t)
				remember(t);
		}
	}
}
/*
import components.abstract.adapters.StringCutterAdapter;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSShadow;
import components.gui.fields.FSSimple;
import components.static.CMD;

class OptREngineNumb extends OptionsBlock
{
	public function OptREngineNumb(_struc:int)
	{
		super();
		
		yshift = 5;
		structureID = _struc;
		operatingCMD = CMD.K5_EPHONE;
		addui( new FSShadow, operatingCMD, "", null, 1 );
		addui( new FSSimple, operatingCMD, loc("g_number")+" "+_struc,null,2,null,"0-9+", 20 );
		getLastElement().setAdapter( new StringCutterAdapter( getField(operatingCMD,1) ));
		attuneElement( 70, 200 );
		
		complexHeight = globalY;
	}
	override public function putRawData(a:Array):void
	{
		getField( operatingCMD,1).setCellInfo( String( a[0] ) );
		getField( operatingCMD,2).setCellInfo( String( a[1] ) );
	}
	public function set disabled(b:Boolean):void
	{
		getField(operatingCMD,2).disabled = b;
	}
}
*/