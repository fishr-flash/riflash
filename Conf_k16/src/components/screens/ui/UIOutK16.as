package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptOut;
	import components.screens.opt.OptOut_patternK16;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.SavePerformer;
	
	public final class UIOutK16 extends UI_BaseComponent
	{
		public static var OUT_BITFIELD:int;
		
		private var opt:OptOut;
		private var opt_pattern:OptOut_patternK16;
		private var ui_control:UIOut_control;
		private var structure_memory:int;

		public function UIOutK16()
		{
			super();
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			
			initNavi();
			
			navi.setUp( openOut, 10 );
			navi.x = 10;
			navi.width = PAGE.SECONDMENU_WIDTH;
			navi.height = 200;
			
			navi.addTree( loc("rfd_output")+" 1", 1, [loc("output_ctrl"),loc("output_handling")] );
			navi.addTree( loc("rfd_output")+" 2", 2, [loc("output_ctrl"),loc("output_handling")] );
			navi.addTree( loc("rfd_output")+" 3", 3, [loc("output_ctrl"),loc("output_handling")] );
			
			opt = new OptOut;
			addChild( opt );
			opt.visible = false;
			opt.x = globalX;
			
			opt_pattern = new OptOut_patternK16(resize);
			addChild( opt_pattern );
			opt_pattern.visible = false;
			opt_pattern.x = globalX;
			
			ui_control = new UIOut_control(resize);
			addChild( ui_control );
			ui_control.visible = false;
			ui_control.x = globalX;
			
			SavePerformer.addCMDParam( CMD.OUT_OFF_LEVEL, SavePerformer.INVERT_SAVE, true );
			SavePerformer.addCMDParam( CMD.OUT_ON_LEVEL, SavePerformer.INVERT_SAVE, true );
			SavePerformer.addCMDParam( CMD.OUT_EXP_LEVEL, SavePerformer.INVERT_SAVE, true );
			
			ui_control.addEventListener( Event.ACTIVATE, onLoaded );
			ui_control.addEventListener( Event.DEACTIVATE, onLoad );
		}
		override public function close():void
		{
			super.close();
			navi.selection = 0;
		}
		private function openOut( value:Object ):void
		{
			if (!navi.isReady)
				return;
			navi.isReady = false;
			opt.visible = false;
			opt_pattern.visible = false;
			ui_control.visible = false;
			
			SavePerformer.closePage();
			structure_memory = value.num;
			
			switch ( value.sub ) {
				case 0:
					navi.isReady = true;
					opt.putRawData([value.num]);
					opt.visible = true;
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT, processState, 1,[1,0,0,0] ));
					initSpamTimer( CMD.OUT_FUNCT, 1,false, [1,0,0,0] );
					ui_control.close();
					changeSecondLabel(loc("ui_rfrelay_config_output")+" "+value.num );
					width = 500;
					height = 0;
					break
				case 1:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_CTRL_INIT, processControl ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT, processState, 1,[1,0,0,0] ));
					ui_control.structure = value.num;
					changeSecondLabel(loc("ui_rfrelay_config_output")+" "+value.num+". " +loc("output_ctrl"));
					initSpamTimer( CMD.OUT_FUNCT, 1,false, [1,0,0,0] );
					break;
				case 2:
					deactivateSpamTimer();
					if( OPERATOR.dataModel.getData( CMD.OUT_INDPART ) == null ) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_PERMANENTLY_ON, processPatterns ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_INDPART, processPatterns ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_INDMES, processPatterns ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_ALARM1, processPatterns ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_ALARM2, processPatterns ));
					} else
						openOutPattern();
					ui_control.close();
					changeSecondLabel(loc("ui_rfrelay_config_output")+" "+value.num+". "+loc("output_handling") );
					break;
			}
		}
		private function processControl(p:Package):void
		{
			if (this.visible)
				ui_control.put( p );
		}
		private function onLoaded(e:Event):void
		{
			navi.isReady = true;
		}
		private function onLoad(e:Event):void
		{
			navi.isReady = false;
		}
		private function processPatterns(p:Package):void
		{
			if ( p.cmd == CMD.OUT_ALARM2 )
				openOutPattern();
		}
		private function openOutPattern():void
		{
			if( opt_pattern.getStructure() != structure_memory )
				opt_pattern.structure = structure_memory;
			
			var array_adress:int = opt_pattern.getStructure()-1;
			
			var pattern:Array = OPERATOR.dataModel.getData( CMD.OUT_INDPART );
			var pack:Array = new Array;
			pack.push( pattern[array_adress] );
			pattern = OPERATOR.dataModel.getData( CMD.OUT_ALARM1 );
			pack.push( pattern[array_adress] );
			pattern = OPERATOR.dataModel.getData( CMD.OUT_PERMANENTLY_ON );
			pack.push( pattern[array_adress] );
			pattern = OPERATOR.dataModel.getData( CMD.OUT_INDMES );
			pack.push( pattern[array_adress] );
			opt_pattern.putRawData( pack );
			opt_pattern.visible = true;
			navi.isReady = true;
		}
		override public function open():void 
		{
			super.open();
			var page:Object = {num:1, sub:0};
			navi.isReady = true;
			navi.tree_selection = page
			openOut( page );
			loadComplete();
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if (this.visible) {
				if( p.success ) {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_STATE, processState ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_CTRL_STATE, processState, structure_memory ));
				} else {
					opt.putData(p);
					if (p.cmd == CMD.OUT_CTRL_STATE)
						ui_control.putOutCtrlState(p);
				}
			}
		}
		private function resize(w:int, h:int):void
		{
			width = w;
			height = h;
		}
	}
}