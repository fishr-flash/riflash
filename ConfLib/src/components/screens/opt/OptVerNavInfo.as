package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class OptVerNavInfo extends OptionsBlock
	{
		public function OptVerNavInfo()
		{
			super();
			
			var shift:int = UIVersion.shift;
			var clr:uint = COLOR.GREEN_DARK;
			
			createUIElement( new FSSimple, CMD.NAV_INFO, loc("gps_type"),null,1);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			globalY-=5;
			createUIElement( new FSSimple, CMD.NAV_INFO, loc("g_ver"),null,2);
			attuneElement( shift, 500, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			
			complexHeight = globalY-7;
		}
		override public function putData(p:Package):void
		{
			if(p.getParamString(1).toLocaleLowerCase() == "unknow" && p.getParamString(2).toLocaleLowerCase() == "unknow" ) {
				getField(p.cmd,1).setCellInfo("Telit");
				getField(p.cmd,2).setCellInfo("Telit");
			} else
				distribute(p.getStructure(),p.cmd);
		}
	}
}