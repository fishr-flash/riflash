package components.abstract.servants
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import mx.core.FlexGlobals;
	
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.gui.MainNavigation;
	import components.gui.fields.FSListCheckBox;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.COLOR;
	import components.static.KEYS;
	import components.system.UTIL;

	public class TabOperator
	{
		public static var _ACTIVE:Boolean;
		public static function set ACTIVE(value:Boolean):void
		{
			_ACTIVE = value;
		}
		public static function get ACTIVE():Boolean
		{
			return _ACTIVE;
		}
		
		public static const GROUP_TABLE:Number = 5000;
		public static const GROUP_FIELDS_AFTER_TABLE:Number = 8000;
		public static const GROUP_BUTTONS:Number = 10000;
		public static const GROUP_LAST:Number = 20000;
		public static const GROUP_MAINMENU:Number = 50000;
		
		public static const TYPE_DISABLED:int = 0x00;	// поле выключено
		public static const TYPE_NORMAL:int = 0x01;		// обычный текстфилд
		public static const TYPE_ACTION:int = 0x02;			// поле с логикой, чекбокс
		
		private var MENU_UPGRATED:Boolean;
		
		private static var instance:TabOperator;
		public static function getInst():TabOperator
		{
			if ( instance == null )	instance = new TabOperator;
			return instance;
		}
		
		private var focusable:Vector.<IFocusable> = new Vector.<IFocusable>;
		private var focusablePopUp:Vector.<IFocusable>;
		private var current:InteractiveObject;
		private var currentFocusable:IFocusable;
		private var lastFocusable:IFocusable;		 // всегда равно currentFocusable, но никогда не стирается при focusOut
		private var order:Number=0;
		
		public function TabOperator()
		{
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.pageLoadLComplete, onPageLoaded );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onChangeOnline );
			getStage().addEventListener(Event.DEACTIVATE, onDeactivate);
		}
		public function currentFocus():InteractiveObject
		{
			if (currentFocusable)
				return currentFocusable.getFocusField();
			return null;
		}
		public function isCurrentFocusableField():Boolean
		{
			if (currentFocusable && currentFocusable is IFormString)
				return true;
			return false;
		}
		public function isCurrentFocusOnMenu():Boolean
		{	// true значит что фокус в данный момент находится в меню
			if( currentFocusable )
				return MainNavigation.getInst().isKeeperOf(currentFocusable);
			if (currentMenuFocusable)
				return MainNavigation.getInst().isKeeperOf(currentMenuFocusable);
			return false;
		}
		public function resetOrder():void
		{
			order = 0;
		}
		public function put(v:Vector.<IFocusable>):void
		{	// через пут добавляются поля, которые уже были раз добавлены
			
			
			focusable = v;
			
			var s:Stage = getStage();
			
			var a:Array;
			var len:int = focusable.length;
			for (var i:int=0; i<len; ++i) {
				if( focusable[i].getFocusables() is Array ) {
					a = focusable[i].getFocusables() as Array;
					var lenj:int = a.length;
					for (var j:int=0; j<lenj; ++j) {
						addListener( a[j] );
					}
				} else if (focusable[i].getFocusables() is InteractiveObject ) {
					addListener(focusable[i].getFocusables() as InteractiveObject);
				}
			}	
			
			removeClones(focusable);
		}
		public function addPopUp(a:Vector.<TextButton>):void
		{
			focusablePopUp = new Vector.<IFocusable>;
			current = null;
			var len:int = a.length;
			var f:IFocusable;
			var localorder:int = 0;
			for (var i:int=0; i<len; ++i) {
				f = a[i] as IFocusable;
				focusablePopUp.push( f );
				addListener( f.getFocusables() as InteractiveObject );
				f.focusorder = localorder++;
			}
			
			removeClones(focusablePopUp);
		}
		public function removePopUp():void
		{
			current = null;
			focusablePopUp = null;
		}
		public function add(f:IFocusable):void
		{
			
			// через add добавляются новые поля
			var len:int = focusable.length;
			var unique:Boolean=true;
			var a:Array;
			for (var i:int=0; i<len; ++i) {
				if( focusable[i] == f ) {
					unique = false;
					break;
				}
			}
			if (unique) {
				if( f.getFocusables() is Array ) {
					focusable.push(f);
					f.focusorder = order++;
					//focusable.splice( focusable.length-1, 0, f );
					a = f.getFocusables() as Array;
					var lenj:int = a.length;
					for (var j:int=0; j<lenj; ++j) {
						addListener( a[j] );
					}
				} else if (f.getFocusables() is InteractiveObject ) {
					focusable.push(f);
					f.focusorder = order++;
					//focusable.splice( focusable.length-1, 0, f );
					addListener(f.getFocusables() as InteractiveObject);
				}
			}
			
			
			removeClones(focusable);
		}
		public function remove(f:IFocusable):void
		{	// используется для элементов которые при каждом заходе на страницу обновляются - во всех таблицах например
			
			
			if (f) {
				var len:int = focusable.length;
				for (var i:int=0; i<len; ++i) {
					if( focusable[i] == f ) {
						focusable.splice(i,1);
						break;
					}
				}
			}
			
			
		}
		public function restoreFocus(f:IFocusable):void
		{	// необходим для восстановления фокуса последнего поля. Передается поле, на которые надо установить фокус и сравнить был ли он последним
			if (lastFocusable == f && !currentFocusable && isAvailable(lastFocusable) ) {
				iNeedFocus(lastFocusable);
			}
		}
		public function addMenu():void
		{	// кнопка меня добавляется каждый раз при заходе на страницу в основной табцикл
			var b:IFocusable = MainNavigation.getInst().getCurrent();
			if (b) { 
				focusable.push( b );
				addListener(b.getFocusables() as InteractiveObject);
				iNeedFocus( b );
			} else
				currentFocusable = null;
			currentMenuFocusable = null;
		}
		public function getFocusables():Vector.<IFocusable>
		{
			if (focusable.length > 0) {
				// для того чтобы убедиться, что менюкнопка точно последняя
				sort();
				// кнопка каждый заход на страницу добавляется, а не только первый раз поэтому надо обнулять добавление
				focusable.splice(focusable.length-1,1);
				
				var len:int = focusable.length;
				var a:Array;
				for (var i:int=0; i<len; ++i) {
					if (focusable[i].getFocusables() is InteractiveObject)
						removeListeners(focusable[i].getFocusables() as InteractiveObject);
					if (focusable[i].getFocusables() is Array) {
						a = focusable[i].getFocusables() as Array;
						var lenj:int = a.length;
						for (var j:int=0; j<lenj; ++j) {
							removeListeners(a[j]);
						}
					}
				}
			}
			current = null;
			currentFocusable = null;
			lastFocusable = null;
			resetOrder();
			
			// для того чтобы при заходе на новую страницу список обновлялся а не дополнялся
			var clone:Vector.<IFocusable> = focusable;
			focusable = new Vector.<IFocusable>;
			
			return clone;
		}
		public function onKey(key:int, shiftKey:Boolean, ctrlKey:Boolean):void
		{
			switch(key) {
				case KEYS.Tab:
					if (ACTIVE)
						cycle(!shiftKey);
					else
						menuCycle(true);
					break;
				case KEYS.DownArrow:
					if ( MainNavigation.getInst().isKeeperOf(currentFocusable) || currentMenuFocusable ) {
						menuCycle(true);
						break;
					}
				case KEYS.UpArrow:
					if ( MainNavigation.getInst().isKeeperOf(currentFocusable) || currentMenuFocusable ) {
						menuCycle(false);
						break;
					}
				case KEYS.Spacebar:
				case KEYS.Enter:
					if ( currentMenuFocusable ) {
						currentMenuFocusable.doAction(key,ctrlKey,shiftKey);
						break;
					}
				default:
					if(currentFocusable)
						currentFocusable.doAction(key,ctrlKey,shiftKey);
					break;
			}
		}
		public function iNeedFocus(f:IFocusable):void
		{	// срабатывает, когда происходит клик мышью на поле (надо высветить в фокус)
			if(focusable.length>0) {
				var len:int = focusable.length;
				for (var i:int=0; i<len; ++i) {
					if (f == focusable[i] && isAvailable(f) ) {
						getStage().focus = f.getFocusField();
						currentFocusable = f;
						lastFocusable = f;
					}
				}
			}
		}
