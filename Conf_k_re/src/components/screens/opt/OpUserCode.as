package components.screens.opt
{
	import components.abstract.adapters.BitAdapter;
	import components.abstract.functions.getAllPartitionCCBList;
	import components.abstract.functions.getAllPartitionUserCodeList;
	import components.abstract.functions.turnToPartitionBitfield;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboCheckBoxGroupDisabler;
	import components.gui.fields.FormString;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIRUserCode;
	import components.static.CMD;
	import components.system.UTIL;
	
	import su.fishr.utils.searcPropValueInArr;
	
	public class OpUserCode extends OptionListBlock implements IFlexListItem
	{
		private var COM:int = CMD.K5_KBD_KEY;
		private var validator:IFormString;

		private var _activeGroup:int;
		
		public function OpUserCode(s:int)
		{
			super();
			
			SELECTION_Y_SHIFT = -1;
			
			drawSelection(421);
			
			structureID = s;
			globalFocusGroup = 10*structureID;
			FLAG_VERTICAL_PLACEMENT = false;
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, String(structureID), null, 1 );
			attuneElement( 40 ); 
			FLAG_SAVABLE = true;
			
			/** Команда K5_KBD_KEY */
			/** Параметр 2 - Пароль пользователя ( 0-9999 ). */
			globalX = 50;
			
			createUIElement( new FormString,COM,"",null,1,null,"0-9",4,new RegExp("^(\\d{4})$")).x = globalX;
			validator = getLastElement();
			attuneElement( 60,NaN, FormString.F_ALIGN_CENTER | FormString.F_EDITABLE | FormString.SEND_EVEN_WHEN_DATA_NOT_CHANGED );
			getLastFocusable().focusorder = 2;
			getLastElement().setAdapter(new HexAdapter4);
			UIRUserCode.getValidator().register(validator);
			
			/** Параметр 3 - Разделы, к которым относится пароль пользователя
			 *  ( Битовое поле, указывающее на на строку в PARTITION. 
			 * 0x0001 - первая строка, 0x0002 - вторая строка, 
			 * 0x0004 - третья строка..., 0x8000 - 16 строка). 
			 * Строки разделов выбираются от 1 до 16 по “или” 
			 * ( битовое представление ); */
			
			
			globalX += 85;
			createUIElement( new FSComboCheckBoxGroupDisabler,COM,"", dlgtPartitionList,2).x = globalX;
			attuneElement( 0, 150 );
			(getLastElement() as FSComboCheckBoxGroupDisabler).turnToBitfield = turnToPartitionBitfield;
			getLastFocusable().focusorder = 3;
			getLastElement().setAdapter( new BitAdapter );
			/** Параметр 4 - Использовать под принуждением ( 0x00 - нет, 0x01 - да ). */
			globalX += 210;
			createUIElement( new FSCheckBox,COM,"",null,3).x = globalX;
			attuneElement( 0 );
			getLastFocusable().focusorder = 4;
			
			width = 425;
		}
		
		private function dlgtPartitionList( ifr:IFormString ):void
		{
			
			remember( ifr );
			
			/*****************************************************************
			 * 	Далее анализируем, если выбран чекбос с пожарным разделом
			 * не даем отмечать другие, если выбраны обычные разделы не 
			 * даем отмечать пожарный
			 * ****************************************************************/
			
			const box:FSComboCheckBoxGroupDisabler = ( ifr as FSComboCheckBoxGroupDisabler); 
			
			const listParts:Array = box.getList().slice();
			const indexGroup:int = searcPropValueInArr( "labeldata", box.getCellInfo(), listParts );

			/// значит выбран второй пункт из этой же группы
			/// выходим без анализа
			if( _activeGroup && box.getCellInfo() > 0 && indexGroup === -1 )
																				return;
			
			_activeGroup = indexGroup > -1?listParts[ indexGroup ].group:0;
			
			
			
			
			var len:int = listParts.length;
			var indexSelected:int = 0;
			for (var i:int=1; i<len; i++) {
				
				if( listParts[ i ].group !== _activeGroup  )	
					listParts[ i ].disabled = true;
				else if( listParts[ i ].group !== 3 )
					listParts[ i ].disabled = false;
				
			}
			
			box.setList( listParts );
			
			
		}
		override public function get height():Number
		{
			return 30;
		}
		public function kill():void		
		{
			UIRUserCode.getValidator().unregister(validator);
		}
		public function change(p:Package):void		{		}
		public function put(p:Package):void
		{
			var info:Array = p.getStructure(structureID);
			
			/** Параметр 1 - Пароль пользователя ( 0-9999 ). */
			getField(COM,1).setCellInfo( UTIL.formateZerosInFront(String(info[0]),4) );
			/** Параметр 2 - Разделы, к которым относится пароль пользователя ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Строки разделов выбираются от 1 до 16 по “или” ( битовое представление ); */
			(getField(COM,2) as FSComboCheckBoxGroupDisabler).setList( getAllPartitionUserCodeList( info[1])  ); 
			/** Параметр 3 - Использовать под принуждением ( 0x00 - нет, 0x01 - да ). */
			getField(COM,3).setCellInfo( String(info[2]) );
		}
		public function putRaw(value:Object):void		{		}
		public function extract():Array		
		{	
			return [int(getField(COM,1).getCellInfo()),int(getField(COM,2).getCellInfo()),int(getField(COM,3).getCellInfo())];
		}
		public function set selectLine(b:Boolean):void	
		{
			select( b );
		}
		public function isSelected():Boolean
		{
			return selection.visible;
		}
	}
}
import components.abstract.adapters.HexAdapter;
import components.system.UTIL;

class HexAdapter4 extends HexAdapter
{
	override public function adapt(value:Object):Object
	{
		return UTIL.fz( super.adapt(value),4);
	}
}