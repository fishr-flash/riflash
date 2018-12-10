package components.gui
{	
	/**2.0 Добавлено управление историей с клавивиатуры
	 * 	   Добавлено блокирование таблицы при загруке
	 * 1.9 Выделение переставил с mClick на mDown
	 * 1.8 Добавил возможность выбора отображаемых кнопок buttonsExistance()
	 * 1.7 Добавлен reset при выходе со страницы, пототму что при загрузке страницы грузится
	 * должна грузиться 1я страница таблицы, а без этого таблица загружает последнюю открытую
	 * и получается несовпадение индексов массива
	 * 
	 * 1.6 Отсылка save.before при нажати выбранных битовой маской add/remove/restore.
	 * 720 Переработан блок проверки уникальных полей, для того чтобы валиадция проходила 
	 *		не только по уникальным номерам но еще и валидировалось само проверяемое поле
	 * 1.5
	 * Добавлен скроллящийся header
	 * 1.4
	 * Добавлено слежение за сохрарением
	 * 1.3
	 * Поправил баг с вставкой структуры
	 * Добавлена восможность переименовывать кнопки renameButtons
	 * Исправлен баг с валидацией после добавления через func/state и выбором строки
	 * 1.2
	 * Исправлена ошибка валидации всей таблицы при уникальной валидирующей функции
	 * Добавлен override add
 	 * Update для К2 (PARAM_UNIQUE_FUNC_PARAM, PARAM_STRICT_RESTORE, deletedLine)
	 * 1.1
	 * Добавлен HEADER (отдельно от общего скролла)
	 * 1.0
	 * Добавлен автовыбор следующей/предыдущей строки после удаления  
	 * */
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.TabOperator;
	import components.basement.OptionListBlock;
	import components.basement.OptionsBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.Separator;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.interfaces.IKeyUser;
	import components.interfaces.IListItem;
	import components.interfaces.ISaveAnalyzer;
	import components.interfaces.ISaveListener;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.static.COLOR;
	import components.static.KEYS;
	import components.system.SavePerformer;
	
	import su.fishr.utils.Dumper;
	
	public class OptList extends UIComponent implements ISaveAnalyzer, ISaveListener, IKeyUser
	{
		private var FLAG_ADD_BUSY:Boolean = false;
		private var FLAG_REMOVE_BUSY:Boolean = false;
		private var FLAG_SAVE_ACTIVE:Boolean = false;
		
		public static const GENERATION_RANDOM:int=0x00;
		public static const GENERATION_FIRSTFREE:int=0x01;
		
		public static const ADD:int=0x01;
		public static const REMOVE:int=0x02;
		public static const RESTORE:int=0x04;
		public static const CHANGE:int=0x08;
		
		public static const PARAM_DRAW_CHECKMATE:int=0x1;
		public static const PARAM_DRAW_SEPARATOR:int=0x2;
		public static const PARAM_ATLEAST_ONE_LINE:int=0x4;
		public static const PARAM_NEED_ADDITIONAL_EVENTS:int=0x8;
		public static const PARAM_DRAW_PAGES:int=0x10;
		public static const PARAM_ENABLER_IS_SWITCH:int=0x20;
		public static const PARAM_NO_BLOCK_SAVE:int=0x40;
		public static const PARAM_SCROLLING_ALWAYS_HIIDDEN:int=0x80;
		public static const PARAM_H_SCROLLING_WHEN_NEEEDED:int=0x100;
		public static const PARAM_V_SCROLLING_WHEN_NEEEDED:int=0x200;
		public static const PARAM_UNIQUE_FUNC_PARAM:int=0x400;
		public static const PARAM_STRICT_RESTORE:int=0x800;		// Запрещает восстанавливать невалидированные структуры
		public static const PARAM_NOTIFY_IF_SELECT:int=0x1000;
		
		private static const BUTTON_PAGE_PREV:int = 1;
		private static const BUTTON_PAGE_NEXT:int = 2;
		private static const BUTTON_DECADE_NEXT:int = 3;
		private static const BUTTON_DECADE_PREV:int = 4;
		private static const BUTTON_PAGE_JUMP:int = 5;
		private static const BUTTON_PAGE_REFRESH:int = 6;
		
		private var _IS_READY:Boolean=true;		// при false не позволяет кнопкам срабатыватьс  клавиатуры 
		
		public var overrideGetFirstFreeLineExt:Function;		// Если нужно переопределить функцию определения свободного места
		public var overrideIsMaxLines:Function;					// Проверка - дисейблить ли кнопку из за достигнутого максимума полей 
		
		private static const C_MAX_BUTTONS_VISIBLE:int = 10;
		private var HEADER_CONT_WIDTH:int;
		
		private var SILENT_UPDATE:Boolean=false;
		private var C_START_PAGE:int=1;
		
		protected var cont:Canvas;
		private var header_cont:Canvas;
		private var cont_buttons:UIComponent;
		private var bAdd:TextButton;
		private var bRemove:TextButton;
		private var bRestore:TextButton;
		
		private var focusables:Vector.<IFocusable>;
		private var aVisual:Array;
		private var totalLines:int;
		public var selectedLine:int;	// выбранная строка
		private var tableShiftSize:int;
		
		private var screenBlock:ScreenBlock;
		
		public var deletedLine:OptionListBlock;
		
		protected var addId:int;

		private var operatingCMD:int;
		private var operatingClass:Class;
		private var data:Vector.<Array>;
		private var maxLines:int;
		private var schema:CommandSchemaModel;
		
		private var C_ATLEAST_ONE_LINE:Boolean=false;		// не может быть меньше одной записи
		private var C_ENABLER_PARAM:int;					// параметр который "включает" (делает отображаемой) структуру
		private var C_ENABLER_PARAM_IS_SWITCH:Boolean=false;
		private var C_UNIQUE_PARAMS:Array;					// параметр, который должен быть уникальным во всей таблице
		private var C_NEED_ADITIONAL_EVENTS:Boolean=false;
		private var C_NO_BUTTONS:Boolean;					// не нужны кнопки добавления/удаления/восстановления
		private var C_CREATION_PATTERN:Object;				// шаблон который будет записываться при создании структуры
		private var C_DRAW_CHECKMATE:Boolean=false;			// отрисовывать полосатую таблицу
		private var C_DRAW_SEPARATOR:Boolean=false;			// отрисовывать сепаратор снизу
		private var C_DRAW_PAGES:Boolean=false;
		private var C_PAGE_LINES_PER_PAGE:int;
		private var C_BLOCK_SAVE:Boolean = true;			// может ли таблица блокировать save
		private var C_OPERATE_WITH_FUNCT:Boolean = false;
		private var C_FUNCT_OPERATOR:Function;		//  C_FUNCT_OPERATOR( номер структуры, номер дейтсвия (ADD/REMOVE/RESTORE))
		// Запрещает добавлять напрямую через запись структуры.
		private var C_UNIQUE_FUNC_EXEC:Boolean = false;
		private var C_STRICT_RESTORE:Boolean = false;		// Запрещает восстанавливать невалидированные структуры
		private var C_FIRE_SAVE_BEFORE_BUTTONS:int = 0;		// (Битовая маска из ккопок)Если требуется запустить функцию сидящую в триггере сейва при нажатии adв//remove/restore при пустом сохранении
		private var C_NOTIFY_IF_SELECT:Boolean = false;		// Сообщает каждый раз о выборе строки FlexEvent.SELECTION_CHANGE

		private var page_line_buttons:Vector.<TextButton>;
		private var page_current:int = 0;
		private var page_b_prev:TextButton;
		private var page_b_next:TextButton;
		private var page_decade_b_prev:TextButton;
		private var page_decade_b_next:TextButton;
		private var page_b_jump:TextButton;
		private var page_b_refresh:TextButton;
		private var page_jump_input:FormString;
		private var page_jump_total:FormString;
		
		private var errorScreen:Sprite;
		private var savable:Boolean = false;
		private var addTimer:Timer;
		
		private var addedObj:Array;
		private var isRestorable:Boolean;
		private var separator:Separator;
		private var scrollBg:UIComponent;
		
		// numerical set up data
		private var N_BUTTONS_Y_SHIFT:int = 0;
		private var N_GLOBAL_X:int = 20;
		private var header:OptionListBlock;
		
		public function OptList()
		{
			super();
			
			
			
			focusables = new Vector.<IFocusable>;
			
			overrideIsMaxLines = isMaxLinesInternal;
			
			errorScreen = new Sprite;
			addChild( errorScreen );
			errorScreen.visible = false;
			
			cont = new Canvas;
			addChild( cont );
			cont.width = 625;
			cont.height = 600;
			cont.verticalScrollPolicy = ScrollPolicy.ON;
			cont.horizontalScrollPolicy = ScrollPolicy.OFF;
			
			scrollBg = new UIComponent;
			cont.addChild( scrollBg );
			
			bAdd = new TextButton;
			addChild( bAdd );
			bAdd.setUp( loc("g_add"), processLine, ADD );
			bAdd.x = 20;
			bAdd.focusorder = 51;
			
			bRemove = new TextButton;
			addChild( bRemove );
			bRemove.setUp( loc("g_remove"), processLine, REMOVE );
			bRemove.x = 140;
			bRemove.focusorder = 52;
			
			bRestore = new TextButton;
			addChild( bRestore );
			bRestore.setUp( loc("g_restore"), processLine, RESTORE );
			bRestore.x = 260;
			bRestore.focusorder = 53;
			
			buttonEnabler();
			
			aVisual = new Array;
			
			
		}
		public function renameButtons(_add:String=null, _remove:String=null, _restore:String=null):void
		{
			if (_add)
				bAdd.setName(_add);
			if (_remove)
				bRemove.setName(_remove);
			if (_restore)
				bRestore.setName( _restore );
			
			bRemove.x = bAdd.x + bAdd.width;
			bRestore.x = bRemove.x + bRemove.width;
		}
		public function buttonsExistance(add:Boolean, remove:Boolean=true, restore:Boolean=true):void
		{
			var gy:int = 20;
			bAdd.visible = add;
			place(bAdd);
			bRemove.visible = remove;
			place(bRemove);
			bRestore.visible = restore;
			place(bRestore);
			
			function place(b:TextButton):void
			{
				if (b.visible) {
					b.x = gy;
					gy += 120;
				}
			}
		}
		public function close():void
		{
			page_current = 1;
			KeyWatcher.remove(this);
		}
		private function distributeData(needUpdate:Boolean=false):void
		{
			if(header_cont)
				header_cont.horizontalScrollPosition = 0;
			
			var opt:OptionListBlock;
			
			var len:int = data.length;
			var localY:int=1;
			var starti:int=0;
			var i:int;
			totalLines = 0;
			
			if (needUpdate && aVisual.length > 0 ) {
				var v_len:int = aVisual.length; 
				for(i=0; i<v_len; ++i) {
					if ( aVisual[i] != null ) {
						removeLine(i);
						/*						
						cont.removeChild( aVisual[i] );
						(aVisual[i] as OptionListBlock).removeEventListener( MouseEvent.MOUSE_DOWN, select );
						
						SavePerformer.remove( operatingCMD, (aVisual[i] as OptionListBlock).getStructure() );
						SavePerformer.forget( operatingCMD, (aVisual[i] as OptionListBlock).getStructure() );
						aVisual[i] = null;
						*/
					}
				}
			}
			
			if (C_DRAW_PAGES) {

				if(page_current<1)
					page_current = 1;
				if (!cont_buttons) {
					cont_buttons = new UIComponent;
					addChild( cont_buttons );
					this.height = height;
				}
				
				if (needUpdate) {
					var cycles:int = Math.ceil(len/C_PAGE_LINES_PER_PAGE);
					var but:TextButton;
					
					if(page_line_buttons.length>0) {
						var len_buttons:int = page_line_buttons.length; 
						for(i=0; i<len_buttons; ++i ) {
							if(page_line_buttons[i] != null) {
								cont_buttons.removeChild( page_line_buttons[i] as TextButton);
								page_line_buttons[i] = null;
							}
						}
						page_line_buttons.length = 0;
					}
					
					if(!page_b_next) {
						
						var to:TabOperator = TabOperator.getInst();
						
						page_b_prev = new TextButton; 
						addButton( page_b_prev );
						page_b_prev.setUp( "<",switchPage, BUTTON_PAGE_PREV );
						page_b_prev.x = 40;
						page_b_prev.disabled = true;
						page_b_prev.focusorder = 2;
						
						page_decade_b_prev = new TextButton;
						addButton( page_decade_b_prev );
						page_decade_b_prev.setUp( "<<",switchPage, BUTTON_DECADE_PREV );
						page_decade_b_prev.x = 10;
						page_decade_b_prev.disabled = true;
						page_decade_b_prev.setWidth( 22 );
						page_decade_b_prev.focusorder = 1;
						
						page_b_next = new TextButton;
						addButton( page_b_next );
						page_b_next.setUp( ">",switchPage, BUTTON_PAGE_NEXT );
						page_b_next.focusorder = 13
						
						page_decade_b_next = new TextButton;
						addButton( page_decade_b_next );
						page_decade_b_next.setUp( ">>",switchPage, BUTTON_DECADE_NEXT );
						page_decade_b_next.setWidth( 22 );
						page_decade_b_next.focusorder = 14;
						
						page_jump_input = new FormString;
						addButton( page_jump_input );
						page_jump_input.restrict("0-9",5);
						page_jump_input.attune( FormString.F_EDITABLE | FormString.F_ALIGN_CENTER | FormString.F_OFF_KEYBOARD_REACTIONS);
						page_jump_input.setWidth( 45 );
						page_jump_input.setCellInfo(1);
						page_jump_input.focusorder = 15;
						
						page_jump_total = new FormString;
						addButton( page_jump_total );
						page_jump_total.setWidth( 70 );
						page_jump_total.attune( FormString.F_NOTSELECTABLE );
						page_jump_total.focusorder = 16;
						
						page_b_jump = new TextButton;
						addButton( page_b_jump );
						page_b_jump.setUp( "",switchPage, BUTTON_PAGE_JUMP );
						page_b_jump.focusorder = 17;
						
						page_b_refresh = new TextButton;
						addButton( page_b_refresh );
						page_b_refresh.setUp( loc("g_refresh_page"),switchPage, BUTTON_PAGE_REFRESH );
						page_b_refresh.focusorder = 18;
						
					}
					page_jump_total.setName( loc("g_loaded_from_bytes")+" "+cycles );
					
					var lastx:int = 40 + page_b_prev.width;
					var existcounter:int=0;
					for(i=0; i<cycles; ++i ) {
						
						var currentDecade:int = Math.floor((page_current-1)/10)*C_MAX_BUTTONS_VISIBLE;
						
						if( i < currentDecade || i > currentDecade + C_MAX_BUTTONS_VISIBLE - 1 ) {
							page_line_buttons.push( null );
							continue;
						}
						but = new TextButton;
						addButton( but );
						but.setUp( String(int(i+1)),selectPage, i+1 );
						but.recalculateWidthForSmallButtons(7);
						but.x = lastx;
						lastx += but.getWidth();
						page_line_buttons[i] = but;
						but.focusorder = 3 + existcounter++;
						but.pressed = Boolean( but.getId() == page_current );
					}
					var but_len:int;
					if( page_line_buttons.length > C_MAX_BUTTONS_VISIBLE )
						but_len = C_MAX_BUTTONS_VISIBLE;
					else
						but_len = page_line_buttons.length;
					
					page_b_next.x = lastx + 10;
					page_decade_b_next.x = page_b_next.x + 20;
					page_b_jump.x = page_decade_b_next.getWidth() + page_decade_b_next.x + 20;
					page_jump_input.x = page_b_jump.getWidth() + page_b_jump.x - 10;
					page_jump_total.x = page_jump_input.getWidth() + page_jump_input.x + 10;
					page_b_refresh.x = page_jump_total.getWidth() + page_jump_total.x + 10; 
						
					page_b_next.disabled = page_current + 1 > page_line_buttons.length; 
					page_decade_b_next.disabled = page_current + 10 > page_line_buttons.length;
					
					page_jump_input.disabled = page_line_buttons.length == 0;
					page_jump_total.disabled = page_line_buttons.length == 0;
					page_b_jump.disabled = page_line_buttons.length == 0;
				}

				starti = (page_current-1)*C_PAGE_LINES_PER_PAGE;

				if( maxLines > starti + C_PAGE_LINES_PER_PAGE )
					len = starti + C_PAGE_LINES_PER_PAGE;
				else
					len = maxLines;
			}
			
			if(SILENT_UPDATE) {
				SILENT_UPDATE=false;
				return;
			}
			
			if( len == 0 && aVisual != null && aVisual.length > 0 ) {
				for( var v:String in aVisual) {
					if ( aVisual[v] != null ) {
						removeLine(int(v));
						/*
						cont.removeChild( aVisual[v] );
						(aVisual[v] as OptionListBlock).removeEventListener( MouseEvent.MOUSE_DOWN, select );
						(aVisual[v] as OptionListBlock).removeEventListener( FocusEvent.FOCUS_IN, fSelect );
						SavePerformer.remove( operatingCMD, (aVisual[v] as OptionListBlock).getStructure() );
						SavePerformer.forget( operatingCMD, (aVisual[v] as OptionListBlock).getStructure() );
						aVisual[v] = null;
						*/
					}
				}
				aVisual.length = 0;
			}
			
			for(i=starti; i<len; ++i ) {
				
				if (C_ENABLER_PARAM>0) {
					if ( data[i][ C_ENABLER_PARAM-1 ] != 0 &&
						( !C_ENABLER_PARAM_IS_SWITCH || (data[i][ C_ENABLER_PARAM-1 ] == 1 || data[i][ C_ENABLER_PARAM-1 ] == 2) )
						) {
						if ( aVisual[i] == null ) {
							opt = new operatingClass( i+1 );
							if( C_UNIQUE_PARAMS )
								opt.setTestUniqueFunction = isUnique;
							cont.addChild( opt );
							aVisual[i] = opt;
							opt.x = N_GLOBAL_X;
							opt.putRawData( data[i] );
							opt.addEventListener( Event.CHANGE, dataChanged );
						} else {
							opt = aVisual[i] as OptionListBlock;
							if (needUpdate)
								opt.putRawData( data[i] );
						}
						totalLines++;
						
						if ( deletedLine && deletedLine.getStructure() == opt.getStructure() )
							deletedLine = null;
						
						if (C_DRAW_CHECKMATE)
							opt.drawCheckMate( Boolean((i+1) & 1 > 0) );
						
						if ( tableShiftSize == 0 ) {
							tableShiftSize = opt.getHeight();
							if ( cont.verticalScrollBar )
								cont.verticalScrollBar.lineScrollSize = tableShiftSize;
						}
						
						opt.y = localY;
						localY += opt.getHeight();
						opt.addEventListener( MouseEvent.MOUSE_DOWN, mSelect );
						opt.addEventListener( FocusEvent.FOCUS_IN, fSelect );
					} else {
						if ( aVisual[i] != null )
							removeLine(i);
					}
				} else {
					if ( aVisual[i] == null ) {
						opt = new operatingClass( i+1 );
						if( C_UNIQUE_PARAMS )
							opt.setTestUniqueFunction = isUnique;
						cont.addChild( opt );
						aVisual[i] = opt;
						opt.x = N_GLOBAL_X;
						
						opt.putRawData( data[i] );
						opt.addEventListener( Event.CHANGE, dataChanged );
					} else {
						opt = aVisual[i] as OptionListBlock;
						if (needUpdate)
							opt.putRawData( data[i] );
					}
					totalLines++;
					
					if ( deletedLine && deletedLine.getStructure() == opt.getStructure() )
						deletedLine = null;
					
					if (C_DRAW_CHECKMATE)
						opt.drawCheckMate( Boolean((i+1) & 1 > 0) );
					
					if ( tableShiftSize == 0 ) {
						tableShiftSize = opt.getHeight();
						if ( cont.verticalScrollBar )
							cont.verticalScrollBar.lineScrollSize = tableShiftSize;
					}
					
					opt.y = localY;
					localY += opt.getHeight();
					opt.addEventListener( MouseEvent.MOUSE_DOWN, mSelect );
					opt.addEventListener( FocusEvent.FOCUS_IN, fSelect );
					
					
				}
				
				
			}
			buttonEnabler();
			IS_READY = true;
		}
		private function removeLine(rnum:int):void
		{
			
			if( DisplayObject( aVisual[ rnum ] ).parent )cont.removeChild( aVisual[rnum] );
			(aVisual[rnum] as OptionListBlock).removeEventListener( MouseEvent.MOUSE_DOWN, select );
			(aVisual[rnum] as OptionListBlock).removeEventListener( FocusEvent.FOCUS_IN, fSelect );
			(aVisual[rnum] as OptionListBlock).removeEventListener( Event.CHANGE, dataChanged );
			SavePerformer.remove( operatingCMD, (aVisual[rnum] as OptionListBlock).getStructure() );
			SavePerformer.forget( operatingCMD, (aVisual[rnum] as OptionListBlock).getStructure() );
			(aVisual[rnum] as OptionListBlock).unFocus();
			aVisual[rnum] = null;
		}
		public function addHeader(cls:Class):void
		{
			if (!header_cont) {
				header_cont = new Canvas;
				addChild( header_cont );
				HEADER_CONT_WIDTH = cont.width;
				headerContResize();
				header_cont.height = 40;
				header_cont.horizontalScrollPolicy = ScrollPolicy.OFF;
				header_cont.horizontalScrollPolicy = ScrollPolicy.OFF;
				cont.addEventListener( "scroll", contentScroll );
				cont.y = 40;
			}
			if (header) {
				header_cont.removeChild( header );
				header.removeEventListener( MouseEvent.MOUSE_DOWN, mSelect );
				header = null;
			}
			header = new cls(0);
			header_cont.addChild( header );
			header.x = N_GLOBAL_X;
			header.putRawData(["header"]);
			header.addEventListener( MouseEvent.MOUSE_DOWN, mSelect );
		}
		private function headerContResize():void
		{
			if( cont.verticalScrollBar == null )
				header_cont.width = HEADER_CONT_WIDTH;
			else
				header_cont.width = HEADER_CONT_WIDTH - 20;
		}
		private function contentScroll(ev:Event):void
		{
			headerContResize();
			header_cont.horizontalScrollPosition = cont.horizontalScrollPosition;
		}
		public function attune(_cmd:int, _enablerParam:int=1,_params:int=0, _paramsData:Object=null ):void
		{
			schema = OPERATOR.getSchema(_cmd);
			operatingCMD = _cmd;
			// какой параметр отвечает за включение/выключение строки
			C_ENABLER_PARAM = _enablerParam;
			C_NO_BUTTONS = Boolean(C_ENABLER_PARAM==0);
			if(C_NO_BUTTONS)
				buttonEnabler();
			// Передача уникального(ых) параметра(ов)
			C_UNIQUE_PARAMS = _paramsData==null ? null : _paramsData.uniqueParams;
			if (!C_UNIQUE_PARAMS)
				this.savable = true;
			// Если требуется задавать значения при создание отличные от нуля
			C_CREATION_PATTERN = _paramsData==null ? null : _paramsData.creationPattern;
			// Количество линий отображаемое на странице, когда C_DRAW_PAGES = true 
			C_PAGE_LINES_PER_PAGE = _paramsData==null ? 30 : _paramsData.linesPerPage;
			// Коллбэк для добавления через фанкс/стейт
			if (_paramsData != null && _paramsData.funcOperator != null ) {
				C_FUNCT_OPERATOR = _paramsData.funcOperator;
				C_OPERATE_WITH_FUNCT = true;
			}
			C_FIRE_SAVE_BEFORE_BUTTONS = _paramsData==null ? 0 : _paramsData.saveBefore;
			
			var value:int = 1;
			for(var len:int; len<_params; ++len ) {
				if( value << len > _params )
					break;
			}
			
			var result:int;
			for(var i:int; i<len; ++i ) {
				 result = _params & (1 << i);
				 if (result>0)
					 applyParam(result);
			}
		}
		public function attune_numerical(_buttonYshift:Number=NaN, _globalX:Number=NaN):void
		{
			if ( !isNaN(_buttonYshift) )
				N_BUTTONS_Y_SHIFT = _buttonYshift;
			if ( !isNaN(_buttonYshift) )
				N_GLOBAL_X = _globalX;
		}
		public function clear():void
		{
			var len:int = aVisual.length;
			for (var i:int=0; i<len; ++i) {
				if ( aVisual[i] is OptionListBlock ) {
					/*cont.removeChild( aVisual[i] );
					(aVisual[i] as OptionListBlock).removeEventListener( MouseEvent.MOUSE_DOWN, select );
					SavePerformer.remove( operatingCMD, (aVisual[i] as OptionListBlock).getStructure() );
					SavePerformer.forget( operatingCMD, (aVisual[i] as OptionListBlock).getStructure() );
					aVisual[i] = null;*/
					removeLine(i);
				}
			}
			if(data)
				data.length = 0;
			if (C_DRAW_PAGES)
				page_current=1;
		}
		private function applyParam(param:int):void
		{
			switch(param) {
				case PARAM_DRAW_CHECKMATE:
					C_DRAW_CHECKMATE = true;
					break;
				case PARAM_DRAW_SEPARATOR:
					C_DRAW_SEPARATOR = true;
					separator = new Separator(width-10);
					addChild( separator )
					separator.x = N_GLOBAL_X;
					break;
				case PARAM_ATLEAST_ONE_LINE:		// Должна ли быть хотябы одна строка неудаленной
					C_ATLEAST_ONE_LINE = true;
					break;
				case PARAM_NEED_ADDITIONAL_EVENTS:	// Если требуются дополнительные действия после успешного ADD REMOVE RESTORE отсылаются евенты
					C_NEED_ADITIONAL_EVENTS = true;
					break;
				case PARAM_DRAW_PAGES:	// Если помимо спика есть страницы
					C_DRAW_PAGES = true;
					page_line_buttons = new Vector.<TextButton>;
					break;
				case PARAM_ENABLER_IS_SWITCH:
					C_ENABLER_PARAM_IS_SWITCH = true;
					break;
				case PARAM_NO_BLOCK_SAVE:
					C_BLOCK_SAVE = false;
					break;
				case PARAM_SCROLLING_ALWAYS_HIIDDEN:
					cont.verticalScrollPolicy = ScrollPolicy.OFF;
					break;
				case PARAM_H_SCROLLING_WHEN_NEEEDED:
					cont.horizontalScrollPolicy = ScrollPolicy.AUTO;
					break;
				case PARAM_V_SCROLLING_WHEN_NEEEDED:
					cont.verticalScrollPolicy = ScrollPolicy.AUTO;
					break;
				case PARAM_UNIQUE_FUNC_PARAM:
					C_UNIQUE_FUNC_EXEC = true;
					break;
				case PARAM_STRICT_RESTORE:
					C_STRICT_RESTORE = true;
					break;
				case PARAM_NOTIFY_IF_SELECT:
					C_NOTIFY_IF_SELECT = true;
			}
		}
		private function isUniqueFunction():void
		{
			var result:Boolean=true;
			var key:String;
			for( key in aVisual ) {
				if ( aVisual[key] != null )
					(aVisual[key] as OptionListBlock).setUnique(true);
			}
			var u:String;
			for( key in aVisual ) {
				
				if (aVisual[key] == null)
					continue;
				
				u = (aVisual[key] as OptionListBlock).getUnique();
				
				if (u == null) {
					result = false;
					continue;
				}
				
				for( var keya:String in aVisual ) {
					if (aVisual[keya] == null || aVisual[key] == aVisual[keya] )
						continue;
					
					if( u == (aVisual[keya] as OptionListBlock).getUnique() ) {
						(aVisual[keya] as OptionListBlock).setUnique(false);
						(aVisual[key] as OptionListBlock).setUnique(false);
						result = false;
						break;
					}
				}
			}
			errorScreen.visible = !result;
			savable = result;
			buttonEnabler();
		}
		private function isUnique(param:int):Boolean
		{
			var result:Boolean=true;
			
			var key:String;
			for( key in aVisual ) {
				if ( aVisual[key] != null )
					((aVisual[key] as OptionListBlock).getField( operatingCMD, param ) as FormEmpty).valid = true;
			}
			
			for( key in aVisual ) {
				
				if (aVisual[key] == null)
					continue;
				var field:FormEmpty = (aVisual[key] as OptionListBlock).getField( operatingCMD, param ) as FormEmpty;
				
				field.isValid( field.getCellInfo() as String );
				
				if( !field.valid ) {
					result = false;
					continue;
				}
				
				for( var keya:String in aVisual ) {
					if (aVisual[keya] == null)
						continue;
					
					var field_target:FormEmpty = (aVisual[keya] as OptionListBlock).getField( operatingCMD, param ) as FormEmpty;
					
					if( field != field_target && String(field.getCellInfo()) == String(field_target.getCellInfo()) ) {
						field.valid = false;
						field_target.valid = false;
						result = false;
						break;
					}
				}
			}
			errorScreen.visible = !result;
			savable = result;
			buttonEnabler();
			return result;
		}
		private function dataIsValid(param:int, value:String):Boolean
		{
			for( var key:String in aVisual ) {
				if (aVisual[key] == null)
					continue;
				var field:FormEmpty = (aVisual[key] as OptionListBlock).getField( operatingCMD, param ) as FormEmpty;
				if ( value == field.getCellInfo() )
					return false;
			}
			return true;
		}
		public function putData( a:Array, cls:Class ):void
		{
			
			
			selectedLine = 0;
			KeyWatcher.add(this);
			operatingClass = cls;
			
			data = new Vector.<Array>;
			var len:int = a.length;
			for( var i:int=0; i<len; ++i) {
				data.push( a[i] );
			}
			
			maxLines = data.length;
			TabOperator.getInst().resetOrder();
			distributeData(true);
			validateData();
			
			if( C_BLOCK_SAVE )
				SavePerformer.addCMDParam( operatingCMD, SavePerformer.BLOCK_SAVE, this );
		}
		public function put( p:Package, cls:Class ):void
		{
			
			
			selectedLine = 0;
			KeyWatcher.add(this);
			operatingClass = cls;
			
			data = new Vector.<Array>;
			var len:int = p.length;
			for( var i:int=0; i<len; ++i) {
				data.push( p.getStructure(i+1) );
			}

			maxLines = data.length;
			TabOperator.getInst().resetOrder();
			distributeData(true);
			validateData();
			
			if( C_BLOCK_SAVE )
				SavePerformer.addCMDParam( operatingCMD, SavePerformer.BLOCK_SAVE, this );
		}
		public function putStructure(p:Package, fake:Boolean=false):void
		{
			data = Vector.<Array>(OPERATOR.dataModel.getData( operatingCMD ));
			if (fake)
				data[p.structure-1] = p.getStructure();
			TabOperator.getInst().resetOrder();
			distributeData(true);

			selectedLine = p.structure;
			autoSelect();
			validateData();

			if ( C_NEED_ADITIONAL_EVENTS )
				this.dispatchEvent( new GUIEvents( GUIEvents.onEventFiredSuccess, {"getActionCode":CHANGE, "getStructure":p.structure} ));
		}
		private function validateData():void
		{
			for(var key:String in C_UNIQUE_PARAMS ) {
				isUnique( C_UNIQUE_PARAMS[key].param );
			}
			if (C_UNIQUE_FUNC_EXEC) {
				isUniqueFunction();
			}
			isRestorable = true;
			if ( C_UNIQUE_PARAMS ) {
				if( deletedLine && savable ) {
					var field:IFormString;
					for( var p:String in C_UNIQUE_PARAMS ) {
						field = deletedLine.getField( operatingCMD,C_UNIQUE_PARAMS[p].param);
						isRestorable = field.isValid() && dataIsValid( C_UNIQUE_PARAMS[p].param, String(field.getCellInfo()) );
						if (!isRestorable)
							break;
					}
				} else
					isRestorable = false;
			}
			
			SavePerformer.validate();	// для верного отобраежения кнопки сохранить
			buttonEnabler();
		}
		private function dataChanged( ev:Event ):void
		{
			
			validateData();
		}
		protected function buttonEnabler():void
		{
			
			if (C_NO_BUTTONS) {
				bAdd.visible = false; 
				bRemove.visible = false;
				bRestore.visible = false;
				return;
			}
			
			var params:Object = {
				"overrideIsMaxLines":overrideIsMaxLines(),
				"this.savable":this.savable,
				"FLAG_ADD_BUSY":FLAG_ADD_BUSY,
				"FLAG_SAVE_ACTIVE":FLAG_SAVE_ACTIVE,
				"isRemovable":isRemovable(),
				"isRestorable":isRestorable
			}
			
			bAdd.disabled = Boolean( overrideIsMaxLines() || !this.savable || FLAG_ADD_BUSY || FLAG_SAVE_ACTIVE ); 
			
			bRemove.disabled = Boolean( selectedLine == 0 || !isRemovable() || FLAG_REMOVE_BUSY || FLAG_SAVE_ACTIVE );
			bRestore.disabled = Boolean( !deletedLine || !this.savable || !isRestorable || FLAG_SAVE_ACTIVE);
		}
		private function isMaxLinesInternal():Boolean
		{
			return totalLines >= maxLines;
		}
		protected function isRemovable():Boolean
		{
			if( C_ATLEAST_ONE_LINE && totalLines == 1 )
				return false;
			
			var o:OptionListBlock = getLine(selectedLine);
			if ( !o || !getLine(selectedLine).isRemovable() )
				return false;
			return true;
		}
		private function mSelect(ev:MouseEvent):void
		{
			if ( (ev.currentTarget as OptionListBlock).isHeader() ) {
				if ( (ev.currentTarget as OptionListBlock).isRightClick(ev.target as DisplayObject) )
					vselect( ev.localX );
			} else
				select( (ev.currentTarget as OptionsBlock).getStructure() );
		}
		private function fSelect(ev:FocusEvent):void
		{
			var st:int = (ev.currentTarget as OptionsBlock).getStructure(); 
			select( st );
			scrollTo( st );
		}
		public function keySelect(down:Boolean):void
		{
			var i:int;
			var len:int = aVisual.length;
			var result:int=-1;
			var found:Boolean=false;
			var opt:OptionListBlock;
			
			if (down) {
				for ( i=0; i<len; ++i) {
					opt = aVisual[i] as OptionListBlock;
					if ( opt && opt.selectable ) {
						if (!found) {
							if( selectedLine == opt.getStructure() )
								found = true;
						} else {
							result = opt.getStructure();
							break;
						}
					}
				}
				if (result < 0) {
					for ( i=0; i<len; ++i) {
						opt = aVisual[i] as OptionListBlock;
						if ( opt && opt.selectable ) {
							result = opt.getStructure();
							break;
						}
					}
				}
			} else {
				for ( i=len; i>-1; --i) {
					opt = aVisual[i] as OptionListBlock;
					if ( opt && opt.selectable ) {
						if (!found) {
							if( selectedLine == opt.getStructure() )
								found = true;
						} else {
							result = opt.getStructure();
							break;
						}
					}
				}
				if (result < 0) {
					for ( i=len; i>-1; --i) {
						opt = aVisual[i] as OptionListBlock;
						if ( opt && opt.selectable ) {
							result = opt.getStructure();
							break;
						}
					}
				}
			}
			select( result );
		}
		public function vselect(posx:int):void
		{
			for( var key:String in aVisual) {
				if ( (aVisual[key] as OptionListBlock) == null || !(aVisual[key] as OptionListBlock).selectable || (aVisual[key] as OptionListBlock).isHeader() )
					continue;
				(aVisual[key] as IListItem).selectVertical( posx );
			}
		}
		public function select(num:int):void
		{
			selectedLine = 0;
			for( var key:String in aVisual) {
				if ( (aVisual[key] as OptionListBlock) == null || !(aVisual[key] as OptionListBlock).selectable )
					continue;
				
				if( num == (aVisual[key] as OptionsBlock).getStructure() ) {
					(aVisual[key] as IListItem).select( true );
					selectedLine = (aVisual[key] as OptionsBlock).getStructure();
					if (C_NOTIFY_IF_SELECT)
						this.dispatchEvent( new Event(FlexEvent.SELECTION_CHANGE));
				} else (aVisual[key] as IListItem).select( false );
			}
			buttonEnabler();
		}
		override public function set height(value:Number):void
		{
			var correction:int = header_cont ? 40:0
			if ( value < 82 ) {
				super.height = 82;
				cont.height = 82-(50+correction);
			} else {
				super.height = value;
				cont.height = value-(50+correction);
			}
			bAdd.y = cont.height + 10 + N_BUTTONS_Y_SHIFT;
			bRemove.y = cont.height + 10 + N_BUTTONS_Y_SHIFT;
			bRestore.y = cont.height + 10 + N_BUTTONS_Y_SHIFT;
			
			errorScreen.graphics.clear();
			errorScreen.graphics.beginFill( 0xfae7e7 );
			errorScreen.graphics.drawRect(10,0,cont.width-25,cont.height );
			errorScreen.graphics.endFill();
			
			if (separator)
				separator.y = cont.height + 5 + correction;
			
			if (cont_buttons) {
				cont_buttons.y = cont.height + 5 + correction;
				if (separator)
					separator.y = cont.height + 35+ correction;	
			}
			if (screenBlock && screenBlock.visible )
				screenBlock.resize( this.width-16, value-50 );
			
			if (scrollBg) {
			//	cont.setChildIndex(scrollBg,0);
				scrollBg.graphics.clear();
				scrollBg.graphics.beginFill(COLOR.WHITE, 0 );
				scrollBg.graphics.drawRect(0,0,cont.width-1, getContentHeight() -1);
				scrollBg.graphics.endFill();
			}
		}
		override public function set width(value:Number):void
		{
			super.width = value;
			cont.width = value;
			if (header_cont) {
				HEADER_CONT_WIDTH = value;
				headerContResize();
			}
			if (separator)
				separator.width = value-10;
			if (screenBlock && screenBlock.visible )
				screenBlock.resize( value-16, this.height-50 );
		}
		public function onKeyUp(ev:KeyboardEvent):void
		{
			if( ev.keyCode == KEYS.Key_Z && ev.ctrlKey )
				processLine(RESTORE);
			if (IS_READY) {
				if( page_jump_input && ev.keyCode == KEYS.Enter && C_DRAW_PAGES && stage.focus == page_jump_input.getFocusable() ) {
					switchPage(BUTTON_PAGE_JUMP);
				} else if ( page_decade_b_next && !page_decade_b_next.disabled && ev.keyCode == KEYS.RightArrow && (ev.ctrlKey || ev.shiftKey) && C_DRAW_PAGES ) {
					switchPage(BUTTON_DECADE_NEXT);
				} else if ( page_decade_b_prev && !page_decade_b_prev.disabled && ev.keyCode == KEYS.LeftArrow && (ev.ctrlKey || ev.shiftKey) && C_DRAW_PAGES ) {
					switchPage(BUTTON_DECADE_PREV);
				} else if ( page_b_next && !page_b_next.disabled && ev.keyCode == KEYS.RightArrow && C_DRAW_PAGES ) {
					switchPage(BUTTON_PAGE_NEXT);
				} else if ( page_b_prev && !page_b_prev.disabled && ev.keyCode == KEYS.LeftArrow && C_DRAW_PAGES ) {
					switchPage(BUTTON_PAGE_PREV);
				} else if ( page_b_refresh && !page_b_refresh.disabled && ev.keyCode == KEYS.F5 && C_DRAW_PAGES ) {
					switchPage(BUTTON_PAGE_REFRESH);
				} else if ( (bAdd.visible || bRemove.visible ) && !TabOperator.getInst().isCurrentFocusableField() && 
					!TabOperator.getInst().isCurrentFocusOnMenu() && ev.keyCode == KEYS.DownArrow ) {
					keySelect( true );
					scrollTo(selectedLine-1);
				} else if ( (bAdd.visible || bRemove.visible ) && !TabOperator.getInst().isCurrentFocusableField() && 
					!TabOperator.getInst().isCurrentFocusOnMenu() && ev.keyCode == KEYS.UpArrow ) {
					keySelect( false );
					scrollTo(selectedLine-1);
				}
			}
		}
		public function addCustom(s:int,arr:Array):void
		{
			addId = s;
			addedObj = arr;
			RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, addSuccess, addId, addedObj ));
		}
		protected function processLine(num:int):void
		{
			if ( (C_FIRE_SAVE_BEFORE_BUTTONS & num) > 0)
				SavePerformer.rememberIfEmpty();
			switch(num) {
				case ADD:
					SavePerformer.save();
					addId = getFirstFreeLine();
					if ( addId > 0 ) {
						// Если включен режим добавления через фанкт/стейт
						if (C_OPERATE_WITH_FUNCT)
							C_FUNCT_OPERATOR(addId,num);
						else {
							if( fOverrideAdd is Function ) {
								addedObj = generateFiledRawData(C_ENABLER_PARAM);
								fOverrideAdd(new Request( operatingCMD, addSuccess, addId, addedObj ));
							} else {
								addedObj = generateFiledRawData(C_ENABLER_PARAM);
								RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, addSuccess, addId, addedObj ));
							}
						}
					}
					break;
				case REMOVE:
					if ( selectedLine > 0 && isRemovable() ) {
						// Если включен режим добавления через фанкт/стейт
						if (C_OPERATE_WITH_FUNCT)
						{
							C_FUNCT_OPERATOR(selectedLine,num);
						}
						else 
						{
							if( fOverrideRemove is Function ) {
								deletedLine = aVisual[selectedLine-1] as OptionListBlock;
								fOverrideRemove(new Request( operatingCMD, removeSuccess, selectedLine, generateFiledRawData() ));
							} else {
								var op:OptionListBlock = new operatingClass(selectedLine);
								op.putRawData( OPERATOR.dataModel.getData(operatingCMD)[selectedLine-1] );
								deletedLine = op; 
								//deletedLine = aVisual[selectedLine-1] as OptionListBlock;
								RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, removeSuccess, selectedLine, generateFiledRawData() ));
							}
						}
					} else
						buttonEnabler();
					break;
				case RESTORE:
					if ( deletedLine ) {
						SavePerformer.save();
						var isCancelable:Boolean = true;
						for( var p:String in C_UNIQUE_PARAMS ) {
							if ( !dataIsValid( C_UNIQUE_PARAMS[p].param, String(deletedLine.getField(operatingCMD,C_UNIQUE_PARAMS[p].param).getCellInfo()) ) ) {
								isCancelable = false;
								break;
							}
						}
						if ( isCancelable ) {
							// Если включен режим добавления через фанкт/стейт
							if (C_OPERATE_WITH_FUNCT)
								C_FUNCT_OPERATOR(deletedLine.getStructure(),num);
							else
								RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, restoreSuccess, deletedLine.getStructure(), gatherDataFromFields(deletedLine) ));
						} else {
							deletedLine = null;
							buttonEnabler();
						}
					} else
						buttonEnabler();
					break;
			}
		}
		private function generateFiledRawData(enabler:int=0):Array
		{
			var params:Array = new Array;
			var paramdata:int = 0;
			for( var p:String in schema.Parameters ) {
				paramdata = 0;
				
				if ( (schema.Parameters[p] as ParameterSchemaModel).Order == enabler )
					paramdata = 1;
				else 
					paramdata = 0;
				
				// Если включающий параметр не 0 значит надо генерить уникальные поля
				if ( enabler > 0 ) {				
					for(var uniquep:String in C_UNIQUE_PARAMS) {
						if( C_UNIQUE_PARAMS[uniquep].param == (schema.Parameters[p] as ParameterSchemaModel).Order ) {
							if( C_UNIQUE_PARAMS[uniquep].gen == GENERATION_RANDOM )
								paramdata = generateUnique( (schema.Parameters[p] as ParameterSchemaModel).Order );
							else
								paramdata = generateFirstFree( (schema.Parameters[p] as ParameterSchemaModel).Order, C_UNIQUE_PARAMS[uniquep].genMin, C_UNIQUE_PARAMS[uniquep].genMax );
							break;
						}
					}
					if ( C_CREATION_PATTERN ) {
						for( var c:String in C_CREATION_PATTERN ) {
							if ( int(c) == (schema.Parameters[p] as ParameterSchemaModel).Order )
								paramdata = C_CREATION_PATTERN[c];
						}
					}
				}
				
				if( (schema.Parameters[p] as ParameterSchemaModel).Type == "String" )
					params.push( paramdata == 0 ? "": String(paramdata) );
				else
					params.push(paramdata);
			}
			return params;
		}
		private function generateFirstFree(param:int, min:int, max:int ):int
		{
			var len:int = totalLines;
			var num:int;
			for( num=min; num<max; ++num ) {
				var choosePartition:Boolean = true;
				for( var p:String in aVisual ) {
					if (aVisual[p] == null)
						continue;
					if ( int( (aVisual[p] as OptionListBlock).getField(operatingCMD,param).getCellInfo() ) == num ) {
						choosePartition = false;
						break;
					}
				}
				if ( choosePartition ) break;
			}
			return num;
		}
		private function generateUnique(param:int):int
		{
			// addId работает только в случае добавления если нужна уникальная генерация
			var uGenerator:IListItem = new operatingClass(addId) as IListItem;
			var uniqueData:String = uGenerator.getUniqueData(param);
			
			while( true ) {
				if ( dataIsValid( param, uniqueData) )
					break;
				uniqueData = uGenerator.getUniqueData(param);
			}
			return int(uniqueData);
		}
		private function gatherDataFromFields(target:OptionsBlock):Array 
		{
			var arr:Array = new Array;
			var param:ParameterSchemaModel;
			for( var p:String in schema.Parameters) {
				param = schema.Parameters[p] as ParameterSchemaModel;
				switch(param.Type) {
					case "String":
						arr.push( String( target.getField( schema.Id, param.Order ).getCellInfo() ) );
						break;
					case "Decimal":
						arr.push( int( target.getField( schema.Id, param.Order ).getCellInfo() ) );
						break;
				}
			}
			return arr;
		}
		protected function getFirstFreeLine():int
		{
			if( overrideGetFirstFreeLineExt is Function )
				return overrideGetFirstFreeLineExt();
			
			if ( totalLines < maxLines ) {
				if(totalLines==0)
					return 1;
				for( var key:String in data ) {
					if ( data[key][0] == 0 || (C_ENABLER_PARAM_IS_SWITCH && data[key][0] != 1))
						return int(key)+1;
				}
			}
			return 0;
		}
		private function addSuccess( p:Package ):void
		{
			if ( p.success && addId > 0 ) {
				if( p.data )
					data[addId-1] = p.data;
				else
					data[addId-1] = addedObj;
				
				distributeData();
				select(addId);
				
				if( !addTimer ) {
					addTimer = new Timer(50,1);
					addTimer.addEventListener(TimerEvent.TIMER, updateScrollFocus );
				}
				addTimer.reset();
				addTimer.start();
				if ( C_NEED_ADITIONAL_EVENTS )
					this.dispatchEvent( new GUIEvents( GUIEvents.onEventFiredSuccess, {"getActionCode":ADD, "getStructure":addId} ));
				if (C_UNIQUE_PARAMS)
					validateData();
			}
		}
		private function updateScrollFocus(ev:Event):void
		{
			if( cont.verticalScrollPosition + cont.height < (addId)*tableShiftSize || cont.verticalScrollPosition > (addId-1)*tableShiftSize )
				cont.verticalScrollPosition = (addId-1)*tableShiftSize;
			addId = 0;
		}
		private function removeSuccess( p:Package ):void
		{
			if (p.success && deletedLine ) {

				data[deletedLine.getStructure()-1] = generateFiledRawData();
				var remStr:int = deletedLine.getStructure();

				distributeData();
				validateData();
				
				if (C_STRICT_RESTORE && !isRestorable)
					deletedLine = null;
				
				autoSelect();
				
				if ( C_NEED_ADITIONAL_EVENTS )
					this.dispatchEvent( new GUIEvents( GUIEvents.onEventFiredSuccess, {"getActionCode":REMOVE, "getStructure":remStr} ));
				
				TabOperator.getInst().restoreFocus(bRemove);
			}
		}
		private function autoSelect():void
		{
			if (aVisual) {
				var newSelection:int=-1;
				var len:int = aVisual.length;
				var i:int;
				if (selectedLine < len) {
					for( i=selectedLine; i<len; ++i) {
						if( aVisual[i] != null ) {
							newSelection = i+1;
							break;
						}
					}
				}
				if (newSelection < 0) {
					for( i=selectedLine; i>=0; --i) {
						if( aVisual[i] != null ) {
							newSelection = i+1;
							break;
						}
					}
				}
			}
			select(newSelection);
		}
		private function restoreSuccess( p:Package ):void
		{
			if ( p.success && deletedLine ) {
				data[ deletedLine.getStructure() - 1 ] = gatherDataFromFields( deletedLine );
				
				var remStr:int = deletedLine.getStructure();

				distributeData();
				select(remStr);
				
				if( !addTimer ) {
					addTimer = new Timer(100,1);
					addTimer.addEventListener(TimerEvent.TIMER, updateScrollFocus );
				}
				// для адекватного отображения в скроллинге
				addId = remStr;
				addTimer.reset();
				addTimer.start();
				
				validateData();
				
				deletedLine = null;
				
				if ( C_NEED_ADITIONAL_EVENTS )
					this.dispatchEvent( new GUIEvents( GUIEvents.onEventFiredSuccess, {"getActionCode":RESTORE, "getStructure":remStr} ));
			}
		}
