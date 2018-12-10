package components.screens.ui
{
	import flash.display.Bitmap;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.Library;
	import components.system.UTIL;
	
	public class UIAlarmKeys extends UI_BaseComponent
	{
		private var opts:Vector.<OptZones>;
		private var wirePic:Bitmap;
		
		public function UIAlarmKeys()
		{
			super();
			
			wirePic = new Library.cZoneButtons;
			addChild( wirePic );
			wirePic.x = 430+50;
			wirePic.y = 14;
			
			var list:Array = CIDServant.getEvent();
			addui( new FSComboBox, 0, loc("g_zone")+" 1", onEvent, 1, list );
			attuneElement( 80, 300 + 57, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			addui( new FSComboBox, 0, loc("g_zone")+" 2", onEvent, 2, list );
			attuneElement( 80, 300 + 57, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			addui( new FSComboBox, 0, loc("g_zone")+" 3", onEvent, 3, list );
			attuneElement( 80, 300 + 57, FSComboBox.F_COMBOBOX_NOTEDITABLE );

			opts = new Vector.<OptZones>(3);
			for (var i:int=0; i<3; i++) {
				opts[i] = new OptZones(i+1);
			}
			drawSeparator(380+40+57);
			
			list = UTIL.getComboBoxList( [[1,loc("keyboard_buttons_disabled")],[0,loc("keyboard_buttons_enabled")],[2,loc("keyboard_buttons_enabled_with_delay")]] );
			addui( new FSComboBox, CMD.OP_C_AKARM_KEY, loc("keyboard_panic_services"), null, 1, list );
			attuneElement( 380-13-30, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		}
		override public function open():void
		{
			super.open();
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_z_ZONES, put) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_C_AKARM_KEY, put) );
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OP_z_ZONES:
					var s:String = p.getStructure()[0];
					var a:Array = s.split(" ");
					LOADING = true;
					for (var i:int=0; i<3; i++) {
						var sa:String = (a[i] as String).slice(3,6) + "1";
						if (sa == "0001")
							sa = "0";
						//getField(0,i+1).setCellInfo((a[i] as String).slice(3,6) + "1");
						getField(0,i+1).setCellInfo(sa);
					}
					LOADING = false;
					break;
				case CMD.OP_C_AKARM_KEY:
					distribute( p.getStructure(), p.cmd );
					loadComplete();
					break;
			}
		}
		private function onEvent(t:IFormString):void
		{
			/** Без аргумента возвращает параметры всех зон в формате SNPAE:
				S – state – состояние (0 – нормальное, 1 – нарушенное, 2 – аварийное)
				N – normal – нормальное состояние (1 – замкнутое, 0 – разомкнутое)
				P – part – номер раздела, к которому относится зона
				A – Ademco ID – код 3 hex-цифры
				E – enter timeout – задержка на вход в секундах – 2 hex-цифры (00..FF)	*/
			
			if( !LOADING ) {
				var s:String = String(t.getCellInfo()).slice(0,3);
				if (s.length < 3)
					s = "000";
				opts[t.param-1].putRawData( ["00"+s+"00"] )
			}			
		}
	}
}
import components.basement.OptionsBlock;
import components.gui.fields.FSShadow;
import components.static.CMD;

class OptZones extends OptionsBlock
{
	public function OptZones(s:int)
	{
		super();
		structureID = s;
		addui( new FSShadow, CMD.OP_z_ZONES, "", null, 1 );
	}
	override public function putRawData(a:Array):void
	{
		distribute(a,CMD.OP_z_ZONES );
		remember( getField( CMD.OP_z_ZONES, 1 ));
	}
}