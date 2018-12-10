package components.screens.opt
{
	import mx.controls.Label;
	
	import components.abstract.adapters.SwitchAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.adapter.FFAdapter;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IBaseComponent;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public final class OptRelay extends OptionsBlock implements IBaseComponent
	{
		private var opt:OptRelayPattern;
		private var bTest:TextButton;
		private var task:ITask;
		
		public function OptRelay(n:int)
		{
			super();
			
			globalX += PAGE.CONTENT_LEFT_SHIFT;
			globalY += PAGE.CONTENT_TOP_SHIFT;
			
			structureID = n;
			
			globalXSep = PAGE.SEPARATOR_SHIFT;
			
			var sh:int = 250;
			var w:int = 300;
			var sw:int = 540;
			
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
			 .......0-Нет действия
			 .......1-Включено
			 .......2-Включить с частотой 1Гц
			 .......3-Короткие импульсы раз в 6 сек
			 .......4-Выключено
			 Параметр 2 - Состояние при отсутствии связи
			 .......0-Нет действия
			 .......1-Включено
			 .......2-Включено с частотой 1Гц
			 .......3-Короткие импульсы раз в 6 сек
			 .......4-Выключено
			 Параметр 3 - инверсия, 0-нет, 1-255  - да */
			
			var l:Array = UTIL.getComboBoxList( [
													[1,loc("g_enabled")]
													,[2,loc("out_switchon_1hz")]
													,[3,loc("out_short_impulse_6sec")]
													,[4,loc("g_disabled")]] );
			addui( new FSComboBox, CMD.CTRL_INIT_OUT, loc("out_start_state"), null, 1, l );
			attuneElement( sh, w, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			var arr:Array = l.slice();
			arr.unshift( { data:0, label:loc("g_no_action")} );
			
			
			
			addui( new FSComboBox, CMD.CTRL_INIT_OUT, loc("out_state_no_connection"), null, 2, arr );
			attuneElement( sh, w, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_CLEAR_BOX_WHEN_DISABLED );
			
			addui( new FSCheckBox, CMD.CTRL_INIT_OUT, loc("out_inverse"), null, 3 );
			attuneElement( sh + w-13 );
			getLastElement().setAdapter( new FFAdapter );
			
			drawSeparator(sw);
			
			/** "Команда CTRL_TEMPLATE_OUT - настроенные шаблоны для выходов
			 
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
			 ....12 - Реакция дополнительная (Реле 10)"												*/
			
			l = UTIL.getComboBoxList( [[0,loc("out_no_action")]
										, [ 5, loc( "output_manual" ) ]/// Ручное управление выводом
										,[9,loc("out_react_part_state")]
										, [10,loc("out_react_zone_state")]
										,[11,loc("out_notif_fire")]
										,[12,loc("out_react_ext")]] );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_OUT, loc("ui_pattern_output_control"), onPattern, 1, l );
			attuneElement( sh-20, w+20, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setAdapter(new Ad);
			
			drawSeparator(sw);
			
			opt = new OptRelayPattern(structureID);
			addChild( opt );
			opt.x = globalX;
			opt.y = globalY;
		}
		public function open():void
		{
			distribute( OPERATOR.dataModel.getData(CMD.CTRL_INIT_OUT)[structureID-1], CMD.CTRL_INIT_OUT );
			distribute( OPERATOR.dataModel.getData(CMD.CTRL_TEMPLATE_OUT)[structureID-1], CMD.CTRL_TEMPLATE_OUT );
			onPattern();
		}
		public function close():void
		{
		}
		public function put(p:Package):void
		{
			
			switch( p.cmd ) {
				
				case CMD.CTRL_DOUT_SENSOR:
					opt.putData( p );
					pdistribute(p);
				default:
					
					manualResize();
					
			}
	
		}
		private function onPattern(t:IFormString=null):void
		{
			var choise:int = int(getField(CMD.CTRL_TEMPLATE_OUT,1).getCellInfo());
			opt.open(choise);
			
			manualResize();
			
			if (t)
				remember(t);
		}
		private function onClick():void
		{
			bTest.disabled = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_TEST_OUT, null, structureID, [5] ));
			if (visible) {
				if (!task)
					task = TaskManager.callLater( unfreeze, TaskManager.DELAY_1SEC*5 );
				else
					task.repeat();
			}
		}
		private function unfreeze():void
		{
			bTest.disabled = false;
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class Ad implements IDataAdapter
{
	
	public function adapt(value:Object):Object
	{
		// TODO Auto Generated method stub
		return value;
	}
	
	public function change(value:Object):Object
	{
		// TODO Auto Generated method stub
		return value;
	}
	
	public function perform(field:IFormString):void
	{
		// TODO Auto Generated method stub
		
	}
	
	public function recover(value:Object):Object
	{
		// TODO Auto Generated method stub
		return value;
	}
}