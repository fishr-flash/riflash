package components.gui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import components.abstract.IMB_KEY_STATES;
	import components.interfaces.IFlexListItem;
	import components.protocol.Package;
	import components.screens.opt.OptImbKeys;
	import components.screens.ui.UIImbKeys;

	public class MFlexListImbKey extends MFlexList
	{
		public static const WIDTH_FIELD:int = 800;
		public var cbSelect:Function;
		
		public function MFlexListImbKey(c:Class)
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
					
					
					if( summKeyCode( p.data[ i ] as Array ) != true  ) 
											continue;
					
						list[cnt] = (new cls( i+1 ) as IFlexListItem);
					
					
					(list[cnt] as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					layer.addChild( list[cnt] as DisplayObject );
					list[cnt].y = list[cnt].height*cnt;
					
					if (evokeSave)
						list[cnt].change(p);
					else
						list[ cnt ].put(p);
					
					
					
					
					cnt++;
					
					
				}
			} else {
				len = list.length; // может быть 1 структура но положена во все строки листа
				
				for (i=0; i<len; i++) 
				{
					if (evokeSave)
						list[i].change(p);
					else
						list[i].put(p);
				}
			}
			
			
			
		}
		
		
		
		override public function add(p:Package, forceStructureNumeration:Boolean=false):IEventDispatcher
		{
			if (!list)
				list = new Vector.<IFlexListItem>;
			
			
			clearDeleted();
			
		
			var fieldAKey:IFlexListItem;
			//var freeStruct:int = getAvailableStructure(); 
			var freeStruct:int = int( p.getParam( 2, 1 ) );
			var structureIndex:int = -1;
			var lastIndex:int = 0;
			var instack:Boolean = false;
			/// тут мы выясняем есть ли элемент с переданной структурой-адресом...
			var len:int = list.length;
			for (var i:int=0; i<len; i++) 
			{
				if( ( list[ i ] as OptImbKeys ).structure < freeStruct ) continue;
				if( !lastIndex )lastIndex = i;
				instack = true;
				if( ( list[ i ] as OptImbKeys ).structure != freeStruct ) continue;
				instack = false;
				structureIndex = i;
				break;
			}
			
			
			
			if(  structureIndex == -1 )
			{
				if( instack )
				{
					
					
					fieldAKey = new cls( p.getParam( 2, 1 ) );
					
					
					
					
					layer.addChild( fieldAKey as DisplayObject );
					(fieldAKey as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					fieldAKey.y = fieldAKey.height*lastIndex;
					
					//list.splice( lastIndex, 0, fieldAKey );
					list.unshift( fieldAKey );
					
					
					
				}
				else
				{
					var maxI:int = 0;
					for (var j:int=0; j<len; j++) 
						if( int( ( list[ j ] as UIComponent ).id ) > maxI ) maxI = int( ( list[ j ] as UIComponent ).id ); 
					
					
					fieldAKey = new cls( p.getParam( 2, 1 ) );
					
					
					layer.addChild( fieldAKey as DisplayObject );
					(fieldAKey as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					fieldAKey.y = fieldAKey.height*list.length;
					
					structureIndex = list.unshift(fieldAKey) - 1;
					
					
				}
				
				
				
				placementOpts();	
				
			}
			
			function placementOpts():void
			{
				var len:int = list.length;
				//for (var k:int= lastIndex + 1; k<len; k++) 
				for (var k:int= 0; k<len; k++) 
				{
					list[ k ].y = list[ k ].height * k;
					//( list[ k ] as OptImbKeys ).updateIndex( k +1 );
					
					
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
				if (list[i] && e.currentTarget == list[i]  ) 
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
		
		public function removeCustomEl( selectedLine:OptImbKeys ):int
		{
			
					const id:int = list.indexOf( selectedLine );
					const nm:int = selectedLine.structure;
					
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
					
					
					return nm;
					
					
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
			var item:OptImbKeys;
			for (var i:int=0; i<len; i++)
			{
				item = list[ i ] as OptImbKeys;
				/// в некоторых состояниях структуры не попадут в список 
				/// действительных чтобы их место можно было занять нвоой структуре
				if( 
					item.state == IMB_KEY_STATES.ALL_CANCEL
					|| item.state == IMB_KEY_STATES.DOUBLE_DETECTED
					|| item.state == IMB_KEY_STATES.SEARCH_UP
					|| item.state == IMB_KEY_STATES.TIME_OUT
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
			
			if( res > UIImbKeys.MAX_COUNT_ALARM_BTNS ) res = 0;
			
			
			
			return res;
			
			
		}
		
		
		/**
		 *  Удаляет ранее удаленные эл-ты т.к. их восстановление
		 * уже невозможно, прибор хранит только последний удаленный эл-т
		 */
		public function clearDeleted():void
		{
			var opAlKey:OptImbKeys 
			for (var i:int=0; i<list.length; i++) 
			{
				opAlKey = list[ i ] as OptImbKeys;
				//if( opAlKey.state == IMB_KEY_STATES.DELETE_SUCCESS ) removeCustomEl( opAlKey );
 
			}
			
			
		}
		
		private function summKeyCode( code:Array ):Boolean
		{
			var summ:int = 0;
			var len:int = code.length;
			for (var i:int=0; i<len; i++) 
			{
				summ += int( code[ i ] );
			}
			
			return summ > 0;
		}
		
		public function scrollUp():void
		{
			layer.verticalScrollPosition = 0;
			
		}
	}
	
	
	
	
}