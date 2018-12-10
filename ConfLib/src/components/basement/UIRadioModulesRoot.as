package components.basement
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarLabelPlacement;
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.SimpleTextField;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.opt.rf_modules.OptModule;
	import components.static.CMD;
	import components.static.KEYS;
	import components.static.MISC;
	import components.static.PAGE;
	import components.static.RF_FUNCT;
	import components.static.RF_STATE;
	import components.system.SavePerformer;
	import components.system.SysManager;
	
	public class UIRadioModulesRoot extends UI_BaseComponent implements IResizeDependant
	{
		public static const EVENT_LOADED:String = "EVENT_LOADED";
		
		protected var BLOCK_BUTTONS:Boolean=false;	// Когда требуется запретить работу кнопок вне зависимости от чего либо другого, наприме при переключении между девайсами.
		
		protected var label:String = "";
		protected var labelParentPadejM:String;
		protected var labelParentPadejS:String;
		protected var labelParentPadejR:String;
		protected var label_construct:String;
		protected var _label_second_current:String="";
		protected function set label_second_current(value:String):void
		{
			_label_second_current = value;
		}
		protected function get label_second_current():String 
		{
			return _label_second_current;
		}
		
		
		protected var label_jumper:String = "";
		protected var cmd:int;
		protected var deviceType:int;
		protected var devicesValid:Array;
		protected var opt:OptionsBlock;
		protected var LOCALE_NOT_FOUND:String;
		protected var DEVICE_MAX:int;
		protected var state:int = CMD.RF_STATE;
		protected var ISRELE:Boolean = false;
		
		protected var oDevices:Object;
		protected var _currentActionDeviceId:int;
		protected var treeContent:Array;
		
		protected var deletedDevice:Package;
		private var oldies:Vector.<int>;		// Сюда записываются СТРУКТУРЫ а не номера массива датчиков которые были найдены старыми на момент загрузки страницы

		private var tListEmpty:SimpleTextField;
		private var tNoDevices:SimpleTextField;
		protected var tNotify:SimpleTextField;
		protected var bAddDevice:TextButton;
		protected var bRemoveDevice:TextButton;
		protected var bRestoreDevice:TextButton;
		protected var bCancelAdd:TextButton;
		private var sep:Separator;
		private var cont:UIComponent;
		
		protected var WAIT_FOR_STATE:Boolean = false;
		private var IS_ADDING:Boolean = false;
		private var REPLACE_RED:Boolean=false; // если достигнут маскимум устройств и при этом есть красные (==2) то надо замещать красные
		private var REPLACING_NUMBER:int=-1; // указывается место в массиве
		protected var NEED_DEFAULTS:Boolean = false;
		
		private var totalPlaces:int;
		private var progress:ProgressBar;
		protected var forgotten:Sprite;
		protected var fwidth:int;
		protected var fheight:int;
		
		private var FIRST_LOAD:Boolean;	// переменная становится true когда происходит переход на страницу с другой страницы
		private var nonRefundable:Boolean;
		
		/**var 1.4.1
		 * поправил баг с уезжанием меню наверх
		 * ver 1.4
		 * вынес кнопки добавления за скроллинг
		 * ver 1.3.2
		 * добавил пробел в названии девайсов в меню
		 * ver 1.3.1
		 * добавил проверку на валидацию старых "688	navi.resetPermanentSelection(oldies[i]-1);"
		 * ver 1.3
		 * 	визуальная коррекция загрузки: спрятан красный потерянный спрайт, спрятаны до загрузки кнопки меню
		 * 	добавление проверки старых устройств и их удаление если enablerParam прхиодит == 0
		 * ver 1.2
		 * 	attune to new foundation
		 * ver 1.1 bugfix: restore valid data	
		 * 					prevet stage.focus = null when Jumperblock
		 * 					at opening page device alwace == 1
		 * 					defaults only while !jumplerblock */
		
		public function UIRadioModulesRoot()
		{
			super();
			
			aItems = new Array;

			forgotten = new Sprite;
			addChild( forgotten );
			forgotten.y = -8;
			
			
			initNavi();
			navi.setUp( openDevice );
			
			cont = new UIComponent;
			
			sep = new Separator( 150 );
			cont.addChild( sep );
			sep.x = 10;
			
			bAddDevice = new TextButton;
			cont.addChild( bAddDevice );
			bAddDevice.setUp(loc("g_add")+" "+ labelParentPadejR.toLowerCase(), addDevice );
			bAddDevice.setFormat(true, 12);
			bAddDevice.x = 10;
			TabOperator.getInst().add(bAddDevice);
			
			bRemoveDevice = new TextButton;
			cont.addChild( bRemoveDevice );
			bRemoveDevice.setUp(loc("g_remove")+" "+ labelParentPadejR.toLowerCase(), removeDevice );
			bRemoveDevice.setFormat(true, 12);
			bRemoveDevice.x = 10;
			bRemoveDevice.disabled = true;
			TabOperator.getInst().add(bRemoveDevice);
			
			bRestoreDevice = new TextButton;
			cont.addChild( bRestoreDevice );
			bRestoreDevice.setUp(loc("g_cancel_remove"), restoreDevice );
			bRestoreDevice.setFormat(true, 12);
			bRestoreDevice.x = 10;
			bRestoreDevice.disabled = true;
			TabOperator.getInst().add(bRestoreDevice);
			
			globalY = 0;
			
			sep.y = globalY;
			globalY += 10;
			
			bAddDevice.y = globalY;
			globalY += bAddDevice.getHeight(); 
			
			bRemoveDevice.y = globalY;
			globalY += bRemoveDevice.getHeight(); 
			
			bRestoreDevice.y = globalY;
			globalY += bRestoreDevice.getHeight();
			
			cont.height = globalY + 30;
			
			tListEmpty = new SimpleTextField( loc("g_list")+" "+labelParentPadejM.toLowerCase()+"\r"+loc("g_empty")+".", 170);
			tListEmpty.setSimpleFormat( "center", -7 );
			tListEmpty.y = -30;
			cont.addChild( tListEmpty );
			
			MISC.subMenu.addChild(cont);
			
			tNoDevices = new SimpleTextField( locNoDevices(), 400);
			tNoDevices.setSimpleFormat( "center",0,14,true );
			tNoDevices.x = PAGE.CONTENT_LEFT_SUBMENU_SHIFT;
			tNoDevices.y = PAGE.CONTENT_TOP_SHIFT;
			addChild( tNoDevices );
			
			progress = new ProgressBar;
			addChild( progress );
			progress.indeterminate = true;
			progress.labelPlacement = ProgressBarLabelPlacement.LEFT;
			progress.label = loc("rfd_adding")+" "+labelParentPadejS.toLowerCase();
			progress.width = 447;
			progress.height = 15;
			progress.x = 10;
			progress.y = 10;
			progress.visible = false;
			
			bCancelAdd = new TextButton;
			progress.addChild( bCancelAdd );
			bCancelAdd.setUp(loc("rfd_cancel_adding"), cancelAdd );
			bCancelAdd.setFormat(true, 12);
			bCancelAdd.x = 50;
			bCancelAdd.y = 35;
			bCancelAdd.disabled = true;
			TabOperator.getInst().add( bCancelAdd );
			
			//tNotify = new SimpleTextField( label + " номер 2 не найден ", 400);
			tNotify = new SimpleTextField( "", 400);
			tNotify.setSimpleFormat( "center",0,14,true );
			tNotify.wordWrap = true;
			tNotify.x = PAGE.CONTENT_LEFT_SUBMENU_SHIFT;
			tNotify.y = PAGE.CONTENT_TOP_SHIFT;
			tNotify.height = 50;
			addChild( tNotify );
			tNotify.visible = false;
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onSystemChange, systemChange);
			
			opt.addEventListener( EVENT_LOADED, onLoaded );
			
			this.height = fheight;
			this.width = fwidth;
			
			
		}
		override public function open():void
		{
			LOADING = true;
			super.open();
			
			FIRST_LOAD = true;
			
			oldies = new Vector.<int>;
			initSpamTimer( state );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyRestore );
			drawOld();
			forgotten.visible = false;
			
			sep.visible = false;
			bAddDevice.visible = false;
			bRemoveDevice.visible = false;
			bRestoreDevice.visible = false;
			label_second_current = "";
			
			MISC.subMenu.addChild(cont);
			
			
		}
		protected function drawOld():void
		{
			forgotten.graphics.clear();
			forgotten.graphics.beginFill( 0xff0000, 0.2 );
			forgotten.graphics.drawRect( 0,0,fwidth,fheight);
			forgotten.graphics.endFill();
		}
		override public function close():void
		{
			if (!this.visible)
				return;
			super.close();
			
			blockButtons(false);
			
			MISC.subMenu.removeChild(cont);
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyRestore );
			tNotify.visible = false;
			overwriteState();
			ResizeWatcher.removeDependent(this);
		}
		protected function overwriteState():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( state, null, 1,[0,0,0]));
		}
		private function keyRestore(ev:KeyboardEvent):void
		{
			if( ev.keyCode == KEYS.Key_Z && ev.ctrlKey && !bRestoreDevice.disabled )
				restoreDevice();
		}
		private function cancelAdd():void
		{
			if ( WAIT_FOR_STATE && !CLIENT.JUMPER_BLOCK)
				assembleFunct( RF_FUNCT.DO_CANCEL );
		}
		protected function getCont():UIComponent
		{
			return cont;
		}
		protected function cancelSuccess( p:Package ):void
		{
			if ( p.success ) {
				blockNaviSilent = false;
//GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
				bCancelAdd.disabled = true;
				WAIT_FOR_STATE = false;
				buttonsEnabler();
			}
		}
		override public function put(p:Package):void
		{
			
			SavePerformer.LOADING = true;
			opt.visible = false;
			BLOCK_BUTTONS = false;
			jumperBlock( CLIENT.JUMPER_BLOCK );
			
			navi.clear();
			totalPlaces = DEVICE_MAX >= p.length?p.length:DEVICE_MAX;
			oDevices = new Object;
			var len:int = totalPlaces;
			var isNoDeviceInList:Boolean = true;
			
			for(var i:int; i<len; ++i ) {
				if ( isActive( p.data[i][0]) ) {
					isNoDeviceInList = false;
					oDevices[i] = p.data[i];
					if( !treeContent )
						navi.addButton( getConcreteDevType( p.data[i][ 1 ] )+" "+int(i+1), i, i*200 );
					else
						navi.addTree( getConcreteDevType( p.data[i][ 1 ] ) +" " +int(i+1), i, treeContent );
					if (!opt.visible) {
						
						currentActionDeviceId = i; 
						var fake:Package = new Package;
						fake.structure = i+1;
						
						
						fake.data = [p.data[i]];
						fake.cmd = p.cmd;
						openDeviceSuccess(fake);
					}
					if ( p.data[i][0] == 2 ) {
						
						navi.permanentSelection();
						oldies.push(i+1);
					}
				}
			}
			
			navi.selection = opt.getStructure()-1;
			listEmptyVisible = isNoDeviceInList;
			tNoDevices.visible = isNoDeviceInList;
			progress.visible = false;
			//jumperBlock( CLIENT.JUMPER_BLOCK );
			buttonsEnabler();
			
			sep.visible = true;
			bAddDevice.visible = true;
			bRemoveDevice.visible = true;
			bRestoreDevice.visible = true;
			LOADING = false;
			SavePerformer.LOADING = false;
			if( navi.selection < 0 )	// если нет ни одонго элемента для загруки, тогда приходится отсюда флаговать о загрузке иначе это делает загружаемы компонент
				loadComplete();
			ResizeWatcher.addDependent(this);
			
		}
		protected function blockButtons(b:Boolean):void
		{
			BLOCK_BUTTONS = b;
			buttonsEnabler();
		}
		protected function openDevice( _id:Object ):void
		{
			
			opt.loading = true;
			TabOperator.ACTIVE = false;
			callLater(navi.disable, [true]);	// чтобы меню не дисейблилось наполовину
			blockButtons(true);
			RequestAssembler.getInstance().fireEvent( new Request( cmd, openDeviceSuccess, int(_id)+1 ));
			currentActionDeviceId = int(_id);
			blockNaviSilent = true;
			
	//		при первой загрузке не блокируется кнопка перехода по итемам, а ее надо блокировать иначе можно сделать клик на страницу, клик на другой итем, клик на другую страницу
		}
		protected function buttonsEnabler():void 
		{
			var old:Boolean = oldies.indexOf( opt.getStructure() ) > -1;
			/*if( old && )
				oldies.splice( oldies.indexOf( currentActionDeviceId + 1 ), 1 );*/
			//bAddDevice.disabled = WAIT_FOR_STATE || CLIENT.JUMPER_BLOCK || isMaximum() || UTIL.isCSD() || BLOCK_BUTTONS;
			bAddDevice.disabled = WAIT_FOR_STATE || CLIENT.JUMPER_BLOCK || isMaximum() || BLOCK_BUTTONS;
			bRemoveDevice.disabled = WAIT_FOR_STATE || Boolean(navi.selection == -1) || BLOCK_BUTTONS; //Boolean(aDeleteHistory.length == 0) 
			bRestoreDevice.disabled = WAIT_FOR_STATE || Boolean(deletedDevice == null) || isMaximum() || BLOCK_BUTTONS || nonRefundable == true; // Boolean(!(aNeedToSave.length > 0));
			
			bCancelAdd.disabled = !IS_ADDING;
		}
		protected function doState( _value:Boolean, doBlock:Boolean=true ):void
		{
			WAIT_FOR_STATE = _value;
			buttonsEnabler();
			if (doBlock)
				blockNaviSilent = _value;
//GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":_value} );
		}
		private function jumperBlock( value:Boolean, maxDevices:Boolean=false ):void
		{
			trace("CLIENT.JUMPER_BLOCK "+CLIENT.JUMPER_BLOCK + " " +value)
			if( CLIENT.JUMPER_BLOCK != value || LOADING ) {
				if ( value ) {
					SysManager.clearFocus(stage);
					if( maxDevices )
						label_jumper = " <font face='"+PAGE.MAIN_FONT+"' size='17' color='#ff0000'>("+loc("rfd_added_max")+")</font>";
					else
						label_jumper = " ("+loc("rfd_jumper_adding")+")";
				} else {
					WAIT_FOR_STATE = false
					IS_ADDING = false;
					label_jumper = "";
				}
				
				if( opt )changeSecondLabel( ( opt as OptModule ).label + label_jumper );
				CLIENT.JUMPER_BLOCK = value;
				buttonsEnabler();
			}
		}
		protected function openDeviceSuccess( p:Package ):void
		{
			
			
			
			if ( !p.error ) {
				SavePerformer.closePage();
				opt.loading = false;
				oDevices[currentActionDeviceId] = p.getStructure();
				
				var fake:Package = new Package;
				fake.structure = currentActionDeviceId+1;
				fake.data = oDevices[currentActionDeviceId];
				fake.cmd = p.cmd;
				
				opt.putData( fake );
				opt.visible = true;
				tNotify.visible = false;
				forgotten.visible = opt.old;
				
				label_second_current = loc("g_setting")+" "+ ( opt as OptModule ).labelParentPadejS+" "+ (currentActionDeviceId+1);
				changeSecondLabel( loc("navi_tuning")+" "+ ( opt as OptModule ).labelParentPadejS+" "+ (currentActionDeviceId+1) + label_jumper );
				
			}
		}
		private function scrollTo(num:int):void
		{
			MISC.subMenuContainer.verticalScrollPosition = navi.getScrollTo(num);
		}
		
