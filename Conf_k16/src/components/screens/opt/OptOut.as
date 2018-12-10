package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIOutK16;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	
	public class OptOut extends OptionsBlock
	{
		private var bSwich:TextButton;
		private var OUT_ON:Boolean=false;
		private var warn:FormString;
		public function OptOut()
		{
			super();
			yshift = 15;
			
			globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT;
			globalY = PAGE.CONTENT_TOP_SHIFT;
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("output_current_ctrl"), null,1);
			attuneElement( 300 );
			createUIElement( new FormString, 0, loc("output_current_state"), null,3);
			createUIElement( new FormString, 0, loc("output_change_state"), null,4);
			attuneElement( 300 );
			globalY += 20;
			warn = createUIElement( new FormString, 0, loc("output_accidently_disabled"), null,5) as FormString;
			warn.setTextColor( COLOR.RED );
			attuneElement( 500, NaN, FormString.F_MULTYLINE );
			
			globalY = PAGE.CONTENT_TOP_SHIFT;
			globalX = 320;
			createUIElement( new FormString, 1, loc("output_waiting_status"), null,1);
			createUIElement( new FormString, 1, loc("output_waiting_status"), null,3);
			bSwich = new TextButton;
			addChild( bSwich );
			bSwich.setUp(loc("g_switchon"), switchOut );
			bSwich.data = 2;
			bSwich.x = globalX;
			bSwich.y = globalY;
		}
		override public function putRawData(a:Array):void
		{
			warn.visible = false;
			structureID = a[0];
		}
		override public function putData(p:Package):void
		{
			var color:uint;
			var txt:String;
			var field:FormString;
			switch( p.cmd ) {
				case CMD.OUT_STATE:
					/** Команда OUT_STATE - состояние выходов
					 * 	Параметр 1 - битовое поле, бит 0 - выход 1 ( 0 - выключен, 1 - включен ), бит 1 - выход 2 ( 0 - выключен, 1 - включен ), бит 2 - выход 3 ( 0 - выключен, 1 - включен ) */
					
					UIOutK16.OUT_BITFIELD = p.getStructure()[0];
					txt = loc("g_disabled_m").toLowerCase();
					color = COLOR.RED;
					OUT_ON = false;
					bSwich.setUp(loc("g_switchon"), switchOut );
					bSwich.data = 1;
					if( (UIOutK16.OUT_BITFIELD & (1 << getStructure()-1)) > 0 ) {
						txt = loc("g_enabled_m").toLowerCase();
						color = COLOR.GREEN;
						OUT_ON = true;
						
						bSwich.setUp(loc("g_switchoff"), switchOut );
						bSwich.data = 0;
					}
					field = getField(1,3) as FormString;
					field.setCellInfo(txt);
					field.setTextColor( color );
					break;
				case CMD.OUT_CTRL_STATE:
					/** Команда OUT_CTRL_STATE - состояние линии контроля выходов, номер структуры-номер выхода;
					Параметр 1 - Значение АЦП при выключенном выходе - последнее измеренное состояние
					Параметр 2 - Значение АЦП при включенном выходе - последнее измеренное состояние
					Параметр 3 - состояние линии контроля выхода в выключенном состоянии.
					Параметр 4 - состояние линии контроля выхода во включенном состоянии.
					Параметр 5 - физическое состояние выхода, 0-выключен, 1-включен , может не соответствовать логическому из-за защитного отключения при обрыве или кз, или из-за мигания.
					Состояние линии контроля ( 0x00 - состояние не известно, 0x01 - контроль отключен, 0x02 - обрыв, 0x04 - норма, 0x08 - короткое замыкание) */
					
					var param:int = 2;
					if ( OUT_ON )
						param = 3;
					
					switch( p.getStructure()[param] ) {
						case 0x00:
							txt = loc("wire_state_unknwn");
							color = COLOR.CIAN;
							break;
						case 0x01:	// правка от 10.09.13 - необходимо отображать "контроль отключен" если установлен первый бит".
						case 0x03:
						case 0x05:
						case 0x09:
							txt = loc("output_ctrl_disabled");
							color = 0x000000;
							break;
						case 0x02:
							txt = loc("wire_cut").toLowerCase();
							color = COLOR.ORANGE;
							break;
						case 0x04:
							txt = loc("wire_norm").toLowerCase();
							color = COLOR.GREEN;
							break;
						case 0x08:
							txt = loc("wire_short_circuit_line").toLowerCase();
							color = COLOR.RED;
							break;
						default:
							txt = loc("output_unexpected");
							color = COLOR.RED;
							break;
					}
					field = getField(1,1) as FormString;
					field.setCellInfo(txt);
					field.setTextColor( color );
					
					warn.visible = Boolean(OUT_ON != (p.getStructure()[4] == 1));
					break;
			}
		}
		private function switchOut():void
		{
			/**Команда OUT_FUNCT - команда выходу включить/выключить и запросить состояние;
			 * Параметр 1 - Запросить состояние выходов ( 0- нет, 1-запросить - ответ в OUT_STATE и OUT_CTRL_STATE);
			 * Параметр 2 - Включить выходы бит 0 - выход 1, бит 1 - выход 2, бит 2 - выход 3 (для включения устанавливаем бит в 1);
			 * Параметр 3 - Выключить выходы бит 0 - выход 1, бит 1 - выход 2, бит 2 - выход 3 (для включения устанавливаем бит в 1);
			 * Параметр 4 - Изменить состояние выхода на противоположное бит 0 - выход 1, бит 1 - выход 2, бит 2 - выход 3 (для переключения устанавливаем бит в 1);*/
			
			var bit:int;
			bit |= ( 1 << getStructure()-1 );
			switch( bSwich.data ) {
				case 1:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT, null, 1,[0,bit,0,0] ));
					break;
				case 0:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.OUT_FUNCT, null, 1,[0,0,bit,0] ));
					break;
			}
		}
	}
}