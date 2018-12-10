package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptOut_patternK14;
	import components.static.CMD;
	import components.static.DS;
	
	// Версия для 7 контакта
	
	public class UIOut extends UI_BaseComponent
	{
		private var selection:int=1;
		private var opt_pattern:OptOut_patternK14;
		
		public function UIOut(amount:int)
		{
			super();
			
			initNavi();
			navi.setUp( openOut, 40 );
			navi.setXOffset(50);
			var i:int;
			
			switch(DS.alias) {
				case DS.K14L:
				case DS.K14A:
					for (i=0; i<amount; ++i) {
						if (i==0)
							navi.addButton( loc("zummer_siren"), (i+1), 1000*i );
						else
							navi.addButton( loc("rfd_output")+" "+i, (i+1), 1000*i );
					}
					break;
				default:
					for (i=0; i<amount; ++i) {
						navi.addButton( loc("rfd_output")+" "+(i+1), (i+1), 1000*i );
					}
					break;
			}
			
			opt_pattern = new OptOut_patternK14;
			addChild( opt_pattern );
			opt_pattern.visible = false;
			opt_pattern.x = globalX;

			starterCMD = [CMD.OUT_INDPART,CMD.OUT_ALARM1,CMD.OUT_ALARM2];
		}
		override public function put(p:Package):void
		{
			if ( p.cmd == CMD.OUT_ALARM2 ) {
				navi.selection = selection;
				openOut(selection);
				loadComplete();
			}
		}
		private function openOut(num:int):void
		{
			selection = num;
			
			if( opt_pattern.getStructure() != selection )
				opt_pattern.structure = selection;
			
			var array_adress:int = opt_pattern.getStructure()-1;
			
			var pattern:Array = OPERATOR.dataModel.getData( CMD.OUT_INDPART );
			var pack:Array = new Array;
			pack.push( pattern[array_adress] );
			pattern = OPERATOR.dataModel.getData( CMD.OUT_ALARM1 );
			pack.push( pattern[array_adress] );
			opt_pattern.putRawData( pack );
			opt_pattern.visible = true;
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if( p.success ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_STATE, processState ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_CTRL_STATE, processState, selection ));
			}
		}
	}
}