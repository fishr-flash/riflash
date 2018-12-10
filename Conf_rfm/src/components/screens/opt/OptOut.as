package components.screens.opt
{
	import components.abstract.adapters.SwitchAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IBaseComponent;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	import su.fishr.utils.Dumper;
	
	public class OptOut extends OptionsBlock implements IBaseComponent
	{
		private const TEMPLATE_MANUAL:int = 5;	// номер ручного шаблона в CTRL_TEMPLATE_OUT
		
		private var bTest:TextButton;
		private var opt:OptOutPattern;
		
		public function OptOut(n:int)
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
			
			var l:Array = UTIL.getComboBoxList( [[1,loc("g_enabled")],[2,loc("out_switchon_1hz")],[3,loc("out_short_impulse_6sec")],[4,loc("g_disabled")]] );
			addui( new FSComboBox, CMD.CTRL_INIT_OUT, loc("out_start_state"), null, 1, l );
			attuneElement( sh, w, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			addui( new FSComboBox, CMD.CTRL_INIT_OUT, loc("out_state_no_connection"), null, 2, l );
			attuneElement( sh, w, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_CLEAR_BOX_WHEN_DISABLED );
			
			addui( new FSCheckBox, CMD.CTRL_INIT_OUT, loc("out_inverse"), null, 3 );
			attuneElement( sh + w-13 );
			getLastElement().setAdapter( new WFAdapter );
			getLastElement().setId( 0 );
			
			if( DS.isDevice( DS.MS1 ) && structureID == 1 )
			{
				addui( new FSCheckBox, 0, loc("to_use_flicker"), dlgtUpdateInitOut, 1 );
				attuneElement( sh + w-13 );
			}
			
			
			
			
			drawSeparator(sw);
			
			/** Команда CTRL_TEMPLATE_OUT - настроенные шаблоны для выходов

				Параметр 1 - идентификационный номер шаблона
				......0 - Реакция не настроена ( Выключен )
				......1 - Индикация состояния раздела
				......2 - Срабатывание по тревоге в разделе
				......3 - Индикация непереданных событий
				......4 - Индикация неисправности
				......5 - Ручное управление выходом */
			
			l = UTIL.getComboBoxList( [[0,loc("out_no_action")],[1,loc("out_part_state_indication")],
				[2,loc("out_trigger_on_part_alarm")],[3,loc("ui_led_unsend_events")],
				[4,loc("out_failure_ind")],[5,loc("output_manual")]] );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_OUT, loc("ui_pattern_output_control"), onPattern, 1, l );
			attuneElement( sh-20, w+20, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator(sw);
			
			opt = new OptOutPattern(structureID);
			addChild( opt );
			opt.x = globalX;
			opt.y = globalY;
		}
		
		
		public function open():void
		{
			distribute( OPERATOR.getData(CMD.CTRL_NAME_OUT)[structureID-1], CMD.CTRL_NAME_OUT );
			distribute( OPERATOR.dataModel.getData(CMD.CTRL_INIT_OUT)[structureID-1], CMD.CTRL_INIT_OUT );
			
			if( DS.isDevice( DS.MS1 )&& structureID == 1 )
					getField( 0, 1 ).setCellInfo( UTIL.isBit( 1, OPERATOR.dataModel.getData(CMD.CTRL_INIT_OUT)[structureID-1][ 2 ] ) );
			
			distribute( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_OUT)[structureID-1], CMD.CTRL_TEMPLATE_OUT );
			onPattern();
			unfreeze();
			
			optTimer();
		}
		public function put(p:Package):void
		{
			
			pdistribute(p);
			
			
		}
		public function close():void
		{
			runTask(optTimer, TaskManager.DELAY_1SEC).stop();
		}
		private function onPattern(t:IFormString=null):void
		{
			var choise:int = int(getField(CMD.CTRL_TEMPLATE_OUT,1).getCellInfo());
			opt.open(choise);
			
			getField(CMD.CTRL_INIT_OUT,2).disabled = choise == TEMPLATE_MANUAL;
			
			if (t)
				remember(t);
		}
		
		private function dlgtUpdateInitOut( field:IFormString ):void
		{
			const field3:IFormString = getField( CMD.CTRL_INIT_OUT, 3 ); 
			var current:int = int( field3.getCellInfo() );
			//UTIL.changeBit( current, 1, field.getCellInfo()?true:false );
			if( field.getCellInfo() ) 
						current |= 0x02;
			else 
						current &= ~0x02;
			
			field3.setCellInfo( current );
			remember( field3 );
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
		private function optTimer():void
		{
			runTask(optTimer, TaskManager.DELAY_1SEC);
			opt.timer();
		}
	}
}

import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;

class WFAdapter implements IDataAdapter
{
	
	private var controlBit:int = 0;
	private static var actualValue:int = 0;
	
	public function change(value:Object):Object
	{
		return value;
	}
	public function adapt(value:Object):Object
	{
		
		actualValue = int( value );
		return UTIL.isBit(  controlBit,  int( actualValue ))?1:0;
	}
	public function recover(value:Object):Object
	{
		//UTIL.changeBit( actualValue, controlBit,value );
		actualValue >>= 1;
		actualValue <<= 1;
		actualValue |= int( value );

		return actualValue;
	}
	public function perform(field:IFormString):void		
	{
		
	}
}


