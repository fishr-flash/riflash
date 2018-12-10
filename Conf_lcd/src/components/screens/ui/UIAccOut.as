package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSRadioGroup;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.PAGE;
	
	public class UIAccOut extends UI_BaseComponent
	{
		public function UIAccOut()
		{
			super();
			
			/** Команда OUT_ACC - Настройка состояния выхода
			
			Параметр 1 -
			 	0 - Нормально разомкнутое состояние выхода, 
				1 - Нормально замкнутое состояние выхода, если видим отличное от нуля значение, то насильно вписываем 1.*/
			
			
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("acc_out_normal_open_state"), selected:false, id:0 },
				{label:loc("acc_out_normal_close_state"), selected:false, id:1 },
			], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = PAGE.CONTENT_LEFT_SHIFT;
			fsRgroup.width = 320;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.OUT_ACC, 1);
			
			starterCMD = CMD.OUT_ACC;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			loadComplete();
			if (p.getStructure()[0] > 1 || p.getStructure()[0] < 0) {
				getField(p.cmd,1).setCellInfo(1);
				remember( getField(p.cmd,1) );
			}
		}
	}
}