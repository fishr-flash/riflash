package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	
	public class UIVerInfoSimple extends UI_BaseComponent
	{
		public function UIVerInfoSimple()
		{
			super();
			
			var shift:int = 220;
			var clr:uint = COLOR.GREEN_DARK;
			
			createUIElement( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_device_name"),null,1);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			createUIElement( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_fw_ver"),null,2);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			
			starterCMD = CMD.VER_INFO;
		}
		override public function put(p:Package):void
		{
			var data:Array = p.getStructure().slice();
			getField( CMD.VER_INFO,1 ).setCellInfo( data[0] );
			getField( CMD.VER_INFO,2 ).setCellInfo( data[1] + " "+DS.getCommit());
			loadComplete();
		}
	}
}