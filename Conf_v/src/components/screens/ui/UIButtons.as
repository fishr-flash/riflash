package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIButtons extends UI_BaseComponent
	{
		public function UIButtons()
		{
			super();
			
			/*"Команда VR_KEY_SIDE_SWITCH - Назначение бокового переключателя
			
			Параметр 1 - Назначение бокового переключателя:
			....Боковой переключатель отключен;
			....Принудительное включение режима ""Онлайн"";
			....Блокировка всех кнопок;
			....Включение/Выключение прибора"													*/
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, loc("button_purpose"), null, 1 );
			attuneElement( 300, NaN, FormString.F_TEXT_BOLD | FormString.F_NOTSELECTABLE );
			FLAG_SAVABLE = true;
			
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("button_ss_disabled"), selected:false, id:0 },
				{label:loc("button_force_online"), selected:false, id:1 },
				{label:loc("button_block_all"), selected:false, id:2 },
				{label:loc("button_device_onoff"), selected:false, id:3 }
				], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = globalX;
			fsRgroup.width = 380;
			addChild( fsRgroup );
			
			addUIElement( fsRgroup, CMD.VR_KEY_SIDE_SWITCH, 1);
			
			starterCMD = CMD.VR_KEY_SIDE_SWITCH;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			loadComplete();
		}
	}
}