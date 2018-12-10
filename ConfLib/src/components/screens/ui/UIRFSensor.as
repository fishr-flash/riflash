package components.screens.ui
{
	import flash.text.TextFormat;
	
	import components.abstract.GroupOperator;
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.RFSensorServant;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.RFSensorEvents;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.visual.Separator;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptRFSensor;
	import components.static.CMD;
	import components.static.DS;
	import components.static.RF_FUNCT;
	import components.static.RF_STATE;
	import components.system.UTIL;
	
	public class UIRFSensor extends UI_BaseComponent implements IResizeDependant
	{
		private var fsAlarmMsg:FSComboBox;
		private var lastState:Array;			// сохранение последнего валидного стейта
		private var _lastActionStructure:int;	// сохранение последней структуры при добавлении, чтобы иметь возможность среагировать на "устройство уже есть в системе"
		private var needDefaults:Boolean = false;	// флаг который устанавливается при получении стейта SUCCESS чтобы проверить применить дефолты
		private var header:Header;
		private var globalResizeShift:int;
		private var screenWidth:int;
		
		private var _slctKeyMode:FSRadioGroup;
		
		private var _gr:GroupOperator;
		
		public function set lastActionStructure(value:int):void
		{
			_lastActionStructure = value;
		}
		public function get lastActionStructure():int
		{
			return _lastActionStructure;
		}
		
		public function UIRFSensor()
		{
			super();
			
			//			header = new Header( [{label:loc("rf_sen_h_num"),align:"center",xpos:5},
			//				{label:loc("rf_sen_h_zone"), xpos:-1},
			//				{label:loc("rf_sen_h_type"), align:"center", xpos:15},
			//				{label:loc("rf_sen_zone_type"), align:"center", xpos:44},
			//				{label:loc("rf_sen_h_enter_delay"), xpos:18},
			//				{label:loc("rf_sen_h_part"), xpos:13},
			//				{label:loc("rf_sen_h_event_main"), align:"center", xpos:7},
			//				{label:loc("rf_sen_h_event_add"), xpos:0},
			//				{label:loc("rf_sen_h_transmission_period"), xpos:6}
			//			],{size:11, posRelative:true, align:true, valign:"top"} );
			var prgrsx:int = 3;
			var prgrsw:int = 50;
			header = new Header( [{label:loc("rf_sen_h_num"),align:"center",xpos: prgrsx, width: prgrsw},
				{label:loc("rf_sen_h_zone"), xpos: prgrsx += prgrsw, width: prgrsw = 50},
				{label:loc("rf_sen_h_type"), align:"center", xpos: prgrsx += prgrsw, width: prgrsw = 180},
				{label:loc("rf_sen_zone_type"), align:"center", xpos: prgrsx += prgrsw, width: prgrsw = 100},
				{label:loc("rf_sen_h_enter_delay"), align:"center", xpos: prgrsx += prgrsw, width: prgrsw = 110},
				{label:loc("rf_sen_h_part"), align:"center", xpos: prgrsx += prgrsw, width: prgrsw = 60},
				{label:loc("rf_sen_h_event_main"), align:"center", xpos: prgrsx += prgrsw, width: prgrsw = 200},
				{label:loc("rf_sen_h_event_add"), align:"center", xpos: prgrsx += prgrsw, width: prgrsw = 200},
				{label:loc("rf_sen_h_transmission_period"), align:"center", xpos: prgrsx += prgrsw }
			],{size:11, align:true, valign:"top"} );
			addChild( header );
			
			header.y = 10;
			
			_gr = new GroupOperator();
			
			
			fsAlarmMsg = new FSComboBox;
			addChild( fsAlarmMsg );
			fsAlarmMsg.setName( loc("rf_sen_transmission_period_for_new_sen") );
			fsAlarmMsg.setWidth( 480 );
			fsAlarmMsg.setCellWidth( 50 );
			fsAlarmMsg.setList( UTIL.getComboBoxList([5, 10, 60, 100]) );
			fsAlarmMsg.y = 290;
			fsAlarmMsg.x = globalX;
			fsAlarmMsg.restrict("0-9",3);
			fsAlarmMsg.rule = new RegExp(RegExpCollection.REF_2to255);//"^(([5-9]|[1-9]\\d|1\\d\\d)|(2[0-4]\\d)|(25[0-5]))$");
			fsAlarmMsg.focusgroup = 11000;
			_gr.add( "opts", fsAlarmMsg );
			
			const sep:Separator = drawSeparator( 950 );
			sep.y = 340;
			_gr.add( "opts", sep );
			
			if( !DS.isfam( DS.K16 ) || ( DS.isfam( DS.K14 ) && DS.release > 22 ) )
			{
				
				
				const lblMngKeyZone:SimpleTextField = new SimpleTextField( loc( "lbl_mng_of_keyzone", true ) );
				addChild( lblMngKeyZone ).y = 360
				lblMngKeyZone.x = globalX;
				lblMngKeyZone.setTextFormat( new TextFormat( null, null, null, true ) );
				lblMngKeyZone.width = 350;
				_gr.add( "opts", lblMngKeyZone );
				_gr.add( "mKeyzone", lblMngKeyZone );
				
				
				_slctKeyMode = new FSRadioGroup( [ {label:loc("on_protect_when_cable_fault"), selected:false, id:0x00 },
					{label:loc("on_protect_of_change_state"), selected:false, id:0x01 }], 1, 30 );
				_slctKeyMode.y = 410;
				_slctKeyMode.x = globalX;
				_slctKeyMode.width = 517;
				addChild( _slctKeyMode );
				addUIElement( _slctKeyMode, CMD.RF_SENSOR_KEY_ZONE, 1);
				
				_gr.add( "opts", _slctKeyMode );
				_gr.add( "mKeyzone", _slctKeyMode );
				_gr.visible( "mKeyzone", false );		
			}
			
			
			list = new OptList;
			addChild( list );
			list.attune( CMD.RF_SENSOR, 1, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED | OptList.PARAM_ENABLER_IS_SWITCH, {funcOperator:callFunct} );
			list.y = 80;
			list.buttonsExistance(true,true,false);
			list.overrideGetFirstFreeLineExt = getFirstFreeLineExt;
			list.overrideIsMaxLines = isMaxLines;
			
			switch(LOC.language) {
				case LOC.RU:
					screenWidth = 980;
					break;
				case LOC.EN:
					screenWidth = 1000;
					break;
				case LOC.IT:
					screenWidth = 1020;
					break;
			}
			
			width = screenWidth;
			
			//GUIEventDispatcher.getInstance().addEventListener( GUIEvents.SELECT_ZONE_AS_KEY, chChanged );
			starterCMD = [  CMD.RF_SENSOR ];
			if( !DS.isfam( DS.K16 ) || ( DS.isfam( DS.K14 ) && DS.release > 22 ) )
				starterRefine( CMD.RF_SENSOR_KEY_ZONE, true );
			
			RFSensorServant.getInst().addEventListener( RFSensorEvents.REQUEST, onRequest );
		}
		
		
		override public function open():void
		{
			super.open();
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.SELECT_ZONE_AS_KEY, chChanged );
		}
		override public function close():void
		{
			ResizeWatcher.removeDependent( this );
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.SELECT_ZONE_AS_KEY, chChanged );
			super.close();
		}
		override public function put(p:Package):void
		{
			
			// необходимо убедиться, что RF_SENSOR_TIME загружен
			if (p.cmd == CMD.RF_SENSOR_KEY_ZONE) 
			{
				pdistribute( p );	
			}
			else if (p.cmd == CMD.RF_SENSOR) {
				if( OPERATOR.dataModel.getData(CMD.RF_SENSOR_TIME) == null && !DS.isfam( DS.K15 ) )
				{
					RequestAssembler.getInstance().fireEvent( new Request(CMD.RF_SENSOR_TIME, put));
				}
				else
					loadPage(p);
			} else
				loadPage(p);
		}
		private function visSensorTime(on:Boolean):void
		{
			header.vis( 8, !on );
			
			fsAlarmMsg.visible = !on;
			width = on ? 910 : screenWidth;
			globalResizeShift = on ? 80 : 130;
			list.width = on ? 960 : 1045;
		}
		private function loadPage(p:Package):void
		{
			if( !DS.isfam( DS.K15 ) )
				visSensorTime( OPERATOR.dataModel.getData(CMD.RF_SENSOR_TIME)[0][0] == UIRadioSystem.sensortime_active );
			else
				visSensorTime( false );
			
			RFSensorServant.PARTITION_LIST = PartitionServant.getPartitionList();
			if( PartitionServant.getPartiton(RFSensorServant.LAST_VALID_PARTITION) == null )
				RFSensorServant.LAST_VALID_PARTITION = PartitionServant.getFirstPartition();
			
			
			var sen:Array  = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			var len:int = sen.length;
			for (var i:int=0; i<len; ++i) {
				if (sen[i][0] == 1 || sen[i][0] == 2)
					RFSensorServant.setZone( i+1, sen[i][1] );
				RFSensorServant.setLost(i+1, Boolean(sen[i][0] == 2) );
				RFSensorServant.setState( i+1, getState( int(sen[i][0]), RFSensorServant.getState(i+1) ));
			}
			
			onRefresh(p);
			initSpamTimer( CMD.RF_STATE );
			ResizeWatcher.addDependent( this );
			
			fsAlarmMsg.setCellInfo( RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM );
			
			
			
			jumperBlock(CLIENT.JUMPER_BLOCK);
			
			loadComplete();
			function getState(param1:int, lastStatus:int):int
			{
				if (param1 == 0 && lastStatus == RF_STATE.DELETED )
					return RF_STATE.DELETED;
				return RF_STATE.NO;
			}
			
			
			
			
		}
		
		/****	GEAR			*********************************/
		
		private function doWaitForState(b:Boolean):void
		{
			
			RFSensorServant.WAIT_FOR_STATE = b;
			blockNavi = b;
			buttonsEnabler();
		}
		private function buttonsEnabler():void
		{
			var params:Object = 
				{
					"WAIT_FOR_STATE":RFSensorServant.WAIT_FOR_STATE,
						"CLIENT.JUMPER_BLOCK":CLIENT.JUMPER_BLOCK
						//	"UTIL.isCSD":UTIL.isCSD()
				}
			
			list.ADD_BUSY = RFSensorServant.WAIT_FOR_STATE || CLIENT.JUMPER_BLOCK;
			//list.ADD_BUSY = RFSensorServant.WAIT_FOR_STATE || CLIENT.JUMPER_BLOCK || UTIL.isCSD();
			list.REMOVE_BUSY = RFSensorServant.WAIT_FOR_STATE;
			//list.disabled = ( RFSensorServant.WAIT_FOR_STATE );
			
			fsAlarmMsg.disabled = RFSensorServant.WAIT_FOR_STATE;
		}
		private function isStateValid(a:Array):Boolean
		{	// проверка пришедшего стейта на валидность и не повтор
			if (a[0] == 0 && a[1] == 0 && a[2] == 0 )
				return false;
			if (lastState && a[0] == lastState[0] && a[1] == lastState[1] && a[2] == lastState[2] )
				return false;
			lastState = a;
			return true
		}
		private function functManager(data:Array, delegate:Function=null):void
		{
			if (!RFSensorServant.WAIT_FOR_STATE || isException(data[2]) ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_FUNCT, delegate, 1, data ));
				doWaitForState(true);
			}
			function isException(funct:int):Boolean
			{	// описывает все исключительные ситуации при которых разрешается отсылать RF_FUNCT во время WAIT_FOR_STATE
				switch(funct) {
					case RF_FUNCT.DO_CANCEL:
						return true;
				}
				return false;
			}
		}
		public function isMaxLines():Boolean
		{
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if( a[i][0] != 1 )
					return false;
			}
			return true;
		}
		private function getFirstFreeSlot():int
		{	// эмуляция перебора прибора - игнорируется все кроме датчика с 1
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if (a[i][0] != 1)
					return i+1;
			}
			return 0;
		}
		private function getFirstFreeLineExt():int
		{
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			
			// если вдруг выделенная строка содержит удаленный датчик
			var i:int;
			var len:int;
			lastActionStructure = 0;
			
			if( list.selectedLine > 0 && (RFSensorServant.getState(list.selectedLine) == 10 || RFSensorServant.getLost(list.selectedLine)) ) {
				len = list.selectedLine-1;
				lastActionStructure = list.selectedLine;
				for ( i=0; i<len; ++i) {
					if( a[i][0] != 1 && a[i][0] != 2 && RFSensorServant.getState(i+1) != 10 ) {
						lastActionStructure = i+1;
						break;
					}
				}
			}
			
			if (lastActionStructure == 0) {
				len = a.length;
				// проход по свободным местам
				for ( i=0; i<len; ++i) {
					if( a[i][0] != 1 && a[i][0] != 2 && RFSensorServant.getState(i+1) != 10 ) {
						lastActionStructure = i+1;
						break;
					}
				}
			}
			if (lastActionStructure == 0) {
				// проход по своодным местам и старым датчикам
				for (i=0; i<len; ++i) {
					if( a[i][0] != 1 ) {
						lastActionStructure = i+1;
						break;
					}
				}
			}
			return lastActionStructure;
		}
		
		/**** 	EVENTS			*********************************/
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var prefH:int = h - globalResizeShift;
			var actualH:int = list.getActualHeight()+5;
			if (actualH < prefH)
				prefH = actualH;
			
			list.height = prefH;
			
			var pos:int = list.height + list.y;
			
			
			_gr.movey( "opts", pos );
			
		}
		private function onRequest(e:RFSensorEvents):void
		{
			var type:int=e.getSensorType();
			if (e.getFunctType() == RF_FUNCT.DO_RESTORE)		// нельзя кидать 0xFE при восстановлении
				type = getType(e.getStructure());
			functManager( [type, e.getStructure(), e.getFunctType(), int(fsAlarmMsg.getCellInfo()) ] );
		}
		private function callFunct(struct:int, action:int):void
		{
			var funct_action:int;
			var type:int=RF_FUNCT.TYPE_NEW;
			switch( action ) {
				case OptList.ADD:
					funct_action = RF_FUNCT.DO_ADD;
					// требуется обнулить зону перед началом добавление, чтобы если SUCESS придет без ADDING можно было присвоить рандомно сгенеренную зону
					RFSensorServant.setZone(struct,0);
					break;
				case OptList.REMOVE:
					funct_action = RF_FUNCT.DO_DEL;
					type = getType(struct);
					break;
			}
			functManager( [type,struct,funct_action,int(fsAlarmMsg.getCellInfo())] );
		}
		override protected function processState(p:Package):void 
		{
			super.processState(p);
			if ( isStateValid(p.getStructure()) ) {
				trace( p.getStructure()[0]+" " +p.getStructure()[1]+" "+p.getStructure()[2] )
				if (getStatus() != RF_STATE.ADDING) {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_STATE, null, 1, [0,0,0] ));
					lastState = null;
				} else
					lastState = p.getStructure();
				var opt:OptRFSensor;
				
				// если пришел статус не добавление то скорее всего надо занулять номер структуры "добавляемого" датчика
				if ( doSetToZero(getStatus()) )
					lastActionStructure = 0;
				
				var st:int = getStatus();
				
				// устройство уже есть в радиосистеме приходится обрабатывать отдельно от других - у него структура ссылается на то утсройство которое есть
				switch( getStatus() ) {
					case RF_STATE.ALREADYEXIST:
						// исключение: массив зон используется для отображения номера датчика который уже есть в системе
						if( lastActionStructure > 0 ) { 
							RFSensorServant.setZone(lastActionStructure,getStruct());
							RFSensorServant.setState(lastActionStructure,getStatus());
						} else {
							var firstFreeSlot:int = getFirstFreeSlot();
							if ( firstFreeSlot>0 ) {
								RFSensorServant.setZone(firstFreeSlot,getStruct());
								RFSensorServant.setState(firstFreeSlot,getStatus());
							}
						}
						break;
					case RF_STATE.JUMPER_ON:
					case RF_STATE.JUMPERBLOCK:
					case RF_STATE.JUMPER_OFF:
						// стейты не для датчиков, не реагировать
						break;
					default:
						RFSensorServant.setState(getStruct(),getStatus());
						break;
				}
				
				switch( getStatus() ) {
					case RF_STATE.ADDING:
						doWaitForState(true);
						onRefresh(null, getStruct());
						break;
					case RF_STATE.SUCCESS:
						// если не было нажато добавление и не поймана перемычка
						if (!RFSensorServant.WAIT_FOR_STATE && !CLIENT.JUMPER_BLOCK) {
							RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, put ));
							CLIENT.JUMPER_BLOCK = true;
							break;
						}
						if( !CLIENT.JUMPER_BLOCK )
							needDefaults = true;
						checkOldies();
					case RF_STATE.RESTORE_SUCCESS:
						RFSensorServant.setState(getStruct(),0);
					case RF_STATE.DELETED:
						if (RFSensorServant.getLost(getStruct()) ) {	// если датчк потерян - надо его удалить насовсем
							RFSensorServant.setLost(getStruct(), false );
							RFSensorServant.setState(getStruct(), RF_STATE.NO);
						}
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, onRefresh, getStruct() ));
						break;
					case RF_STATE.ALREADYEXIST:
					case RF_STATE.CANCELED:
					case RF_STATE.NOTFOUND:
					case RF_STATE.RESTORE_IMPOSSIBLE:
					case RF_STATE.CANNOTADD:
						doWaitForState(false);
						onRefresh(null);
						break;
					case RF_STATE.JUMPER_ON:
					case RF_STATE.JUMPERBLOCK:
						jumperBlock(true);
						doWaitForState(false);
						lastActionStructure = 0;
						break;
					case RF_STATE.JUMPER_OFF:
						jumperBlock(false);
						doWaitForState(false);
						break;
				}
			}
			
			
			
			function getStatus():int
			{
				return p.getStructure()[2];
			}
			function getStruct():int
			{
				return p.getStructure()[1];
			}
			function doSetToZero(v:int):Boolean
			{	// если пришел статус не добавление и не установка перемычки то скорее всего надо занулять номер структуры "добавляемого" датчика
				switch (v) {
					case RF_STATE.ADDING:
					case RF_STATE.JUMPER_ON:
					case RF_STATE.JUMPERBLOCK:
					case RF_STATE.ALREADYEXIST:
						return false;
				}
				return true;
			}
		}
		
		protected function chChanged(event:GUIEvents):void
		{
			
			
			var onKeyZone:Boolean = false;
			
			var len:int = list.getLines().length;
			for (var i:int=0; i<len; i++) {
				if( !onKeyZone && list.getLine( i + 1 ) ) // list.getLine( i + 1 ) может быть пустым при разряженом составе 
					onKeyZone = ( list.getLine( i + 1 ) as OptRFSensor ).isKeyZone;
				if( onKeyZone ) break;
			}
			
			
			
			
			_gr.visible( "mKeyzone", onKeyZone );
		}
		
		private function onRefresh(p:Package, scrollTo:int=0):void
		{
			if (needDefaults) {
				defaults(p);
			} else {
				
				var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR).slice();
				for (var i:int=0; i<32; ++i) {
					if (RFSensorServant.getState(i+1) != RF_STATE.NO ) {
						a[i] = [1,1,0xffff,0,0,0,1,0,0,0];
					}
				}
				
				
				
				list.put( Package.create( a ), OptRFSensor );
				ResizeWatcher.doResizeMe(this);
				
				var selection:int=0;
				if(p) {
					// Перестаем ждать стейт только при реальном ответе с прибора
					doWaitForState(false);
					selection = p.structure;
				} else if ( scrollTo > 0)
					selection = scrollTo;
				// если нужно проскроллить к виновнику экшена и выделить его
				if (selection > 0 )
					callLater(select, [selection]);
				
				//list.disabled = ( false );
			}
			
			
		}
		private function defaults(p:Package):void
		{
			
			
			var def:Array = p.getStructure();
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			
			def[1] = RFSensorServant.getZone(p.structure);
			
			var isZoneVhodnaya:Boolean = false;
			var len:int = a.length;
			var selfCount:Boolean = true;
			
			
			for( var i:int; i<len; ++i ) {
				if ( a[i][0] == 1 ) {
					if ( a[i][2] == RF_FUNCT.TYPE_IOGERKON ||
						a[i][2] == RF_FUNCT.TYPE_IOGERKON_CR2032 || 
						a[i][2] == RF_FUNCT.TYPE_IOOBEMNY ) {
						
						/// не понял о чем это условие
						if ( p.structure != i+1)
							isZoneVhodnaya = true;
					}
					
				}
			}
			
			// дополнительный шлейф
			switch( def[2] ) {
				case RF_FUNCT.TYPE_IPDYMOVOY:
					def[8] = 0x6041;
					break;
				case RF_FUNCT.TYPE_RFRETRANS:
					def[8] = 0x3011;
					break;
				case RF_FUNCT.TYPE_IPR:
				case RF_FUNCT.TYPE_IOGERKON_CR2032:
					//case RF_FUNCT.TYPE_IOOBEMNY:
					def[8] = 0;
					break;
				default:
					def[8] = 0x1301 //1401;
			}
			def[4] = 0;
			if ( def[2] == RF_FUNCT.TYPE_IOGERKON || 
				def[2] == RF_FUNCT.TYPE_IOGERKON_CR2032 || 
				def[2] == RF_FUNCT.TYPE_IOOBEMNY ) {
				// если в системе нет ни одного сенсора нужного типа с входной зоной
				if( !isZoneVhodnaya ) {
					def[3] = CIDServant.ZONE_TYPE_VHODNAYA;
					// Задержка на вход - 30
					def[4] = 30;
				} else { // если входная зона существует
					def[3] = CIDServant.ZONE_TYPE_MGNOVENNAYA;
				}
			}
			else if( def[2] == RF_FUNCT.TYPE_RFRETRANS )
				def[3] = CIDServant.ZONE_TYPE_MGNOVENNAYA;
			
			// если датчик Радиодатчик разбития стекла или пожарные извещатели или ручной 
			if ( def[2] == RF_FUNCT.TYPE_IPGLASSBREAK || 
				def[2] == RF_FUNCT.TYPE_IPDYMOVOY || 
				def[2] == RF_FUNCT.TYPE_IPZATOPLENIYA || 
				def[2] == RF_FUNCT.TYPE_IPR ) {
				def[3] = CIDServant.ZONE_TYPE_24HOURS;
			}
			/*if ( def[2] == RF_FUNCT.TYPE_IPZATOPLENIYA ) {
			def[3] = CIDServant.ZONE_TYPE_MGNOVENNAYA;
			}*/
			
			// Задаем партишн 
			def[5] = RFSensorServant.LAST_VALID_PARTITION;
			def[6] = 0;
			
			// Событие при срабатывании дополнительного шлейфа для всех радиодатчиков устанавливается, по умолчанию, "140.1 Общая тревога";
			def[7] = 0x1401;
			// Событие при срабатывании основной зоны радиодатчика, для типа зоны Входная, "134.1 Тревога:Входная зона";
			if ( def[3] == CIDServant.ZONE_TYPE_VHODNAYA ) { 
				def[7] = 0x1341;
				def[8] = 0x1341;
				// Событие при срабатывании основной зоны радиодатчика, для типа зоны Мгновенная, Проходная - "130.1 Тревога: по зоне"
			} else if ( def[3] == CIDServant.ZONE_TYPE_PROHODNAYA || 
				def[3] == CIDServant.ZONE_TYPE_MGNOVENNAYA ) {
				def[7] = 0x1301;
				
			} else if ( def[3] == CIDServant.ZONE_TYPE_24HOURS ) {
				// Для пожарных извещателей с зоной 24 часа событие - "110.1 Пожарная тревога;
				if ( def[2] == RF_FUNCT.TYPE_IPDYMOVOY || def[2] == RF_FUNCT.TYPE_IPR ) {
					def[7] = 0x1101;
					// Событие от радиодатчика разбития стекла для типа зоны 24 часа - "150.1 Тревога: 24 часовая зона";
				} else if ( def[2] == RF_FUNCT.TYPE_IPGLASSBREAK) {
					def[7] = 0x1311;//1501;					
				}
			}
			
			if ( def[2] == RF_FUNCT.TYPE_IPZATOPLENIYA ) {
				def[7] = 0x1541;
			}
			
			needDefaults = false;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, null, p.structure, def ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, onRefresh, p.structure ));
		}
		
		/**** 	MISC			*********************************/
		private function select(value:int):void
		{
			list.scrollTo(value);
			list.select(value);	
		}
		private function getType(struc:int):int
		{
			return OPERATOR.dataModel.getData(CMD.RF_SENSOR)[struc-1][2];
		}
		private function jumperBlock( value:Boolean ):void
		{
			CLIENT.JUMPER_BLOCK = value;
			if ( value ) {
				changeSecondLabel("("+loc("rfd_jumper_adding")+")");
				if (lastActionStructure>0)
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, onRefresh, lastActionStructure ));
			} else {
				changeSecondLabel("");
			}
		}
		private function checkOldies():void
		{
			var a:Array = OPERATOR.dataModel.getData(CMD.RF_SENSOR);
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if( a[i][0] == 2 )
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, null, i+1 ));
			}
		}
	}
}