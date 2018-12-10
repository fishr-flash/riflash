package components.screens.opt
{
	import components.abstract.adapters.SwitchAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.adapter.FFAdapter;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IBaseComponent;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class OptOutLoRa extends OptionsBlock implements IBaseComponent
	{
		public static const DEVICE_ALARM_BUTTON:int = 11;
		public static const TEMPLATE_ALARM_BUTTON:int = 13;
		public static const DEVICE_TRINKET:int = 18;
		public static const TEMPLATE_TRINKET:int = 6;
		public static const FIELD_NO_ACTION:int = 0;
		
		
		private var bTest:TextButton;
		private var opt:OptOutTemplateLoRa;

		private var lastStateInitOut:Object = 4;
	
		
		
		public function OptOutLoRa(n:int)
		{
			super();
			
			globalX += PAGE.CONTENT_LEFT_SHIFT;
			globalY += PAGE.CONTENT_TOP_SHIFT;
			
			structureID = n;

			globalXSep = PAGE.SEPARATOR_SHIFT;
			
			var sh:int = 250;
			var w:int = 250;
			var sw:int = 540;
			
			addui( new FSSimple, CMD.CTRL_NAME_OUT, loc("out_title"), null, 1, null, "", 15 );
			attuneElement( sh, w );
			
			drawSeparator(sw);
			
			bTest = new TextButton;
			addChild( bTest );
			bTest.x = 430;
			bTest.y = globalY;
			bTest.setFormat(true,12,"right");
			bTest.setUp(loc("g_test"),onClick);
			bTest.setWidth( 100 );
			
			addui( new FSSimple, CMD.CTRL_DOUT_SENSOR, loc("out_current_state"), null, 1 );
			attuneElement( sh, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setAdapter( new SwitchAdapter );
			
			drawSeparator(sw);
			
			/** Команда CTRL_INIT_OUT - начальное состояние выхода
				Параметр 1 - Начальное состояние выхода
				.......1-Включено
				.......2-Включить с частотой 1Гц
				.......3-Короткие импульсы раз в 6 сек
				.......4-Выключено
				Параметр 2 - Состояние при отсутствии связи
				.......1-Включено
				.......2-Включено с частотой 1Гц
				.......3-Короткие импульсы раз в 6 сек
				.......4-Выключено
				Параметр 3 - инверсия, 0-нет, 1-255  - да */
			
			
			
			var ar:Array = UTIL.getComboBoxList( [
													[1,loc("g_enabled")],
													[2,loc("out_switchon_1hz")],
													[3,loc("out_short_impulse_6sec")],
													[4,loc("g_disabled")]
												] );
			
			addui( new FSComboBox, CMD.CTRL_INIT_OUT, loc("out_start_state"), dlgtInitOut, 1, ar );
			attuneElement( sh, w, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			addui( new FSShadow, CMD.CTRL_INIT_OUT, "", null, 2 );
			getLastElement().disabled = true;
			
			addui( new FSCheckBox, CMD.CTRL_INIT_OUT, loc("out_inverse"), null, 3 );
			attuneElement( sh + w-13 );
			getLastElement().setAdapter( new FFAdapter );
			
			drawSeparator(sw);
			
			/** Команда CTRL_TEMPLATE_OUT - настроенные шаблоны для выходов

				Параметр 1 - идентификационный номер шаблона
				......0 - Реакция не настроена ( Выключен )
				......1 - Индикация состояния раздела
				......2 - Срабатывание по тревоге в разделе
				......3 - Индикация непереданных событий
				......4 - Индикация неисправности
				......5 - Ручное управление выходом
				......6 - Кнопки от брелока (RDK)
				......7 - Тревоги от радиодатчиков (RDK)
				......8 - Повторитель состояния радиодатчиков (RDK)
				......9 - Реакция на состояние раздела. (Реле10)
				....10 - Реакция на состояние зоны. (Реле10)
				....11 - Оповещение о пожаре (Реле 10)
				....12 - Реакция дополнительная (Реле 10)
				....13 - Тревожная кнопка (RDK_LR)
				Чтобы включить программу чтения с экрана, нажмите Ctrl+Alt+Z. Для просмотра списка быстрых клавиш нажмите Ctrl+косая черта.
			 */
			
			var l:Array = UTIL.getComboBoxList( [[ FIELD_NO_ACTION,loc("out_no_action")],[ TEMPLATE_ALARM_BUTTON,loc("input_panic_button")],[ TEMPLATE_TRINKET,loc("out_trinket_buttons")] ] );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_OUT, loc("ui_pattern_output"), onPattern, 1, l );
			attuneElement( sh-20, w+20, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator(sw);
			
			opt = new OptOutTemplateLoRa(structureID);
			addChild( opt );
			opt.x = globalX;
			opt.y = globalY;
			
			
			
		}
		
			
		
		public function open():void
		{
			
			distribute( OPERATOR.getData(CMD.CTRL_NAME_OUT)[structureID-1], CMD.CTRL_NAME_OUT );
			distribute( OPERATOR.dataModel.getData(CMD.CTRL_INIT_OUT)[structureID-1], CMD.CTRL_INIT_OUT );
			lastStateInitOut = OPERATOR.dataModel.getData(CMD.CTRL_INIT_OUT)[structureID-1][ 0 ];
			distribute( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_OUT)[structureID-1], CMD.CTRL_TEMPLATE_OUT );
			onPattern();
			unfreeze();
			RequestAssembler.getInstance().doPing( false );
			//optTimer();
		}
		public function put(p:Package):void
		{
		
			
			
			switch( p.cmd ) {
				case CMD.CTRL_INIT_OUT:
					lastStateInitOut = p.getParam( 1, structureID );
					break;
				
				case CMD.CTRL_TEMPLATE_RF_ALARM_BUTTON:
				case CMD.LR_DEVICE_LIST_RF_SYSTEM:
					opt.putData( p );
					break;
				
				default:
					pdistribute(p);
					break;
			}
			if( p.cmd == CMD.CTRL_INIT_OUT )
			opt.putData( p );
			//
		}
		public function close():void
		{
			
			
			
		}
		private function onPattern(t:IFormString=null):void
		{
			var choise:int = int(getField(CMD.CTRL_TEMPLATE_OUT,1).getCellInfo());
			
			opt.open(choise);
			
			
			
			if( choise != TEMPLATE_TRINKET )
			{
				
				/// показываем состояние выключено
				getField(CMD.CTRL_INIT_OUT,1).setCellInfo( 4 );
				getField(CMD.CTRL_INIT_OUT,1).disabled = true ;
				
				
				
			}
			else
			{
				getField(CMD.CTRL_INIT_OUT,1).disabled = false;
				getField(CMD.CTRL_INIT_OUT,1).setCellInfo( lastStateInitOut );
				
			}
			
			if (t)
			{
				remember(t);
				remember( getField( CMD.CTRL_INIT_OUT,1 ) );
			}
				
		}
		private function onClick():void
		{
			bTest.disabled = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_TEST_OUT, null, structureID, [5] ));
			if (visible) {
				runTask(unfreeze, TaskManager.DELAY_5SEC,1 );
			}
		}
		private function unfreeze():void
		{
			bTest.disabled = false;
		}
		
		private function dlgtInitOut(ifr:IFormString ):void
		{
			var choise:int = int(getField(CMD.CTRL_TEMPLATE_OUT,1).getCellInfo());
			if( choise == TEMPLATE_TRINKET )
				lastStateInitOut = getField(CMD.CTRL_INIT_OUT,1).getCellInfo();
			
			if( ifr )remember( ifr );
		}	
	}
}