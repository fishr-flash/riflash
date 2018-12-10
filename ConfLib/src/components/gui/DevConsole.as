package components.gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.text.TextFieldType;
	import flash.utils.ByteArray;
	
	import mx.controls.TextArea;
	import mx.core.ScrollControlBase;
	import mx.core.UIComponent;
	
	import components.abstract.ParsingBot;
	import components.abstract.functions.dtrace;
	import components.gui.debug.BinaryParsingScreen;
	import components.gui.triggers.CMButton;
	import components.gui.triggers.ClrMButton;
	import components.gui.triggers.MButton;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.TunnelOperator;
	import components.protocol.models.BinaryModel;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.KEYS;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.UTIL;
	
	import su.fishr.utils.Dumper;
	
	public class DevConsole extends UIComponent
	{
		public static var MAX_HISTORY_IN_LINE:int = 50;
		private var _onAScroll:Boolean = true;
		
		private var tCmd:SimpleTextField;
		private static var tLog:TextArea;
		private var tTitle:SimpleTextField;
		private var dragTitle:Sprite;
		private var bounds:Rectangle;
		
		public static const SIMPLE:int = 0x00;
		public static const CMD_TO:int = 0x01;
		public static const SYSTEM:int = 0x02;
		public static const ERROR:int = 0x03;
		public static const LIGHT:int = 0x04;
		public static const GARBAGE:int = 0x05;
		public static const BUG:int = 0x06;
		public static const MANUAL:int = 0x07;
		public static const IGNORE:int = 0x08;
		
		//private static var re:RegExp = /(<font)/g;
		//private static var re:RegExp = /(<font id='0')/g;
		private static var re:RegExp = /(<end>)/g;
		private static var log:String = "";
		//private var history:String = "";
		private var so:SharedObject;
		private static var IS_VISIBLE:Boolean=false;
		private static var totalmsg:int;
		
		private var history:Vector.<String>;
		private var history_index:int;
		private var parsingScreen:BinaryParsingScreen;
		private var bClose:MButton;
		private var bClear:MButton;
		private var bK5Stop:MButton;
		private var bAuto:MButton;
		private var btns:Array;
		
		private const commands:Vector.<String> = new <String>["help","getpages","pages",
			"loglen",
			"bin",
			"bout",
			"bytesinrow",
			"getts",
			"timestamp",
			"hideonclick",
			"historydigitalview",
			"doping",
			"resetk9dir",
			"restart",
			"debugkey",
			"activeresponse",
			"sendpacket",
			"sendpacketu",
			"showparsing","sp",
			"showsocketerrors",
			"showvars", "sv",
			"showhttperrors",
			"showlbslog",
			"ignorefielderrors",
			"ipstatus",
			"k1fastload",
			"maxindcmds",
			"maxidleincomplete",
			"maxidlesocket",
			"bufout",
			"bufin",
			"clear","cls",
			"overrideadr",
			"tracehttp",
			"lang"
		];
		
		public static var inst:DevConsole;

		

		
		public function get onAScroll():Boolean
		{
			return _onAScroll;
		}
		
		public function set onAScroll(value:Boolean):void
		{
			if( _onAScroll == value ) return;
			_onAScroll = value;
			
			
			if( _onAScroll )
				bAuto.alpha = .4;
			else 
				bAuto.alpha = 1;
		}
		
		
		public function DevConsole()
		{
			super();

			history = new Vector.<String>;
			
			tCmd = new SimpleTextField("",100);
			tCmd.x = 9;
			tCmd.height = 25;
			tCmd.addEventListener( KeyboardEvent.KEY_DOWN, sendCmd );
			tCmd.background = true;
			tCmd.backgroundColor = COLOR.WHITE;
			tCmd.border = true;
			tCmd.type = TextFieldType.INPUT;
			tCmd.selectable = true;
			tCmd.multiline = false;
			addChild(tCmd);
			
			tLog = new TextArea;
			tLog.tabFocusEnabled = false;
			tLog.tabEnabled = false;
			tLog.x = 9;
			tLog.y = 22;
			tLog.selectable = true;
			tLog.editable = false;
			tLog.addEventListener( "htmlTextChanged", onScroll );
			tLog.addEventListener(TextEvent.LINK, linkHandler);
			tLog.addEventListener(MouseEvent.MOUSE_WHEEL, onStopAutoScroll ); 
			tLog.addEventListener(Event.SCROLL, onStopAutoScroll ); 
			addChild(tLog);
			
			dragTitle = new Sprite;
			addChild( dragTitle );
			
			bounds = new Rectangle(0,0,0,0);
			
			tTitle = new SimpleTextField("Dev console " + MISC.COPY_CLIENT_VERSION + "     Для справки наберите .help			 (Размер консоли можно менять ухватив за вот эту серую полосочку)");
			tTitle.x = 9;
			tTitle.height = 20;
			dragTitle.addChild( tTitle );
			tTitle.addEventListener(MouseEvent.MOUSE_DOWN, mDown );
			
			var r:String = "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH;
			so = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
			if ( so.data["loglen"] != null )
				MISC.DEBUG_MAX_LENGTH = so.data["loglen"];
			else
				so.data["loglen"] = MISC.DEBUG_MAX_LENGTH;
			
			if ( so.data["con_size"] != null )
				MISC.DEBUG_CONSOLE_SIZE = so.data["con_size"];
			else
				so.data["con_size"] = MISC.DEBUG_CONSOLE_SIZE;
			
			if ( so.data["bin"] != null )
				MISC.DEBUG_BIN = so.data["bin"];
			else
				so.data["bin"] = MISC.DEBUG_BIN;
			
			if ( so.data["bout"] != null )
				MISC.DEBUG_BOUT = so.data["bout"];
			else
				so.data["bout"] = MISC.DEBUG_BOUT;
			
			if ( so.data["timestamp"] != null )
				MISC.DEBUG_TIMESTAMP = so.data["timestamp"];
			else
				so.data["timestamp"] = MISC.DEBUG_TIMESTAMP;
			
			if ( so.data["bytesinrow"] != null )
				MISC.DEBUG_BYTESINROW = so.data["bytesinrow"];
			else
				so.data["bytesinrow"] = MISC.DEBUG_BYTESINROW;
			
			if ( so.data["doping"] != null )
				MISC.DEBUG_DO_PING = so.data["doping"];
			else
				so.data["doping"] = MISC.DEBUG_DO_PING;
			
			if ( so.data["showparsing"] != null )
				MISC.DEBUG_SHOW_PARSING = so.data["showparsing"];
			else
				so.data["showparsing"] = MISC.DEBUG_SHOW_PARSING;
			
			if ( so.data["showsocketerrors"] != null )
				MISC.DEBUG_SHOW_SOCKETERRORS = so.data["showsocketerrors"];
			else
				so.data["showsocketerrors"] = MISC.DEBUG_SHOW_SOCKETERRORS;
			
			if ( so.data["hideonclick"] != null )
				MISC.DEBUG_HIDEMENU_ON_CLICK = so.data["hideonclick"];
			else
				so.data["hideonclick"] = MISC.DEBUG_HIDEMENU_ON_CLICK;
			
			if ( so.data["overrideadr"] != null )
				MISC.DEBUG_OVERRIDE_ADR = so.data["overrideadr"];
			else
				so.data["overrideadr"] = MISC.DEBUG_OVERRIDE_ADR;
			
			if ( so.data["tracehttp"] != null )
				MISC.DEBUG_TRACE_HTTP = so.data["tracehttp"];
			else
				so.data["tracehttp"] = MISC.DEBUG_TRACE_HTTP;
			
			if ( so.data["historydigitalview"] != null )
				MISC.DEBUG_HISTORY_DIGITAL_VIEW = so.data["historydigitalview"];
			else
				so.data["historydigitalview"] = MISC.DEBUG_HISTORY_DIGITAL_VIEW;
			
			if ( so.data["k1fastload"] != null )
				MISC.DEBUG_K1_FAST_LOAD = so.data["k1fastload"];
			else
				so.data["k1fastload"] = MISC.DEBUG_K1_FAST_LOAD;

			if ( so.data["showlbslog"] != null )
				MISC.DEBUG_SHOW_LBS_LOG = so.data["showlbslog"];
			else
				so.data["showlbslog"] = MISC.DEBUG_SHOW_LBS_LOG;
			
			if ( so.data["lang"] != null )
				MISC.DEBUG_LANG = so.data["lang"]; 
			else
				so.data["lang"] = MISC.DEBUG_LANG;
			
			
			if (MISC.COPY_DEBUG) {
				if ( so.data["maxidlesocket"] != null )
					CLIENT.TIMER_IDLE = so.data["maxidlesocket"]; 
				else
					so.data["maxidlesocket"] = CLIENT.TIMER_IDLE;
				
				if ( so.data["showhttperrors"] != null )
					MISC.DEBUG_SHOW_HTTPERRORS = so.data["showhttperrors"]; 
				else
					so.data["showhttperrors"] = MISC.DEBUG_SHOW_HTTPERRORS;
			}
			
			flush();
			
			this.visible = false;
			
			this.height = MISC.DEBUG_CONSOLE_SIZE;
			const htmlLblI:String = "<font size='14' color='#666666' ><b>X</b></font>";
			bClose = new MButton("X", close);
			bClose.setHTMLLabel( htmlLblI );
			bClose.x = 9;
			bClose.height = 20;
			dragTitle.addChild( bClose );
			
			const htmlLblII:String = "<font color='#000000' >cls</font>";
			
			bClear = new MButton("cls", clear);
			bClear.setHTMLLabel( htmlLblII );
			bClear.x = 9;
			bClear.height = 20;
			dragTitle.addChild( bClear );
			
			
			const htmlLblIII:String = "<font color='#DD0000' >" + String.fromCharCode( 0x2261 ) + "</font>";
			
			bAuto = new MButton( String.fromCharCode( 0x2261 ) ,  onAuto );
			bAuto.setHTMLLabel( htmlLblIII );
			bAuto.x = 9;
			bAuto.height = 20;
			//bAuto.disabled = true;
			bAuto.alpha = .4;
			dragTitle.addChild( bAuto );
			
			
			
			/*const cLangBtns:CMButton = new CMButton( changeLang );
			cLangBtns.x = 9;
			dragTitle.addChild( cLangBtns );
			*/
			
			btns =
			[
				bClose,
				bAuto,
				bClear
				//cLangBtns
			];
			
			
			
			inst = this;
		}
		
				
				
			
			
		
		

		public function isFocused():Boolean
		{
			if ( stage && stage.focus == tCmd )
				return true;
			return false;
		}
		public function focus():void
		{
			stage.focus = tCmd;
		}
		public static function write( _msg:String, _type:int=0 ):void
		{
			if(tLog) {
				var c:String = COLOR.BLACK.toString(16);
				var before:String = "";
				var after:String = "";
				switch( _type ) {
					case SYSTEM:
						c = COLOR.DEVCONSOLE_SYSTEM_BLUE.toString(16);
						break;
					case CMD_TO:
						c = COLOR.GREEN_SIGNAL.toString(16);
						break;
					case ERROR:
						c = COLOR.PINK_TRACE.toString(16);
						break;
					case LIGHT:
						c = COLOR.LIGHT_GREY.toString(16);
						break;
					case GARBAGE:
						c = COLOR.VIOLET.toString(16);
						before = "GARBAGE \"";
						after = "\"";
						break;
					case IGNORE:
						c = COLOR.GREY_POPUP_OUTLINE.toString(16);
						before = "IGNORE \"";
						after = "\"";
						break;
					case BUG:
						c = COLOR.DEVCONSOLE_BUG.toString(16);
						before = "DEBUG ";
						break;
					case MANUAL:
						c = COLOR.DEVCONSOLE_MANUAL.toString(16);
						before = "MANUAL TEXT RESPONSE:\n";
						_msg = _msg.replace( /\r/g, "" );
						break;
				}
				var ts:String = "> ";
				if (MISC.DEBUG_TIMESTAMP == 1) {
					var d:Date = new Date;
					ts = UTIL.formateZerosInFront(d.hours,2) +":"+
						UTIL.formateZerosInFront(d.minutes,2)+":"+
						UTIL.formateZerosInFront(d.seconds,2)+":"+
						d.milliseconds+"> ";
				}

				log += "<font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + c + "'>" + ts + before + _msg + after + "</font>\n<end>";
				totalmsg++;
				while(totalmsg > MISC.DEBUG_MAX_LENGTH) 
				{
					re.exec(log);
					log = log.slice( re.lastIndex);
					totalmsg--;
					re.lastIndex = 0;
				}
				if (IS_VISIBLE)
					tLog.htmlText = log;
			}
		}
		
		public function changeLang( id:int ):void
		{
			write(cmdParser( [ "lang", id ] ), SYSTEM);
			
			if( ExternalInterface.available )
				ExternalInterface.call( "function(){ location.reload(); }" );
		}
		
		private function onScroll(ev:Event):void
		{
			if( onAScroll )tLog.verticalScrollPosition= tLog.maxVerticalScrollPosition;
		}
		private function sendCmd( ev:KeyboardEvent ):void 
		{
			var cmd:String;
			var len:int;
			var i:int;
			switch(ev.keyCode) {
				case KEYS.Enter:
					if ( tCmd.text == "")
						return;
					history.unshift( tCmd.text );
					history_index = 0;
					if (history.length > MAX_HISTORY_IN_LINE)
						history.length == MAX_HISTORY_IN_LINE;
					
					var iscmd:RegExp = /^((\.\w+)|(\.(\w+)=(-?[A-Za-z,.;"_0-9]+)))$/g;
					var testpText:RegExp = /^(\+\w+\=.+)$/g;
					//var testpBinary:RegExp = /^(80 80 80 ([A-Fa-f0-9 ]){1,})$/g;// /^((80 80 80 )([A-Fa-f0-9]?[A-Fa-f0-9]\s){14,}([A-Fa-f0-9]?[A-Fa-f0-9]))$/g;
					var testpBinary:RegExp = /^(([80\s?]){3,3}([A-Fa-f0-9\s?]){1,})$/g;
					var testForce:RegExp = /^(\/.+)$/;
					
					
					if ( iscmd.test(tCmd.text.toLowerCase() ) ) {
						cmd = (tCmd.text as String).slice(1);
						write(cmdParser( cmd.split("=") ), SYSTEM);
					} else if ( testpText.test(tCmd.text.toLowerCase() ) ) {
						SocketProcessor.getInstance().sendManualRequest( tCmd.text, getResponse );
						write(tCmd.text, CMD_TO);
					} else if ( testpBinary.test(tCmd.text.toLowerCase()) ) {
						//var a:Array = (tCmd.text as String).split(" ");
						var a:Array = (tCmd.text as String).match(/([A-Fa-f0-9]{2}\s?)/g);
						var b:ByteArray = new ByteArray;
						len = a.length;
						for (i=0; i<len; ++i) {
							
							b.writeByte( int("0x"+a[i]) );
						}
						SocketProcessor.getInstance().sendGeneratedRequest( b, getResponse );
						write(tCmd.text, CMD_TO);
					} else if ( testForce.test(tCmd.text.toLowerCase()) ) {
						cmd = (tCmd.text as String).slice(1);
						SocketProcessor.getInstance().sendManualRequest( cmd, getResponse );
						write(cmd, CMD_TO);
					} else {
						write( "Нераспознанный синтаксис. Для справки наберите .help" );// Чтобы принудительно отправить содержимое в сокет, наберите\r \"/"+tCmd.text );
					}
					tCmd.text = "";
					break;
				case KEYS.UpArrow:
					if (history.length > 0) {
						tCmd.text = history[history_index];
						history_index++;
						if (history_index > history.length - 1)
							history_index = history.length-1;
						
						callLater(onChange);
					}
					break;
				case KEYS.DownArrow:
					if (history.length > 0) {
						history_index--;
						if (history_index < 0)
							history_index = 0;
						tCmd.text = history[history_index];
						
						callLater(onChange);
					}
					break;
				case KEYS.Tab:
					var p:String = (tCmd.text as String).replace(".","");
					len = commands.length;
					for (i=0; i<len; ++i) {
						if ( commands[i].search(p) == 0 ) {
							if (p == commands[i])
								tCmd.text = "."+commands[i]+"=";
							else
								tCmd.text = "."+commands[i];
							break;
						}
					}
					callLater( onChange );
					break;
			}
		}
		private function onChange():void
		{
			var pos:int = (tCmd.text as String).length;
			tCmd.setSelection( pos,pos );
		}
		
		private function cmdParser(args:Array):String
		{
			var cmdname:String = args[0].toString().toLowerCase();
			var txt:String = "";
			var value:int=0;
			var params:Array;
			var i:int;
			
			
			var len:int;
			switch(cmdname) {
				case "getpages":
				case "pages":
					if (args[1] == null) {
						var arr:Array = MISC.COPY_MENU;
						txt="Любое число меньше нуля отключает автовход (-1 к примеру)\n";
						for(var k:String in arr ) {
							txt += arr[k].label + ": "+arr[k].data + "\n"; 
						}
					} else {
						so.data["auto_select_page"] = int(args[1]);
						CLIENT.AUTO_SELECT_PAGE = so.data["auto_select_page"]; 
						txt="Автовход: "+so.data["auto_select_page"]+"\n";
					}
					break;
				case "help":
					txt="Синтаксис внутренних команд:\n.имя_команды[=параметры] (пример: .bin=1), " +
						"\nНажатие таба дописывает окончание команды, повторное нажатие дорисовывает \"=\". Автодополнение распознает начало команды и с точкой, и без точки впереди\n"+
					"Список доступных команд " +
					"\n    help - синтаксис и список команд" +
					"\n    getpages/pages [int32]- отображение допустимых страниц и автовход + установка автовхода" +
					"\n    loglen [int]- изменение длины лога дебаг окна" +
					"\n    bin [1/0]- отображение входящего потока" +
					"\n    bout [1/0]- отображение исходящего потока"+
					"\n    bytesinrow [int32]- количество байт отображаемое в одном ряду при отображении любого потока"+
					"\n    timestamp [1/0]- отображение времени рядом с каждой записью в логе"+
					"\n    hideonclick [1/0]- прятать меню настройки по клику или по mouse out"+
					"\n    doping [1/0]- слать команду пинг на прибор"+
					"\n    restart - перезапуск клиента"+
					"\n    debugkey [1/0] - служит для экпорта, 1 - установка ключа, 0 - стирание ключа."+
					"\n    showparsing,sp [0-3]- 0/1 - отображать парсинг ответов от прибора, 2 - включить bin,bout, 3 - выключить bin,bout"+
					"\n    showsocketerrors [1/0]- отображать ошибки коннекта"+
					"\n    showvars, sv - вывести flashvars ( Объект, содержащий пары имен и значений, представляющих параметры для загруженного SWF-файла. )"+
					"\n    ipstatus - вывести информацию о состоянии коннекта клиента"+
					"\n    maxindcmds [byte] - позволяет задать собственное количество индексируемых команд. Не сохраняется при перезапуске"+
					"\n    maxidleincomplete [int32] - позволяет задать таймаут ожидания частей пакета если пришел неполный ответ (мс)"+
					"\n    maxidlesocket [int32] - позволяет задать таймаут ожидания ответа от прибора (мс)"+
					"\n    clear/cls - чистит лог консоли"+
					"\n    overrideadr [1/0]- 1 - использовать всегда 0xFF, 0 - использовать адресацию вычитанную из прибора"+
					"\n    activeresponse [int32] - 1 - отвечать на активные запросы прибора (binary 2)"+
					"\n    bufout [int32] - устанавливает иходящий из прибра буфер на заданное число"+
					"\n    bufin [int32] - устанавливает входящий на прибор буфер на заданное число"+
					"\n    tracehttp [1/0] - отображает исходящие http запросы"+
					"\n    historydigitalview [1/0] - отображает историю Вояджера в виде цифр, без адаптации"+
					"\n    showhttperrors [1/0] - отображать ошибки http-движка"+
					"\n    sendpacket [имя_команды[;структура[;масив для записи через запятую, строки в кавычках]]] - посылает сформированный бинарный пакет, синтаксис:\n"+
					"        пример записи SMS_PART, второй структуры: .sendpacket=SMS_PART;2;2,\"asd\"\n"+
					"        допускаются так же запросы без записи информации или указания структуры\n" +
					"        .sendpacket=SMS_PART;2 - запрос второй структуры, .sendpacket=SMS_PART - запрос всех структур\n" +
					"        просмотр команд на чтение возможен с помощью .sp=1, регистр внутри команд не важен" +
					"\n    ignorefielderrors [1/0] - позволяет сохранять поля с ошибками"+
					"\n    k1fastload [1/0] - 1 игнорирует загрузку параметров и запрос пароля на К1"+
					"\n    showlbslog [1/0] - 1 отображает лог ответа lbs с прибора на странице \"карта\". Требуется рестарт клиента"+
					"\n    getts - отображает статус коннекта Тоннеля обвнолвения"+
					"\n    lang[0,1,2,3] - 0 - дефолт, 1 - ру, 2 - енг, 3 - итал"+
					"\n    resetk9dir - устанавливает все каналы связи К9 в v32 sim2"+
					
					
					"\r"+
					"Синтаксис текстового протокола:\n+\"имя команды\"=\"параметры\"\r"+
					"Синтаксис бинарного протокола:\n\"80 80 80 01 1 1 02\", обязательны пробелы между байтами, посылка должна быть не менее 18 байт\r"+
					"Отослать любою строку не проходящую валидацию на клиенте можно написав вначале /, то есть \"/что угодно\"\n";
					break;
				
				"idletimer"
				"idleincompletetimer"
				"pingtimer"
				
				case "loglen":
					if (args[1]) {
						if (args[1] > 0)
							MISC.DEBUG_MAX_LENGTH = int(args[1]);
						so.data["loglen"] = MISC.DEBUG_MAX_LENGTH;
					}
					txt="Макс. количество записей в логе "+MISC.DEBUG_MAX_LENGTH + "\n";
					break;
				case "bin":
					if (args[1]) {
						MISC.DEBUG_BIN = int(args[1]);
						so.data["bin"] = MISC.DEBUG_BIN;
					}
					txt = "bin="+MISC.DEBUG_BIN;
					break;
				case "bout":
					if (args[1]) {
						MISC.DEBUG_BOUT = int(args[1]);
						so.data["bout"] = MISC.DEBUG_BOUT;
					}
					txt = "bout="+MISC.DEBUG_BOUT;
					break;
				case "bytesinrow":
					if (args[1]) {
						if (args[1] > 0)
							MISC.DEBUG_BYTESINROW = int(args[1]);
						so.data["bytesinrow"] = MISC.DEBUG_BYTESINROW;
					}
					txt = "bytesinrow="+MISC.DEBUG_BYTESINROW;
					break;
				case "timestamp":
					if (args[1]) {
						MISC.DEBUG_TIMESTAMP = int(args[1]);
						so.data["timestamp"] = MISC.DEBUG_TIMESTAMP;
					}
					txt = "timestamp="+MISC.DEBUG_TIMESTAMP;
					break;
				case "hideonclick":
					if (args[1]) {
						MISC.DEBUG_HIDEMENU_ON_CLICK = int(args[1]);
						so.data["hideonclick"] = MISC.DEBUG_HIDEMENU_ON_CLICK;
					}
					txt = "hideonclick="+MISC.DEBUG_HIDEMENU_ON_CLICK;
					break;
				case "doping":
					if (args[1]) {
						MISC.DEBUG_DO_PING = int(args[1]);
						so.data["doping"] = MISC.DEBUG_DO_PING;
						RequestAssembler.getInstance().doPing( Boolean(MISC.DEBUG_DO_PING == 1) );
					}
					txt = "doping="+MISC.DEBUG_DO_PING;
					break;
				case "debugkey":
					var dkey:SharedObject = SharedObject.getLocal( "RITM", "/" );
					if (args[1]) {
						var add:String = "";
						if( int(args[1]) > 0)
							dkey.data["debugkey"] = MISC.DEBUG_KEY;
						else
							delete dkey.data["debugkey"];
					}
					if ( dkey.data["debugkey"] && dkey.data["debugkey"] == MISC.DEBUG_KEY)
						add = ", клиент в режиме экспорта";
					else
						add = ", клиент в обычном режиме";
					txt = "debugkey="+MISC.DEBUG_KEY+add;
					break;
				case "restart":
					SocketProcessor.getInstance().reConnect();
					break;
				case "showparsing":
				case "sp":
					if (args[1]) {
						switch(int(args[1])) {
							case 0:
							case 1:
								MISC.DEBUG_SHOW_PARSING = int(args[1]);
								break;
							case 2:
								MISC.DEBUG_SHOW_PARSING = 1;
								MISC.DEBUG_BIN = 1;
								MISC.DEBUG_BOUT = 1;
								break;
							case 3:
								MISC.DEBUG_SHOW_PARSING = 0;
								MISC.DEBUG_BIN = 0;
								MISC.DEBUG_BOUT = 0;
								break;
						}
						so.data["bin"] = MISC.DEBUG_BIN;
						so.data["bout"] = MISC.DEBUG_BOUT;
						//txt = "bin="+MISC.DEBUG_BIN+", bout="+MISC.DEBUG_BOUT
						so.data["showparsing"] = MISC.DEBUG_SHOW_PARSING;
					}
					txt = "showparsing="+MISC.DEBUG_SHOW_PARSING;
					if (int(args[1]) == 2 || int(args[1]) == 3 ) {
						txt = "showparsing="+MISC.DEBUG_SHOW_PARSING+", bin="+MISC.DEBUG_BIN+", bout="+MISC.DEBUG_BOUT
					}
					break;
				case "showsocketerrors":
					if (args[1]) {
						MISC.DEBUG_SHOW_SOCKETERRORS = int(args[1]);
						so.data["showsocketerrors"] = MISC.DEBUG_SHOW_SOCKETERRORS;
					}
					txt = "showsocketerrors="+MISC.DEBUG_SHOW_SOCKETERRORS;
					break;
				
				case "showvars":
				case "sv":
					txt = getShowVars();
					break;
				case "ipstatus":
					txt = SocketProcessor.getInstance().getstats() + "\n" +
					RequestAssembler.getInstance().getstats()+ "\n";
					MISC.DEBUG_SHOW_SOCKETERRORS = 1;
					break;
				case "maxindcmds":
					if (args[1]) {
						SERVER.TOP_MAX_IND_CMDS = int(args[1]);
						SERVER.BOTTOM_MAX_IND_CMDS = int(args[1]);
					}
					txt = "maxindcmds="+SERVER.MAX_IND_CMDS + " SERVER.TOP_MAX_IND_CMDS="+SERVER.TOP_MAX_IND_CMDS +" SERVER.BOTTOM_MAX_IND_CMDS="+SERVER.BOTTOM_MAX_IND_CMDS;
					break;
				case "maxidleincomplete":
					if (args[1]) {
						CLIENT.TIMER_IDLE_INCOMPLETE = int(args[1]);
					}
					txt = "maxidleincomplete="+CLIENT.TIMER_IDLE_INCOMPLETE;
					break;
				case "maxidlesocket":
					if (args[1]) {
						CLIENT.TIMER_IDLE = int(args[1]);
						so.data["maxidlesocket"] = CLIENT.TIMER_IDLE;
					}
					txt = "maxidlesocket="+CLIENT.TIMER_IDLE;
					break;
				case "clear":
				case "cls":
					
					log = "";
					txt="Лог очищен";
					totalmsg=0;
					break;
				case "overrideadr":
					if (args[1]) {
						MISC.DEBUG_OVERRIDE_ADR = int(args[1]);
						so.data["overrideadr"] = MISC.DEBUG_OVERRIDE_ADR;
					}
					txt = "overrideadr="+MISC.DEBUG_OVERRIDE_ADR;
					break;
				case "activeresponse":
					if (args[1]) {
						MISC.DEBUG_ANSWER_PROTOCOL2 = int(args[1]);
						so.data["activeresponse"] = MISC.DEBUG_ANSWER_PROTOCOL2;
					}
					txt = "activeresponse="+MISC.DEBUG_ANSWER_PROTOCOL2;
					break;
				case "bufout":
					if (args[1]) {
						SERVER.TOP_BUF_SIZE_SEND = int(args[1]);
					}
					txt = "bufout="+SERVER.TOP_BUF_SIZE_SEND;
					break;
				case "bufin":
					if (args[1]) {
						SERVER.TOP_BUF_SIZE_RECEIVE = int(args[1]);
					}
					txt = "bufin="+SERVER.TOP_BUF_SIZE_RECEIVE;
					break;
				case "tracehttp":
					if (args[1]) {
						MISC.DEBUG_TRACE_HTTP = int(args[1]);
						so.data["tracehttp"] = MISC.DEBUG_TRACE_HTTP;
					}
					txt = "tracehttp="+MISC.DEBUG_TRACE_HTTP;
					break;
				case "historydigitalview":
					if (args[1]) {
						MISC.DEBUG_HISTORY_DIGITAL_VIEW= int(args[1]);
						so.data["historydigitalview"] = MISC.DEBUG_HISTORY_DIGITAL_VIEW;
					}
					txt = "historydigitalview="+MISC.DEBUG_HISTORY_DIGITAL_VIEW;
					break;
				case "showhttperrors":
					if (args[1]) {
						MISC.DEBUG_SHOW_HTTPERRORS= int(args[1]);
						so.data["showhttperrors"] = MISC.DEBUG_SHOW_HTTPERRORS;
					}
					txt = "showhttperrors="+MISC.DEBUG_SHOW_HTTPERRORS;
					break;
				case "ignorefielderrors":
					if (args[1]) {
						MISC.DEBUG_IGNORE_FIELD_ERRORS= int(args[1]);
					}
					txt = "ignorefielderrors="+MISC.DEBUG_IGNORE_FIELD_ERRORS;
					break;
				case "k1fastload":
					if (args[1]) {
						MISC.DEBUG_K1_FAST_LOAD= int(args[1]);
						so.data["k1fastload"] = MISC.DEBUG_K1_FAST_LOAD;
					}
					txt = "k1fastload="+MISC.DEBUG_K1_FAST_LOAD;
					break;
				case "lang":
					if (args[1]) {
						MISC.DEBUG_LANG= int(args[1]);
						if (MISC.DEBUG_LANG < 0 || MISC.DEBUG_LANG > 3)
							MISC.DEBUG_LANG=0;
						so.data["lang"] = MISC.DEBUG_LANG;
					}
					switch(MISC.DEBUG_LANG) {
						case 0:
							txt = "язык подгружается по переменной (lang="+MISC.DEBUG_LANG+")"
							break;
						case 1:
							txt = "язык Русский (lang="+MISC.DEBUG_LANG+")"
							break;
						case 2:
							txt = "language English (lang="+MISC.DEBUG_LANG+")"
							break;
						case 3:
							txt = "lingua Italiana (lang="+MISC.DEBUG_LANG+")"
							break;
					}
					txt += "\t0 - default, 1 - RU, 2 - EN, 3 - IT";
					break;
				case "showlbslog":
					if (args[1]) {
						MISC.DEBUG_SHOW_LBS_LOG= int(args[1]);
						so.data["showlbslog"] = MISC.DEBUG_SHOW_LBS_LOG;
					}
					txt = "showlbslog="+MISC.DEBUG_SHOW_LBS_LOG;
					break;
				case "getts":
					txt = "Tunnel is " + (TunnelOperator.access().online() ? "online":"offline");
					break;
				case "resetk9dir":
					for (i=0; i<8; i++) {
						RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_DIRECTIONS,null,i+1,[i]));
					}
					txt = "Каналы сброшены";
					break;
				case "sendpacket":
					txt = "Неправильно сформирована команда";
					if (args[1]) {
						params = (args[1] as String).split(";");
						if (params.length > 0) {
							
							var writedata:Array = params[2] is String ? (params[2] as String).split(",") : null;
							if (writedata) {
								len = writedata.length;
								for ( i=0; i<len; ++i) {
									if ( (writedata[i] as String).search(/"/) > -1 ) {
										writedata[i] = String((writedata[i] as String).replace(/"/g, "" ));
										//writedata[i] = String(writedata[i]);
									} else {
										writedata[i] = int(writedata[i]);
									}
								}
							}
							
							var data:Object = {
								cmdname:(params[0] as String).toUpperCase(),
								cmd:(CMD as Object)[(params[0] as String).toUpperCase()],
								structure:params[1] is String ? int(params[1]) : 0, 
								data:writedata
							}
							RequestAssembler.getInstance().fireEvent( new Request(data.cmd,null,data.structure,data.data));
							txt = "Команда " + data.cmdname + " сформирована и если она есть в командах данного прибра, то отправлена"; 
						} else
							txt = "Без параметров команда не работает";
					}
					break;
				
				case "f":
					/*value = 0;
					if (args[1]) {
						value = int(args[1]);
					}
					MISC.DD = true;*/
					//SharedObjectBot.write(SharedObjectBot.HISTORY_VISIBLE_PARAMS, null );
					//SharedObjectBot.write(SharedObjectBot.HISTORY_ORDER_PARAMS, null );
					
					txt = "Недокументированная команда\n"
					break;
				default:
					txt="Команды не существует\n";
					break;
			}
			flush();
			return txt;
		}
		
		private function getShowVars():String
		{
			if( this.stage )
			{
				
				return "flashvars: /r" + Dumper.dump( this.root.loaderInfo.parameters );
			}
			return "no container or no parameters";
		}
		private function getResponse( _arr:Array ):void 
		{
			
		};
		
		private function mDown(ev:MouseEvent):void
		{
			var p:Point = localToGlobal(new Point(0,0));
			bounds.height = stage.stageHeight;
			bounds.y = -p.y;
			stage.addEventListener(MouseEvent.MOUSE_UP, mUp );
			dragTitle.startDrag( false, bounds );
		}
		private function mUp(ev:MouseEvent):void
		{
			dragTitle.stopDrag();
			this.height = (this.height-dragTitle.y);
			dragTitle.y = 0;
			stage.removeEventListener(MouseEvent.MOUSE_UP, mUp );
		}
		private function linkHandler( e:TextEvent):void
		{
			showParsedData( ParsingBot.getData( int(e.text) ) );
		}
		
		private function onStopAutoScroll(event:Event):void
		{
			if( tLog.verticalScrollPosition > tLog.maxVerticalScrollPosition - 5 )
			{
				onAScroll = true;
			}
			else
			{
				onAScroll = false;
			}
								
			
								
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if (value) 
			{
				tLog.htmlText = log;
				tLog.verticalScrollPosition= tLog.maxVerticalScrollPosition;
				stage.focus = tCmd;
				
				if( ( DS.isfam( DS.K5 ) || DS.isfam( DS.K5RT3 ) || DS.isfam( DS.KLAN ) ) && !bK5Stop )
				{
					const htmlLblIII:String = "<font color='#008800' >k5 stop</font>";
					
					bK5Stop = new MButton("k5 stop", k5stop);
					bK5Stop.setHTMLLabel( htmlLblIII );
					bK5Stop.x = this.width - 140;
					bK5Stop.height = 20;
					dragTitle.addChild( bK5Stop );
					btns.push( bK5Stop );
				}
			}
			else
			{
				onAScroll = true;
			}
			
			this.dispatchEvent( new Event( MISC.EVENT_RESIZE_IMPACT ));
			IS_VISIBLE = value;
		}
		override public function set height(value:Number):void
		{
			super.height = value;
			this.dispatchEvent( new Event( MISC.EVENT_RESIZE_IMPACT ));
			
			tCmd.y = this.height - 32;
			tLog.height = this.height - 57;
			MISC.DEBUG_CONSOLE_SIZE = value;
			so.data["con_size"] = value;
			flush();
			backgroud();
		}
		override public function set width(value:Number):void
		{
			super.width = value;
			tTitle.width = value - 20;
			tLog.width = value - 18;
			tCmd.width = value - 19;
			
			dragTitle.graphics.clear();
			dragTitle.graphics.beginFill( COLOR.LIGHT_GREY );
			dragTitle.graphics.drawRect(0,0,value,20);
			backgroud();
			
			const padding:int = 7;
			
			
			
			bClose.x = value - 27;
			
			var len:int = btns.length;
			for (var i:int=1; i<len; i++) 
				btns[ i ].x =  btns[ i - 1 ].x - ( btns[ i ].width + padding );
				
			
			
			
			
			
			
			
		}
		private function backgroud():void
		{
			this.graphics.clear();
			this.graphics.beginFill( COLOR.WHITE_GREY );
			this.graphics.drawRect(0,0,this.width,this.height);
		}
		private function showParsedData(bm:BinaryModel):void
		{
			onAScroll = false;
			
			if (!parsingScreen) {
				parsingScreen = new BinaryParsingScreen;
				this.stage.addChild( parsingScreen );
			}
			parsingScreen.open(bm);
		}
		private function flush():void
		{
			if (so) {
				try {
					so.flush();
				} catch(error:Error) {
					dtrace("Error: flush shared object  at DevConsole");
				}
			}
		}
		private function close():void
		{
			this.visible = false;
		}
		
		private function clear():void
		{
			write(cmdParser( [ "clear" ] ), SYSTEM);
			onAScroll = true;
			
		}	
		
		private function k5stop():void
		{
			const req:String = "+K5_STOP_PANEL=1,1";
			SocketProcessor.getInstance().sendManualRequest( req , null );
			write( req, CMD_TO);
			SocketProcessor.getInstance().reConnect();
			
			
		}	
		
		private function onAuto():void
		{
			onAScroll = true;
			tLog.verticalScrollPosition= tLog.maxVerticalScrollPosition;
			
		}
		
		
	}
}
class Initiator {public function Initiator()}