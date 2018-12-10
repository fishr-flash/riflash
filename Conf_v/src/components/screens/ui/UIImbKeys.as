package components.screens.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import components.abstract.GroupOperator;
	import components.abstract.IMB_KEY_STATES;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.Balloon;
	import components.gui.Header;
	import components.gui.MFlexListImbKey;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptImbKeys;
	import components.static.CMD;
	
	public class UIImbKeys extends UI_BaseComponent implements IResizeDependant, IWidget
	{
		public static const MAX_COUNT_ALARM_BTNS:int = 16;
		private static const LABEL_MENU_BUSY_DEVICE:String = "    ( " + loc("rfd_adding_via_button") + " )";
		public static var COLOUMN_POSITIONS:Array;
		private var btns:Vector.<TextButton>;
		private var downPing:Boolean;
		
		
		
		
		private var go:GroupOperator;

		private var flist:MFlexListImbKey;
		private var selectedLine:OptImbKeys;

		private var toBeAdded:OptImbKeys;

		private var pseudoPing:ITask;
		
		
		
		public function UIImbKeys()
		{
			super();
			
			toplevel = false;
			
			
			go = new GroupOperator;
			
			
			
			const COLOUMN_MARGIN:int = 20;
			const COLOUMN_WCOUNT:int = 60;
			const COLOUMN_KEYCODE:int = 140;
			const COLOUMN_WSTATE:int = 200;
			const COLOUMN_WTYPE:int = 0;
			const COLOUMN_RESTORE:int = 0;
			const header:Header = new Header
				(
					[
						{ label: loc("g_number"), align: Header.ALIGN_CENTER, xpos:0, width:COLOUMN_WCOUNT },
						{ label: loc("rfd_tmkey_code"), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN, width:COLOUMN_KEYCODE },
						{ label: loc(""), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN + COLOUMN_KEYCODE + COLOUMN_MARGIN, width:COLOUMN_WSTATE },
						//{ label: loc("rf_sen_h_type"), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN +  COLOUMN_WADDRESS + COLOUMN_MARGIN + COLOUMN_WSTATE + COLOUMN_MARGIN, width:COLOUMN_WTYPE },
						{ label: loc(""), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN +  COLOUMN_KEYCODE + COLOUMN_MARGIN + COLOUMN_WSTATE + COLOUMN_MARGIN + COLOUMN_WTYPE + COLOUMN_MARGIN, width:COLOUMN_RESTORE }
					]
				);
			
			COLOUMN_POSITIONS = header.coloumnPositions;
			
			this.addChild( header );
			header.y = globalY;
			globalY += header.height+ 40;
			
			//go.add( "screen", getLastElement() );
			flist = new MFlexListImbKey( OptImbKeys );
			addChild(flist);
			go.add( "screen", flist );
			flist.height = 350;
			flist.width = MFlexListImbKey.WIDTH_FIELD;
			flist.y = globalY;
			flist.x = globalX;
			flist.cbSelect = onSelect;
			
			go.add( "bottom", drawSeparator( MFlexListImbKey.WIDTH_FIELD ) );
			go.add( "screen", getLastElement() );
			const xPos:int = 120;
			
			addButton( loc( "g_add" ), xPos, onAddKey );
			go.add( "bottom", getLastElement() );
			go.add( "screen", getLastElement() );
			
			addButton( loc( "g_remove" ), xPos + 170, onDeleteKey );
			go.add( "bottom", getLastElement() );
			go.add( "screen", getLastElement() );
			
			
			/*wirePic = new Library.cZoneButtons;
			addChild( wirePic );
			wirePic.x = 430+50;
			wirePic.y = 14;
			
			var list:Array = CIDServant.getEvent();
			addui( new FSComboBox, 0, loc("g_zone")+" 1", onEvent, 1, list );
			attuneElement( 80, 300 + 57, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			addui( new FSComboBox, 0, loc("g_zone")+" 2", onEvent, 2, list );
			attuneElement( 80, 300 + 57, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			addui( new FSComboBox, 0, loc("g_zone")+" 3", onEvent, 3, list );
			attuneElement( 80, 300 + 57, FSComboBox.F_COMBOBOX_NOTEDITABLE );

			opts = new Vector.<OptZones>(3);
			for (var i:int=0; i<3; i++) {
				opts[i] = new OptZones(i+1);
			}
			drawSeparator(380+40+57);
			
			list = UTIL.getComboBoxList( [[1,loc("keyboard_buttons_disabled")],[0,loc("keyboard_buttons_enabled")],[2,loc("keyboard_buttons_enabled_with_delay")]] );
			addui( new FSComboBox, CMD.OP_C_AKARM_KEY, loc("keyboard_panic_services"), null, 1, list );
			attuneElement( 380-13-30, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );*/
			
			WidgetMaster.access().registerWidget( CMD.VR_TM_SEARCH, this );
			WidgetMaster.access().registerWidget( CMD.VR_TM_KEY, this );
			
			ResizeWatcher.addDependent(this);
			starterCMD = [ CMD.VR_TM_KEY ];
			
		}
		
				
		
		
		
		
		override public function open():void
		{
			toplevel = true;
			super.open();
			WidgetMaster.access().registerWidget( CMD.VR_TM_SEARCH, this );
			WidgetMaster.access().registerWidget( CMD.VR_TM_KEY, this );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onBlockNavigation, onBlockNavigation );
			
		}
		
		
		
		override public function close():void
		{
			toplevel = false;
			super.close();
			WidgetMaster.access().unregisterWidget( CMD.VR_TM_SEARCH );
			WidgetMaster.access().unregisterWidget( CMD.VR_TM_KEY );
			ResizeWatcher.removeDependent(this);
			//RequestAssembler.getInstance().doPing( true );
			flist.clearlist();
			//pseudoPing.stop();
			//pseudoPing.kill();
			//pseudoPing = null;
			toBeAdded = null;
			
			
			
			
		}
		
		override public function put(p:Package):void
		{
			flist.scrollUp();
			switch(p.cmd) {
				
				case CMD.VR_TM_KEY:
					
					
					
					if( toBeAdded )
					{
						p.data[ toBeAdded.structure - 1 ] = p.data[ 0 ];
						toBeAdded.put( p );
						toBeAdded = null;
						//pseudoPing.stop();
					}
					else
					{
						flist.put( p, true );
						ResizeWatcher.doResizeMe(this);
					}
					
					go.disabled( "screen", false );
					
					btns[ 1 ].disabled = true;
					
					
					if( !flist.getAvailableStructure() ) btns[ 0 ].disabled = true;
					
					loadComplete();
					break;
				
				
				case CMD.VR_TM_SEARCH:
					/**
					 * Команда VR_TM_SEARCH - Команда поиска ключа

						Параметр 1 - Команда для выполнения устройством (0 - закончить действие, 1 - начать поиск ключа, 2 - выполняется поиск ключа, 3 - поиск ключа успешно завершен, 4 - поиск ключа завершен по таймауту, 5 - ключ уже присутствует в таблице, 6 - в таблице нет свободной ячейки )
						Параметр 2 - Номер структуры команды VR_TM_KEY, указывается для значений '3' и '5' в поле "Параметр 1"
						Поиск заканчивается через таймаут 30 секунд или после нахождения ключа.
						Чтобы включить программу чтения с экрана, нажмите Ctrl+Alt+Z. Для просмотра списка быстрых клавиш нажмите Ctrl+косая черта.
						 

					 */
					
					switch( p.getParam( 1 ) ) {
						
						case IMB_KEY_STATES.KEY_FOUND:
							GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
							if( flist.getAvailableStructure() ) btns[ 0 ].disabled = false;
							break;
						
						case IMB_KEY_STATES.ON_SEARCH:
							
							if( !toBeAdded )toBeAdded = flist.add( p, false ) as OptImbKeys;
							
							ResizeWatcher.doResizeMe(this);
							//RequestAssembler.getInstance().doPing( false );
							
							
							
							if( !flist.getAvailableStructure() ) btns[ 0 ].disabled = true;
							
							ResizeWatcher.doResizeMe(this);
							//pseudoPing.repeat();
							toBeAdded.put( p );
							break;
						
						
						case IMB_KEY_STATES.ALL_CANCEL:
							go.disabled( "screen", false );
							go.disabled( "bottom", false );
							btns[ 0 ].disabled = false;
							
							
							break;
						case IMB_KEY_STATES.TIME_OUT:
						case IMB_KEY_STATES.DOUBLE_DETECTED:
							
							if( toBeAdded ) 
							{
								toBeAdded.put( p );
								//flist.removeCustomEl( toBeAdded );
								//toBeAdded = null;
							}
							go.disabled( "screen", false );
							go.disabled( "bottom", false );
							
							
							btns[ 1 ].disabled = true;
							
							//pseudoPing.stop();
							//RequestAssembler.getInstance().doPing( true );
							ResizeWatcher.doResizeMe(this);
							
							GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
							break;
						
						default:
							
							//flist.put( p, true );
							break;
					}
					
					if( toBeAdded ) toBeAdded.dispatchEvent( new MouseEvent( MouseEvent.CLICK ) );
					/*GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.onNeedChangeLabel, { getData:{ labelnum:2, label:"" }} ) );
					
					switch( p.getParamInt( 2 ) )
					{
						case IMB_KEY_STATES.RECREATE_AT_BUTTON:
							//// Если повторное добавление идет по кнопке с прибора toBeAdded-а может и не быть
							if( toBeAdded )flist.removeCustomEl( toBeAdded );
							toBeAdded = null;
							
							Balloon.access().show( "sys_attention",loc( "recreate_at_button_baloon" ) +  p.getParam( 1 ) + ""  );
						case IMB_KEY_STATES.DELETE_SUCCESS:
							flist.clearDeleted();
						case IMB_KEY_STATES.ADDED_SUCCESS:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.LR_DEVICE_LIST_RF_SYSTEM, put ) );
						case IMB_KEY_STATES.RESTORE_SUCCESS:
						case IMB_KEY_STATES.ADD_FAIL:
						case IMB_KEY_STATES.ADDRESS_BUSY:
						case IMB_KEY_STATES.RESTORE_FAIL:
						case IMB_KEY_STATES.NO_ADD:
						case IMB_KEY_STATES.DELETE_FAIL:
						case IMB_KEY_STATES.OPERATION_BREAK:
						
							toBeAdded = null;
							go.disabled( "screen", false );
							go.disabled( "bottom", false );
							
							
							btns[ 1 ].disabled = true;
							
							pseudoPing.stop();
							RequestAssembler.getInstance().doPing( true );
							break;
						case IMB_KEY_STATES.CREATE_AT_BUTTON:

							if( toBeAdded ) 
							{
								flist.removeCustomEl( toBeAdded );
								toBeAdded = null;
							}
							go.disabled( "screen", true );
							go.disabled( "bottom", true );
							
							btns[ 1 ].disabled = true;
							
							GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.onNeedChangeLabel, { getData:{ labelnum:2, label:LABEL_MENU_BUSY_DEVICE }} ) );
							RequestAssembler.getInstance().doPing( false );
							pseudoPing.repeat();
							break;
						
						
					}
					
								
					flist.put( p, false );
					
					if( !flist.getAvailableStructure() ) btns[ 0 ].disabled = true;
					
					ResizeWatcher.doResizeMe(this);
					
					break;
					case CMD.LR_DEVICE_LIST_RF_SYSTEM:
					
					
					flist.put( p, true );
					ResizeWatcher.doResizeMe(this);
					go.disabled( "screen", false );
					go.disabled( "bottom", false );
					btns[ 1 ].disabled = true;
					
					if( !flist.getAvailableStructure() ) btns[ 0 ].disabled = true;
					
					loadComplete();
					break;*/
			}
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = flist.getActualHeight();
			var preferredH:int = h - 260;
			var value:int = realH > preferredH ? preferredH : realH;
			flist.height = value;
			
			go.movey("bottom", flist.y + value + 10 );
		}
		
		
		
		private function onAddKey( id:int ):void
		{
			
			
			go.disabled( "screen", true );
			go.disabled( "bottom", true );
			
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_TM_SEARCH, put, 0, [ IMB_KEY_STATES.SEARCH_UP, 0  ], Request.SYSTEM ) );
			
		}
		
		private function onDeleteKey( id:int ):void
		{
			
			
				const id:int = flist.removeCustomEl( selectedLine );
				
				selectedLine = null;
				toBeAdded = null;
				ResizeWatcher.doResizeMe(this);
				btns[ 1 ].disabled = true;
				go.disabled( "screen", true );
				go.disabled( "bottom", true );
				RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_TM_KEY, onLeftKey, id , [ 0,0,0,0,0,0,0,0,0,0 ], Request.SYSTEM ) );
			
		}
		
		private function onLeftKey( p:Package ):void
		{
			go.disabled( "screen", false );
			go.disabled( "bottom", false );
			btns[ 1 ].disabled = true;
			
		}
		
		private function addButton(ttl:String, xpos:int, handler:Function ):void
		{
			if (!btns)
				btns = new Vector.<TextButton>;
			var i:int = btns.length;
			btns.push( new TextButton );
			addChild( btns[i] );
			btns[i].x = xpos;
			btns[i].y = globalY;
			btns[i].setUp(ttl, handler,i);
			
			go.add( "bottom", btns[i] );
		}
		
		private function onSelect( idOpt:int ):void
		{
			
			selectedLine = flist.getLine( idOpt ) as OptImbKeys;
			if( !toBeAdded || toBeAdded.state != IMB_KEY_STATES.ON_SEARCH  ) btns[ 1 ].disabled = false;
			/// Для ситуаций когда фокус перешел на поле которое не должно получать фокус
			/// например удаленное поле, которое можно только восстановить
			/*if( idOpt == -1 )
			{
				selectedLine = null;
				btns[ 1 ].disabled = true;
				
			}
			else 
			{
				selectedLine = null;
				const line:OptImbKeys = flist.getLine( idOpt ) as OptImbKeys;
				if( 
					line.state == IMB_KEY_STATES.DELETE_FAIL
					|| line.state == IMB_KEY_STATES.DELETE_SUCCESS
					
					)
					btns[ 1 ].disabled = true;
				else
				{
					
				}
			}*/
			
			
		}
		
		protected function onBlockNavigation(event:SystemEvents):void
		{
			
			if( event.serviceObject.isBlock == false && ( toBeAdded && toBeAdded.state == IMB_KEY_STATES.ALL_CANCEL ) ) btns[ 0 ].disabled = false;
			
		}
				
	
	}
}

