package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.UTIL;
	
	public class UISensor extends UI_BaseComponent
	{
		public function UISensor()
		{
			super();
			
			var sep_width:int = 520;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("sensor_state"), null, 1 );
			attuneElement( 300,180, FSSimple.F_HTML_TEXT | FSSimple.F_CELL_ALIGN_RIGHT | FSSimple.F_CELL_NOTSELECTABLE );
			FLAG_SAVABLE = true;
			drawSeparator(sep_width);
			
			var menu:Array = [{label:loc("g_no"),data:0},{label:"10",data:10},{label:"20",data:20},{label:"30",data:30}];
			
			createUIElement( new FSComboBox, CMD.SENSOR_K2, loc("sensor_enter_delay"), null, 1,menu,"0-9",3, new RegExp( RegExpCollection.REF_0to255 ) );
			attuneElement(420,60);
			createUIElement( new FSComboBox, CMD.SENSOR_K2, loc("sensor_exit_delay"), null, 2,menu,"0-9",3, new RegExp( RegExpCollection.REF_0to255 ) );
			attuneElement(420,60);
			
			drawSeparator(sep_width);
			
			createUIElement( new FSComboBox, CMD.SENSOR_K2, loc("sensor_output"),
				null,3,[{label:loc("g_disabled_m"), data:0x00},{label:loc("ui_out_opened"), data:0x1},{label:loc("ui_out_closed"),data:0x02}] );
			attuneElement(380,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE);
				
			drawSeparator(sep_width);
			
			createUIElement( new FSComboBox, CMD.SENSOR_K2, loc("sensor_disable_motion_after_trigger"),
				null, 4, ([{label:loc("g_no"),data:0x00}] as Array).concat( UTIL.comboBoxNumericDataGenerator( 1,20 ) ), "0-9",2, new RegExp( "^((0?\\d)|(1\\d)|20|"+loc("g_no")+")$" ));
			attuneElement(420,60);
				
			createUIElement( new FSComboBox, CMD.SENSOR_K2, loc("sensor_limit_alamr"),
				null, 5, ([{label:loc("g_no"),data:0},{label:"5",data:5},{label:"20",data:20}] ) );
				//null, 5, ([{label:"Нет",data:0},{label:"5",data:5},{label:"20",data:20}] ), "0-9",2, new RegExp( "^((0?0)|(0?5)|(0?20)|Нет)$" ));
			attuneElement(420,60, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			
			drawSeparator(sep_width);
			
			const target1:FormEmpty = createUIElement( new FSCheckBox, 0, loc("sensor_animal_protect"),onChangeSensorProps,6);
			attuneElement(380);
			(getLastElement() as FSCheckBox).setXPos( 380+87 );
			
			
			const target2:FormEmpty = createUIElement( new FSCheckBox, 0, loc("trigger_volume_sensor"), onChangeSensorProps,7);
			attuneElement(380);
			(getLastElement() as FSCheckBox).setXPos( 380+87 );
			
			addui( new FSShadow, CMD.SENSOR_K2, "", null, 6 );
			getLastElement().setAdapter( new AdapterSensor( target1, target2 ) );
			width = 560;
			height = 315;
			
			starterCMD = [CMD.PART_STATE_ALL2,CMD.SENSOR_K2];
		}
		
		private function onChangeSensorProps( ifrm:IFormString ):void
		{
			
			var val6:int = int( getField( CMD.SENSOR_K2, 6 ).getCellInfo() );
			var value:int = int( ifrm.getCellInfo() );
			
			if( ifrm.param == 6 )
			{
				if( value ) val6 = UTIL.changeBit( val6, 0, true );
				else val6 = UTIL.changeBit( val6, 0, false );
				
			}
			else
			{
				if( value )val6 = UTIL.changeBit( val6, 1, true );
				else val6 = UTIL.changeBit( val6, 1, false );
			}
			
			getField( CMD.SENSOR_K2, 6 ).setCellInfo( val6 );
			remember( getField( CMD.SENSOR_K2, 6 ) );
			
		}
		override public function open():void
		{
			super.open();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.SENSOR_K2, put ));
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.PART_STATE_ALL2:
					initSpamTimer(p.cmd);
					processState(p);
					break;
				case CMD.SENSOR_K2:
					distribute( p.getStructure(1), CMD.SENSOR_K2 );
					loadComplete();
					break;
			}
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			/**Параметр 1 - текущее состояние раздела. 
			 * Индекс раздела соответствует разделу из PARTITION. 
			 * состояние раздела (
			 * 0x00 - неизвестное состояние, 
			 * 0x01 - снят с охраны, 
			 * 0x02 - под охраной, 
			 * 0x06 - ошибка, нет раздела, 
			 * 0x07 - ошибка команды. (коды 0x06 и 0x07 в К2 не реализуются )*/
			
			var f:FSSimple = getField(0,1) as FSSimple;
			
			switch(p.getStructure()[0]) {
				case 1:
					f.setCellInfo( UTIL.wrapHtml( loc("guard_off"), COLOR.GREEN_SIGNAL ));
					break;
				case 2:
					f.setCellInfo( UTIL.wrapHtml( loc("guard_on"), COLOR.ORANGE));
					break;
				default:
					f.setCellInfo( UTIL.wrapHtml( loc("guard_unkwn"), COLOR.RED));
					break;
			}
		}
	}
}
import components.gui.fields.FormEmpty;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;


class AdapterSensor implements IDataAdapter
{
	private var _target1:FormEmpty;
	private var _target2:FormEmpty;
	
	public function AdapterSensor( target1:components.gui.fields.FormEmpty, target2:FormEmpty )
	{
		_target1 = target1;
		_target2 = target2;
	}
	
	public function change(value:Object):Object
	{
		return value;// меняет вбитое значение до валидации
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		_target1.setCellInfo( UTIL.isBit( 0, int( value ) )?1:0 );
		_target2.setCellInfo( UTIL.isBit( 1, int( value ) )?1:0 );
		
		return value;
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object
	{
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void
	{
		
	}
}