package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.PAGE;
	
	public class OptVerInfoMain extends OptionsBlock
	{
		public function OptVerInfoMain()
		{
			super();
			
			var shift:int = 190 + PAGE.CONTENT_LEFT_SHIFT;
			yshift = 0;
			addui( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_device_name"), null, 1 );
			attuneElement( shift, 300, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			
			addui( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_fw_ver"), null, 2 );
			attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			
			complexHeight = globalY + 10;
		}
		override public function putData(p:Package):void
		{
			var vinfo:Array = OPERATOR.dataModel.getData( CMD.VER_INFO )[0];
			getField( CMD.VER_INFO,1 ).setCellInfo( vinfo[0] );
			getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] + " "+DS.getCommit() );
		}
	}
}