/*** LINE INTERACT ************************************************************************************/
		public function callEach(value:Object=null, global_param:int=0):Boolean // Вызвать функцию call на всех видимых линиях
		{	//	Если хотябы один вернет false, вся функция вернет false
			var len:int = aVisual.length;
			var statement:Boolean = true;
			var b:Boolean;
			for(var i:int=0; i<len; ++i) {
				if( aVisual[i] != null ) {
					if (value is Array)
						b = (aVisual[i] as OptionListBlock).call(value[i], global_param);
					else
						b = (aVisual[i] as OptionListBlock).call(value, global_param);
				}
				if (!b)
					statement = false;
			}
			return statement;
		}
/*** PAGE SECTION *************************************************************************************/
		public function getCurrentPage():int
		{
			return page_current;
		}
		public function selectPage(num:int):void
		{
			IS_READY = false;
			page_current = num;
			
			for( var v:String in aVisual) {
				if ( aVisual[v] != null ) {
					/*
					cont.removeChild( aVisual[v] );
					(aVisual[v] as OptionListBlock).removeEventListener( MouseEvent.MOUSE_DOWN, select );
					SavePerformer.remove( operatingCMD, (aVisual[v] as OptionListBlock).getStructure() );
					SavePerformer.forget( operatingCMD, (aVisual[v] as OptionListBlock).getStructure() );
					aVisual[v] = null;*/
					removeLine(int(v));
				}
			}
			aVisual.length = 0;
			page_b_next.disabled = page_current + 1 > page_line_buttons.length; 
			page_b_prev.disabled = page_current - 1 < 1;
			
			var starting_page:int = (page_current-1)*C_PAGE_LINES_PER_PAGE;
			var needLoadData:Boolean = false;
			for( var i:int = 0; i < C_PAGE_LINES_PER_PAGE; ++i) {
				if( !(data.length < i+starting_page) || data[i+starting_page] == null || data[i+starting_page][C_ENABLER_PARAM] == 0 ) {
					needLoadData = true;
					break;
				}
			}
			
			page_jump_input.setCellInfo(num);
			
			if( needLoadData )
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedPage, {"getData":page_current});
			else
				distributeData();
		}
		private function switchPage(num:int):void
		{
			switch(num) {
				case BUTTON_PAGE_NEXT:
					page_current++;
					break;
				case BUTTON_PAGE_PREV:
					page_current--;
					break;
				case BUTTON_DECADE_NEXT:
					if(page_current+10 <= page_line_buttons.length)
						page_current += 10;
					break;
				case BUTTON_DECADE_PREV:
					if(page_current-10 > 0 )
						page_current -= 10;
					break;
				case BUTTON_PAGE_JUMP:
					var page:int = int(page_jump_input.getCellInfo());
					if( page > 0 && page <= page_line_buttons.length ) 
						page_current = page;
					else
						return;
					break;
				case BUTTON_PAGE_REFRESH:
					if( page_current > page_line_buttons.length )
						page_current = page_line_buttons.length;
					if (page_current < 1)
						page_current = 1;
					break;
			}
			page_b_next.disabled = page_current + 1 > page_line_buttons.length; 
			page_b_prev.disabled = page_current - 1 < 1;
			page_decade_b_next.disabled = page_current+10 > page_line_buttons.length;
			page_decade_b_prev.disabled = page_current-10 < 1;
			selectPage(page_current);
		}
		public function set disabled(value:Boolean):void
		{
			if (!screenBlock) {
				screenBlock = new ScreenBlock(1,1,ScreenBlock.MODE_ONLY_BLOCK);
				addChild( screenBlock );
			}
			if (value) {
				setChildIndex( screenBlock, this.numChildren-1 );
				screenBlock.resize( this.width-16, this.height-50 );
			}
			screenBlock.visible = value;
			
			var len:int = aVisual.length;
			for (var i:int=0; i<len; ++i) {
				if (aVisual[i] != null) {
					aVisual[i].disabled = value;
				}
			}
		}