/***********************************************************************
 * 				EVENT SECTION
 * *********************************************************************/
		private function onLoaded(e:Event):void	// сигналит opt когда прогрузит все свои команды
		{
			if (FIRST_LOAD) {
				loadComplete();
				FIRST_LOAD = false;
			} else
				blockNaviSilent = false;
			navi.disable(false);
			blockButtons(false);
			
			ResizeWatcher.doResizeMe(this);
		}
		private function systemChange(ev:GUIEvents):void
		{
			if( deletedDevice )
				deletedDevice = null;
		}
		protected function addDevice( p:Package = null ):void 
		{// если массив !null значит это ответ с сервера, иначе запрос на fireEvent
			systemChange( null );
			
			if ( p ) {
				if ( p.success ) {
					doState( true );
					label_second_current = loc("g_adding")+" "+labelParentPadejS+"...";
				} else if ( p.error ) {
					doState( false );
				}
			} else {
				currentActionDeviceId = getFreeSpaceNumber();
				if ( currentActionDeviceId > -1 ) {
					doState( true );
					navi.disable(true);
					opt.visible = false;
					forgotten.visible = false;
					assembleFunct( RF_FUNCT.DO_ADD );
				} 
			}
		}
		protected function removeDevice( p:Package = null ):void 
		{// если массив !null значит это ответ с сервера, иначе запрос на fireEvent
			if ( p ) {
				if ( p.success ) {
					doState( true );
					label_second_current = loc("g_removing")+" "+labelParentPadejS+"...";
					nonRefundable = oldies.indexOf( int( p.request.data[ 1 ] ) ) > -1;
				} else if ( p.error )
					doState( false );
			} else {
				if ( navi.selection > -1 ) {
					opt.visible = false;
					forgotten.visible = false;
					doState( true );
					navi.disable(true);
					currentActionDeviceId = navi.selection;
					assembleFunct(RF_FUNCT.DO_DEL);
				}
			}
		}
		protected function restoreDevice( p:Package=null):void
		{// если массив !null значит это ответ с сервера, иначе запрос на fireEvent
			if ( !p ) {
				if ( deletedDevice != null ) {
					opt.visible = false;
					forgotten.visible = false;
					doState( true );
					navi.disable(true);
					assembleFunct(RF_FUNCT.DO_RESTORE);
				} 
				bRestoreDevice.disabled = true;
			}
		}
		protected function getStateStatus(re:Array):int
		{
			return re[2];
		}
		protected function isDeviceValid(re:Array):Boolean
		{
			
			return (devicesValid.indexOf( re[0] ) > -1 );
		}
		protected function getStruct(re:Array):int
		{
			return re[1];
		}
		override protected function processState(p:Package):void 
		{
			
			
			if (this.visible) {
				var sel:int;
				var d:String;
				var status:int = getStateStatus(p.getStructure());
				
				
				//super.processState(p);
				super.processState(p);
				// СОбытия перемычки касаются всех радиоустройств
				switch( status ) 
				{
					case 0:
						return;
					case RF_STATE.JUMPERBLOCK:
						doState(false);
					case RF_STATE.JUMPER_ON:
						jumperBlock(true, status == RF_STATE.LACKOFSPACE);
						
						if(!opt.visible && !ISRELE ) {
							sel = -1;
							for( d in oDevices ) {
								openDevice(int(d));
								navi.disable( WAIT_FOR_STATE );
								sel = int(d);
								break;
							}
							navi.selection = sel;
						}
						IS_ADDING = false;
						WAIT_FOR_STATE = false;
						tNotify.visible = false;
						progress.visible = false;
						blockNaviSilent = false;
						return;
					case RF_STATE.JUMPER_OFF:
						jumperBlock(false);
						blockNaviSilent = false;
						return;
				}
				
				if ( CLIENT.JUMPER_BLOCK )
					label_jumper = " ("+loc("rfd_jumper_adding")+")";
				else
					label_jumper = "";
				
				changeSecondLabel( label_second_current + label_jumper);
				
				// Если тип не является заданным основным компонентом
				if ( !isDeviceValid(p.getStructure()) ) 
					return;
				
				navi.disable( WAIT_FOR_STATE );
				
				tNotify.visible = false;
				progress.visible = false;
				var struct:int = getStruct(p.getStructure());
				IS_ADDING = false;
				
				// кнопка добавление не была нажата, выключена перемычка
				if( !CLIENT.JUMPER_BLOCK ) {
					// пришел статус SUCCESS - надо включать перемычку и перечитывать все структуры
					if (status == RF_STATE.SUCCESS && !WAIT_FOR_STATE) {
						overwriteState();	// зануляем
						RequestAssembler.getInstance().fireEvent( new Request( cmd, put ));
						jumperBlock(true);
						return;
					}
					// не реагировать на статусы кроме доабвления и недостаточно места
					if ((status != RF_STATE.ADDING || status != RF_STATE.LACKOFSPACE) && opt.visible )
						return;
				}
				switch( status ) {
					
					case RF_STATE.ADDING:
						label_second_current = loc("g_adding")+" "+labelParentPadejS.toLowerCase()+" "+getStruct(p.getStructure());
						IS_ADDING = true;
						WAIT_FOR_STATE = true;
						
						navi.disable( WAIT_FOR_STATE );
						progress.visible = true;
						TabOperator.getInst().restoreFocus( bCancelAdd );
						progress.label = loc("rfd_adding")+" "+labelParentPadejS.toLowerCase();
						tNoDevices.visible = false;
						opt.visible = false;
						forgotten.visible = false;
						break;
					case RF_STATE.NOTFOUND:
						opt.visible = false;
						navi.selection = -1;
						forgotten.visible = false;
						textVisibility(tNotify);
						tNotify.textColor = 0xff0000;
						tNotify.text = label+" "+loc("g_number")+" "+struct+" "+loc("g_not")+" " +LOCALE_NOT_FOUND +"!";
						doState(false);
						break;
					case RF_STATE.ALREADYEXIST:
						opt.visible = false;
						navi.selection = -1;
						forgotten.visible = false;
						textVisibility(tNotify);
						tNotify.textColor = 0xff0000;
						tNotify.text = label+" "+loc("g_number")+" "+struct+" "+loc("rfd_already_exist_alone");
						doState(false);
						break;
					case RF_STATE.SUCCESS:
						
						
						if ( oDevices[struct-1] == null || ((REPLACE_RED || CLIENT.JUMPER_BLOCK)&& oDevices[struct-1][0] == 2) ) {
							if( CLIENT.JUMPER_BLOCK && oDevices[struct-1] != null && oDevices[struct-1][0] == 2) { 
								navi.removeButton( struct-1 );
								oDevices[struct-1][1];
							} else
								oDevices[struct-1] = [1,0,0,0,0];
							if( !treeContent )
								
								navi.addButton( getConcreteDevType( int( p.getParam( 1 ) ) ) + " " + struct, struct-1, (struct-1)*200  );
							else
								
								navi.addTree( getConcreteDevType( int( p.getParam( 1 ) ) )+ " " + struct, struct-1, treeContent  );
							
							if (REPLACING_NUMBER > -1 && REPLACING_NUMBER != struct-1) {
								delete oDevices[REPLACING_NUMBER];
								navi.removeButton( REPLACING_NUMBER );
								REPLACING_NUMBER=-1;
							}
							
							doState( false );
							
							if( tListEmpty.visible ) { 
								listEmptyVisible = false;
								tNoDevices.visible = false;
							}
							navi.selection = struct-1;
							NEED_DEFAULTS = !CLIENT.JUMPER_BLOCK;
							openDevice( struct-1 );
							validateOld(struct);
							
							callLater( scrollTo, [struct-1] )
							overwriteState();
						}
						break;
					case RF_STATE.CANCELED:
						opt.visible = false;
						navi.selection = -1;
						forgotten.visible = false;
						textVisibility(tNotify);
						tNotify.text = loc("g_adding")+" "+ labelParentPadejS+" "+loc("g_number")+" "+struct+" "+loc("g_cancelled")+"!";
						doState(false);
						break;
					case RF_STATE.CANNOTADD:
					case RF_STATE.ERROR:
						textVisibility(tNotify);
						tNotify.text = loc("rfd_error_add_or_delete")+" "+ labelParentPadejS;
						doState(false);
						break;
					case RF_STATE.DELETED:
						
						if ( oDevices[struct-1] != null ) {
							navi.removeButton( struct-1 );
							
							
							if( oldies.indexOf( opt.getStructure() ) == - 1 ) {
								deletedDevice = new Package;//new S_Structure( struct, oDevices[ struct-1 ] );
								deletedDevice.structure = struct;
								deletedDevice.data = oDevices[ struct-1 ];
							} else
								deleteOld(struct);
	
							delete oDevices[struct-1];
							label_second_current = loc("g_removing")+ " "+labelParentPadejS.toLowerCase()+" "+p.getStructure()[1];
							progress.label = loc("g_performing_remove")+" "+labelParentPadejS.toLowerCase();
							doState( false );
							var isNoDeviceLeft:Boolean = true;
							for( var key:String in oDevices )
								isNoDeviceLeft = false;
	
							listEmptyVisible = isNoDeviceLeft;
							tNoDevices.visible = isNoDeviceLeft;
							if (isNoDeviceLeft) {
								label_second_current = "";
								changeSecondLabel( label_second_current + label_jumper );
							}
							
							if ( opt.getId() == struct -1 ) {
								opt.visible = false;
								forgotten.visible = false;
							}							
							
							sel = -1;
							for( d in oDevices ) {
								openDevice(int(d));
								navi.disable( WAIT_FOR_STATE );
								sel = int(d);
								break;
							}
							navi.selection = sel;
						}
						break;
					case RF_STATE.RESTORE_SUCCESS:
						
						
						if ( !(oDevices[ struct-1 ] is Array) && deletedDevice ) {
							oDevices[ struct-1 ] = deletedDevice.data;
							if( !treeContent )
								navi.addButton(  getConcreteDevType( int( p.getParam( 1 ) ) ) + " " + struct, struct-1, (struct-1)*200 );
							else
								navi.addTree(  getConcreteDevType( int( p.getParam( 1 ) ) ) + " " + struct, struct-1, treeContent );
							
							scrollTo(struct-1);
							doState(false,false);
							
							navi.selection = deletedDevice.structure-1;
							//label_second_current = getSecondLabel();
							label_second_current = loc("g_setting")+" "+ labelParentPadejS+" "+ deletedDevice.structure;
							changeSecondLabel( label_second_current + label_jumper );
							
							if( tListEmpty.visible ) { 
								listEmptyVisible = false;
								tNoDevices.visible = false;
							}
							RequestAssembler.getInstance().fireEvent( new Request( cmd, restoreFromDevice, deletedDevice.structure));
							deletedDevice = null;
							buttonsEnabler();
							opt.visible = true;
							
							ResizeWatcher.doResizeMe(this);
						}
						break;
					case RF_STATE.RESTORE_IMPOSSIBLE:
						opt.visible = false;
						navi.selection = -1;
						navi.disable( false );
						forgotten.visible = false;
						listEmptyVisible = false;
						textVisibility(tNotify);
						tNotify.textColor = 0xff0000;
						tNotify.text = loc("rfd_restore_impossible")+" "+ labelParentPadejR;
						
						deletedDevice = null;
						
						doState(false);
						break;
					case RF_STATE.LACKOFSPACE:
						opt.visible = false;
						navi.selection = -1;
						navi.disable( false );
						forgotten.visible = false;
						listEmptyVisible = false;
						textVisibility(tNotify);
						tNotify.textColor = 0xff0000;
						tNotify.text = loc("rfd_no_space_for_add");
						
						doState(false);
						break;
				}
			}
			if( CLIENT.JUMPER_BLOCK )
				overwriteState();//RequestAssembler.getInstance().fireEvent(new Request(CMD.RF_STATE, null, 1, [0,0,0]));
			bCancelAdd.disabled = !IS_ADDING;
		}
		private function textVisibility(field:SimpleTextField):void
		{
			tNotify.visible = Boolean(field == tNotify);
			tNoDevices.visible = Boolean(field == tNoDevices);
		}
		protected function restoreFromDevice(p:Package):void
		{		
			
			const p:Package = Package.create( p.data[0], p.structure );
			p.cmd = cmd;
			opt.putData( p );
		}
		private function deleteOld(struc:int):void
		{
			if (oldies.length > 0) {
				var len:int = oldies.length;
				for (var i:int=0; i<len; ++i) {
					if ( oldies.length <= i)
						break;
					if ( !oldies[i])
						continue;
					if (oldies[i] == struc)
						oldies.splice(i,1);
				}
			}
		}
		private function validateOld(struc:int):void
		{
			if (oldies.length > 0) {
				var len:int = oldies.length;
				for (var i:int=0; i<len; ++i) {
					if ( oldies.length <= i)
						break;
					if ( !oldies[i])
						continue;
					if (oldies[i] != struc) {
						RequestAssembler.getInstance().fireEvent( new Request(cmd,onGotValidationRequest,oldies[i]));
					} else {
						navi.resetPermanentSelection(oldies[i]-1);
						oldies.splice(i,1);
						
					}
				}
			}
		}
		private function onGotValidationRequest(p:Package):void
		{
			var a:Array = p.getStructure();
			if( a[0] != 2 ) {
				switch(a[0]) {
					case 0:
						navi.removeButton( p.structure-1 );
						break;
					case 1:
						navi.resetPermanentSelection(p.structure-1 );
						break;
				}
				var len:int = oldies.length;
				for (var i:int=0; i<len; ++i) {
					if (oldies[i] == p.structure) {
						oldies.splice(i,1);
						break;
					}
				}
			}
		}
