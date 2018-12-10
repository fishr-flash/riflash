package components.screens.opt
{
	import components.abstract.ClientArrays;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSComboCheckBoxEditable;
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
	
	import su.fishr.utils.searcPropValueInArr;
	
	/** Редакция для 16 Модема	*/
	
	public class OptLinkChannel extends OptionsBlock
	{
		private var rePort:RegExp = new RegExp("^" + RegExpCollection.RE_PORT + "$");
		
		private var hashArrToParam:Object = {0:1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9:10};
		private var hashParamToArr:Object = {1:0,2:1,3:2,4:3,5:4,6:5,7:6,8:7};
		
		private var _slave:Boolean;
		private var _uiDisabled:Boolean;
		
		private var comObj:FSComboCheckBoxEditable;
		private var comPart:FSComboCheckBoxEditable;
		private var comZone:FSComboCheckBoxEditable;
		private var comEvent:FSComboCheckBox;
		
		private var LOADING:Boolean=false;	// если false то будут очищаться поля Телефон/ип адрес при загрузке
		
		private var flagOfBlockForWriting:Boolean;
		
		public function OptLinkChannel(struct:int)
		{
			super();
			
			structureID = struct;
			FLAG_VERTICAL_PLACEMENT = false;
			complexHeight = 25;
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0,structureID.toString(),null,1);
			FLAG_SAVABLE = true;
			var shift:int = 30;
			
			/**	Команда CH_COM_LINK - каналы связи, настройка соединения, 8 структур - 8 каналов связи*/
			/**	Параметр 1 - Номер направления ( группировка каналов связи ) */
			createUIElement( new FSShadow, CMD.CH_COM_LINK,"",null,1);
			/**	Параметр 2 - Телефонный номер или IP адрес или доменное имя */
			//createUIElement( new FormString, CMD.CH_COM_LINK,"",null,2,null,"",63,new RegExp("^" + RE_IP_ADDRESS +"|"+ RE_TEL + "|"+ RE_DOMEN + "$") );
			createUIElement( new FormString, CMD.CH_COM_LINK,"",null,2,null,"",63).x = shift+210;
			attuneElement( 110,NaN,FormString.F_EDITABLE );
			var first:int = (getLastElement() as IFocusable).focusorder;
			getLastElement().disabled = true;
			(getLastElement() as IFocusable).focusorder++;
			
			/**	Параметр 3 - Порт для IP или доменного имени */
			createUIElement( new FormString, CMD.CH_COM_LINK,"",null,3,null,"0-9",5, rePort).x = 115 + shift+210;
			attuneElement( 50,NaN,FormString.F_EDITABLE );
			(getLastElement() as FormString).hint = loc("g_port");
			getLastElement().disabled = true;
			(getLastElement() as IFocusable).focusorder++;
			
			/**	Параметр 4 - Пароль пользователя (по умолчанию TestTest) */
			createUIElement( new FormString, CMD.CH_COM_LINK,"",null,4,null,"",20).x = 170 + shift+210;
			attuneElement( 80,NaN,FormString.F_EDITABLE );
			(getLastElement() as FormString).hint = loc("g_pass");
			getLastElement().disabled = true;
			(getLastElement() as IFocusable).focusorder++;
			/**	Параметр 5 - Канал связи */
			
			
			var list:Array = ClientArrays.CH_COMLINK_PARAM5_16RT1.slice();
			/**
			 * Удавляем для этого прибора:
			 * "ui_linkch_sim1_gsm_dtmf":"SIM1 Голосовой канал GSM DTMF ContactID",
				"ui_linkch_sim2_gsm_dtmf":"SIM2 Голосовой канал GSM DTMF ContactID",
			 */
			
			if( DS.isDevice( DS.K16_3G ) )
			{
				list.splice( searcPropValueInArr( "data", 23, list ), 2 );
			}
			
			
			createUIElement( new FSComboBox, CMD.CH_COM_LINK,"",changeChannel,5, list).x = shift;
			attuneElement( 200,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			(getLastElement() as IFocusable).focusorder = first;
			
			/**	Параметр 6 - Попытки соединения, 0-постоянно пытаться, 1-255 - количество попыток; */
			createUIElement( new FSComboBox, CMD.CH_COM_LINK,"",null,6,UTIL.comboBoxNumericDataGenerator(1,3)).x = 470 + shift;
			attuneElement( 50,NaN,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().disabled = true;
			
			/**	Команда CH_COM_OBJ - Фильтр по объектам CID */
			/**	Номер параметра - номер канала связи; */
			/**	Параметр  - номер объекта 0x0001-0xFFFF" */			
			FLAG_SAVABLE = false;
			comObj = createUIElement( new FSComboCheckBoxEditable, CMD.CH_COM_OBJ,"",changeObject, getStructure(),
				null, "B-Fb-f0-9 ,",0, new RegExp( RegExpCollection.REF_1toFFFE) ) as FSComboCheckBoxEditable;
			comObj.x = 530 + shift;
			attuneElement( NaN,80+16,
				FSComboCheckBoxEditable.F_RETURNS_ARRAY_OF_LABELDATA | 
				FSComboCheckBoxEditable.F_RETURNS_BCD_FORMAT | 
				FSComboCheckBoxEditable.F_FORMAT_PARTITION_OBJECT,
				true );
			comObj.AUTOMATED_SAVE = true;
			getLastElement().disabled = true;
			
			/**	Команда CH_COM_PART */
			/**	Номер параметра - номер канала связи; */
			/** Параметр - Раздел CID */
			comPart = createUIElement( new FSComboCheckBoxEditable, CMD.CH_COM_PART,"",changeObject, getStructure(),
				null, "0-9 ,",0, new RegExp( RegExpCollection.REF_1to99)) as FSComboCheckBoxEditable;
			comPart.x = 620+32-16 + shift;
			attuneElement( NaN,80+32,
				FSComboCheckBoxEditable.F_RETURNS_ARRAY_OF_LABELDATA |
				FSComboCheckBoxEditable.F_RETURNS_BCD_FORMAT,
				true );
			comPart.AUTOMATED_SAVE = true;
			comPart.SELECT_ALL_KEY = 0xFF;
			getLastElement().disabled = true;
			
			/**	Команда CH_COM_ZONE - Фильтр по зонам CID (зоны = датчики, брелоки, клавиатура-пользователи )
			/**	Номер параметра - номер канала связи;
			/**	Параметр - Зона CID ( младшая тетрада свободна, в истории это место занимает контрольная сумма CID ). */													
			comZone = createUIElement( new FSComboCheckBoxEditable, CMD.CH_COM_ZONE,"",changeObject, getStructure(),
				null, "0-9 ,",0, new RegExp( RegExpCollection.REF_1to999)) as FSComboCheckBoxEditable;
			comZone.x = 710+64-16 + shift;
			attuneElement( NaN,80+32+16, FSComboCheckBoxEditable.F_RETURNS_ARRAY_OF_LABELDATA | FSComboBox.F_CLEAR_BOX_WHEN_DISABLED, true );
			comZone.AUTOMATED_SAVE = true;
			comZone.LABEL_SELECT_ALL = loc("g_all");
			getLastElement().disabled = true;
			
			/**	Команда CH_COM_EVENT - Фильтр по событиям CID */
			/** Номер параметра - номер канала связи; */
			/**	Параметр  - тревога/восстановление старшая тетрада, событие CID - остальное. */
			comEvent = createUIElement( new FSComboCheckBox, CMD.CH_COM_EVENT,"",changeObject, getStructure() ) as FSComboCheckBox;
			comEvent.x = 800+96 + shift;
			
			attuneElement( NaN,80+32,FSComboCheckBox.F_RETURNS_ARRAY_OF_LABELDATA | FSComboCheckBox.F_RETURNS_FIRST_NIMBLE_FORWARD | FSComboCheckBox.F_RETURNS_BCD_FORMAT  ,true );
			comEvent.AUTOMATED_SAVE = true;
			comEvent.LABEL_SELECT_ALL = loc("cid_all");
			getLastElement().disabled = true;
			
			FLAG_SAVABLE = true;
		}
		public function putAuto(re:Array, cmd:int):void
		{
			if (cmd == CMD.CH_COM_LINK ) {
				
				(getField(CMD.CH_COM_LINK,2) as IFormString).disabled = true;
				(getField(CMD.CH_COM_LINK,3) as IFormString).disabled = true;
				(getField(CMD.CH_COM_LINK,4) as IFormString).disabled = true;
				(getField(CMD.CH_COM_LINK,6) as IFormString).disabled = true;
				
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
				
				if( isGprsOnline(re[hashParamToArr[5]]) )
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onGPRSOnline, {"isGPRSOnline":true, "getStructure":getStructure()} );
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
					return true;
			}
			return false;
		}
		public function isEnabled():Boolean
		{
			return int((getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo()) != 0;
		}
		private function drawTelOrDomen(selection:int):Boolean
		{
			var f2:FormString = getField(CMD.CH_COM_LINK,2) as FormString;
			var f3:FormString = getField(CMD.CH_COM_LINK,3) as FormString;
			var f4:FormString = getField(CMD.CH_COM_LINK,4) as FormString;
			var f6:FSComboBox = getField(CMD.CH_COM_LINK,6) as FSComboBox;
			uiDisabled(selection == 0);
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
			
			switch(selection) {
				case 0:		//Канал не используется
					evaluateTelOrDomen();
					break;
				case 1:		//ContactID GPRS-online SIM1
				case 2:		//ContactID GPRS-online SIM2
					isGPRS = true;
					f6.setCellInfo("1");
					f6.disabled = true;
				case 3:		//ContactID GPRS-offline SIM1
				case 4:		//ContactID GPRS-offline SIM2
					/*if (f2.getCellInfo() == "")
						f2.setCellInfo("");
					if (f3.getCellInfo() == "")
						f3.setCellInfo("");
					if (f4.getCellInfo() == "")
						f4.setCellInfo("");*/
					
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
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onGPRSOnline, {"isGPRSOnline":isGPRS, "getStructure":getStructure()} );
			SavePerformer.remember( getStructure(), target );
		}
		public function callDataDistributionOnSlaves():void
		{
			changeObject(comObj);
			changeObject(comEvent);
			changeObject(comPart);
			changeObject(comZone);
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
				case CMD.MODEM_NETWORK_CTRL:
					
					
					
					var list:Array = ClientArrays.CH_COMLINK_PARAM5_16RT1.slice();
					/**
					 * Удавляем для этого прибора:
					 * "ui_linkch_sim1_gsm_dtmf":"SIM1 Голосовой канал GSM DTMF ContactID",
					 "ui_linkch_sim2_gsm_dtmf":"SIM2 Голосовой канал GSM DTMF ContactID",
					 */
					
					list.splice( searcPropValueInArr( "data", 23, list ), 2 );
					
					
					/**
					 * Если MODEM_NETWORK_CTRL не равен GSM 2G удваляем
					 * 	7 - SIM1 CSD V.32 ContactID через цифровой канал GSM;
						8 - SIM2 CSD V.32 ContactID через цифровой канал GSM;
					 */
					if( data[ 0 ][ 0 ] != 1 )list.splice( searcPropValueInArr( "data", 7, list ), 2 );
					( getField( CMD.CH_COM_LINK, 5 ) as FSComboBox ).setList( list );
					break;
				case CMD.CH_COM_ZONE:
				case CMD.CH_COM_PART:

					var decimal:Object = new Object;
					for( var i:String in data) {
						if ( data[i] is int ) {
							if(cmd==CMD.CH_COM_ZONE) {
								decimal[i] = int(data[i]).toString();
							} else
								decimal[i] = int((data[i]).toString(16));
						} else {
							if(cmd==CMD.CH_COM_ZONE) {
								decimal[i] = data[i];;
							} else
								if( data[i] == "255" )
									decimal[i] = data[i];
								else
									decimal[i] = int(data[i]).toString(16);
						}
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
		}
		private function uiDisabled(value:Boolean):void
		{
			_uiDisabled = value;
			(getField(CMD.CH_COM_LINK,2) as IFormString).disabled = value  || flagOfBlockForWriting;
			(getField(CMD.CH_COM_LINK,3) as IFormString).disabled = value  || flagOfBlockForWriting;
			(getField(CMD.CH_COM_LINK,4) as IFormString).disabled = value  || flagOfBlockForWriting;
			(getField(CMD.CH_COM_LINK,6) as IFormString).disabled = value;
			cbDisabler();
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
		}/*
		public function set linkData(v:Vector.<Object>):void
		{	// порядок - сначала сменить канал, потом заполнить его инфой, а не наоборот
			drawTelOrDomen( int( v[4] ) );
			for (var i:int=0; i<6; ++i) {
				getField(CMD.CH_COM_LINK,i+1).setCellInfo(v[i]);
			}
			(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = isGprsOnline();
		}*/
		public function setGPRSoffline():void
		{
			var num:int = int((getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo());
			//var t:int = getStructure();
		//	trace(num);
			switch(num) {
				case 1:		//ContactID GPRS-online SIM1
					if( (getField(CMD.CH_COM_LINK,5) as IFormString).getCellInfo() != "3" )
						SavePerformer.remember( getStructure(), (getField(CMD.CH_COM_LINK,5) as IFormString) );
						
					(getField(CMD.CH_COM_LINK,5) as IFormString).setCellInfo("3"); //ContactID GPRS-offline SIM1
					(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = false;//slave ? true:false;
					break;
				case 2:		//ContactID GPRS-online SIM2
					
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
					
					(getField(CMD.CH_COM_LINK,5) as IFormString).setCellInfo("14"); //ContactID WIFI offline
					(getField(CMD.CH_COM_LINK,6) as FSComboBox).disabled = false;//slave ? true:false;
					break;
			}
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