package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	
	public class OptVerInfoModem extends OptionsBlock
	{
		public function OptVerInfoModem( structure:int )
		{
			super();
			
			init( structure);
		}
		
		private function init( structure:int  ):void
		{
			operatingCMD = CMD.VER_INFO1;
			structureID = structure;
			
			drawSeparator(UIVersion.sepwidth);
			
			createUIElement( new FSSimple, operatingCMD, loc("ui_verinfo_modem") + " " + structureID,null,2);
			attuneElement( UIVersion.shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( UIVersion.clr );
			createUIElement( new FSSimple, operatingCMD, loc("ui_verinfo_modem_fw_ver"),null,3);
			attuneElement( UIVersion.shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( UIVersion.clr );
			createUIElement( new FSSimple, operatingCMD, loc("ui_verinfo_imei"),null,4);
			attuneElement( UIVersion.shift, 170, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( UIVersion.clr );
			
			
			complexHeight = globalY-7;
			
		}
		
		override public function putRawData( data:Array ):void
		{
			
			
			getField( operatingCMD ,2 ).setCellInfo( data[1] );
			getField( operatingCMD ,3 ).setCellInfo( data[2] );
			getField( operatingCMD ,4 ).setCellInfo( data[3] );
		}
	}
}