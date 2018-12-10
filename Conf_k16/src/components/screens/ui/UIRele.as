package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptRele;
	import components.screens.opt.OptReleWire_pattern;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.SavePerformer;

	public class UIRele extends UI_BaseComponent
	{
		private var opt:OptRele;
		private var opt_pattern:OptReleWire_pattern;
		private var relay:int;
		
		public static const SWITCH_NONE:int = 0x00;
		public static const SWITCH_RELAY_INDPART:int = 0x01;
		public static const SWITCH_RELAY_ALARM:int = 0x02;
		public static const SWITCH_RELAY_INDMES:int = 0x03;
		public static const SWITCH_RELAY_PERMANENT:int = 0x04;
		
		public function UIRele()
		{
			super();
			
			initNavi();
			navi.setUp( openRele, 10 );
			navi.x = 10;
			navi.width = PAGE.SECONDMENU_WIDTH;
			navi.height = 200;
			
			navi.addTree( loc("relay"), 1, [loc("rfd_output")+" 1",loc("rfd_output")+" 2",loc("rfd_output")+" 3",loc("rfd_output")+" 4",loc("rfd_output")+" 5"] );
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			
			opt = new OptRele;
			addChild( opt );
			opt.visible = false;
			opt.x = globalX;
			opt.y = globalY;
			width = 650;
			height = 380;
		}
		override public function open():void
		{
			super.open();
			if (opt.visible)
				initSpamTimer( CMD.RELAY_FUNCT,1,false,[1,0,0,0] );
			navi.isReady = true;
			navi.tree_selection = {num:1, sub:0};
			loadComplete();
		}
		override public function close():void 
		{
			super.close();
			navi.selection = 0;
		}
		private function openRele( value:Object ):void
		{
			if (navi.isReady)
				navi.isReady = false;
			
			SavePerformer.closePage();
			switch(value.sub) {
				case 0:
					if(opt_pattern)
						opt_pattern.visible = false;
					opt.visible = true;
					if (!isSpamTimer())
						initSpamTimer( CMD.RELAY_FUNCT,1,false,[1,0,0,0] );
					changeSecondLabel(loc("rfd_relay_out_state") );
					navi.isReady = true;
					break;
				default:
					relay = value.sub-1;
					if( OPERATOR.dataModel.getData( CMD.RELAY_INDPART ) == null ) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDPART, openSuccess ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_INDMES, openSuccess ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_PERMANENTLY_ON, openSuccess ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_ALARM1, openSuccess ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_ALARM2, openSuccess ));
					} else
						openPattern();
					break;
			}
		}
		protected function openSuccess( p:Package ):void
		{
			if(opt_pattern)
				opt_pattern.visible = false;
			opt.visible = false;
			
			switch( p.cmd ) {
				case CMD.RELAY_INDPART:
					if(!opt_pattern) {
						opt_pattern = new OptReleWire_pattern;
						opt_pattern.visible = false;
						addChild( opt_pattern );
						opt_pattern.x = 10;
						opt_pattern.y = 10;
					}
				case CMD.RELAY_INDMES:
				case CMD.RELAY_PERMANENTLY_ON:
				case CMD.RELAY_ALARM1:
				case CMD.RELAY_ALARM2:
					if ( p.cmd == CMD.RELAY_ALARM2 )
						openPattern();
					break;
			}
		}
		private function openPattern():void
		{
			opt.visible = false;
			
			opt_pattern.structure = relay+1;
			var pattern:Array = OPERATOR.dataModel.getData( CMD.RELAY_INDPART );
			var pack:Array = new Array;
			pack.push( pattern[relay] );
			pattern = OPERATOR.dataModel.getData( CMD.RELAY_ALARM1 );
			pack.push( pattern[relay] );
			pattern = OPERATOR.dataModel.getData( CMD.RELAY_INDMES );
			pack.push( pattern[relay] );
			pattern = OPERATOR.dataModel.getData( CMD.RELAY_PERMANENTLY_ON);
			pack.push( pattern[relay] );
			opt_pattern.putRawData( pack );
			opt_pattern.visible = true;
			
			changeSecondLabel( loc("ui_rfrelay_config_output")+" "+(relay+1) );
			
			navi.isReady = true;
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if (this.visible) {
				if(opt.visible) {
					if( p.cmd == CMD.RELAY_STATE )
						opt.putState( p.getStructure() );
					else
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_STATE, processState ));
				} else
					deactivateSpamTimer();
			}
		}
	}
}