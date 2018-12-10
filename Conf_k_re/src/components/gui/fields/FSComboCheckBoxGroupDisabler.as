package components.gui.fields
{
	import flash.events.Event;

	public class FSComboCheckBoxGroupDisabler extends FSComboCheckBox
	{
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
						var sg:int = -1;	// selectedgroup
						for( i=0; i<len; ++i ) {
							tObj = cell.dataProvider.getItemAt( i ) as Object; 
							// если итем не триггер 1,2  т.е. его надо обрабатывать
							if ( tObj.trigger == null && !tObj.disabled ) {
								
								if (!tObj.group || sg < 0 || (tObj.group && tObj.group == sg) )
									tObj.data = obj.data;
								if ( tObj.group && sg == -1 )
									sg = tObj.group;
								if ( tObj.group && sg > -1 && tObj.group != sg )
									tObj.disabled = true;
							}
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
			
			var selectedgroup:int;
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
						if( tObj.group is int ) {
							gr_total[ tObj.group ] += gr_total[ tObj.group ]=="" ?  tObj.labeldata : ","+tObj.labeldata;
							if (!tObj.disabled)
								selectedgroup = tObj.group; 
						} else
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
				if (gr_total[k] != "")
					str += str == "" ? gr_total[k] : ","+gr_total[k];
				if (trAll)
					trAll.data = 0;
			}
			
			// выключаем обьекты по группам 
			var totalavailable:int = 0;
			var totalselected:int = 0;
			for( i=0; i<len; ++i ) {
				tObj = cell.dataProvider.getItemAt( i ) as Object;
				if (!tObj.trigger) {
					if  (tObj.group == 3 || tObj.group != selectedgroup && selectedgroup > 0 )
						tObj.disabled = true;
					else {
						tObj.disabled = false;
						
						totalavailable++;
						if( tObj.data == 1 )
							totalselected++;
					}
				}
			}
			// если число доступных равно числу выбранных, значит отмечаем галочку на "выбрать все"
			if (totalselected == totalavailable) {
				trAll.data = 1;
				trace("trAll.data "+ trAll.data);
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
		override protected function getObjByGroup(g:Object):Object
		{
			var len:int = cell.dataProvider.length;
			var i:int;
			var tObj:Object;
			for( i=0; i<len; ++i ) {
				tObj = cell.dataProvider.getItemAt( i ) as Object; 
				if ( tObj.group is int && tObj.group == int(g) )
					return tObj;
			}
			return null;
		}
	}
}