/*** OVERRIDE SECTION *********************************************************************************/
		private var fOverrideAdd:Function;
		public function overrideAdd(f:Function):void
		{
			fOverrideAdd = f;
		}
		private var fOverrideRemove:Function;
		public function overrideRemove(f:Function):void
		{
			fOverrideRemove = f;
		}
/*** EVENT SECTION ************************************************************************************/
		public function saveObserver():void
		{
			SavePerformer.addObserver(this);
		}
		public function saveEvent(e:int):void
		{
			switch(e) {
				case SavePerformer.EVENT_ACTIVE:
					FLAG_SAVE_ACTIVE = true;
					break;
				case SavePerformer.EVENT_COMPLETE:
				case SavePerformer.EVENT_CANCEL:
					FLAG_SAVE_ACTIVE = false;
					break;
			}
			buttonEnabler();
		}
/*** FUNCT SECTION ************************************************************************************/
		public function clearRestore():void
		{	// отчищает память стирания
			deletedLine = null;
			buttonEnabler();
		}
		public function scrollTo(value:int):void
		{
			if( cont.verticalScrollPosition + cont.height < (value)*tableShiftSize || cont.verticalScrollPosition > (value-1)*tableShiftSize )
				cont.verticalScrollPosition = (value-1)*tableShiftSize;
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable) {
				TabOperator.getInst().add(child as IFocusable);
				focusables.push( child as IFocusable );
			}
			return super.addChild(child);
		}
		private function addButton(f:IFocusable):void
		{
			cont_buttons.addChild(f as InteractiveObject);
			TabOperator.getInst().add(f);
			focusables.push( f );
			f.focusgroup = TabOperator.GROUP_TABLE;
		}
