package components.gui.fields
{
	import flash.events.Event;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.gui.fields.lowlevel.MComboBox;
	import components.interfaces.IFocusable;

	public class FSComboCheckBox extends FSComboBox implements IFocusable
	{
		protected var lastValidInfo:String;
		protected var line_data:String;				// Строка откуджа будет подцепляться информация для отправки
		
		public static const TRIGGER_SELECT_ALL:int = 0x01;
		public static const TRIGGER_I_SEPERATOR:int = 0x02;
		public static const TRIGGER_SELECT_GROUP:int = 0x03;
		public static const TRIGGER_SELECT_ALL_INVERT:int = 0x04;
		
		public static const F_RETURNS_ARRAY_OF_LABELDATA:int = 0x01;
		public static const F_RETURNS_FIRST_NIMBLE_FORWARD:int = 0x02;
		public static const F_RETURNS_BCD_FORMAT:int = 0x04;
		public static const F_ATLEAST_ONE_SELECTED:int = 0x08;
		public static const F_RETURNS_RAW_LABEL:int = 0x10;
		public static const F_MULTYLINE:int = 0x20;
		
		public var LABEL_SELECT_ALL:String=loc("g_all");
		public var MAX_SELECTED_ITEMS:int=-1;
		
		protected var RETURNS_LABELDATA:Boolean=false;
		protected var RETURNS_FIRST_NIMBLE_FORWARD:Boolean=false;
		protected var RETURNS_BCD_FORMAT:Boolean = false;
		protected var ATLEAST_ONE_SELECTED:Boolean = false;
		protected var RETURNS_RAW_LABEL:Boolean = false;
		
		protected var atlestOne_selected:String = loc("g_selected");
		protected var atlestOne_none:String = loc("g_no");
		
		protected const REF_DELIM:String = " +, +|, *| *,| +";
		
		public var debugId:int;
		public var turnToBitfield:Function;
		public var blackText:String=null;
		
		public function FSComboCheckBox()
		{
			super();
		}
		/***********************************************
		 * Параметры обьекта для dataProvider:
		 * label:String		- отображение в каждой ячейке, оно не отсылается никуда
		 * labeldate:String	- информация о ячейке, оно же отсылается в строковом виде через запятую
		 * data:int			- 1 или 0 отмечен чекбокс или нет
		 * block:int		- все итемы содаержащие block не равный выбранному будут блокированы 
		 * trigger:int		- если >0 то итем не участвует в сборе информации и других действиях. 
		 * 					Он выполняет действия только при нажатии на него:
		 *				 		1 - select all/ deselect all
		 * 						2 - simple separator (empty space)
		 * 						3 - select group == object.group number
		 * 						4 - selec all при нажатии, снимает выделение со всех объектов, а объекты снимают выделение с него
		 * senddata:int		- у триггера 1 есть возможность послать специальную комманду если он был выбран
		 * *********************************************/		
		
		override protected function construct():void
		{
			cell = new MComboBox(MComboBox.S_CheckComboBox);
			addChild( cell );
			cell.width = 100;
			configureListeners();
		}
		override public function setWidth( _num:int ):void 
		{
			tName.width = _num;
			cell.x = tName.width;
		}
		override public function setCellWidth(value:int):void
		{
			cell.width = value;
		}
		override protected function change(ev:Event):void
		{
			selectItem(ev);
			send();
			dispatchEvent(new Event(Event.CHANGE));
		}
		protected function selectItem( ev:Event ):void
		{
			var obj:Object;
			
			if (ev && cell.selectedIndex > -1) {
				obj = cell.dataProvider.getItemAt( cell.selectedIndex );
				obj.data = int(!obj.data);
			}
			var anythingToBlock:Boolean = false;
			var str:String="";							// Строка которая собирает реальную информацию о выбранных чекбоксах
			var len:int = cell.dataProvider.length;
			var i:int;
			var tObj:Object;
			
			// если обьект имеет действие 
			if ( obj && obj.trigger is int ) {
				
				switch(obj.trigger) {
					case TRIGGER_SELECT_ALL:		// выбрать все / убрать все
						for( i=0; i<len; ++i ) {
							tObj = cell.dataProvider.getItemAt( i ) as Object; 
							// если итем не триггер 1,2  т.е. его надо обрабатывать
							if ( tObj.trigger == null && !tObj.disabled )
								tObj.data = obj.data;
						}
						break;
					case TRIGGER_SELECT_GROUP:		// выбрать / убрать группу
						for( i=0; i<len; ++i ) {
							// если итем не триггер и он принадлежит группе триггера
							tObj = cell.dataProvider.getItemAt( i ) as Object; 
							if ( !(tObj.trigger is int ) && tObj.group == obj.group )
								tObj.data = obj.data;
						}
						break;
					case TRIGGER_SELECT_ALL_INVERT:	// выбрать все
						if(obj.data == 1) {
							for( i=0; i<len; ++i ) {
								tObj = cell.dataProvider.getItemAt( i ) as Object; 
								// если итем не триггер 1,2  т.е. его надо обрабатывать
								if ( tObj.trigger == null )
									tObj.data = 0;
							}
						}
						
						break;
				}
			}
			
			var gr_total:Object = new Object;
			var gr_not_whole_selected:Object = new Object;
			
			if ( MAX_SELECTED_ITEMS > -1 && !(obj && obj.trigger && obj.trigger == TRIGGER_SELECT_ALL) ) {
				var total:int = 0;
				// Перебор всех обьектов комбочекбокса чтобы выяснить не превышает ли число галочек мак значения
				for( i=0; i<len; ++i ) {
					tObj = cell.dataProvider.getItemAt( i ) as Object;
					if ( tObj.trigger == null ) {
						if ( tObj.data == 1 ) {
							total++;
						}
						// Доходим до максимального значения
						if (total > MAX_SELECTED_ITEMS) {
							// Если есть объект значит на галочку ткнули мышкой
							if (obj)
								obj.data = 0;
							
							total = 0;
							
							// После этого надо проверить не было ли выделено еще лишних галочек
							for (var l:int=0; l<len; ++l) {
								tObj = cell.dataProvider.getItemAt( l ) as Object;
								if ( tObj.trigger == null ) {
									if ( tObj.data == 1 ) {
										total++;
									}
								}
							}
							// Если были то надо все обнулить
							if (total > MAX_SELECTED_ITEMS) {
								for (l=0; l<len; ++l) {
									tObj = cell.dataProvider.getItemAt( l ) as Object;
									if ( tObj.trigger == null ) {
										tObj.data = 0;
									}
								}
							} else
								return;
							break;
						}
					}
				}
			}
			// Перебор всех обьектов комбочекбокса
			for( i=0; i<len; ++i ) {
				tObj = cell.dataProvider.getItemAt( i ) as Object;

				// если объект не триггер
				if ( !(tObj.trigger is int )) {
					// если объект принадлежит группе, создаем соответствующий раздел в объекте групп 
					if( tObj.group is int ) {
						if (!(gr_total[ tObj.group ] is String))
							gr_total[ tObj.group ] = "";
						// если нет, создаем раздел "nogroup"
					} else {
						if (!(gr_total[ "nogroup" ] is String))
							gr_total[ "nogroup" ] = "";
					}
					// если объект выбран
					if ( tObj.data == 1 ) {
						anythingToBlock = true;
						// если объект принадлежит группе
						if( tObj.group is int )
							gr_total[ tObj.group ] += gr_total[ tObj.group ]=="" ?  tObj.labeldata : ","+tObj.labeldata;
						else
							gr_total[ "nogroup" ] += gr_total[ "nogroup" ]=="" ?  tObj.labeldata : ","+tObj.labeldata;
						str += str=="" ?  tObj.labeldata : ","+tObj.labeldata;
					} else {
						// если объект не выключен
						if ( !tObj.disabled ) {
							// если обьект не выбран, но принадлежит группе создаем соответствующий раздел в объекте "группа которая не выбрана" 
							if( tObj.group is int )
								gr_not_whole_selected[ tObj.group ] = 1;
							else
								gr_not_whole_selected[ "nogroup" ] = 1;
						}
					}
				} 
			}
			line_data = str;
			
			str = "";
			var trAll:Object = getObjByTrigger(TRIGGER_SELECT_ALL);
			if (trAll)
				trAll.data = 1;
			var trAllOneWay:Object = getObjByTrigger(TRIGGER_SELECT_ALL_INVERT);
			// проверяем объект существующих групп
			for(var k:String in gr_total) {
				// если "не выбранные группы" существует добавляем в строку выбранные элементы
				
				if(gr_not_whole_selected[k] is int) {
					if (gr_total[k] != "")
						str += str == "" ? gr_total[k] : ","+gr_total[k];
					if (k != "nogroup")
						getObjByGroup(k).data = 0;
					if (trAll)
						trAll.data = 0;
					if (trAllOneWay && trAllOneWay != obj )
						trAllOneWay.data = 0;
					
					// иначе заменяем элементы на название группы
				} else {
					if (k != "nogroup") {
						str += str == "" ? getObjByGroup(k).label : ","+getObjByGroup(k).label;
						getObjByGroup(k).data = 1;
					} else
						str += str == "" ? gr_total[k] : ","+gr_total[k];
				}
			}
			// если все объекты оказались выбраны, заменяем лейбл на "выбрано все";
			if (trAll && trAll.data == 1 && !RETURNS_RAW_LABEL ) {
				str = LABEL_SELECT_ALL;
				if( trAll.senddata != null ) {
					line_data = String(trAll.senddata);  
				}
				
			}
			// если все объекты оказались выбраны, заменяем лейбл на "выбрано все";
			if( trAllOneWay && trAllOneWay.data == 1 && !RETURNS_RAW_LABEL ) {
				str = LABEL_SELECT_ALL;
				if( trAllOneWay.senddata != null ) {
					line_data = String(trAllOneWay.senddata);  
				}
			}
			// если выбран режим atleastOneSelected заменяем лейбы на выбрано/не выбрано.
			if (ATLEAST_ONE_SELECTED) {
				if (line_data != "")
					str = atlestOne_selected;
				else
					str = atlestOne_none;
			}
			
			if ( obj && obj.block != null ) {
				if ( anythingToBlock )
					cell.disable( obj.block );
				else
					cell.disable( -1 );
			} else
				cell.disable( -1 );
			
			if (adapter)
				cell.text = adapter.adapt(str) as String;
			else
				cell.text = str;
			lastValidInfo = str;
			
			if (cell.text == "" && blackText is String )
				cell.text = blackText;
			
			if (ev)
				send();
			if (obj && obj.param == 0xFFFF )
				cell.close();
		}
		public function setAtlLEastOneSelectedNames(selected:String, no:String):void
		{
			atlestOne_selected = selected;
			atlestOne_none = no; 
		}
		protected function getObjByTrigger(t:Object):Object
		{
			var len:int = cell.dataProvider.length;
			var i:int;
			var tObj:Object;
			for( i=0; i<len; ++i ) {
				tObj = cell.dataProvider.getItemAt( i ) as Object; 
				if ( tObj.trigger is int && tObj.trigger == int(t) )
					return tObj;
			}
			return null;
		}
		protected function getObjByGroup(g:Object):Object
		{
			
			var len:int = cell.dataProvider.length;
			var i:int;
			var tObj:Object;
			for( i=0; i<len; ++i ) {
				tObj = cell.dataProvider.getItemAt( i ) as Object; 
				if ( tObj.trigger is int && tObj.group is int && tObj.group == int(g) )
					return tObj;
			}
			return null;
		}
		private function isAtleastOneBlock( _block:int ):Boolean 
		{
			var len:int = cell.dataProvider.length;
			for( var i:int; i<len; ++i ) {
				if ( !((cell.dataProvider.getItemAt( i ) as Object).trigger is int) &&
					(cell.dataProvider.getItemAt( i ) as Object).block == _block && 
					(cell.dataProvider.getItemAt( i ) as Object).data == 1 ) {
					return true
				}
			}
			return false;
		}
		override public function setList( _arr:Array, _selectedIndex:int=-1 ):void
		{
			
			super.setList( _arr, _selectedIndex );
			selectItem(null);
		}
		override public function getCellInfo():Object
		{
			var result:String = line_data;
			var trAll:Object = getObjByTrigger(TRIGGER_SELECT_ALL);
			if (trAll && trAll.senddata == result)
				return [result];
			var trAllInvert:Object = getObjByTrigger(TRIGGER_SELECT_ALL_INVERT);
			if (trAllInvert && trAllInvert.senddata == result)
				return [result];
			
			if( RETURNS_LABELDATA ) {
				
				var arr:Array;
				if (result == "")
					arr = [];
				else
					arr = result.split( new RegExp( REF_DELIM ));
				var a:String;
				var bcd:String = RETURNS_BCD_FORMAT ? "0x":"";
				if(RETURNS_FIRST_NIMBLE_FORWARD) {
					for(a in arr) {
						var len:int = (arr[a]).toString().length;
						var target:int = int( bcd+arr[a]);
						arr[a] = (target & 0x000F) << 4*(len-1) | target >> 4;
					}
				} else if(RETURNS_BCD_FORMAT){
					for(a in arr) {
						arr[a] = int("0x"+arr[a]);
					}
				}
				return arr;
			}
			if (!result)
				result = "";
			//ЗДесь должна уходить битовая маска разделов на К7		
			if (turnToBitfield is Function) {
				if( result is String && result.length > 0 )
					return turnToBitfield( result.split(",") );
				return turnToBitfield([]);
			}
			
			dtrace("FSComboCheckBox не имеет функции превращения в битовое поле. Возвращается простой массив");
			if (result != "")
				return result.split(",");
			else
				return [];
		}
		override public function get valid():Boolean
		{
			return true;
		}
		override protected function applyParam(param:int):void
		{
			switch( param ) {
				case F_RETURNS_ARRAY_OF_LABELDATA:
					RETURNS_LABELDATA = true;
					break;
				case F_RETURNS_FIRST_NIMBLE_FORWARD:
					RETURNS_FIRST_NIMBLE_FORWARD = true;
					break;
				case F_RETURNS_BCD_FORMAT:
					RETURNS_BCD_FORMAT = true;
					break;
				case F_ATLEAST_ONE_SELECTED:
					ATLEAST_ONE_SELECTED = true;
					break;
				case F_RETURNS_RAW_LABEL:
					RETURNS_RAW_LABEL = true;
					break;
				case F_MULTYLINE:
					tName.multiline = true;
					//textFormat.leading = -7;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					tName.height = tName.textHeight+5;
					tName.y = -int((tName.height - 22)/2);
					break;
			}
		}
		override public function set disabled(value:Boolean):void
		{
			
			if( super.disabled == value ) return;
			super.disabled = value;
			
		}
		override public function getHeight():int 
		{
			return cell.height;
		}
		override public function getType():int
		{
			if (!cell.enabled)
				return TabOperator.TYPE_DISABLED;  
			return TabOperator.TYPE_ACTION;
		}
	}
}