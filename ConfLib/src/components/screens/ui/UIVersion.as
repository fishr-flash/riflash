package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UIVersion extends UI_BaseComponent
	{
		public static var shift:int = 300;
		public static var sepwidth:int = 530;
		public static var clr:uint = COLOR.GREEN_DARK;
		
		/** bitv - битовая маска полей VER_INFO, bitv1 битовая маска полей VER_INFO1	*/
		public function UIVersion(bitv:int, bitv1:int=0xff)
		{
			super();
			
			FLAG_SAVABLE = false;
			
			/* VER_INFO		*******/
			if (UTIL.isBit(0,bitv)) {
				addui( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_device_name"),null,1);
				attuneElement( shift, 500, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT );
				(getLastElement() as FSSimple).setTextColor( clr );
			} else
				addui( new FSShadow, CMD.VER_INFO, "", null, 1 );
			if (UTIL.isBit(1,bitv)) {	
				addui( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_fw_ver"),null,2);
				attuneElement( shift, 500, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT );
				(getLastElement() as FSSimple).setTextColor( clr );
			} else
				addui( new FSShadow, CMD.VER_INFO, "", null, 2 );
			if (UTIL.isBit(2,bitv)) {
				addui( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_memory_type"),null,3);
				attuneElement( shift, 500, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT );
				(getLastElement() as FSSimple).setTextColor( clr );
			} else
				addui( new FSShadow, CMD.VER_INFO, "", null, 3 );
			
			
			if (bitv1 != 0xff) {
				
				drawSeparator(sepwidth);
				
				/* VER_INFO1	*******/
				if (UTIL.isBit(0,bitv1)) {
					addui( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_conn_type"),null,1);
					attuneElement( shift, 500, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( clr );
				} else
					addui( new FSShadow, CMD.VER_INFO1, "", null, 1 );
				if (UTIL.isBit(1,bitv1)) {
					addui( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_modem"),null,2);
					attuneElement( shift, 500, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( clr );
				} else
					addui( new FSShadow, CMD.VER_INFO1, "", null, 2 );
				if (UTIL.isBit(2,bitv1)) {
					addui( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_modem_fw_ver"),null,3);
					attuneElement( shift, 500, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( clr );
				} else
					addui( new FSShadow, CMD.VER_INFO1, "", null, 3 );
				if (UTIL.isBit(3,bitv1)) {
					addui( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_imei"),null,4);
					attuneElement( shift, 500, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( clr );
				} else
					addui( new FSShadow, CMD.VER_INFO1, "", null, 4 );
				
				starterCMD = [CMD.VER_INFO1];
			}
		}
		override public function open():void
		{
			super.open();
			
			var vinfo:Array = OPERATOR.getData( CMD.VER_INFO )[0];
			getField( CMD.VER_INFO,1 ).setCellInfo( loc( DS.name ) );
			
			getField( CMD.VER_INFO,2 ).setCellInfo( DS.getFullVersion() + " "+DS.getCommit() );
			getField( CMD.VER_INFO,3 ).setCellInfo( vinfo[2] )
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VER_INFO1:
					getField( p.cmd ,1 ).setCellInfo( p.getParamString(1) );
					getField( p.cmd ,2 ).setCellInfo( p.getParamString(2) );
					getField( p.cmd ,3 ).setCellInfo( p.getParamString(3) );
					getField( p.cmd ,4 ).setCellInfo( p.getParamString(4) );
					break;
			}
		}
	}
}