/** MISC		***/
		/**	POPUP NAVIGATION	****/
		private function popCycle(down:Boolean):void
		{	// цикл по кнопкам открытого попапа
			var stage:Stage = getStage();
			var a:Array = MainNavigation.getInst().getList();
			var len:int = a.length;			
			var i:int;
			
			if (!MENU_UPGRATED) {
				for (i=0; i<len; ++i) {
					addListener( (a[i] as IFocusable).getFocusField() );
				}
				MENU_UPGRATED = true;
			}
			if (!currentMenuFocusable)
				currentMenuFocusable = MainNavigation.getInst().getCurrent();
			
			// если не выбрано вообще ничего, то currentMenuFocusable будет null, и тогда выбирается первая кнопка по списку
			if (currentMenuFocusable) { 
				for (i=0; i<len; ++i) {
					if (currentMenuFocusable == a[i]) {
						if (down) {
							if (i+1<len)
								currentMenuFocusable = a[i+1];
							else
								currentMenuFocusable = a[0];
						} else {
							if (i>0)
								currentMenuFocusable = a[i-1];
							else
								currentMenuFocusable = a[len-1];
						}
						break;
					}
				}
			} else
				currentMenuFocusable = MainNavigation.getInst().getFirst();
			stage.focus = currentMenuFocusable.getFocusField();
		}
		/**	MENU NAVIGATION	****/
		private var currentMenuFocusable:IFocusable;
		private function menuCycle(down:Boolean):void
		{	// цикл по главному меню, он отдельный от основного
			var stage:Stage = getStage();
			var a:Array = MainNavigation.getInst().getList();
			var len:int = a.length;			
			var i:int;
			
			if (!MENU_UPGRATED) {
				for (i=0; i<len; ++i) {
					addListener( (a[i] as IFocusable).getFocusField() );
				}
				MENU_UPGRATED = true;
			}
			if (!currentMenuFocusable)
				currentMenuFocusable = MainNavigation.getInst().getCurrent();

			// если не выбрано вообще ничего, то currentMenuFocusable будет null, и тогда выбирается первая кнопка по списку
			if (currentMenuFocusable) { 
				for (i=0; i<len; ++i) {
					if (currentMenuFocusable == a[i]) {
						if (down) {
							if (i+1<len)
								currentMenuFocusable = a[i+1];
							else
								currentMenuFocusable = a[0];
						} else {
							if (i>0)
								currentMenuFocusable = a[i-1];
							else
								currentMenuFocusable = a[len-1];
						}
						break;
					}
				}
			} else
				currentMenuFocusable = MainNavigation.getInst().getFirst();
			if( currentMenuFocusable )
				stage.focus = currentMenuFocusable.getFocusField();
		}
		private function addListener(io:InteractiveObject):void
		{
			io.focusRect = false;
			io.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			io.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
		}
		private function removeListeners(io:InteractiveObject):void
		{
			io.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			io.removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			io.filters = [];
		}
		private function sort():void
		{	// идет сортировка от малому к большему
			var last:Number = 0;
			var len:int = focusable.length;
			for (var i:int=0; i<len; ++i) {
				if (focusable[i].focusorder < last) {
					focusable.sort(sortFucusables);
					break;
				} else
					last = focusable[i].focusorder;
			}
		}
		private function sortFucusables(a:IFocusable, b:IFocusable):int
		{	// идет сортировка от малому к большему
			if( a.focusorder < b.focusorder )
				return -1;
			else if (a.focusorder > b.focusorder)
				return 1;
			return 0;
		}
		
		private function removeClones(local:Vector.<IFocusable>):void
		{
			
			var len:int = local.length;
			for (var i:int=0; i<len; i++) {
				var lenj:int = local.length;
				for (var j:int=0; j<lenj; j++) {
					if (i != j && local[i] == local[j] ) {
						trace( "remove " + local[j] );
						local.splice(j,1);
						
						removeClones(local);
						return;
					}
				}
			}
		}
		
		private function cycle(forward:Boolean):void
		{
			var local:Vector.<IFocusable>;
			if (focusablePopUp)
				local = focusablePopUp;
			else
				local = focusable;
			
			removeClones(local);
			
			//removeClones(local);
			
			if (local.length > 0) {
				
				sort();
				
				var stage:Stage = getStage();
				var i:int=0;
				var len:int;
				var target:InteractiveObject;
				if ( stage.focus && !currentMenuFocusable )	{// если в данный момент в фокусе стейджа что-то есть и это не пункт меню
					trace("TabOperator.cycle(forward) way 1");
					
					target = stage.focus;
				}else if (current) {	// последнее запомненное место с которого надо начинать цикл
					trace("TabOperator.cycle(forward) way 2");
					target = current;
				} else {				// если нет обьекта для сравнения выбираем первый объект в очереди
					trace("TabOperator.cycle(forward) way 3");
					target = local[local.length-1].getFocusField();
				}
				currentMenuFocusable = null;
				
				var result:int;
				len = local.length;
				for ( i=0; i<len; ++i) {
					// находим отправную точку, где сейчас находится фокус
					//if( target == local[i].getFocusField() ) {
					if( local[i].isPartOf(target) ) {
					
						if (forward)
							saveIncrease();
						else
							saveDecrease();
						// цикл перескакивает к ближайшему доступному филду
						var total:int=0;
						while(true) {
							// если филд выключен, перескакиваем к следующему
							if( !isAvailable( local[i] ) ) {
								if (forward)
									saveIncrease();
								else
									saveDecrease();
							} else		// 26.04.2016 таб цикл прерывался на последнем элементе
								break;
							// увеличиваем тотал, чтобы не было дедлупа если все объекты в цилке недоступны для фокуса
							total++;
							if (total == len)
								break;
						}
						break;
					}
				}
				if (i >= len) {
					i = 0;
					trace("TabOperator didn't found valid focusable");
					if (current) {
						current = null;
						cycle(forward);
						return;
					}
				}
				
				// Если на этом этапе встречается типа disabled значит во всем цикле вообще нет выделяемых филдов
				if ( isAvailable(local[i]) ) {
					stage.focus = local[i].getFocusField(); 
					current = stage.focus;
					currentFocusable = local[i];
					lastFocusable = local[i];
					currentFocusable.focusSelect();
					trace( "TabOperator:focusorder " +currentFocusable.focusorder );
				}
			}
			function saveIncrease():void
			{
				i++;
				if (i >= len)
					i=0;
			}
			function saveDecrease():void
			{
				i--;
				if (i < 0)
					i=len-1;
			}
		}
		private function isAvailable(f:IFocusable):Boolean
		{
			if ( !_block && f.getType() != TYPE_DISABLED && (f is FSListCheckBox || UTIL.isThroughVisible(f.getFocusField() as DisplayObject)) )
				return true;
			return false;
		}
		private function getStage():Stage
		{
			return FlexGlobals.topLevelApplication.stage;
		} 

		private var def:Array = ["0x"+COLOR.GREEN_EMERALD.toString(16),1,5,5,1,3,0,0];
		private var eff:Array = ["0x"+COLOR.GREEN_EMERALD.toString(16),1,5,5,1,3,0,0];
		public function setFocusColor(color:uint, alpha:Number=1,blurX:Number=6,blurY:Number=6,str:Number=2,quality:Number=1, inner:int=0, knockout:int=0):void
		{
			eff = ["0x"+color.toString(16), alpha, blurX, blurY, str, quality, inner, knockout];
			focusGlow = new GlowFilter(color, alpha, blurX, blurY, str, quality, inner==1, knockout==1);
		}
		public function getFocusColor():String
		{
			return eff.toString();
		}
		public function getDefaultEffect():Array
		{
			return def.slice();
		}
	/*	public function getCurrentFocusableByFocus():IFocusable
		{	// находить focusable по обьекту который находиться в stage.focus
			if (getStage().focus ) {
				trace("TabOperator.getCurrentFocusableByFocus()");
				
				var io:InteractiveObject = getStage().focus;
				var len:int = focusable.length;
				for (var i:int=0; i<len; ++i) {
					if (focusable[i].getFocusField() == io )
						return focusable[i];
				}
			}
			return null;
		}
		*/
