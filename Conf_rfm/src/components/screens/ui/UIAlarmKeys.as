package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.LR_AL_KEY_STATES;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.Balloon;
	import components.gui.Header;
	import components.gui.MFlexListAlKey;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptAlKey;
	import components.static.CMD;
	
	public class UIAlarmKeys extends UI_BaseComponent implements IResizeDependant, IWidget
	{
		public static const MAX_COUNT_ALARM_BTNS:int = 32;
		private static const LABEL_MENU_BUSY_DEVICE:String = "    ( " + loc("rfd_adding_via_button") + " )";
		public static var COLOUMN_POSITIONS:Array;
		private var btns:Vector.<TextButton>;
		private var downPing:Boolean;
		
		
		
		
		private var go:GroupOperator;

		private var flist:MFlexListAlKey;
		private var selectedLine:OptAlKey;

		private var toBeAdded:OptAlKey;

		private var pseudoPing:ITask;
		
		
		
		public function UIAlarmKeys()
		{
			super();
			
			toplevel = false;
			
			
			go = new GroupOperator;
			
			
			
			const COLOUMN_MARGIN:int = 20;
			const COLOUMN_WCOUNT:int = 80;
			const COLOUMN_WADDRESS:int = 120;
			const COLOUMN_WSTATE:int = 100;
			const COLOUMN_WTYPE:int = 200;
			const COLOUMN_RESTORE:int = 150;
			const header:Header = new Header
				(
					[
						{ label: loc("rf_sen_h_num"), align: Header.ALIGN_CENTER, xpos:0, width:COLOUMN_WCOUNT },
						{ label: loc("navi_adress"), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN, width:COLOUMN_WADDRESS },
						{ label: loc(""), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN + COLOUMN_WADDRESS + COLOUMN_MARGIN, width:COLOUMN_WSTATE },
						{ label: loc("rf_sen_h_type"), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN +  COLOUMN_WADDRESS + COLOUMN_MARGIN + COLOUMN_WSTATE + COLOUMN_MARGIN, width:COLOUMN_WTYPE },
						{ label: loc(""), align: Header.ALIGN_CENTER, xpos:COLOUMN_WCOUNT + COLOUMN_MARGIN +  COLOUMN_WADDRESS + COLOUMN_MARGIN + COLOUMN_WSTATE + COLOUMN_MARGIN + COLOUMN_WTYPE + COLOUMN_MARGIN, width:COLOUMN_RESTORE }
					]
				);
			
			COLOUMN_POSITIONS = header.coloumnPositions;
			
			this.addChild( header );
			header.y = globalY;
			globalY += header.height+ 40;
			
			//go.add( "screen", getLastElement() );
			flist = new MFlexListAlKey( OptAlKey );
			addChild(flist);
			go.add( "screen", flist );
			flist.height = 350;
			flist.width = MFlexListAlKey.WIDTH_FIELD;
			flist.y = globalY;
			flist.x = globalX;
			flist.cbSelect = onSelect;
			
			go.add( "bottom", drawSeparator( MFlexListAlKey.WIDTH_FIELD ) );
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
			
			WidgetMaster.access().registerWidget( CMD.LR_RF_STATE, this );
			
			ResizeWatcher.addDependent(this);
			starterCMD = [ CMD.LR_DEVICE_LIST_RF_SYSTEM ];
			
		}
		
				
		
		
		
		
		override public function open():void
		{
			toplevel = true;
			super.open();
			WidgetMaster.access().registerWidget( CMD.LR_RF_STATE, this );
			
			pseudoPing = TaskManager.callLater( checkChanell, TaskManager.DELAY_1MIN + TaskManager.DELAY_10SEC );
			pseudoPing.stop();
			
		}
		
		override public function close():void
		{
			toplevel = false;
			super.close();
			WidgetMaster.access().unregisterWidget( CMD.LR_RF_STATE );
			ResizeWatcher.removeDependent(this);
			RequestAssembler.getInstance().doPing( true );
			flist.clearlist();
			pseudoPing.stop();
			pseudoPing.kill();
			pseudoPing = null;
			
			
		}
		
		override public function put(p:Package):void
		{
			
			
			
			switch(p.cmd) {
				
				case CMD.LR_DEVICE_ADD_TO_RF_SYSTEM:
					toBeAdded = flist.add( p, false ) as OptAlKey;
					ResizeWatcher.doResizeMe(this);
					RequestAssembler.getInstance().doPing( false );
					break;
				
				case CMD.LR_DEVICE_RES_FROM_RF_SYSTEM:
				case CMD.LR_DEVICE_BREAK:
					
					
					go.disabled( "screen", true );
					go.disabled( "bottom", true );
					
					
					RequestAssembler.getInstance().doPing( false );
					break;
					
				
				case CMD.LR_RF_STATE:
					
					
					GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.onNeedChangeLabel, { getData:{ labelnum:2, label:"" }} ) );
					
					switch( p.getParamInt( 2 ) )
					{
						case LR_AL_KEY_STATES.RECREATE_AT_BUTTON:
							//// Если повторное добавление идет по кнопке с прибора toBeAdded-а может и не быть
							if( toBeAdded )flist.removeCustomEl( toBeAdded );
							toBeAdded = null;
							
							Balloon.access().show( "sys_attention",loc( "recreate_at_button_baloon" ) +  p.getParam( 1 ) + ""  );
						case LR_AL_KEY_STATES.DELETE_SUCCESS:
							flist.clearDeleted();
						case LR_AL_KEY_STATES.ADDED_SUCCESS:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.LR_DEVICE_LIST_RF_SYSTEM, put ) );
						case LR_AL_KEY_STATES.RESTORE_SUCCESS:
						case LR_AL_KEY_STATES.ADD_FAIL:
						case LR_AL_KEY_STATES.ADDRESS_BUSY:
						case LR_AL_KEY_STATES.RESTORE_FAIL:
						case LR_AL_KEY_STATES.NO_ADD:
						case LR_AL_KEY_STATES.DELETE_FAIL:
						case LR_AL_KEY_STATES.OPERATION_BREAK:
						
							toBeAdded = null;
							go.disabled( "screen", false );
							go.disabled( "bottom", false );
							
							
							btns[ 1 ].disabled = true;
							
							pseudoPing.stop();
							RequestAssembler.getInstance().doPing( true );
							break;
						case LR_AL_KEY_STATES.CREATE_AT_BUTTON:

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
					break;
			}
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = flist.length*34;
			var preferredH:int = h - 260;
			var value:int = realH > preferredH ? preferredH : realH;
			flist.height = value;
			
			go.movey("bottom", flist.y + value + 10 );
		}
		
		/**
		 *  На время работы с бин2 останавливаем пинг, чтобы избежать
		 * конфилкта пакетов. Однако, если пакет не будет получен в
		 * течении 20 секунд, включится обычное пингование,  с тем, чтобы 
		 * установить нет ли разрывов на канале....
		 * 
		 */
		private function checkChanell():void
		{
			pseudoPing.stop();
			RequestAssembler.getInstance().doPing( true );
			
		}
		
		private function onAddKey( id:int ):void
		{
			
			
			go.disabled( "screen", true );
			go.disabled( "bottom", true );
			
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.LR_DEVICE_ADD_TO_RF_SYSTEM, put, 1, [ flist.getAvailableStructure(), 0 ], Request.SYSTEM ) );
			
		}
		
		private function onDeleteKey( id:int ):void
		{
			
			if( 
				selectedLine.state == LR_AL_KEY_STATES.ADD_FAIL
				 || selectedLine.state == LR_AL_KEY_STATES.ADDRESS_BUSY
				 || selectedLine.state == LR_AL_KEY_STATES.RESTORE_FAIL
				 || selectedLine.state == LR_AL_KEY_STATES.NO_ADD
				 || selectedLine.state == LR_AL_KEY_STATES.OPERATION_BREAK
				 || selectedLine.state == LR_AL_KEY_STATES.CREATE_AT_BUTTON
				)
			{
				flist.removeCustomEl( selectedLine );
				selectedLine = null;
				ResizeWatcher.doResizeMe(this);
				btns[ 1 ].disabled = true;
			}
			else
			{
				go.disabled( "screen", true );
				go.disabled( "bottom", true );
				RequestAssembler.getInstance().fireEvent( new Request( CMD.LR_DEVICE_DEL_FROM_RF_SYSTEM, put, 1, [ selectedLine.structure ], Request.SYSTEM ) );
			}
			
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
			
			
			/// Для ситуаций когда фокус перешел на поле которое не должно получать фокус
			/// например удаленное поле, которое можно только восстановить
			if( idOpt == -1 )
			{
				selectedLine = null;
				btns[ 1 ].disabled = true;
				
			}
			else 
			{
				selectedLine = null;
				const line:OptAlKey = flist.getLine( idOpt ) as OptAlKey;
				if( 
					line.state == LR_AL_KEY_STATES.DELETE_FAIL
					|| line.state == LR_AL_KEY_STATES.DELETE_SUCCESS
					
					)
					btns[ 1 ].disabled = true;
				else
				{
					selectedLine = flist.getLine( idOpt ) as OptAlKey;
					btns[ 1 ].disabled = false;
				}
			}
			
			
		}
		
				
	
	}
}

