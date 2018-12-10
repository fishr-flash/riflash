package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.screens.ui.UIVersion;
	import components.static.COLOR;
	
	public final class OptVpn extends OptionsBlock
	{
		public function OptVpn()
		{
			super();
			structureID = 1;
			yshift = 0;
			
			createUIElement( new FSSimple, 0, loc("lan_vpn"),null,1);
			attuneElement( UIVersion.shift, 200 , FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK);
			createUIElement( new FSSimple, 0, loc("lan_ipadr"),null,2);
			attuneElement( UIVersion.shift, 200 , FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK);
			
			complexHeight = 80;
		}
		override public function putData(p:Package):void
		{
			var txt:String; 
			var f:FSSimple = (getField( 0,1) as FSSimple);
			if (p.getStructure()[0] == 1) {
				txt = loc("lan_connected");
				getField( 0,2).visible = true;
			} else {
				txt = loc("lan_disconnected");
				getField( 0,2).visible = false;
			}
			f.setCellInfo( txt );
			
			getField(0,2).setCellInfo( p.getStructure()[1] );
		}
	}
}