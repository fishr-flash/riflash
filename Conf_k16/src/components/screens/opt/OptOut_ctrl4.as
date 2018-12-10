package components.screens.opt
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import components.abstract.OutServantOn;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.Header;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.gui.visual.out.LevelPanelOn;
	import components.static.CMD;
	import components.system.Library;
	import components.system.SavePerformer;
	
	public class OptOut_ctrl4 extends OptionsBlock
	{
		private var panel:LevelPanelOn;
		
		private var pic:Bitmap;
		
		public function OptOut_ctrl4()
		{
			super();
			
			operatingCMD = CMD.OUT_ON_LEVEL;
			var header:Header = new Header( [{label:loc("output_config_control_limits"),align:"left",xpos:10,width:300}], {size:12} );
			addChild( header );
			
			panel = new LevelPanelOn;
			addChild( panel );
			panel.y = 80;
			panel.x = 10;
			var arr:Array = [ {label:loc("wire_cut"),color:0x1C75BC}, {label:loc("wire_norm"),color:0x009444},{label:loc("wire_short_circuit"),color:0xF15A29}];
			panel.build( arr );
			
			var sep:Separator = new Separator(530);
			addChild( sep );
			sep.y = 160+20;
			
			FLAG_SAVABLE = false;
			globalY = 180+20;
			globalX = 80;
			createUIElement( new FormString, 0, loc("output_schema1"),null,1);
			attuneElement( 500 );
			
			pic = new Library.cPicOn;
			addChild( pic );
			pic.y = 210+20;
			
			FLAG_SAVABLE = true;
			var aLevelFields:Array = panel.getFields();
			for( var keya:String in aLevelFields ) {
				addUIElement( (aLevelFields[keya] as FormEmpty), operatingCMD, int(keya)+1, null, getStructure() ); 
			}
			panel.addEventListener( Event.CHANGE, levelChanged );
			FLAG_SAVABLE = false;
		}
		private function levelChanged(ev:Event=null):void
		{
			SavePerformer.remember( getStructure(), panel.getTarget() );
		}
		override public function putRawData(a:Array):void
		{
			structureID = a[0];
			
			panel.edges( a[1][3], a[1][0] );
			
			refreshCells( operatingCMD );
			panel.structureID = structureID;
			panel.put( (a[1] as Array).reverse() );
		}
		override public function putState(re:Array):void
		{
			if (re[0] == CMD.OUT_CTRL_STATE ) {
				panel.putWireResistance( re[1][4] == 0 ? 1 : re[1][1] );
			}
		}
	}
}