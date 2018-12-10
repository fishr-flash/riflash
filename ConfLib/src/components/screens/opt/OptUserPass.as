package components.screens.opt
{
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.IListItem;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	import flash.events.Event;
	
	public class OptUserPass extends OptionListBlock implements IListItem
	{
		private var COM:int = CMD.USER_PASS;
		
		public function OptUserPass( _struct:int)
		{
			super();
			
			drawSelection(484);
			
			structureID = _struct;
			globalFocusGroup = 10*structureID;
			FLAG_VERTICAL_PLACEMENT = false;
			
		/** Команда USER_PASS */
		/** Параметр 1 - Наличие пользователя в приборе ( 0x00 - Нет пользователя, 0x01 - Есть пользователь ); */
			createUIElement( new FormString,COM , String(getStructure()),null,1).x = 15;
			attuneElement(50,NaN, FormString.F_ALIGN_CENTER | FormString.F_RETURN_0OR1 );
			getLastFocusable().focusorder = 1;
		/** Параметр 2 - Пароль пользователя ( 0-9999 ). */
			createUIElement( new FormString,COM,"",change,2,null,"0-9",4, new RegExp("^([\\d]{4})$")).x = 135;
			attuneElement( 50,NaN, FormString.F_ALIGN_CENTER | FormString.F_EDITABLE | FormString.SEND_EVEN_WHEN_DATA_NOT_CHANGED );
			getLastFocusable().focusorder = 2;
			var field:FormEmpty = getField(COM,2) as FormEmpty;
			field.addEventListener( Event.CHANGE, dataChanged );
		/** Параметр 3 - Разделы, к которым относится пароль пользователя ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление ); */
			createUIElement( new FSComboCheckBox,COM,"",null,3).x = 225;
			attuneElement( 0,150 );
			(getLastElement() as FSComboCheckBox).turnToBitfield = PartitionServant.turnToPartitionBitfield;
			getLastFocusable().focusorder = 3;
		/** Параметр 4 - Использовать под принуждением ( 0x00 - нет, 0x01 - да ). */
			createUIElement( new FSCheckBox,COM,"",null,4).x = 405;
			attuneElement( 0 );
			getLastFocusable().focusorder = 4;
		}
		private function dataChanged(ev:Event):void
		{
			dispatchEvent(ev);
			
			var field:FormEmpty = getField(COM,2) as FormEmpty;
			var info:String = String(field.getCellInfo()); 
			if( !field.isValid( info ) )
				field.valid = false;
			else
				isUnique(2);
			
			SavePerformer.remember( getStructure(), field );
		}
		private function change(target:IFormString):void{}
		
		override public function putRawData(data:Array):void
		{
			var info:Array = data;
			
			/** Команда USER_PASS */
			/** Параметр 1 - Наличие пользователя в приборе ( 0x00 - Нет пользователя, 0x01 - Есть пользователь ); */
			/** Параметр 2 - Пароль пользователя ( 0-9999 ). */
			var field:FormEmpty = getField(COM,2) as FormEmpty;
			field.setCellInfo( UTIL.formateZerosInFront(String(info[1]),4) );
			/** Параметр 3 - Разделы, к которым относится пароль пользователя ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление ); */
			(getField(COM,3) as FSComboCheckBox).setList( PartitionServant.getPartitionCCBList(info[2]) ); 
			/** Параметр 4 - Использовать под принуждением ( 0x00 - нет, 0x01 - да ). */
			getField(COM,4).setCellInfo( String(info[3]) );
		}
		override public function getUniqueData(param:int):String 
		{
			return UTIL.createPassword(4,true);
		}
	}
}
//139 строк до рефакторинга