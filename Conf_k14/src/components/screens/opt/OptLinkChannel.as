package components.screens.opt
{
	import components.abstract.ClientArrays;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSCCBMaximumSelections;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.screens.ui.UILinkChannels;
	import components.static.CMD;
	import components.static.DS;
	import components.system.Controller;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	import su.fishr.utils.Dumper;
	import su.fishr.utils.searcPropValueInArr;
	
	/** Редакция для 7,14 Контакта */
	
	public class OptLinkChannel extends OptionsBlock
	{
		private var rePort:RegExp = new RegExp("^" + RegExpCollection.RE_PORT + "$");
		
		private var hashArrToParam:Object = {0:1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9:10};
		private var hashParamToArr:Object = {1:0,2:1,3:2,4:3,5:4,6:5,7:6,8:7};
		
		private var _slave:Boolean;
		private var _uiDisabled:Boolean;
		
		private var comObj:FSCCBMaximumSelections;
		private var comPart:FSCCBMaximumSelections;
		private var comZone:FSCCBMaximumSelections;
		private var comEvent:FSCCBMaximumSelections;
		
		private var LOADING:Boolean=false;	// если false то будут очищаться поля Телефон/ип адрес при загрузке
		
		private var flagOfBlockForWriting:Boolean;
		private var _enableCallOpts:Boolean = true;
		private var callOpts:Array;

		private var isCall:Boolean;
		
		public function get enableCallOpts():Boolean
		{
			return _enableCallOpts;
		}
		
		public function set enableCallOpts(value:Boolean):void
		{
			
			_enableCallOpts = value;
			
			/// опции Звонок нет в устройствах ниже 13го релиза, поэтому не фильтруем виды каналов на предмет содержания канала Звонок
			if( DS.release < 13 ) return;
			
			var arr:Array;
			if( !callOpts )
			{
				arr = ClientArrays.getComLinkAdapted();
				callOpts = [ arr[ searcPropValueInArr( "data", 25, arr ) ], arr[ searcPropValueInArr( "data", 26, arr ) ] ];
			}
			
			arr = ( getField( CMD.CH_COM_LINK, 5 ) as FSComboBox ).getList();
			
			if( _enableCallOpts )
			{
				if( searcPropValueInArr( "data", 25, arr ) < 0 ) arr.splice( arr.length , 0, callOpts[ 0 ], callOpts[ 1 ] );
			}
			else
			{
				if( searcPropValueInArr( "data", 25, arr ) != -1 )arr.splice( searcPropValueInArr( "data", 25, arr ), 2 );
			}
			
			( getField( CMD.CH_COM_LINK, 5 ) as FSComboBox ).setList(  arr );
			
		}
		
		public function OptLinkChannel(struct:int)
		{
			super();
			
			structureID = struct;
			complexHeight = 25;
			FLAG_VERTICAL_PLACEMENT = false;
			
			/**	Команда CH_COM_LINK - каналы связи, настройка соединения, 8 структур - 8 каналов связи*/
			/**	Параметр 1 - Номер направления ( группировка каналов связи ) */
			createUIElement( new FSShadow, CMD.CH_COM_LINK,"",null,1);
			/**	Параметр 2 - Телефонный номер или IP адрес или доменное имя */
			//createUIElement( new FormString, ProjConst.EVENT_CH_COM_LINK,"",null,2,null,"",63,new RegExp("^" + RE_IP_ADDRESS +"|"+ RE_TEL + "|"+ RE_DOMEN + "$") );
			createUIElement( new FormString, CMD.CH_COM_LINK,"",null,2,null,"",63).x = 210;
			attuneElement( 110,NaN, FormString.F_EDITABLE );
			getLastElement().disabled = true;
			var first:int = (getLastElement() as IFocusable).focusorder;
			(getLastElement() as IFocusable).focusorder++;

			/**	Параметр 3 - Порт для IP или доменного имени */
			
			createUIElement( new FormString, CMD.CH_COM_LINK,"",null,3,null,"0-9",5, rePort ).x = 210+115;
			attuneElement( 50,NaN, FormString.F_EDITABLE );
			(getLastElement() as FormString).hint = loc("g_port");
			getLastElement().disabled = true;
			(getLastElement() as IFocusable).focusorder++;

			/**	Параметр 4 - Пароль пользователя (по умолчанию TestTest) */
			createUIElement( new FormString, CMD.CH_COM_LINK,"",null,4,null,"",20).x = 210+170;
			attuneElement( 80,NaN, FormString.F_EDITABLE );
			(getLastElement() as FormString).hint = loc("");
			getLastElement().disabled = true;
			(getLastElement() as IFocusable).focusorder++;
			
			
			/**	Параметр 5 - Канал связи */
			createUIElement( new FSComboBox, CMD.CH_COM_LINK,"",changeChannel,5,ClientArrays.getComLinkAdapted()).x = 0;
			attuneElement( 200,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			(getLastElement() as IFocusable).focusorder = first;
			//getLastElement().parent.removeChild( getLastElement() );
			
			/**	Параметр 6 - Попытки соединения, 0-постоянно пытаться, 1-255 - количество попыток; */
			createUIElement( new FSComboBox, CMD.CH_COM_LINK,"",null,6,UTIL.comboBoxNumericDataGenerator(1,3)).x = 470;
			attuneElement( 50,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().disabled = true;
			
			/**	Команда CH_COM_OBJ - Фильтр по объектам CID */
			/**	Номер параметра - номер канала связи; */
			/**	Параметр  - номер объекта 0x0001-0xFFFF" */			
			FLAG_SAVABLE = false;
			comObj = createUIElement( new FSCCBMaximumSelections, CMD.CH_COM_OBJ,"",changeObject, getStructure() ) as FSCCBMaximumSelections;
			comObj.x = 530;
			attuneElement( 0,80+16, FSComboCheckBox.F_RETURNS_ARRAY_OF_LABELDATA | FSComboCheckBox.F_RETURNS_BCD_FORMAT,true );
			comObj.AUTOMATED_SAVE = true;
			getLastElement().disabled = true;

			/**	Команда CH_COM_PART */
			/**	Номер параметра - номер канала связи; */
			/** Параметр - Раздел CID */
			comPart = createUIElement( new FSCCBMaximumSelections, CMD.CH_COM_PART,"",changeObject, getStructure() ) as FSCCBMaximumSelections;
			comPart.x = 620+32-16;
			attuneElement( 0,80+32, FSComboCheckBox.F_RETURNS_ARRAY_OF_LABELDATA | FSComboCheckBox.F_RETURNS_BCD_FORMAT,true );
			comPart.AUTOMATED_SAVE = true;
			getLastElement().disabled = true;
			
			/**	Команда CH_COM_ZONE - Фильтр по зонам CID (зоны = датчики, брелоки, клавиатура-пользователи )
			/**	Номер параметра - номер канала связи;
			/**	Параметр - Зона CID ( младшая тетрада свободна, в истории это место занимает контрольная сумма CID ). */													
			comZone = createUIElement( new FSCCBMaximumSelections, CMD.CH_COM_ZONE,"",changeObject, getStructure() ) as FSCCBMaximumSelections;
			comZone.x = 710+64-16;
			attuneElement( 0,80+32+16, FSComboCheckBox.F_RETURNS_ARRAY_OF_LABELDATA,true );
			comZone.AUTOMATED_SAVE = true;
			getLastElement().disabled = true;
			
			/**	Команда CH_COM_EVENT - Фильтр по событиям CID */
			/** Номер параметра - номер канала связи; */

		

		
			/**	Параметр  - тревога/восстановление старшая тетрада, событие CID - остальное. */
			comEvent = createUIElement( new FSCCBMaximumSelections, CMD.CH_COM_EVENT,"",changeObject, getStructure() ) as FSCCBMaximumSelections;
			comEvent.x = 800+96;
			attuneElement( 0,80+32, FSComboCheckBox.F_RETURNS_ARRAY_OF_LABELDATA | FSComboCheckBox.F_RETURNS_FIRST_NIMBLE_FORWARD | FSComboCheckBox.F_RETURNS_BCD_FORMAT, true );
			comEvent.AUTOMATED_SAVE = true;
			comEvent.LABEL_SELECT_ALL = loc("cid_all");
			FLAG_SAVABLE = true;
			getLastElement().disabled = true;
			comEvent.setAdapter( new EventAdapter );
			
			
		}
		public function set maxItems(o:Object):void
		{
			comEvent.MAX_SELECTED_ITEMS = o.event;
			comObj.MAX_SELECTED_ITEMS = o.obj;
			comPart.MAX_SELECTED_ITEMS = o.part;
			comZone.MAX_SELECTED_ITEMS = o.zone;
		}
		public function putAuto(re:Array, cmd:int):Boolean
		{
			
			
			if (cmd == CMD.CH_COM_LINK ) {
				
				
				(getField(CMD.CH_COM_LINK,2) as IFormString).disabled = _uiDisabled && true;
				(getField(CMD.CH_COM_LINK,3) as IFormString).disabled = _uiDisabled && true;
				(getField(CMD.CH_COM_LINK,4) as IFormString).disabled = _uiDisabled && true;
				(getField(CMD.CH_COM_LINK,6) as IFormString).disabled = _uiDisabled && true;
				comEvent.disabled = true;
				comObj.disabled = true;
				comPart.disabled = true;
				comZone.disabled = true;
				
				comObj.setList( Controller.getInstance().getCHObjectCCBList(new Object) );						
				comZone.setList( Controller.getInstance().getCHUserAndDevicesCCBList(new Object) );
				comEvent.setList( Controller.getInstance().getCHEventCCBList(new Object) );
				comPart.setList( Controller.getInstance().getCHPartitionCCBList(new Object) );
				
				
				var len:int = re.length;
				for( var i:int=0; i<len; ++i ) {
					getField( cmd, hashArrToParam[i] ).setCellInfo( String(re[i]) );
				}
				
				uiDisabled(re[hashParamToArr[5]] == 0);
				LOADING = true;
				evaluateConnectParams();	// если бл поставлен телефон а потом сохранено как "не используется", то без этой функции оторажаться будет интернет параметры
				drawTelOrDomen( re[hashParamToArr[5]] );
				LOADING = false;
				
				
				
				/*if( isGprsOnline(re[hashParamToArr[5]]) )
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onGPRSOnline, {"isGPRSOnline":true, "getStructure":getStructure()} );
				else
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onGPRSOnline, {"isGPRSOnline":false, "getStructure":getStructure()} );
				*/
				if( _enableCallOpts == false )enableCallOpts = false;
				
			}
			function evaluateConnectParams():void
			{
				var f2:FormString = getField(CMD.CH_COM_LINK,2) as FormString;
				var f3:FormString = getField(CMD.CH_COM_LINK,3) as FormString;
				var f4:FormString = getField(CMD.CH_COM_LINK,4) as FormString;
				
				if( re[2] == 0 && re[3] == "" ) {
					(f2 as FormString).rule = new RegExp("^" + RegExpCollection.RE_TEL_LC + "$");
					f2.hint = loc("g_tel");
					f2.setWidth(250);
					f3.visible = false;
					f3.rule = null;
					f4.visible = false;
				} else {
					f2.setWidth(110);
					f3.visible = true;
					f4.visible = true;
					f2.rule = new RegExp("^" + RegExpCollection.RE_IP_ADDRESS + "|" + RegExpCollection.RE_DOMEN + "$");
					f2.hint = loc("g_ipdomen");
					f3.hint = loc("g_port");
					f3.rule = rePort;
					f4.hint = loc("g_pass");
				}
			}
			
			return isGprsOnline(re[hashParamToArr[5]]);
		}
		public function putSilent(a:Array):void
		{
			var len:int = a.length;
			for( var i:int=0; i<len; ++i ) {
				getField( CMD.CH_COM_LINK, hashArrToParam[i] ).setCellInfo( String(a[i]) );
			}
		}
		public function isGprsOnline(num:int=-1):Boolean
		{
			if(num==-1)
				num = int((getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo());
				
			switch(num) {
				case 1:		//ContactID GPRS-online SIM1
				case 2:		//ContactID GPRS-online SIM2
				case 11:	//LAN online ContactID
				case 13:	//WIFI online ContactID
				case 100:	//Тест
				case 101:	//Тест
					return true;
			}
			return false;
		}
		public function isWifiOnline():Boolean
		{
			return int((getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo()) == 13;
		}			
		public function isEnabled():Boolean
		{
			return int((getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo()) != 0;
		}
		public function fictiveDispatch():void
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onGPRSOnline, {"isCall":isCall, "isGPRSOnline":true, "getStructure": getStructure()} );
		}
		private function drawTelOrDomen(selection:int):Boolean
		{
			var f2:FormString = getField(CMD.CH_COM_LINK,2) as FormString;
			var f3:FormString = getField(CMD.CH_COM_LINK,3) as FormString;
			var f4:FormString = getField(CMD.CH_COM_LINK,4) as FormString;
			var f6:FSComboBox = getField(CMD.CH_COM_LINK,6) as FSComboBox;
			
			if( selection != 0 ) {	// решение бага когда при отключении с CSD отображается ip
				f2.rule = new RegExp("^" + RegExpCollection.RE_IP_ADDRESS + "|" + RegExpCollection.RE_DOMEN + "$");
				f2.hint = loc("g_ipdomen");
			}
			f3.hint = loc("g_port");
			f3.rule = rePort;
			f4.hint = loc("g_pass");
			uiDisabled(selection == 0);
			f6.disabled = _uiDisabled;
			var isGPRS:Boolean = false;
			isCall = false;
			switch(selection) {
				case 0:		//Канал не используется
					evaluateTelOrDomen();
					break;
				case 1:		//ContactID GPRS-online SIM1
				case 2:		//ContactID GPRS-online SIM2
				case 100:
				case 101:
					isGPRS = true;
					f6.setCellInfo("1");
					f6.disabled = true;
				case 3:		//ContactID GPRS-offline SIM1
				case 4:		//ContactID GPRS-offline SIM2
				case 27:		//ContactID GPRS-offline SIM2
				case 28:		//ContactID GPRS-offline SIM2
					if (!f4.visible)
						clearFields();
					
					f2.setWidth(110);
					f3.visible = true;
					f4.visible = true;
					break;
				case 5:		//SIM1 CSD ContactID через цифровой канал GSM;
				case 6:		//SIM2 CSD ContactID через цифровой канал GSM;
				case 7:		//SIM1 CSD V.32 ContactID через цифровой канал GSM;
				case 8:		//SIM2 CSD V.32 ContactID через цифровой канал GSM;
				case 9:		//SIM1 SMS ContactID;
				case 10:	//SIM2 SMS ContactID;
				case 15:	//Проводная линия длинный DTMF ContactID 
				case 16:	//Проводная линия DTMF ContactID
				case 17:	//SIM1 Текстовое SMS собственнику;
				case 18:	//SIM2 Текстовое SMS собственнику;
				case 19:	//SIM1 Речевое сообщение собственнику
				case 20:	//SIM2 Речевое сообщение собственнику
				case 21:	//SIM1 Голосовой канал GSM длинный DTMF ContactID
				case 22:	//SIM2 Голосовой канал GSM DTMF ContactID
				case 23:	//SIM1 Голосовой канал GSM длинный DTMF ContactID
				case 24:	//SIM2 Голосовой канал GSM DTMF ContactID
				case 25:	//SIM1 Звонок
				case 26:	//SIM2 Звонок
					if (selection == 15 || selection == 16)
						(f2 as FormString).rule = new RegExp("^" + RegExpCollection.RE_TEL_PROVOD + "$");
					else
						(f2 as FormString).rule = new RegExp("^" + RegExpCollection.RE_TEL_LC + "$");
					f2.hint = loc("g_tel");
					f2.setWidth(250);

					if (f4.visible)
						clearFields();
					
					f3.visible = false;
					f3.rule = null;
					f4.visible = false;
					isCall = true;
					break;
				case 11:	//LAN online ContactID;
				case 13:	//WIFI online ContactID;
					isGPRS = true;
					f6.setCellInfo("1");
					f6.disabled = true;
				case 12:	//LAN offline ContactID;
				case 14:	//WIFI offline ContactID
					f2.setWidth(110);
					
					if (!f4.visible)
						clearFields();
					
					f3.visible = true;
					f4.visible = true;
					break;
			}
			f2.isValid();
			f3.isValid();
			f4.isValid();
			return isGPRS;
			
			function clearFields():void
			{
				if (!LOADING) {
					f2.setCellInfo("");
					f3.setCellInfo("");
					f4.setCellInfo("");
				}
			}
			function evaluateTelOrDomen():void
			{
				if (LOADING) {
					var str:String = f2.getCellInfo().toString();
					if (str != "") {
						if (str.search(/\./g) > -1 ) {
							f2.setWidth(110);
							f3.visible = true;
							f4.visible = true;
						} else {
							f2.hint = loc("g_tel");
							f2.setWidth(250);
							f3.visible = false;
							f3.rule = null;
							f4.visible = false;
						}
					}
				}
			}
		}
		private function changeChannel(target:IFormString):void
		{
			var isGPRS:Boolean = drawTelOrDomen( int(target.getCellInfo()) );
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onGPRSOnline, { "isCall":isCall, "isGPRSOnline":isGPRS, "getStructure":getStructure()} );
			SavePerformer.remember( getStructure(), target );
		}
		public function callDataDistributionOnSlaves():void
		{
			changeObject(comObj);
			changeObject(comEvent);
			changeObject(comPart);
			changeObject(comZone);
			
			if( !_enableCallOpts )enableCallOpts = false;
		}
		private function changeObject(target:IFormString):void
		{
			var arr:Array = target.getCellInfo() as Array;
			if(target.cmd == CMD.CH_COM_ZONE) {
				// Превращение с BCD формат со свободной младшей тетрадой + проверка это не ключ 0xFFFF = Все
				if (arr.length > 1 || arr[0] != 0xFFFF ) {
					for(var s:String in arr) {
						arr[s] = int( "0x"+(arr[s] as String).slice()+"0");
						
					}
				}
			}

			
			var maxStruct:int;
			switch(target.cmd) {
				case CMD.CH_COM_OBJ:
					maxStruct = UILinkChannels.CH_INFO_MAXOBJ_LAST_STRUCTURES[getStructure()]//UILinkChannels.CH_INFO_MAXOBJ_LAST;
					break;
				case CMD.CH_COM_ZONE:
					maxStruct = UILinkChannels.CH_INFO_MAXZONE_LAST_STRUCTURES[getStructure()];
					break;
				case CMD.CH_COM_EVENT:
					maxStruct = UILinkChannels.CH_INFO_MAXEVENT_LAST_STRUCTURES[getStructure()];
					break;
				case CMD.CH_COM_PART:
					maxStruct = UILinkChannels.CH_INFO_MAXPART_LAST_STRUCTURES[getStructure()];
					break;
			}
			
			
			while( arr.length < maxStruct) {
				arr.push(0);
			}
			
			
			updateLimits(target.cmd,arr.length);
			
			trace( "OptLinkChannel param: "+getStructure() );
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onChangeObject, {"getData":{"param":getStructure(),"data":arr,"cmd":target.cmd}} );
		}
		public function putAtypicalData(cmd:int,data:Object):void
		{
			switch(cmd) {
				case CMD.CH_COM_OBJ:
					comObj.setList( Controller.getInstance().getCHObjectCCBList(data) );						
					break;
				case CMD.CH_COM_EVENT:
					comEvent.setList( Controller.getInstance().getCHEventCCBList(data) );
					break;
				case CMD.CH_COM_ZONE:
				case CMD.CH_COM_PART:

					var decimal:Object = new Object;
					for( var i:String in data) {
						if ( data[i] is int ) {
							if(cmd==CMD.CH_COM_ZONE)
								decimal[i] = int(data[i]).toString();
							else
								decimal[i] = int((data[i]));
						} else
							decimal[i] = data[i];
					}
					
					switch(cmd) {
						case CMD.CH_COM_ZONE:
							comZone.setList( Controller.getInstance().getCHUserAndDevicesCCBList(decimal) );
							break;
						case CMD.CH_COM_PART:
							comPart.setList( Controller.getInstance().getCHPartitionCCBList(decimal) );
							break;
					}
					break;
			}
			if( data is Array )
				updateLimits(cmd, (data as Array).length ); 
			
			if( !_enableCallOpts )enableCallOpts = false;
			
		}
		private function uiDisabled(value:Boolean):void
		{
			_uiDisabled = value;
			(getField(CMD.CH_COM_LINK,2) as IFormString).disabled = _uiDisabled  || flagOfBlockForWriting;
			(getField(CMD.CH_COM_LINK,3) as IFormString).disabled = _uiDisabled || flagOfBlockForWriting;
			(getField(CMD.CH_COM_LINK,4) as IFormString).disabled = _uiDisabled || flagOfBlockForWriting;
			(getField(CMD.CH_COM_LINK,6) as IFormString).disabled = _uiDisabled;
			cbDisabler();
		}
		public function isUiDisabled():Boolean
		{
			return _uiDisabled;
		}
		private function updateLimits(cmd:int,value:int):void
		{
			switch(cmd) {
				case CMD.CH_COM_OBJ:
					UILinkChannels.CH_INFO_MAXOBJ_LAST_STRUCTURES[getStructure()] = value;
					break;
				case CMD.CH_COM_ZONE:
					UILinkChannels.CH_INFO_MAXZONE_LAST_STRUCTURES[getStructure()] = value;
					break;
				case CMD.CH_COM_EVENT:
					UILinkChannels.CH_INFO_MAXEVENT_LAST_STRUCTURES[getStructure()] = value;
					break;
				case CMD.CH_COM_PART:
					UILinkChannels.CH_INFO_MAXPART_LAST_STRUCTURES[getStructure()] = value;
					break;
			}
		}
		private function cbDisabler():void
		{
			
			var st:int = getStructure();
			comEvent.disabled = slave || _uiDisabled;
			comObj.disabled = slave || _uiDisabled;
			comPart.disabled = slave || _uiDisabled;
			comZone.disabled = slave || _uiDisabled;
			
			
		}
		public function set slave(value:Boolean):void
		{
			_slave = value;
			cbDisabler();		
		}
		public function get slave():Boolean
		{
			return _slave;
		}
		public function get group():String
		{
			return String(getField(CMD.CH_COM_LINK,1).getCellInfo());
		}
		public function get linkData():Vector.<Object>
		{
			var v:Vector.<Object> = new Vector.<Object>;
			for (var i:int=0; i<6; ++i) {
				v.push( getField(CMD.CH_COM_LINK,i+1).getCellInfo() );
			}
			return v;
		}
		public function set linkData(v:Vector.<Object>):void
		{	// порядок - сначала сменить канал, потом заполнить его инфой, а не наоборот
			// инвертировал порядок. Не знаю что будет, но то что правил - работает	12.05.2014
			for (var i:int=0; i<6; ++i) {
				getField(CMD.CH_COM_LINK,i+1).setCellInfo(v[i]);
			}
			LOADING=true;
			drawTelOrDomen( int( v[4] ) );
			LOADING=false;
			(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = isGprsOnline() || _uiDisabled;
		}
		public function setGPRSoffline():void
		{
			var num:int = int((getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo());
			
			
			//var t:int = getStructure();
		//	trace(num);
			switch(num) {
				case 1:		//ContactID GPRS-online SIM1
				case 27:		//SIM1 GPRS-offline ContactID + config.   (только в направлении 1 и только если есть wifi)
					if( (getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo() != "3" )
						SavePerformer.remember( getStructure(), (getField(CMD.CH_COM_LINK,5) as IFormString) );
						
					(getField(CMD.CH_COM_LINK,5) as IFormString).setCellInfo("3"); //ContactID GPRS-offline SIM1
					(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = false;//slave ? true:false;
					break;
				case 2:		//ContactID GPRS-online SIM2
				case 28:		//SIM2 GPRS-offline ContactID + config.   (только в направлении 1 и только если есть wifi)
					
					if( (getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo() != "4" )
						SavePerformer.remember( getStructure(), (getField(CMD.CH_COM_LINK,5) as IFormString) );
					
					(getField(CMD.CH_COM_LINK,5) as IFormString).setCellInfo("4"); //ContactID GPRS-offline SIM2
					(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = false;//slave ? true:false;;
					break;
				case 11:		//ContactID LAN online
					if( (getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo() != "12" )
						SavePerformer.remember( getStructure(), (getField(CMD.CH_COM_LINK,5) as IFormString) );
					
					(getField(CMD.CH_COM_LINK,5) as IFormString).setCellInfo("12"); //ContactID LAN offline
					(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = false;//slave ? true:false;
					break;
				case 13:	//ContactID WIFI online
					if( (getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo() != "14" )
						SavePerformer.remember( getStructure(), (getField(CMD.CH_COM_LINK,5) as IFormString) );
					
					(getField(CMD.CH_COM_LINK,5) as IFormString).setCellInfo("0"); //ContactID WIFI offline
					(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = false;//slave ? true:false;
					break;
			}
			
			removeOnlineOptions();
			
		}
		
		
		public function removeOnlineOptions(  ):void
		{
			var combBox:FSComboBox = getField(CMD.CH_COM_LINK, 5) as FSComboBox;
			var options:Array = combBox.getList();
			
			var sublen:int = ClientArrays.EXCLUDE_OPTIONS.length;
			for (var i:int=0; i<options.length; i++) 
			{
				
				for (var j:int=0; j<sublen; j++) 
				{
					if( options[ i ].data == ClientArrays.EXCLUDE_OPTIONS[ j ].data )
					{
						options.splice( i--, 1 );
						break;
					}
				}
			}
			
			combBox.setList( options );
			/// список опций перенабрали поэтому еще раз исключаем звонки
			if( _enableCallOpts == false )enableCallOpts = false;
		}
		
		public function createOnlineOptions( ):void
		{
			FSComboBox( getField(CMD.CH_COM_LINK, 5) ).setList( ClientArrays.getComLinkAdapted() );
			/// список опций перенабрали поэтому еще раз исключаем звонки
			if( _enableCallOpts == false )enableCallOpts = false;
			
		}
		
		public function onDisableOfBlockWriters( flag:Boolean ):void
		{
			flagOfBlockForWriting = flag;
			getField( CMD.CH_COM_LINK, 1 ).disabled = flag;
			getField( CMD.CH_COM_LINK, 2 ).disabled = flag;
			getField( CMD.CH_COM_LINK, 3 ).disabled = flag;
			getField( CMD.CH_COM_LINK, 4 ).disabled = flag;
			getField( CMD.CH_COM_LINK, 5 ).disabled = flag;
		}
		
		
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class EventAdapter implements IDataAdapter
{
	public function change(value:Object):Object 	{ return value	}
	public function adapt(value:Object):Object
	{
		var s:String = String(value);
		var result:String = "";
		var cid:RegExp = /\d\d\d\d/g;
		while ( cid.test(s) ) {
			s = s.slice(0,cid.lastIndex-1) + "." + s.slice(cid.lastIndex-1);
		}
		return s;
	}
	
	public function perform(field:IFormString):void	{	}
	
	public function recover(value:Object):Object
	{
		return null;
	}
}