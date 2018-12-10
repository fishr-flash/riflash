package components.gui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import components.abstract.LR_AL_KEY_STATES;
	import components.interfaces.IFlexListItem;
	import components.protocol.Package;
	import components.screens.opt.OptAlKey;
	import components.screens.ui.UIAlarmKeys;

	public class MFlexListAlKey extends MFlexList
	{
		public static const WIDTH_FIELD:int = 800;
		public var cbSelect:Function;
		
		public function MFlexListAlKey(c:Class)
		{
			super(c);
			
			
		}
		
		
		
		override public function put(p:Package, clear:Boolean=true, evokeSave:Boolean=false):void
		{
			
			var len:int = p.length;
			
			
			var i:int;
			
			if (clear || !list) {
				clearlist();
				
				list = new Vector.<IFlexListItem>();
				var cnt:int = 0;
				for (i=0; i<len; i++) {
					
					if( p.getParamInt( 1, i + 1 ) == 0  ) 
											continue;
					
						list[cnt] = (new cls(i+1, cnt ) as IFlexListItem);
					
					
					(list[cnt] as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					layer.addChild( list[cnt] as DisplayObject );
					list[cnt].y = list[cnt].height*cnt;
					
					if (evokeSave)
						list[cnt].change(p);
					else
						list[ cnt ].put(p);
					
					
					
					/*if( p.getParamInt( 1, i + 1 ) == 2 )
						( list[ cnt ] as OptAlKey ).onRemove();*/
					
					cnt++;
					
					
				}
			} else {
				len = list.length; // может быть 1 структура но положена во все строки листа
				for (i=0; i<len; i++) {
					if (evokeSave)
						list[i].change(p);
					else
						list[i].put(p);
				}
			}
		}
		
		/**
		 *  Подбирает свободную структуру, для 
		 * того чтобы можно было предсказать структуру которая
		 * будет сообщена новому эл-ту
		 */
		public function getAvailableStructure():int
		{
			var res:int = 0;
			var busyIndexes:Array = [];
			var len:int = list.length;
			var item:OptAlKey;
			for (var i:int=0; i<len; i++)
			{
				item = list[ i ] as OptAlKey;
				/// в некоторых состояниях структуры не попадут в список 
				/// действительных чтобы их место можно было занять нвоой структуре
				if( 
					item.state == LR_AL_KEY_STATES.ADD_FAIL
					|| item.state == LR_AL_KEY_STATES.ADDRESS_BUSY
					|| item.state == LR_AL_KEY_STATES.NO_ADD
					|| item.state == LR_AL_KEY_STATES.RESTORE_FAIL
					|| item.state == LR_AL_KEY_STATES.OPERATION_BREAK
					|| item.state == LR_AL_KEY_STATES.DELETE_SUCCESS
				) 
															continue;
				busyIndexes.push( list[ i ].getStructure() );
			}
				
			
			busyIndexes.sort( Array.NUMERIC );
			
			for (var j:int=0; j<len; j++) 
			{
				if( busyIndexes[ j ] != j + 1 ) 
				{
					res = j+ 1;
					break;
				}
				
			}
			
			if( !res ) res = j + 1;
			
			if( res > UIAlarmKeys.MAX_COUNT_ALARM_BTNS ) res = 0;
			
			
			
			return res;
			
						
		}
		
		
		override public function add(p:Package, forceStructureNumeration:Boolean=false):IEventDispatcher
		{
			if (!list)
				list = new Vector.<IFlexListItem>;
			
			
			clearDeleted();
			
			var fieldAKey:IFlexListItem;
			var freeStruct:int = getAvailableStructure(); 
			var structureIndex:int = -1;
			var lastIndex:int = 0;
			var instack:Boolean = false;
			/// тут мы выясняем есть ли элемент с переданной структурой-адресом...
			var len:int = list.length;
			for (var i:int=0; i<len; i++) 
			{
				if( ( list[ i ] as OptAlKey ).structure < freeStruct ) continue;
				if( !lastIndex )lastIndex = i;
				instack = true;
				if( ( list[ i ] as OptAlKey ).structure != freeStruct ) continue;
				instack = false;
				structureIndex = i;
				break;
			}
			
			
			
			if(  structureIndex == -1 )
			{
				if( instack )
				{
					
					
					fieldAKey = new cls( p.request.data[ 0 ],  lastIndex);
					
					
					
					
					layer.addChild( fieldAKey as DisplayObject );
					(fieldAKey as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					fieldAKey.y = fieldAKey.height*lastIndex;
					
					list.splice( lastIndex, 0, fieldAKey );
					
					len = list.length;
					for (var k:int= lastIndex + 1; k<len; k++) 
					{
						list[ k ].y = list[ k ].height * k;
						( list[ k ] as OptAlKey ).updateIndex( k +1 );
						
						
					}
					
				}
				else
				{
					var maxI:int = 0;
					for (var j:int=0; j<len; j++) 
						if( int( ( list[ j ] as UIComponent ).id ) > maxI ) maxI = int( ( list[ j ] as UIComponent ).id ); 
					
					
					fieldAKey = new cls( p.request.data[ 0 ],  maxI);
					
					
					layer.addChild( fieldAKey as DisplayObject );
					(fieldAKey as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					fieldAKey.y = fieldAKey.height*list.length;
					
					structureIndex = list.push(fieldAKey) - 1;
				}
				
				
				
				
				
			}
			
			if( list.length < 10 )allowComponentControlItsHeight = true;
			
			if (allowComponentControlItsHeight) {
				height = getActualHeight();
				layer.height = height;
				allowComponentControlItsHeight = true;
			}
			
			
			
			return  fieldAKey as IEventDispatcher;
		}
		
		
		
		override protected function onSelect(e:Event):void
		{

			var len:int = list.length;
			var selId:int = -1;
			for (var i:int=0; i<len; i++) {
				if (list[i] 
					&& e.currentTarget == list[i] 
					&& ( list[ i ] as OptAlKey ).state != LR_AL_KEY_STATES.ADDING 
					&& ( list[ i ] as OptAlKey ).state != LR_AL_KEY_STATES.OPERATION_BREAK ) 
				{
					selId = i;
					
					list[selId].selectLine = true;
				}
				else 
					list[i].selectLine = false;
					
					 
			}
			
			
			
			/// Сообщаем экрану индекс выбранного опт-элемента для операций с ним 
			/// и активации кнопки Удалить
			cbSelect( selId );
		}
		
		override public function removeSelected():int
		{
			
			 
			var s:int = -1;
			var len:int = list.length;
			for (var i:int=0; i<len; i++) {
				if(list[i].isSelected() ) {
					s = i;
					(list[i] as EventDispatcher).removeEventListener( MouseEvent.CLICK, onSelect );
					
					 layer.removeChild( list[i] as DisplayObject ) ;
					list[i].kill();
					list.splice( i, 1 );
				}
			}
			var c:int;
			for (i=0; i<len; i++) {
				if(list[i])
					list[i].y = list[i].height*c;
				c++;
			}
			
			
			
			
			
			
			return s;
			
			
		}
		
		/**
		 *  Если добавляемая кнопка садится в список
		 * повторно надо удалить ранее зарезервированное 
		 * поле под новую кнопку.
		 */
		public function removeWaitOpt():void
		{
			
		}
		
		public function removeCustomEl( selectedLine:OptAlKey ):void
		{
			
					const id:int = list.indexOf( selectedLine );
					
					(list[id] as EventDispatcher).removeEventListener( MouseEvent.CLICK, onSelect );
					
					 layer.removeChild( list[id] as DisplayObject ) ;
					
					list[id].kill();
					list.splice( id, 1 );
					
					var c:int;
					var len:int = list.length;
					for (var i:int =0; i<len; i++) {
						if(list[i])
							list[i].y = list[i].height*c;
						c++;
					}
					
					
					
					
					
		}
		
		
		
		/**
		 *  Удаляет ранее удаленные эл-ты т.к. их восстановление
		 * уже невозможно, прибор хранит только последний удаленный эл-т
		 */
		public function clearDeleted():void
		{
			var opAlKey:OptAlKey 
			for (var i:int=0; i<list.length; i++) 
			{
				opAlKey = list[ i ] as OptAlKey;
				if( opAlKey.state == LR_AL_KEY_STATES.DELETE_SUCCESS ) removeCustomEl( opAlKey );
 
			}
			
			
		}
		
		
	}
	
	
	
	
}