/***********************************************************************
 * 				GET SECTION
 ***********************************************************************/		
		
		protected function getFreeSpaceNumber():int
		{
			for(var i:int=0; i < totalPlaces; ++i ) {
				if ( REPLACE_RED ) {
					// Если пустое место не усовпадает с заменяемым красным девайсом - надо его найти чтобы потом удалить
					if( !(oDevices[i] is Array) ) {
						for(var k:int=i; k < totalPlaces; ++k ) {
							if ( oDevices[k] is Array && oDevices[k][0] == 2 ) {
								REPLACING_NUMBER = k;
								break;
							}
						}
						return i;
					} else if ( oDevices[i][0] == 2 || oDevices[i][0] == 0 || oDevices[i][0] == 0xFF ) {
						return i;
					}
				} else {
					if( !(oDevices[i] is Array) || oDevices[i][0] == 0 || oDevices[i][0] == 0xFF )
						return i;					
				}
			}
			return -1;
		}
		/**
		 *  индекс выбранного устройства
		 */
		protected function set currentActionDeviceId(value:int):void
		{
			_currentActionDeviceId = value;
		}
		
		protected function get currentActionDeviceId():int
		{
			return _currentActionDeviceId;
		}
		protected function isMaximum():Boolean
		{
			var total:int = 0;
			var totalUniversal:int = 0;
			for( var s:String in oDevices ) {
				if( oDevices[s][0] == 1 )
					total++;
				if( oDevices[s][0] == 1 || oDevices[s][0] == 2 )
					totalUniversal++;
			}
			REPLACE_RED = Boolean( totalUniversal >= DEVICE_MAX );
			return total >= DEVICE_MAX;
		}
		
		protected function assembleFunct(action:int):void
		{
			var callFunct:Function;
			var strId:int;
			
			
			switch(action)
			{
				case RF_FUNCT.DO_CANCEL:
					callFunct = cancelSuccess;
					strId = currentActionDeviceId+1;
					
					
					break;
				case RF_FUNCT.DO_ADD:
					callFunct = addDevice;
					strId = currentActionDeviceId+1;
					
					
					break;
				case RF_FUNCT.DO_DEL:
					callFunct = removeDevice;
					strId = navi.selection+1;
					
					
					break;
				case  RF_FUNCT.DO_RESTORE:
					callFunct = restoreDevice;
					strId = deletedDevice.structure;
					
					
					break;
				default:
					
					return;
			}
			
			RequestAssembler.getInstance().fireEvent( 
				new Request( CMD.RF_FUNCT, callFunct, 1, [deviceType, strId,  action,0] ));
		}
		protected function isActive(v:int):Boolean
		{
			return Boolean(v == 1 || v == 2 );
		}
		protected function setDefaults(num:int):void {};
		
		protected function getSecondLabel():String
		{
			return label_construct+ deletedDevice.structure;
		}
		protected function set listEmptyVisible(b:Boolean):void
		{
			tListEmpty.visible = b;
			globalY = b ? 10:-20;	
			
			sep.y = globalY;
			globalY += 10;
			
			bAddDevice.y = globalY;
			globalY += bAddDevice.getHeight(); 
			
			bRemoveDevice.y = globalY;
			globalY += bRemoveDevice.getHeight(); 
			
			bRestoreDevice.y = globalY;
			globalY += bRestoreDevice.getHeight();
			
			cont.height = globalY + 50;
			
			ResizeWatcher.doResizeMe(this);
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			// положение блока с кнопками
			cont.y = h-2;
			// высота контейнера меню минус высота блока с кнопками
			MISC.subMenuContainer.height = h - 92;
			if (cont.y > navi.height + 90 )
				cont.y = navi.height + 90;
			
			this.height = 0;
			manualResize();
			this.height += 20;
		}
		/** LOC	**/
		protected function locNoDevices():String
		{
			return loc("rfd_no_registered")+" "+labelParentPadejM.toLowerCase()+" "+loc("rfd_in_device");
		}
		
		private function getConcreteDevType( id:int ):String
		{
			var type:String = "";
			
			switch( id ) 
			{
				case RF_FUNCT.TYPE_RFRELAY:
					type = loc( "navi_rf_rele" );
				break;
				
				case RF_FUNCT.TYPE_RFSIREN:
					type = loc( "navi_rf_siren" );
				break;
				
				case RF_FUNCT.TYPE_RFBOARD:
					type = loc( "navi_rf_board" );
				break;
				
				default: ///TYPE_RFMODULE
					type = loc( "navi_rf_modules" );
				
				
			}
			
			return type;
		}
		
		
	}
}