package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptConnectServer;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.static.TAGS;
	
	public class UIServerCoordUNI extends UI_BaseComponent
	{
		private var srvs:Vector.<OptConnectServer>;
		private var btns:Vector.<TextButton>;
		private var auth:Vector.<OptAuthorization>;
		private var sep:Separator;
		
		private var go:GroupOperator;
		private var cbRitm:FSCheckBox;
		private var cbEgts:FSCheckBox;
		private var bot:SBot;
		
		private var secured:Boolean;
		
		public function UIServerCoordUNI()
		{
			super();
		
			secured = TAGS.VOYAGER_CONNECT_SERVER_SECURED;
			if (secured)
				bot = new SBot;
			
			go = new GroupOperator;
			
			var sepw:int = 530;
			
			srvs = new Vector.<OptConnectServer>(4);
			btns = new Vector.<TextButton>(2);
			
			createUIElement( new FSShadow, CMD.PROTOCOL_TYPE, "", null, 1 );
			
			cbRitm = createUIElement( new FSCheckBox, 2, 
				loc("ui_coords_send_in_protocol_ritm"), onRITM, 1 ) as FSCheckBox;
			attuneElement( 468,NaN,FSCheckBox.F_MULTYLINE );
			
			var btnlabel:String = loc("ui_coords_copy_to_reserve");
			
			go.add( "noegts", cbRitm );
			go.add( "noegts", drawSeparator(sepw) );
			
			if (DS.isDevice(DS.R15) || DS.isDevice(DS.R15IP)) {
				srvs[0] = new OptConnectServer(1,loc("server_main"), loc("server_port_main") );
			} else {
				srvs[0] = new OptConnectServer(1,loc("ui_coords_main_server"), loc("ui_coords_port_main_server"), 
					OptConnectServer.SHOW_OBJECT | OptConnectServer.SHOW_PASS );
			}
			//srvs[0] = new OptConnectServer(1,"IP адрес основного сервера приема\rкоординат", "Порт основного сервера приема координат", true);
			srvs[0].sbot = bot;
			addChild( srvs[0] );
			srvs[0].cloneEgts = cloneEgts;
			srvs[0].x = globalX;
			srvs[0].y = globalY;
			srvs[0].addEventListener( Event.CHANGE, onPassword );
			go.add("ritm", srvs[0] );
			
			btns[0] = new TextButton;
			addChild( btns[0] );
			btns[0].setUp( btnlabel, onCopy, 0 );
			btns[0].x = sepw;
			btns[0].y = globalY+40+50;
			btns[0].focusgroup = 0;
			go.add("ritm", btns[0] );
			btns[ 0 ].visible = false;
			
			globalY += srvs[0].complexHeight-3;
			go.add("ritm", drawSeparator(sepw) );
			
			if (DS.isDevice(DS.R15) || DS.isDevice(DS.R15IP))
				srvs[1] = new OptConnectServer(2,loc("server_reserve"),loc("server_port_reserve"));
			else
				srvs[1] = new OptConnectServer(2,loc("ui_coords_reserve_server"),loc("ui_coords_port_reserve_server"));
			//srvs[1] = new OptConnectServer(2,"IP адрес резервного сервера приема\rкоординат","Порт резервного сервера приема координат");
			srvs[1].sbot = bot;
			addChild( srvs[1] );
			srvs[1].x = globalX;
			srvs[1].y = globalY;
			go.add("ritm", srvs[1] );
			
			globalY += srvs[1].complexHeight;
			
			sep = drawSeparator(sepw);
			go.add("ritm", sep );
			go.add( "noegts",sep);
			
			cbEgts = createUIElement( new FSCheckBox, 2, 
				loc("ui_coords_send_in_protocol_egts"), onEGTS, 2 ) as FSCheckBox;
			attuneElement( 468,NaN,FSCheckBox.F_MULTYLINE );
			go.add("egts",getLastElement());
			globalY -= 8;
			
			go.add( "noegts", cbEgts );
			sep = drawSeparator(sepw);
			go.add("egts",sep);
			go.add( "noegts",sep);
			
			var showPass:int;
			if( TAGS.VOYAGER_CONNECT_SERVER_SHOW_EGTS_PASS )
				showPass = OptConnectServer.SHOW_PASS;
			
			srvs[2] = new OptConnectServer(3,loc("ui_coords_ip_main_egts"),loc("ui_coords_port_main_egts"),OptConnectServer.SHOW_OBJECT | showPass);
			//srvs[2] = new OptConnectServer(3,"IP адрес основного сервера ЕГТС\r","Порт основного сервера ЕГТС",true);
			addChild( srvs[2] );
			srvs[2].cloneEgts = cloneEgts;
			srvs[2].x = globalX;
			srvs[2].y = globalY;
			srvs[2].addEventListener( Event.CHANGE, onPassword );
			go.add("egts",srvs[2]);
			
			btns[1] = new TextButton;
			addChild( btns[1]);
			btns[1].setUp( btnlabel, onCopy, 1 );
			btns[1].x = sepw;
			if (TAGS.VOYAGER_CONNECT_SERVER_SHOW_EGTS_PASS)
				btns[1].y = globalY+5+36+50;
			else
				btns[1].y = globalY+5+36+50-34;
			btns[1].focusgroup = 0;
			go.add("egts",btns[1]);
			globalY += srvs[2].complexHeight-3;
			sep = drawSeparator(sepw);
			go.add( "noegts", sep );
			go.add("egts",sep);
			srvs[3] = new OptConnectServer(4,loc("ui_coords_ip_reserve_egts"), loc("ui_coords_port_reserve_egts") );
			addChild( srvs[3] );
			srvs[3].x = globalX;
			srvs[3].y = globalY;
			go.add("egts",srvs[3]);
			globalY += srvs[3].complexHeight-3;
			
			if ( DS.isNoEGTSVojagers( DS.alias ) && DS.release >= 42) {
				go.add("auth", drawSeparator(sepw) );
				go.add("auth", addui( new FSCheckBox, CMD.EGTS_LOGIN_ENABLE, loc("on_egts_auth"), onAuthEnabled, 1 ) );
				attuneElement( 468 );
				auth = new Vector.<OptAuthorization>;
				for (var i:int=0; i<2; i++) {
					auth.push( new OptAuthorization(i+1) );
					addChild( auth[i] );
					auth[i].x = globalX;
					auth[i].y = globalY;
					go.add("auth", auth[i] );
					globalY += auth[i].complexHeight-3;
				}
				
			}
			
			width = 700;
			height = 545;
			
			starterCMD = CMD.CONNECT_SERVER;
			if ( DS.isNoEGTSVojagers( DS.alias ) &&  DS.release >= 42) {
				
				starterRefine( CMD.EGTS_LOGIN_ENABLE, true );
				starterRefine( CMD.EGTS_USER_NAME_PASSWORD, true );
			}	
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.PROTOCOL_TYPE:
					
					switch(p.getStructure()[0]) {
						case 0:	// РИТМ
							cbRitm.setCellInfo("1");
							cbEgts.setCellInfo("0");
							break;
						case 1:	// РИТМ + EGTS
							cbRitm.setCellInfo("1");
							cbEgts.setCellInfo("1");
							break;
						case 2:	// EGTS
							cbRitm.setCellInfo("0");
							cbEgts.setCellInfo("1");
							break;
						case 3:
							cbRitm.setCellInfo("0");
							cbEgts.setCellInfo("0");
							break;
					}
					onRITM();
					onEGTS();
					LOADING = false;
					loadComplete();
					break;
				case CMD.CONNECT_SERVER:
					LOADING = true;
				//	SavePerformer.LOADING = true;
					var edited:Array;
					var targ:Array;
					var etalon:Array = p.getStructure();
					var len:int = srvs.length;
					var compoundName:Number = 0;
					const hight_bit_num:uint = 2147483648;
					
					for (var i:int=0; i<len; ++i) {
						if( ( !DS.isfam( DS.F_V ) || ( DS.isfam( DS.F_V ) && DS.release > 54 ) ) )
						{
							if( i == 2 )
							{
								
								compoundName =  configureX32Nm( ( int( p.getStructure(i+2)[ 0 ] ) ), int( p.getStructure(i + 1)[ 0 ] ) );
								
								p.getStructure(i + 1)[ 0 ]  = compoundName;
								
							}
							else if( i == 3 )
							{
								p.getStructure(i)[ 0 ]  = compoundName;
							}
							
							
						}
						
						
						srvs[i].dispell = true;	// для скрывания ошибки сохранения
						srvs[i].putRawData( p.getStructure(i+1) );
							
						
					}

					
					cbRitm.disabled = p.length < 4;
					cbEgts.disabled = p.length < 4;
					
					
					if( p.length < 4 ) {
						cbRitm.setCellInfo("1");
						cbEgts.setCellInfo("0");
						onRITM();
						onEGTS();
						LOADING = false;
						//SavePerformer.LOADING = false;
						go.visible("noegts",false);
						go.movey("ritm", PAGE.CONTENT_TOP_SHIFT);
						loadComplete();
					} else
						RequestAssembler.getInstance().fireEvent( new Request( CMD.PROTOCOL_TYPE, put ));
					break;
				case CMD.EGTS_LOGIN_ENABLE:
					pdistribute(p);
					onAuthEnabled(null);
					break;
				case CMD.EGTS_USER_NAME_PASSWORD:
					auth[0].putData(p);
					auth[1].putData(p);
					break;
			}
		}
		
		private function configureX32Nm( n:int, nn:int ):Number 
		{
			/// самый старший разряд в десятичном представлении
			const hight_bit:Number = 2147483648;
			/// включен ли старший бит
			const hb:Boolean = ( n & 0x8000 ) > 0;
			/// первая половина числа исключая знаковый старший бит
			const i_int:Number = n & 0x7FFF;
			
			var res:Number = ( i_int << 16 ) + nn;
			
			
			if ( hb )
				res += hight_bit;
			
			return res;
		}
		
		private function onAuthEnabled(t:IFormString):void
		{	// блокирует поля авторизации ЕГТС, 41 релиз
			var f:IFormString = getField(CMD.EGTS_LOGIN_ENABLE, 1 );
			auth[0].block = int(f.getCellInfo()) == 0;
			auth[1].block = int(f.getCellInfo()) == 0;
			if (t)
				remember(t);
		}
		private function switchPassword():void
		{
			(getField(CMD.CONNECT_SERVER,2) as FSSimple).displayAsPassword( Boolean( getField(0,1).getCellInfo()==0 ) );
		}
		private function cloneEgts(struc:int, o:String, p:String):void
		{
			srvs[struc].clone( o, "" );
		}
		private function onCopy(value:int):void
		{
			var adr:Array;
			switch(value) {
				case 0:
					
					if (secured && !bot.solved) {
						bot.process();
						return;
					}
					
					adr = srvs[0].getAddress();
					srvs[1].setAddress( adr[0], adr[1] );
					break;
				case 1:
					adr = srvs[2].getAddress();
					srvs[3].setAddress( adr[0], adr[1] );
					break;
			}
		}
		
		private function getProtocolTypeValue(save:Boolean=true):int
		{
			var value:int = 3;	// если ничего не совпало - все оключаем
			if ( cbRitm.getCellInfo() == "1" && cbEgts.getCellInfo() == "0" )
				value = 0;	// РИТМ
			if ( cbRitm.getCellInfo() == "0" && cbEgts.getCellInfo() == "1" )
				value = 2;	// EGTS
			if ( cbRitm.getCellInfo() == "1" && cbEgts.getCellInfo() == "1" )
				value = 1;	// РИТМ + EGTS
			getField( CMD.PROTOCOL_TYPE,1).setCellInfo( value );
			if (save)
				remember( getField( CMD.PROTOCOL_TYPE,1) );
			return value;
		}
		private function onRITM(t:IFormString=null):void
		{
			if (!LOADING && secured && !bot.solved) {
				cbRitm.setCellInfo(1);
				bot.process();
				return;
			}
			var value:int = getProtocolTypeValue(t!=null);
			var b:Boolean = value == 1 || value == 0;
			go.visible("ritm", b);
			srvs[0].dispell = !b;
			srvs[1].dispell = !b;
			
			go.movey("egts", b==true ? 326:66);
			
			// блок нужен если необходим хотя бы один канал связи онлайн
			// на 15 может не быть ни одного канала связи
			/*if (!b && !DEVICES.isV15()) {
				cbEgts.setCellInfo(1);
				onEGTS();
			} else*/
				resize();
		}
		private function onEGTS(t:IFormString=null):void
		{
			var value:int = getProtocolTypeValue(t!=null);
			
			var b:Boolean = value == 1 || value == 2 ;//getField(CMD.PROTOCOL_TYPE, 1).getCellInfo() == "0";
			
			srvs[2].dispell = !b;
			srvs[3].dispell = !b;
			sep.visible = b;
			btns[1].visible = b;
			
			resize();
			// блок нужен если необходим хотя бы один канал связи онлайн
			/*if (!b) {
				cbRitm.setCellInfo(1);
				onRITM();
			}*/
		}
		private function resize():void
		{
			if (srvs[3].visible) {
				if (srvs[0].visible)
					height = 620;
				else
					height = 360;
				
			} else {
				if (srvs[0].visible)
					height = 390;
				else
					height = 200;
			}
			
			if (srvs[0].visible && srvs[3].visible) {
				go.movey("auth", 583);
			} else if (!srvs[0].visible && srvs[3].visible) {
				go.movey("auth", 323);
			} else if (srvs[0].visible && !srvs[3].visible) {
				go.movey("auth", 361);
			} else {
				go.movey("auth", 101);
			}
		}
		private function onPassword(e:Event):void
		{	// когда меняется пароль в нечетной структуре, он должен автоматом прописаться и в четной
			var arraynum:int = (e.currentTarget as OptConnectServer).getStructure();
			srvs[arraynum].password = (e.currentTarget as OptConnectServer).password;
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.PopUp;
import components.gui.fields.FSSimple;
import components.interfaces.IAbstractProcessor;
import components.protocol.Package;
import components.static.CMD;
import components.static.MISC;

class SBot implements IAbstractProcessor
{
	private var _solved:Boolean;
	private var tested:Boolean;
	private var callbacks:Array;
	
	public function set callback(f:Function):void
	{
		if(!callbacks)
			callbacks = [];
		callbacks.push(f);
	}
	public function get solved():Boolean 
	{
		return _solved;
	}
	public function process():void
	{
		var p:PopUp = PopUp.getInstance();
		p.construct( PopUp.wrapHeader("sys_enter_pass"), PopUp.wrapMessage("", true), PopUp.BUTTON_OK | PopUp.BUTTON_CANCEL, [{f:doCheck}] );
		p.open();
	}
	private function doCheck(s:String):void
	{
		if( s == ((Math.SQRT1_2*10).toString() + int(Math.PI/2*int(23.31)-int(Math.LOG2E)).toString(10) + int(Math.asin(Math.PI) + 
			(Math.SQRT2*30).toString(5).substr(1,2) + (int(MISC.DEBUG_KEY.substr(2,1))/9).toString(10) )).toString().substr(2,6) && !tested ) {
			_solved = true;
			releaseCallback();
		}
		tested = true;
	}
	private function releaseCallback():void
	{
		if (callbacks) {
			var len:int = callbacks.length;
			for (var i:int = 0; i < len; i++) {
				callbacks[i].call();
			}
		}
	}
}
class OptAuthorization extends OptionsBlock
{
	public function OptAuthorization(str:int)
	{
		super();
		operatingCMD = CMD.EGTS_USER_NAME_PASSWORD;
		structureID = str;
		addui( new FSSimple, operatingCMD, str == 1 ? loc("g_user") : loc("g_pass"), null, 1, null, "A-z0-9", 31 );
		attuneElement( 180, 300 );
			
		complexHeight = globalY;
	}
	public function set block(b:Boolean):void
	{
		getField(operatingCMD,1).disabled = b;
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
}