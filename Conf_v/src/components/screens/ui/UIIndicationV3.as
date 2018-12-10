package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIIndicationV3 extends UI_BaseComponent
	{
		private var fsRgroup:FSRadioGroup;
		
		public function UIIndicationV3()
		{
			super();
			
			/*"Команда VR_IND_MODE - режим индикации вояджера
			
			Параметр 1 - режим работы индикации
			.....0x00 - Выключена,
			.....0x01 - Кратковременно,
			.....0x02 - Постоянно
			.....0x03 - На время
			Параметр 2 - время работы индикации, в секундах, если выбрано в параметре 1 - ""На время"""	*/
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, loc("ind_mode"), null, 1 );
			attuneElement( 300, NaN, FormString.F_TEXT_BOLD | FormString.F_NOTSELECTABLE );
			FLAG_SAVABLE = true;
			
			fsRgroup = new FSRadioGroup( [ {label:loc("his_disabled_f"), selected:false, id:0 },
				{label:loc("ind_on_short"), selected:false, id:1 },
				{label:loc("ind_on_constant"), selected:false, id:2 },
				{label:loc("ind_on_time"), selected:false, id:3 }
			], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = globalX;
			fsRgroup.width = 250;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.VR_IND_MODE, 1, onChange);
			globalY += fsRgroup.getHeight() - 30;
			
			addui( new FSSimple, CMD.VR_IND_MODE, loc("ind_enable_time"), null, 2, null, "0-9", 5, new RegExp(RegExpCollection.REF_0to65535) ).x = globalX + fsRgroup.width + 20;
			attuneElement(NaN, 60 );
			
			starterCMD = CMD.VR_IND_MODE;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			onChange(null);
			loadComplete();
		}
		private function onChange(t:IFormString):void
		{
			getField(CMD.VR_IND_MODE,2).disabled = int(fsRgroup.getCellInfo())!=3; 
			if (t)
				remember(t);
		}
	}
}