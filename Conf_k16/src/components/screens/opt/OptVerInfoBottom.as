package components.screens.opt
{
	import components.abstract.DEVICESB;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FormString;
	import components.gui.visual.SIMSignal;
	import components.protocol.Package;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.MISC;
	
	public class OptVerInfoBottom extends OptionsBlock
	{
		private var signal:SIMSignal;
		
		public function OptVerInfoBottom()
		{
			super();
			
			yshift = 0;
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("ui_verinfo_device_name"),null,1);
			createUIElement( new FormString, 0, loc("ui_verinfo_fw_ver"),null,1);
			
			/**Команда VER_INFO
			 * Параметр 1 - Название прибора;
			 * Параметр 2 - Версия прошивки;
			 * Параметр 3 - Тип памяти; */
			
			globalY = 0;
			globalX = UIVersion.shift;
			var clr:uint = COLOR.GREEN_DARK;
			createUIElement( new FormString, CMD.VER_INFO, "",null,1);
			(getLastElement() as FormString).setTextColor( clr );
			createUIElement( new FormString, CMD.VER_INFO, "",null,2);
			attuneElement(250);
			(getLastElement() as FormString).setTextColor( clr );
			
			complexHeight = globalY + 10;
		}
		override public function putData(p:Package):void
		{
			
			
			var vinfo:Array = p.getStructure();
			getField( CMD.VER_INFO,1 ).setCellInfo( DEVICESB.name_k16 );
			
			if (MISC.COPY_DEBUG)
				getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] +"."+ DEVICESB.bootloader + " commit " + DEVICESB.commit);
			else
				getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] +"."+ DEVICESB.bootloader );
			
			
		}
	}
}