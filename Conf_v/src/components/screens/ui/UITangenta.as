package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UITangenta extends UI_BaseComponent
	{
		public function UITangenta()
		{
			super();
			
			starterCMD = CMD.VR_TANGENTA;
			
			createUIElement( new FSCheckBox, CMD.VR_TANGENTA, loc("tangenta_dispatcher_on"), onAction, 1 );
			attuneElement( 500 );
			/*FLAG_SAVABLE = false;
			createUIElement( new FormString, 9, loc("tangenta_auto_answer"), null, 1 );
			attuneElement( 550,NaN, FormString.F_MULTYLINE );
			FLAG_SAVABLE = true;*/
			drawSeparator(553);
			
			var l:Array = UTIL.getComboBoxList( [[0, loc("tangenta_no_limit")], 15, 30, 60, 120 ] );
			createUIElement( new FSComboBox, CMD.VR_TANGENTA, loc("tangenta_voice_limited"), null, 2, l,
				"0-9",3,new RegExp( RegExpCollection.REF_0and5to255_f ));
			attuneElement( 400-17, 130 );
			
			createUIElement( new FSShadow, CMD.VR_TANGENTA, "", null, 3 );
			
			if( DS.isDevice( DS.V_ASN ) )
			{
				drawSeparator(553);
				createUIElement( new FSSimple, CMD.VR_EGTS_DISPATCH_CENTER_NUM, loc( "num_to_out_call" ), null, 1, null, "+0-9", 20 );
				attuneElement( 330-17, 200 );
				
				starterRefine( CMD.VR_EGTS_DISPATCH_CENTER_NUM, true );
			}
			
			
			
		}
		override public function put(p:Package):void
		{
			
			switch( p.cmd ) {
				case CMD.VR_EGTS_DISPATCH_CENTER_NUM:
					distribute(p.getStructure(),p.cmd);
					break;
				case CMD.VR_TANGENTA:
					distribute(p.getStructure(),p.cmd);		
					onAction();
					loadComplete();
					break;
				default:
					break;
			}
			
			
			
		}
		private function onAction(t:IFormString=null):void
		{
			getField(CMD.VR_TANGENTA,2).disabled = Boolean(int(getField(CMD.VR_TANGENTA,1).getCellInfo()) == 0);
			if (t)
				SavePerformer.remember( getStructure(), t );
		}
	}
}