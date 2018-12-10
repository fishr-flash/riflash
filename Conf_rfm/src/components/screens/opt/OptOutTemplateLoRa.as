package components.screens.opt
{
	import flash.display.Bitmap;
	
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.Header;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.Library;
	import components.system.UTIL;
	
	public class OptOutTemplateLoRa extends OptionsBlock
	{

		
		private var gr:GroupOperator;

		private var evokeAkbChkBox:FSCheckBox;
		private var bitmaps:Vector.<Bitmap>;
		
		public function OptOutTemplateLoRa( struct:int )
		{
			super();
			
			structureID = struct;
			operatingCMD = CMD.CTRL_TEMPLATE_RF_ALARM_BUTTON;
			
			const wEl:int = 250;
			
			
			gr = new GroupOperator();
			FLAG_VERTICAL_PLACEMENT = true;
			
			
			addui( new FSComboCheckBox, operatingCMD, loc("navi_panic_buttons"), null, 1 );
			
			(getLastElement() as FSComboCheckBox).turnToBitfield = turnToBitfield;
			attuneElement( wEl, 250 );
			gr.add( OptOutLoRa.TEMPLATE_ALARM_BUTTON.toString(), getLastElement() );
			globalY += 20;
			
			const header:Header = new Header
			(
				[
					{ label:loc( "notify_alarms" ), xpos:0, width:100 },  
					{ label:loc( "alarm_run_command" ), xpos:wEl, width:250 }
				]
			);
			
			gr.add( OptOutLoRa.TEMPLATE_ALARM_BUTTON.toString(), header );
			
			header.x = globalX;
			header.y = globalY;
			this.addChild( header );
			
			globalY+= header.height + 30;
			
			
			
			const bntChkBx:FormEmpty = addui( new FSCheckBox, 0, loc("g_button"), change2Param, 1 );
			attuneElement( wEl );
			gr.add( OptOutLoRa.TEMPLATE_ALARM_BUTTON.toString(), bntChkBx );
			
			evokeAkbChkBox = addui( new FSCheckBox, 0, loc("out_sensor_battery"), change2Param,  2 ) as FSCheckBox;
			attuneElement( wEl );
			gr.add( OptOutLoRa.TEMPLATE_ALARM_BUTTON.toString(), getLastElement() );
			
			addui( new FSShadow, operatingCMD, "", null, 2 );
			getLastElement().setAdapter( new OptionsAdapter( getField( 0, 1 ), getField( 0, 2 ) ) );
			
			
			var list:Array = [ {label:loc("g_no"),data:"00:00"},
				{label:"01:00", data:"01:00"},{label:"05:00", data:"05:00"},
				{label:"15:00", data:"15:00"},{label:"30:00", data:"30:00"} ];
			
			addui( new FSComboBox, operatingCMD, loc("out_switchon_time"), null, 3,list , "0-9:",5,new RegExp( RegExpCollection.REF_TIME_0000to9959) );
			attuneElement( wEl,170, FSComboBox.F_COMBOBOX_TIME );
			gr.add( OptOutLoRa.TEMPLATE_ALARM_BUTTON.toString(), getLastElement() );
			
			/*** TRINKET	******************************/
			/** Команда CTRL_TEMPLATE_RCTRL - шаблон для выходов, кнопки от брелока
			 
			 Параметр 1 - Брелоки для управления. битовое поле, биты 0..31 - брелоки с номерами 1..32 соответственно. бит=0-брелок не используется в шаблоне, бит=1-брелок используется в шаблоне.
			 Параметр 2 - Действие с выходом при нажатии кнопки ""Замок закрыт"":
			 ....0 - Выключить
			 ....1 - Включить
			 ....2 - Включить на время
			 ....3 - Включить с частотой 1Гц
			 ....4 - Включить на время с частотой 1Гц
			 Параметры 3,4 - время включения (ММ:СС), параметр 3 - минуты (00-99), параметр 4 - секунды (00-59)
			 Параметр 5 - Действие с выходом при нажатии кнопки ""Замок открыт"".
			 ....0 - Выключить
			 ....1 - Включить
			 ....2 - Включить на время
			 ....3 - Включить с частотой 1Гц
			 ....4 - Включить на время с частотой 1Гц
			 Параметры 6,7 - время включения (ММ:СС), параметр 6 - минуты (00-99), параметр 7 - секунды (00-59)
			 Параметр 8 - Действие с выходом при нажатии кнопки ""Замок открыт"".
			 ....0 - Выключить
			 ....1 - Включить
			 ....2 - Включить на время
			 ....3 - Включить с частотой 1Гц
			 ....4 - Включить на время с частотой 1Гц
			 Параметры 9,10 - время включения (ММ:СС), параметр 6 - минуты (00-99), параметр 7 - секунды (00-59)	*/
			
			globalY = 0;
			var shittime:int = 50;
			var wtime:int = 70;
			var sh:int = 250;
			var w:int = 250;
			
			addui( new FSComboCheckBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_trinket_ctrl"), null, 1 );
			attuneElement(sh,w);
			(getLastElement() as FSComboCheckBox).turnToBitfield = turnToBitfield;
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), getLastElement() );
			
			var h:Header = new Header( [{label:loc("ui_part_action"),xpos:0, width:200},{label:loc("alarm_run_command"), xpos:sh, width:200}], {size:12, border:false, align:"left"} );
			addChild( h );
			gr.add( OptOutLoRa.TEMPLATE_TRINKET.toString(), h );
			h.y = globalY;
			globalY += 40;
			
			
			
			var l:Array = UTIL.getComboBoxList([[0, loc("g_switchoff")],[1,loc("g_switchon")],[2,loc("g_switchon_time")],[3, loc("out_switchon_1hz")],[4,loc("g_switchon_1hz")]]);
			var ltime:Array = UTIL.getComboBoxList([["01:00","01:00"],["05:00","05:00"],["10:00","10:00"],["30:00","30:00"]]);
			
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), addBitmap(Library.cLock, sh - 30) );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_onclick_action"), onClick, 2, l );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_switchon_time"), null, 3, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0002to9959) ).x = shittime;
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), getLastElement() );
			attuneElement(sh + (w-(wtime+shittime)),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), addBitmap(Library.cUnlock, sh - 30) );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_onclick_action"), onClick, 5, l );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_switchon_time"), null, 6, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0002to9959) ).x = shittime;
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), getLastElement() );
			attuneElement(sh + (w-(wtime+shittime)),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), addBitmap(Library.cStar, sh - 30) );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_onclick_action"), onClick, 8, l );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_switchon_time"), null, 9, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0002to9959) ).x = shittime;
			gr.add(OptOutLoRa.TEMPLATE_TRINKET.toString(), getLastElement() );
			attuneElement(sh + (w-(wtime+shittime)),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			
		}
		
		private function onClick(t:IFormString):void
		{
			
			
			getField(CMD.CTRL_TEMPLATE_RCTRL,3).disabled = int(getField(CMD.CTRL_TEMPLATE_RCTRL,2).getCellInfo())!=4 && int(getField(CMD.CTRL_TEMPLATE_RCTRL,2).getCellInfo())!=2;
			getField(CMD.CTRL_TEMPLATE_RCTRL,6).disabled = int(getField(CMD.CTRL_TEMPLATE_RCTRL,5).getCellInfo())!=4 && int(getField(CMD.CTRL_TEMPLATE_RCTRL,5).getCellInfo())!=2;
			getField(CMD.CTRL_TEMPLATE_RCTRL,9).disabled = int(getField(CMD.CTRL_TEMPLATE_RCTRL,8).getCellInfo())!=4 && int(getField(CMD.CTRL_TEMPLATE_RCTRL,8).getCellInfo())!=2;
			if (t)
				remember(t);
		}
		
		private function addBitmap(cls:Class, xpos:int):Bitmap
		{
			if (!bitmaps)
				bitmaps = new Vector.<Bitmap>(3);
			bitmaps.push(new cls);
			var index:int = bitmaps.length-1;
			addChild( bitmaps[index] );
			bitmaps[index].x = xpos;
			bitmaps[index].y = globalY;
			return bitmaps[index];
		}
		
		private function change2Param( field:IFormString ):void
		{
			
			var res:int = 0;
			
			const one:int = int( getField( 0, 1 ).getCellInfo() );
			const three:int = int( getField( 0, 2 ).getCellInfo() );
			
			if( one ) res |= 1;
			if( three ) res |= 8;
			
			
			
			getField( operatingCMD, 2 ).setCellInfo( res );
			
			 
			remember( getField( operatingCMD, 2 ) );
		}		
		
		
		public function open(choise:int):void
		{
			
			
			var len:int = gr.names.length;
			for (var i:int=0; i<len; i++) 
				gr.visible( gr.names[ i ], false );
			
			
			switch( choise ) {
				case OptOutLoRa.TEMPLATE_ALARM_BUTTON:
					RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, putData) );
					gr.visible( gr.names[ gr.names.indexOf( choise.toString() ) ], true );
					break;
				case OptOutLoRa.TEMPLATE_TRINKET:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_TEMPLATE_RCTRL, putData) );
					gr.visible( gr.names[ gr.names.indexOf( choise.toString() ) ], true );
					break;
				default:
					/// zero
					break;
			}
			
		}
		
		override public function putData(p:Package):void 
		{
			
			switch( p.cmd ) {
				case operatingCMD:
					( getField( operatingCMD, 1 ) as FSComboCheckBox ).setList( createDataofAButtons( p, OptOutLoRa.DEVICE_ALARM_BUTTON ) );
					getField( operatingCMD, 2 ).setCellInfo( p.data[ structureID - 1][ 1 ] );
					
					getField(operatingCMD,3).setCellInfo( mergeIntoTime( OPERATOR.getData(operatingCMD)[structureID-1][2],
						OPERATOR.getData(operatingCMD)[structureID-1][3] ));
					break;
				
				case CMD.CTRL_TEMPLATE_RCTRL:
					
					( getField( CMD.CTRL_TEMPLATE_RCTRL, 1 ) as FSComboCheckBox ).setList( createDataofAButtons( p, OptOutLoRa.DEVICE_TRINKET ) );
					
					onClick(null);
					
					
					getField(CMD.CTRL_TEMPLATE_RCTRL,2).setCellInfo( p.data[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_RCTRL,3).setCellInfo( mergeIntoTime( p.data[structureID-1][2],
						p.data[structureID-1][3] ));
					getField(CMD.CTRL_TEMPLATE_RCTRL,5).setCellInfo( p.data[structureID-1][4] );
					getField(CMD.CTRL_TEMPLATE_RCTRL,6).setCellInfo( mergeIntoTime( p.data[structureID-1][5],
						p.data[structureID-1][6] ));
					getField(CMD.CTRL_TEMPLATE_RCTRL,8).setCellInfo( p.data[structureID-1][7] );
					getField(CMD.CTRL_TEMPLATE_RCTRL,9).setCellInfo( mergeIntoTime( p.data[structureID-1][8],
						p.data[structureID-1][9] ));
					
					onClick(null);
					
					break;
				
				default:
					break;
			}
			
			
		}
		
		
		
		
		private function turnToBitfield( arr:Array ):int
		{
			var num:int = 0;
			var len:int = arr.length;
			for (var i:int=0; i<len; i++) {
				num |= (1<< int(arr[i]-1));
			}
			return num;
		}
		private function createDataofAButtons( p:Package, deviceIndex:int ):Array
		{
			
			const exist_list:Array = new Array();
			const value:int = int( p.data[ structureID - 1 ][ 0 ] );
			const in_list:Array = selectNonEmptyPositions( OPERATOR.getData( CMD.LR_DEVICE_LIST_RF_SYSTEM ) );
			
			exist_list.push( {"label":loc("his_everyone"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL }  );
			var choice:Boolean;
			
			const len:int = in_list.length;
			for (var i:int=0; i<len; i++) 
			{
				
				if( in_list[ i ][ 1 ] != deviceIndex ) continue;
				
				exist_list.push( {"labeldata":( in_list[ i ][ 2 ]+1), 
					"label":(in_list[ i ][ 2 ]+1),
					"data":UTIL.isBit( in_list[ i ][ 2 ], int( value ) ), 
					"block": 0 } ); 
			}
			
			return exist_list;
			
			/**
			 *  избавляемся от незанятых мест
			 */
			function selectNonEmptyPositions( in_list:Array):Array
			{
				var len:int = in_list.length;
				var out_values:Array = [];
				for (var j:int=0; j<len; j++) {
					
					if( in_list[ j ][ 0 ] != 1 ) continue;
						
					out_values.push(  ( in_list[ j ] as Array ).slice() );
					out_values[ out_values.length - 1 ][ 2 ] = j;
				}
				
				return out_values;
			}	
		}
		
			
		
		
	}
}
import components.gui.fields.FSComboCheckBox;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;

class AdapterButtonsField implements IDataAdapter
{
	
	private var _combo:FSComboCheckBox;
	
	public function change(value:Object):Object 	// меняет вбитое значение до валидации
	{
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		
		const list:Array = new Array();
		
		
		const len:int = Number( value ).toString( 2 ).length;
		for (var i:int=0; i<len; i++) 
		{
			
			
			
			list.push( {"labeldata":(i+1), 
				"label":(i+1),
				"data":UTIL.isBit( i, int( value ) ), 
				"block":0 } ); // param = partition (45,65,99 etc)
		}
		
		return list;
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
		
		_combo = field as FSComboCheckBox;
	}
}

class OptionsAdapter implements IDataAdapter
{

	private var _fieldOne:IFormString;

	private var _fieldThree:IFormString;

	public function OptionsAdapter( fieldOne:IFormString, fieldThree:IFormString )
	{
		_fieldOne = fieldOne;
		_fieldThree = fieldThree;
	}
	
	public function change(value:Object):Object 	// меняет вбитое значение до валидации
	{
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		_fieldOne.setCellInfo( UTIL.isBit( 0, int( value ) ) );
		_fieldThree.setCellInfo( UTIL.isBit( 3, int( value ) ) );
		
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