package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class UITest extends UI_BaseComponent
	{
		public function UITest()
		{
			super();
			
			createUIElement( new FSSimple, CMD.TEST_K2, loc("test_volume_state"), null, 1 );
			attuneElement( 300, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			createUIElement( new FSSimple, CMD.TEST_K2, loc("test_add_wire"), null, 2 );
			attuneElement( 300, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			createUIElement( new FSSimple, CMD.TEST_K2, loc("test_tamper"), null, 3 );
			attuneElement( 300, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			
			starterCMD = CMD.TEST_K2;
		}
		
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			initSpamTimer( p.cmd, 1, true, null, 1000 );
			loadComplete();
		}
		override protected function processState(p:Package):void 
		{
			super.processState(p);
			distribute( p.getStructure(), p.cmd );
		}
		override protected function distribute(data:Array, cmd:int):void
		{
			fill( getField(cmd,1) as FSSimple, data[0] );
			fill( getField(cmd,2) as FSSimple, data[1] );
			fill( getField(cmd,3) as FSSimple, data[2] );
		}
		private function fill(t:FSSimple, value:int):void
		{
			switch(value) {
				case 0:
					t.setTextColor( COLOR.GREEN_SIGNAL );
					t.setCellInfo( loc("test_norm") );
					break;
				case 1:
					t.setTextColor( COLOR.RED );
					t.setCellInfo( loc("test_violation") );					
					break;
				case 2:
					t.setTextColor( COLOR.BLACK );
					t.setCellInfo( loc("g_disabled_m") );
					break;
				default:
					t.setTextColor( COLOR.BLACK );
					t.setCellInfo( loc("g_unkwn") );
					break;
			}
		}
	}
}