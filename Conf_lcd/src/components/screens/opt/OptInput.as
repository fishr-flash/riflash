package components.screens.opt
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.servants.TaskManager;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptInput extends OptionsBlock
	{
		private const fullmenu:Array = [
			{data:0,label:"Отключен"},
			{data:1,label:"Дискретный"},
			{data:2,label:"Аналоговый"},
			{data:3,label:"Частотный"},
			{data:4,label:"Импульсный"}
		];
		private const input_digital:Array = UTIL.getComboBoxList([[0,"Механизм"],[1,"Зажигание"],[2,"Тревожная кнопка"]]);
		private const input_default:Array = UTIL.getComboBoxList([[0,"Датчик уровня топлива"],[1,"Датчик температуры"]]);
		private const input_pulse:Array = UTIL.getComboBoxList([[0,"Измерение расхода топлива"],[1,"Датчик температуры"]]);
		
		private const cmdHash:Object = {1:CMD.VR_INPUT_DIGITAL, 2:[CMD.VR_INPUT_ANALOG, CMD.VR_INPUT_ANALOG_VALUE], 3:CMD.VR_INPUT_FREQ, 4:CMD.VR_INPUT_PULSE};
		private const cmdHashPurpose:Object = {1:CMD.VR_INPUT_DIGITAL, 2:CMD.VR_INPUT_ANALOG, 3:CMD.VR_INPUT_FREQ, 4:CMD.VR_INPUT_PULSE};
		//private const cmdHash:Object = {1:CMD.VR_INPUT_DIGITAL, 2:CMD.VR_INPUT_ANALOG, 3:CMD.VR_INPUT_FREQ, 4:CMD.VR_INPUT_PULSE};
		private const TYPE_DISABLED:int = 0;
		private const TYPE_DISCRED:int = 1;
		private const TYPE_ANALOG:int = 2;
		private const TYPE_FREQ:int = 3;
		private const TYPE_PULSE:int = 4;
		private var TYPE:int;
		private const TYPE_SUB_INGNITION:int = 0;
		
		private var group:GroupOperator;
		private var subgroup:GroupOperator;
		private var cache:Array;
		private var task:ITask;
		
		public function OptInput(s:int)
		{
			super();
			
			structureID = s;
			
			createUIElement( new FSShadow, CMD.VR_INPUT_TYPE, "", null, 1 );
			createUIElement( new FSComboBox, CMD.VR_INPUT_TYPE, "Тип входа", load, 2, getMenu(0) );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator(520);
			
			group = new GroupOperator;
			subgroup = new GroupOperator;
			
			var anchor:int = globalY;
			
			/** Дискретный
			 	Команда VR_INPUT_DIGITAL - цифровой дискретный вход. Номер структуры = номер входа.
				
			  	Параметр 1 - Поддерживаемые назначения входа, бит0=1 - механизм, бит1=1 - зажигание, бит2=1 - тревожная кнопка.
				Параметр 2 - Назначение входа. 0-механизм, 1-зажигание, 2-тревожная кнопка;
				Параметр 3 - Полярность сигнала на входе. 0-положительная, 1-отрицательная;
				Параметр 4 - Длительность сигнала, 0.1-10сек. 1=0,1 сек - 100=10 сек.	*/
			
			createUIElement( new FSShadow, CMD.VR_INPUT_DIGITAL, "", null, 1 );
			createUIElement( new FSComboBox, CMD.VR_INPUT_DIGITAL, "Назначение", onInputDigital, 2);
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_DISCRED.toString(), getLastElement() );
			createUIElement( new FSComboBox, CMD.VR_INPUT_DIGITAL, "Полярность сигнала на входе", null, 3, UTIL.getComboBoxList([[0,"Положительная (+)"],[1,"Отрицательная (-)"]]) );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_DISCRED.toString(), getLastElement() );
			createUIElement( new FSComboBox, CMD.VR_INPUT_DIGITAL, "Длительность сигнала для срабатывания, в секундах", null, 4, 
				UTIL.getComboBoxList([["0.3","0.3"],["2.0","2.0"],["10.0","10.0"]]), "0-9.",5, new RegExp( RegExpCollection.COMPLETE_0dot1to10dot0 ) );
			getLastElement().setAdapter(new FloatToIntAdapter);
			attuneElement(420, 100 );
			group.add( TYPE_DISCRED.toString(), getLastElement() );
			
			FLAG_SAVABLE = false;
			subgroup.add( TYPE_SUB_INGNITION.toString(), drawSeparator(520) );
			createUIElement( new FormString, 0, "Сигнал \"Зажигание\" используется для контроля работы двигателя, \r\nвключения навигационного приемника и передачи данных.",
				null,1);
			attuneElement( 600, NaN, FormString.F_MULTYLINE );
			subgroup.add( TYPE_SUB_INGNITION.toString(), getLastElement() );
			FLAG_SAVABLE = true;
			
			globalY = anchor;
			
			/** Аналоговый 
			  	Команда VR_INPUT_ANALOG - аналоговый вход. Номер структуры = номер входа.

 				Параметр 1 - Поддерживаемое назначение входа, бит0=1 Датчи уровня топлива. далее возможно расширение
				Параметр 2 - Назначение уровня топлива, 0-датчик уровня топлива; далее возможно расширение
				Параметр 3 - Измерение уровня топлива ( для датчика уровня топлива ) 0-постоянно, 1- при включенном зажигании. далее можножно расширение. */
			
			createUIElement( new FSShadow, CMD.VR_INPUT_ANALOG, "", null, 1 );
			createUIElement( new FSComboBox, CMD.VR_INPUT_ANALOG, "Назначение", null, 2 );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_ANALOG.toString(), getLastElement() );
			createUIElement( new FSComboBox, CMD.VR_INPUT_ANALOG, "Измерение уровня топлива", null, 3, UTIL.getComboBoxList([[0,"Постоянно"],[1,"При включенном зажигании"]]) );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_ANALOG.toString(), getLastElement() );
			group.add( TYPE_ANALOG.toString(), drawSeparator(520) );
	
			addui( new FSSimple, CMD.VR_INPUT_ANALOG_VALUE, "Мгновенное значение на входе, АЦП", null, 1 );
			attuneElement( 300+159, 60, FSSimple.F_CELL_NOTSELECTABLE);
			group.add( TYPE_ANALOG.toString(), getLastElement() );
			addui( new FSSimple, CMD.VR_INPUT_ANALOG_VALUE, "Усредненное значение на входе, АЦП", null, 2 );
			attuneElement( 300+159, 60, FSSimple.F_CELL_NOTSELECTABLE );
			group.add( TYPE_ANALOG.toString(), getLastElement() );

			globalY = anchor;
			
			/** Частотный 
			 	Команда VR_INPUT_FREQ - частотный вход. Номер структуры = номер входа

				Параметр 1 - Поддерживаемое назначение входа, бит0=1 Датчи уровня топлива. далее возможно расширение
				Параметр 2 - Назначение уровня топлива, 0-датчик уровня топлива; далее возможно расширение
				Параметр 3 - Измерение уровня топлива ( для датчика уровня топлива ) 0-постоянно, 1- при включенном зажигании. далее можножно расширение.*/
			
			createUIElement( new FSShadow, CMD.VR_INPUT_FREQ, "", null, 1 );
			createUIElement( new FSComboBox, CMD.VR_INPUT_FREQ, "Назначение", null, 2 );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_FREQ.toString(), getLastElement() );
			createUIElement( new FSComboBox, CMD.VR_INPUT_FREQ, "Измерение уровня топлива", null, 3, UTIL.getComboBoxList([[0,"Постоянно"],[1,"При включенном зажигании"]]) );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_FREQ.toString(), getLastElement() );
			
			globalY = anchor;
			
			/** Частотный 
				Команда VR_INPUT_PULSE - импульсный вход. Номер структуры = номер входа.

				Параметр 1 - Поддерживаемое назначение входа, бит0=1 Датчи уровня топлива. далее возможно расширение
				Параметр 2 - Назначение уровня топлива, 0-датчик уровня топлива; далее возможно расширение
				Параметр 3 - Измерение расхода топлива ( для датчика расхода топлива - измерение постоянно ) 0-На входе в ДВС, 1- На выходе из ДВС	*/
			
			createUIElement( new FSShadow, CMD.VR_INPUT_PULSE, "", null, 1 );
			createUIElement( new FSComboBox, CMD.VR_INPUT_PULSE, "Назначение", null, 2 );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_PULSE.toString(), getLastElement() );
			createUIElement( new FSComboBox, CMD.VR_INPUT_PULSE, "Измерение расхода топлива", null, 3, UTIL.getComboBoxList([[0,"На входе в ДВС"],[1,"На выходе из ДВС"]]) );
			attuneElement(300, 220, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			group.add( TYPE_PULSE.toString(), getLastElement() );
		}
		override public function putRawData(a:Array):void
		{
			cache = a;
			var data:Array = getData(CMD.VR_INPUT_TYPE);
			var bit:int = data[0];
			var f:IFormString = getField(CMD.VR_INPUT_TYPE,2); 
			(f as FSComboBox).setList( getMenu(bit) );
			distribute( data, CMD.VR_INPUT_TYPE );
			load(f,false);
		}
		public function close():void
		{
			execute(0);
		}
		private function load(t:IFormString, save:Boolean=true):void
		{
			TYPE = int(t.getCellInfo());
			
			group.visible( "1", TYPE==1 );
			group.visible( "2", TYPE==2 );
			group.visible( "3", TYPE==3 );
			group.visible( "4", TYPE==4 );
			
			setPurposeMenu(cmdHashPurpose[TYPE]);	// устанавливает список назначения в зависимости от выбранного входа
			
			if (TYPE>0) {
				if (cmdHash[TYPE] is Array) {
					var len:int = cmdHash[TYPE].length;
					for (var i:int=0; i<len; i++) {
						distribute( getData(cmdHash[TYPE][i]), cmdHash[TYPE][i] );
					}
				} else
					distribute( getData(cmdHash[TYPE]), cmdHash[TYPE] );
			}
			execute(TYPE);
			onInputDigital(null);
			
			if (save)
				SavePerformer.remember(getStructure(),t);
			else
				SavePerformer.closePage();
		}
		private function getData(cmd:int):Array
		{
			var len:int = cache.length;
			for (var i:int=0; i<len; ++i) {
				if( cache[i].cmd == cmd )
					return cache[i].data;
			}
			return null;
		}
		private function execute(t:int):void
		{
			switch(t) {
				case TYPE_ANALOG:
					onRequestAnalog();
					break;
				default:
					if (task)
						task.kill();
					task = null;
					break;
			}
		}
		private function onRequestAnalog():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_INPUT_ANALOG_VALUE, put ));
		}
		private function put(p:Package):void
		{
			distribute( p.getStructure(structureID), p.cmd );
			if (!task)
				task = TaskManager.callLater( onRequestAnalog, TaskManager.DELAY_2SEC );
			task.repeat();
		}
		private function getMenu(bit:int):Array
		{
			/** Параметр 1 - Поддерживаемые типы у входа, 
			 * бит0=1 - может быть цифровым (дискретным), 
			 * бит1=1 - может быть аналоговым, 
			 * бит2=1 - может быть частотным, 
			 * бит3=1 - может быть импульсным 
			 * 
			 * Параметр 2 - Тип входа = 0-Отключен, 1-Дискретный, 2-Аналоговый, 3-Частотный, 4-Импульсный */
			
			var a:Array = [];
			a.push( fullmenu[0] );
			var len:int = fullmenu.length;
			for (var i:int=0; i<len; ++i) {
				if( (bit & (1<<i)) > 0 ) {
					a.push( fullmenu[i+1] );
				}
			}
			return a;
		}
		private function onInputDigital(t:IFormString):void
		{
			subgroup.visible( TYPE_SUB_INGNITION.toString(), int(getField(CMD.VR_INPUT_DIGITAL,2).getCellInfo()) == 1 && TYPE == TYPE_DISCRED );
			if (t)
				remember(t);
		}
		private function setPurposeMenu(cmd:int):void
		{
			if (cmd > 0) {
				var a:Array = [];
				var target:Array;
				var len:int;
				var bit:int;
				var param:Object = {
					"data":OPERATOR.dataModel.getData(cmd)
				}
				
				switch(cmd) {
					case CMD.VR_INPUT_DIGITAL:
						bit = OPERATOR.dataModel.getData(cmd)[getStructure()-1][0];
						target = input_digital;
						break;
					case CMD.VR_INPUT_ANALOG:
					case CMD.VR_INPUT_FREQ:
						target = input_default;
						bit = OPERATOR.dataModel.getData(cmd)[getStructure()-1][0];
						break;
					case CMD.VR_INPUT_PULSE:
						target = input_pulse
			//			target = input_default;
						bit = OPERATOR.dataModel.getData(cmd)[getStructure()-1][0];
						break;
				}
				len = target.length;
				for (var i:int=0; i<len; ++i) {
					if( (bit & (1<<i)) > 0 ) {
						a.push( target[i] );
					}
				}
				(getField(cmd,2) as FSComboBox).setList( a );
			}
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class FloatToIntAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return (int(value)/10).toString();
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		var res:int = Math.round(Number(value)*10);
		return res;
	}
}