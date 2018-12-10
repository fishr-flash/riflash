package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.Library;
	import components.system.SensorConst;
	
	public class UISensorInfo extends UI_BaseComponent
	{
		private var pics:Array;
		
		public function UISensorInfo()
		{
			super();
			
			var shift:int = 220;
			var clr:uint = COLOR.GREEN_DARK;
			FLAG_SAVABLE = false;
			
			addui( new FSSimple, 0, loc("ui_verinfo_device_name"),null,1);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			addui( new FSSimple, 0, loc("ui_verinfo_fw_ver"),null,2);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( clr );
			
			pics = new Array;
			pics[0] = new Library.cRdd1;
			pics[1] = new Library.cRmd;
			pics[2] = new Library.cRsd;
			pics[3] = new Library.cRipr;
			pics[4] = new Library.cRgd;
			pics[5] = new Library.cRdd3;
			for (var i:int=0; i<6; i++) {
				addChild( pics[i]);
				pics[i].visible = false;
				pics[i].x = globalX;
				pics[i].y = globalY + 20;
				pics[i].visible = false;
			}
		}
		override public function open():void
		{
			super.open();
			
			var v:String = DS.deviceAlias;
			getField(0,1).setCellInfo( v.slice(0, v.length-1) );
			getField(0,2).setCellInfo( DS.getStatusVersion() );
			
			for (var i:int=0; i<6; i++) {
				pics[i].visible = SensorConst.HASH_NUMBERS[i] == v; 
			}
			
			loadComplete();
		}
	}
}