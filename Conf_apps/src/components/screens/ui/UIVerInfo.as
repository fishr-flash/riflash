package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.PAGE;
	
	public class UIVerInfo extends UI_BaseComponent
	{
		private var FLAG_ASK_BALANCE:Boolean = false;
		private var FLAG_SIMCARD_INITIALISED:Boolean = false;

		public function UIVerInfo()
		{
			super();
			
			globalY = PAGE.CONTENT_TOP_SHIFT;
			yshift = 0;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("ui_verinfo_device_name"),null,1);
			globalY += 10;
			createUIElement( new FormString, 0, loc("ui_verinfo_fw_ver"),null,1);
			globalY += 10;
			if( DS.isDevice( DS.WTS_1 ) == false )
				createUIElement( new FormString, 0, loc("ui_verinfo_memory_type"),null,1);
			
			
			/**Команда VER_INFO
			 * Параметр 1 - Название прибора;
			 * Параметр 2 - Версия прошивки;
			 * Параметр 3 - Тип памяти;
			 */
			globalY = PAGE.CONTENT_TOP_SHIFT;
			globalX = 220;
			var clr:uint = COLOR.GREEN_DARK;
			createUIElement( new FormString, CMD.VER_INFO, "",null,1);
			attuneElement(400 );
			(getLastElement() as FormString).setTextColor( clr );
			globalY += 10;
			createUIElement( new FormString, CMD.VER_INFO, "",null,2);
			(getLastElement() as FormString).setTextColor( clr );
			globalY += 10;
			if( DS.isDevice( DS.WTS_1 ) == false )
			{
				createUIElement( new FormString, CMD.VER_INFO, "", null, 3 );
				(getLastElement() as FormString).setTextColor( clr );
			}
			else
			{
				createUIElement( new FSShadow, CMD.VER_INFO, "", null, 3 );
			}
			
			
			width = 465;
			height = 285;
		}
		override public function open():void
		{
			super.open();
			
			var vinfo:Array = OPERATOR.dataModel.getData(CMD.VER_INFO)[0];
			getField( CMD.VER_INFO,1 ).setCellInfo( DS.name );
			getField( CMD.VER_INFO,2 ).setCellInfo( getString(vinfo[1])+ " "+DS.getCommit() );
			getField( CMD.VER_INFO,3 ).setCellInfo( getString(vinfo[2]) );
			
			loadComplete();
		}
		private function getString(s:String):String
		{
			if (!s)
				return "";
			return s;
		}
	}
}