/*** GET SECTION **************************************************************************************/
		
		public function isSavable():Boolean
		{
			return savable;
		}
		public function getLine(struct:int):OptionListBlock
		{
			for( var key:String in aVisual){
				if (aVisual[key]==null)
					continue;
				if ( (aVisual[key] as OptionListBlock).getStructure() == struct )
					return aVisual[key];
			}
			return null;
		}
		public function getLines():Array
		{
			return aVisual;
		}
		public function getActualLinesCount():int
		{
			return totalLines;
		}
		public function getActualHeight():int
		{	// Возвращает длину вместе с кнопками
			for( var key:String in aVisual){
				if (aVisual[key]==null)
					continue;
				return (aVisual[key] as OptionListBlock).complexHeight * totalLines + 51; 
			}
			return 0;
		}
		private function getContentHeight():int
		{	// возвращает высоту контента
			for( var key:String in aVisual){
				if (aVisual[key]==null)
					continue;
				return (aVisual[key] as OptionListBlock).complexHeight * totalLines; 
			}
			return 0;
		}
		public function getLastVisualLineNum():int
		{
			var len:int = aVisual.length;
			var last:int = 0;
			for ( var i:int=0; i<len; ++i ) {
				if( aVisual[i] != null ) {
					last = i;
				}
			}
			return last;
		}
		public function getFieldData():Array
		{	// Собирает String информацию с полей компонента и формирует массив
			var arr:Array = new Array;
			for(var key:String in aVisual) {
				if (aVisual[key] as OptionListBlock)
					arr.push( (aVisual[key] as OptionListBlock).getFieldsData() );
			}
			return arr;
		}
		public function getHeader():Array
		{
			return header.getFieldsData();
		}
		public function set ADD_BUSY(value:Boolean):void
		{
			FLAG_ADD_BUSY = value;
			buttonEnabler();
		}
		public function get ADD_BUSY():Boolean
		{
			return FLAG_ADD_BUSY;
		}
		public function set REMOVE_BUSY(value:Boolean):void
		{
			FLAG_REMOVE_BUSY = value;
			buttonEnabler();
		}
		public function get REMOVE_BUSY():Boolean
		{
			return FLAG_REMOVE_BUSY;
		}
		public function set IS_READY(value:Boolean):void
		{
			if (_IS_READY != value) { 
				_IS_READY = value;
				var len:int = focusables.length;
				for (var i:int=0; i<len; ++i) {
					focusables[i].focusable = value;
				}
			}
		}
		public function get IS_READY():Boolean
		{
			return _IS_READY;
		}
	}
}