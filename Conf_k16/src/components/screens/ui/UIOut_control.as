package components.screens.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Timer;
	
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptOut_ctrl3;
	import components.screens.opt.OptOut_ctrl4;
	import components.screens.opt.OptOut_ctrl5;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	import components.system.SavePerformer;
	
	public class UIOut_control extends UI_BaseComponent
	{
		private var screens:Vector.<OptionsBlock>;
		
		private var out_3:OptOut_ctrl3;
		private var out_4:OptOut_ctrl4;
		private var out_5:OptOut_ctrl5;
		private var current:OptionsBlock;
		private var request:Request;
		
		private var tSpam:Timer;
		private var currentPageNum:int;
		private var tempPageNum:int;
		private var whiteScreen:Sprite;
		
		private var overrideSize:Function;
		
		public function UIOut_control(f:Function)
		{
			super();
			
			overrideSize = f;
			
			globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT + 60;
			globalY = PAGE.CONTENT_TOP_SHIFT;
			
			var menu:Array = [ {label:loc("g_no"), data:0x00},
				{label:loc("output_amperage_off"), data:0x03},
				{label:loc("output_amperage_on"), data:0x04},
				{label:loc("output_amperage_onoff"), data:0x05} ];
			
			createUIElement( new FSComboBox, CMD.OUT_CTRL_INIT, loc("output_control_line"), switchControl, 1, menu );
			attuneElement( 280, 340, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_MULTYLINE );
			
			var sep:Separator = new Separator(620);
			addChild( sep );
			sep.y = globalY;
			sep.x = globalX;
			
			screens = new Vector.<OptionsBlock>(5);
			
			whiteScreen = new Sprite;
			addChild( whiteScreen );
			with( whiteScreen.graphics ) {
				beginFill( COLOR.WHITE, 0.6 );
				drawRect(-30,42,930, 800);
				endFill();
			}
			block( false );
		}
		override public function put(p:Package):void
		{
			getField( CMD.OUT_CTRL_INIT, 1).setCellInfo( String( p.getStructure(getStructure())[0]) );
			switchControl(null);
		}
		private function switchControl(target:IFormString):void
		{
			// Если таргет есть значит было сохранение иначе выбор при начальной загрузке
			
			this.dispatchEvent( new Event( Event.DEACTIVATE ));
			
			if(target) {
				tempPageNum = int(getField(CMD.OUT_CTRL_INIT, 1).getCellInfo());
				if (currentPageNum == tempPageNum) {
					block( false );
					SavePerformer.forget( target.cmd, getStructure() );
				} else {
					block( true );
					SavePerformer.remember( getStructure(), target );
				}
			} else {
				block( false );
				SavePerformer.trigger( {"prepare":prepare} );
				currentPageNum = int(getField(CMD.OUT_CTRL_INIT, 1).getCellInfo());
			}
			
			var bit:int=0;
			var spamCMD:int;
			getField(CMD.OUT_CTRL_INIT, 1).disabled = true;
			switch( getField(CMD.OUT_CTRL_INIT, 1).getCellInfo() ) {
				case "3":	// 	По току в выключенном состоянии
					//SavePerformer.LOADING = target == null;
					bit |= ( 1 << getStructure()-1 );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT,  null, 1,[0,0,bit,0] ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_OFF_LEVEL, ctrl3, getStructure() ));
					overrideSize(950, 630);
					break;
				case "4":	//	По току во включенном состоянии
					//SavePerformer.LOADING = target == null;
					bit |= ( 1 << getStructure()-1 );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT,  null, 1,[0,bit,0,0] ) );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_ON_LEVEL, ctrl4, getStructure() ));
					overrideSize(950, 630);
					break;
				case "5": 	//	По току в выключенном/включенном состоянии
					request = null;
					//SavePerformer.LOADING = target == null;
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_OFF_LEVEL, ctrl5, getStructure() ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_ON_LEVEL, ctrl5, getStructure() ));
					overrideSize(950, 780);
					break;
				default:
					closeAll();
					overrideSize(840, 0);
					getField(CMD.OUT_CTRL_INIT, 1).disabled = false;
			}
			
			// если нет таргета, значит был выбор при начальной загрузке, значит надо 
			if (!target)
				releaseRequest();
		}
		public function putOutCtrlState(p:Package):void
		{
			if(current)
				current.putState([ p.cmd, p.getStructure() ]);
		}
		public function set structure(value:int):void
		{
			structureID = value;
			refreshCells( CMD.OUT_CTRL_INIT );
		}
		private function closeAll():void
		{
			callVisualizer(null);
		}
		private function ctrl3(p:Package):void
		{
			if(!out_3) {
				out_3 = new OptOut_ctrl3;
				addChild( out_3 );
				
				out_3.y = 70;
				out_3.x = globalX;
				screens[3] = out_3;
			}
			current = out_3;
			out_3.putRawData( [getStructure(), p.getStructure() ] );
			//SavePerformer.LOADING = false;
			callVisualizer( out_3 );
			getField(CMD.OUT_CTRL_INIT, 1).disabled = false;
		}
		private function ctrl4(p:Package):void
		{
			if(!out_4) {
				out_4 = new OptOut_ctrl4;
				addChild( out_4 );
				
				out_4.y = 70;
				out_4.x = globalX;
				screens[4] = out_4;
			}
			current = out_4;
			out_4.putRawData( [getStructure(), p.getStructure() ] );
			//SavePerformer.LOADING = false;
			callVisualizer( out_4 );
			getField(CMD.OUT_CTRL_INIT, 1).disabled = false;
		}
		private function ctrl5(p:Package):void
		{
			if(!out_5) {
				out_5 = new OptOut_ctrl5;
				addChild( out_5 );
				
				out_5.y = 70;
				out_5.x = globalX;
				screens[5] = out_5;
				out_5.focusable = !whiteScreen.visible;
			}
			current = out_5;
			out_5.putRawData( [getStructure(), p.cmd, p.getStructure() ] );
			//SavePerformer.LOADING = false;
			callVisualizer( out_5 );
			getField(CMD.OUT_CTRL_INIT, 1).disabled = false;
		}
		private function callVisualizer(opt:OptionsBlock):void
		{
			this.visible = true;
			this.dispatchEvent( new Event( Event.ACTIVATE ));
			var len:int = screens.length;
			for(var i:int=0; i<len; ++i) {
				if ( screens[i] is OptionsBlock)
					screens[i].visible = Boolean(opt == screens[i]);
			}
			setChildIndex( whiteScreen, this.numChildren-1);
		}
		private function releaseRequest():void
		{
	/*		if (request)
				RequestAssembler.getInstance().fireEvent( request );
			*/
		}
		private function prepare():void
		{
			releaseRequest();
			block( false );
			currentPageNum = tempPageNum;
		}
		private function block(b:Boolean):void
		{
			whiteScreen.visible = b;
			if( out_5  )
				out_5.focusable = !b;
		}
	}
}