/** EVENTS			***/		
		
		private var focusGlow:GlowFilter = new GlowFilter(COLOR.GREEN_EMERALD, 1, 5, 5, 1, 3);
		private function focusInHandler(e:Event):void
		{
			if( e.currentTarget is TextField && (e.currentTarget as TextField).text == "0050" ) {
				trace("TabOperator.focusInHandler(e)");
				
			}
			(e.currentTarget as InteractiveObject).filters = [focusGlow];
		}
		private function focusOutHandler(e:Event):void
		{
			(e.currentTarget as InteractiveObject).filters = [];
			currentFocusable = null;
		}
		private function onPageLoaded(e:SystemEvents):void
		{
			ACTIVE = true;
		}
		private function onChangeOnline(e:SystemEvents):void
		{
			if( !e.isConneted() ) {
				MENU_UPGRATED = false;
				var a:Array = MainNavigation.getInst().getList();
				var len:int = a.length;
				for (var i:int=0; i<len; ++i) {
					removeListeners( (a[i] as IFocusable).getFocusField() );
				}
			}
		}
		private function onDeactivate(e:Event):void
		{
			current = null;
			currentFocusable = null;
			lastFocusable = null;
			currentMenuFocusable = null;
		}
/** GET SET		****/
		private var _block:Boolean=false;
		public function set block(value:Boolean):void
		{
			_block = value;
			if (value)
				getStage().focus = null;
		}
		public function get block():Boolean
		{
			return _block;
		}
	}
}