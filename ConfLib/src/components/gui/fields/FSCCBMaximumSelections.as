package components.gui.fields
{
	import flash.events.Event;
	
	import components.abstract.LOC;
	import components.gui.Balloon;

	public class FSCCBMaximumSelections extends FSComboCheckBox
	{
		public var REACH_MAX_TEXT:String = LOC.loc("g_item_limit_exceed0");
		//public var EXCEED_MAX_TEXT:String = "Достигнуто максимальное количество выбранных пунктов. Выберите \"Все\" либо снимите существующую галочку, чтобы выбрать что-то другое."
		
		public function FSCCBMaximumSelections()
		{
			super();
		}
		override public function setWidth( _num:int ):void 
		{
			//cell.width = _num;
			
			tName.width = _num;
			cell.x = tName.width;
		}
		override public function setCellWidth(value:int):void
		{
			cell.width = value;
		}
		override protected function selectItem( ev:Event ):void
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
				}
			}
			
			var gr_total:Object = new Object;
			var gr_not_whole_selected:Object = new Object;
			
			
			var reachMaximum:Boolean = false;
			var exceedMaximum:Boolean = false;
			var totalDeselected:int = 0;
			
			total = 0;
			for( i=0; i<len; ++i ) {
				tObj = cell.dataProvider.getItemAt( i ) as Object;
				if ( tObj.trigger == null ) {
					if ( tObj.data == 1 ) {
						total++;
					}
				}
			}
			if (total+1 == len)
				obj = getObjByTrigger(TRIGGER_SELECT_ALL);
			
			if ( MAX_SELECTED_ITEMS > -1 && !(obj && obj.trigger && obj.trigger == TRIGGER_SELECT_ALL) ) {
				var total:int = 0;
				// Перебор всех обьектов комбочекбокса чтобы выяснить не превышает ли число галочек мак значения
				for( i=0; i<len; ++i ) {
					tObj = cell.dataProvider.getItemAt( i ) as Object;
					if ( tObj.trigger == null ) {
						if ( tObj.data == 1 ) {
							total++;
						}
						//tObj.disabled = total > MAX_SELECTED_ITEMS;
						// Доходим до максимального значения
						if (total > MAX_SELECTED_ITEMS) {
							reachMaximum = true;
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
								exceedMaximum = true;
								
								for (l=len-1; total>MAX_SELECTED_ITEMS; --l) {
									tObj = cell.dataProvider.getItemAt( l ) as Object;
									if ( tObj.trigger == null && tObj.data == 1 ) {
										tObj.data = 0;
										total--;
										totalDeselected++;
									}
								}
							}
							break;
						}
					}
				}
			}
			
			if (exceedMaximum) {
				Balloon.access().show( LOC.loc("sys_attention"), LOC.loc("g_item_limit_exceed")+totalDeselected+" "+getGalochki(totalDeselected)+LOC.loc("") );
			} else if (reachMaximum) {
				Balloon.access().show( LOC.loc("sys_attention"), REACH_MAX_TEXT, 70 );
			}
			
			var totalitems:int;
			
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
			
			if (ev)
				send();
			if (obj && obj.param == 0xFFFF )
				cell.close();
		}
		private function getGalochki(amount:int):String
		{
			var v:int = amount - (int(amount/10)*10)
			
			switch(v) {
				case 1:
					return LOC.loc("util_check1");
				case 2:
				case 3:
				case 4:
					return LOC.loc("util_check2");
			}
			return LOC.loc("util_check0");
		}
	}
}