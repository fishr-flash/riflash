package components.screens.opt
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.Header;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.gui.visual.out.LevelPanelOff;
	import components.gui.visual.out.LevelPanelOn;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIOutK16;
	import components.static.CMD;
	import components.system.Library;
	import components.system.SavePerformer;
	
	public class OptOut_ctrl5 extends OptionsBlock
	{
		private var picOnOff:Bitmap;
		private var panel_on:LevelPanelOn;
		private var panel_off:LevelPanelOff;
		private var switched_on:Boolean=true;
		private var bSwitchOff:TextButton;
		private var bSwitchOn:TextButton;
		private var on:Boolean;

		public function OptOut_ctrl5()
		{
			super();
			
			var header:Header = new Header( [{label:loc("output_config_control_limits"),align:"left",xpos:10,width:300}], {size:12} );
			addChild( header );
			
			panel_on = new LevelPanelOn;
			addChild( panel_on );
			panel_on.y = 200+20;
			panel_on.x = 10;
			var arr:Array = [ {label:loc("wire_cut"),color:0x1C75BC}, {label:loc("wire_norm"),color:0x009444},{label:loc("wire_short_circuit"),color:0xF15A29}];
			panel_on.build( arr );
			
			panel_off = new LevelPanelOff;
			addChild( panel_off );
			panel_off.y = 80;
			panel_off.x = 10;
			panel_off.build( arr );
			
			bSwitchOff = new TextButton;
			addChild( bSwitchOff );
			bSwitchOff.setUp( loc("output_configure_offline_out"), switchAction, 0 );
			bSwitchOff.x = 730;
			bSwitchOff.y = 72;
			
			bSwitchOn = new TextButton;
			addChild( bSwitchOn );
			bSwitchOn.setUp( loc("output_configure_online_out"), switchAction, 1 );
			bSwitchOn.x = 730;
			bSwitchOn.y = 192+20;
			bSwitchOn.disabled = true;
			
			var sep:Separator = new Separator(530);
			addChild( sep );
			sep.y = 300+20;
			
			FLAG_SAVABLE = false;
			globalY = 320+20;
			globalX = 80;
			createUIElement( new FormString, 0, loc("output_schema1"),null,1);
			attuneElement( 500 );
			
			picOnOff = new Library.cPicOff;
			addChild( picOnOff );
			picOnOff.y = 350 + 20;

			FLAG_SAVABLE = true;
			var aLevelFields:Array = panel_on.getFields();
			var keya:String
			for( keya in aLevelFields ) {
				addUIElement( (aLevelFields[keya] as FormEmpty), CMD.OUT_ON_LEVEL, int(keya)+1, null, getStructure() ); 
			}
			panel_on.addEventListener( Event.CHANGE, levelOnChanged );
			
			aLevelFields = panel_off.getFields();
			for( keya in aLevelFields ) {
				addUIElement( (aLevelFields[keya] as FormEmpty), CMD.OUT_OFF_LEVEL, int(keya)+1, null, getStructure() ); 
			}
			panel_off.addEventListener( Event.CHANGE, levelOffChanged );
			FLAG_SAVABLE = false;
		}
		public function set focusable(b:Boolean):void
		{
			bSwitchOff.focusable = b; 
			bSwitchOn.focusable = b;
		}
		private function levelOnChanged(ev:Event=null):void
		{
			SavePerformer.remember( getStructure(), panel_on.getTarget() );
		}
		private function levelOffChanged(ev:Event=null):void
		{
			SavePerformer.remember( getStructure(), panel_off.getTarget() );
		}
		override public function putRawData(a:Array):void
		{
			structureID = a[0];
			refreshCells( a[1] );
			switch( a[1] ) {
				case CMD.OUT_ON_LEVEL:
					panel_on.edges( a[2][3], a[2][0] );
					panel_on.structureID = structureID;
					panel_on.put( (a[2] as Array).reverse() );
					break;
				case CMD.OUT_OFF_LEVEL:
					panel_off.edges( a[2][3], a[2][0] );
					panel_off.structureID = structureID;
					panel_off.put( (a[2] as Array).reverse() );
					break;
			}
		}
		override public function putState(re:Array):void
		{
			switch( re[0] ) {
				case CMD.OUT_CTRL_STATE:
					
 					on = (UIOutK16.OUT_BITFIELD & 1 << (structureID-1))>0
					
					panel_on.putWireResistance( re[1][1], on );
					panel_off.putWireResistance( re[1][0], !on );
					
					if (on) { 	// включено
						bSwitchOn.disabled = true;
						bSwitchOff.disabled = false;
					} else {					// вЫключено
						bSwitchOn.disabled = false;
						bSwitchOff.disabled = true;
					}					
					break;
			}
		}
		private function switchAction(value:int):void
		{
			var bit:int=0;
			switch(value) {
				case 0:
					bit |= ( 1 << getStructure()-1 );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT, null, 1,[0,0,bit,0] ));
					break;
				case 1:
					bit |= ( 1 << getStructure()-1 );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT, null, 1,[0,bit,0,0] ));
					break;
			}
		}
	}
}