package components.abstract.sysservants
{
	import components.abstract.LOC;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.RFSensorServant;
	import components.gui.PopUp;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.static.PART_FUNCT;
	import components.system.UTIL;
	
	public class LoaderServant
	{
		public static const NEED_SIZE_CMD:int = 1;
		public static const NEED_PARTITION:int = 2;
		public static const NEED_SYSTEM:int = 3;
		public static const NEED_VER_INFO1:int = 4;
		public static const NEED_SET_ADR485:int = 5;
		public static const NEED_SIZE_CMD_BOTTOM:int = 6;	// настройки для нижней платы
		public static const NEED_VER_INFO_BOTTOM:int = 7;	// версия нижней платы
		public static const NEED_APN_INFO:int = 8;	// gprs apn
		public static const NEED_RFM_OUTCOUNT:int = 9;	// rf modules out count
		public static const NEED_USSD_BALANCE:int = 10;
		public static const NEED_STOP_PANEL:int = 11;
		public static const NEED_RFM_AVAILABLE_SENSOR:int = 12;	// rf modules sensors availability
		public static const NEED_PATCH14AN2:int = 13;	// Исправление 14А от 08.04.2016
		public static const NEED_K1_DEFAULTS:int = 14;	// запись необходимых дефолтов для адекватной работы К1
		public static const NEED_PARTITION_K5A:int = 15;
		public static const NEED_K5_ADC_TRESH:int = 16;
		public static const NEED_RFM_CNT_SENSOR:int = 17; // rfm lr 
		public static const NEED_SMS_PARAMS:int = 18; // rfm lr 
		public static const NEED_CH_COM_TIME_PARAM_COUNT:int = 19; 
		public static const NEED_KBD:int = 20; 
		public static const ERASE_DISABLED_PARTITION_OF_K5A:int = 21; 
		
		
		
		private var list:Array;
		private var launch:Function;
		private var fDefaultMenu:Function;
		private var fInitHardware:Function;
		private var rs485:RS485Operator;
		
		public function LoaderServant(f:Function, dDefaultMenu:Function=null, initHardware:Function=null)
		{	// дефолтное меню нужно только на системах с двумя приборами 
			launch = f;
			fDefaultMenu = dDefaultMenu;
			fInitHardware = initHardware;
		}
		public function load(params:Array=null):void
		{
			if (params)
				list = params.slice();
			
			if (list.length > 0) {
				switch ( list.shift() ) {
					case NEED_SIZE_CMD:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.GET_BUF_SIZE,	process,1,null,Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.GET_MAX_IND_CMDS,process,0,null,Request.SYSTEM ))
						break;
					case NEED_PARTITION:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.PARTITION,		process,0,null,Request.SYSTEM ));
						break;
					case NEED_SYSTEM:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SYSTEM,		process,0,null,Request.SYSTEM ));
						break;
					case NEED_VER_INFO1:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.VER_INFO1,		process,0,null,Request.SYSTEM ));
						break;
					case NEED_SET_ADR485:
						if (rs485)
							rs485.reset();
						RequestAssembler.getInstance().fireEvent( new Request( CMD.SET_ADDR_RS485,	process,0,null,Request.SYSTEM ));
						break;
					case NEED_SIZE_CMD_BOTTOM:
						SERVER.ADDRESS = SERVER.ADDRESS_BOTTOM;
						RequestAssembler.getInstance().fireEvent( new Request( CMD.GET_BUF_SIZE,	process,1,null,Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.GET_MAX_IND_CMDS,process,0,null,Request.SYSTEM ))
						break;
					case NEED_VER_INFO_BOTTOM:
						SERVER.ADDRESS = SERVER.ADDRESS_BOTTOM;
						RequestAssembler.getInstance().fireEvent( new Request( CMD.VER_INFO,		process,0,null,Request.SYSTEM ));
						break;
					case NEED_APN_INFO:
						SERVER.ADDRESS = SERVER.ADDRESS_TOP;
						RequestAssembler.getInstance().fireEvent( new Request( CMD.SIM_SLOT_COUNT,	process,0,null,Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.GPRS_APN_COUNT,	process,0,null,Request.SYSTEM ));
						break;
					case NEED_RFM_OUTCOUNT:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_COUNT_OUT,	process,0,null,Request.SYSTEM ));
						break;
					case NEED_USSD_BALANCE:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.SYS_NOTIF2,	process,0,null,Request.SYSTEM ));
						break;
					case NEED_STOP_PANEL:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_STOP_PANEL,	process,0,[1],Request.SYSTEM ));
						break;
					case NEED_RFM_AVAILABLE_SENSOR:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_SENSOR_CNT_STRUCT,	process,0,null,Request.SYSTEM ));
						break;
					case NEED_RFM_CNT_SENSOR:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_SENSOR_AVAILABLE,	process,0,null,Request.SYSTEM ));
						break;
					case NEED_PATCH14AN2:
						// Исправление 14А от 08.04.2016
						if (DS.fullver == "K-14A.007.007") {
							RequestAssembler.getInstance().fireEvent( new Request( CMD.SET_DEV_HARD_VER,	null,2,[255],Request.SYSTEM ));
							RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT,	process,0,[1],Request.SYSTEM ));
						} else
							load();
						break;
					case NEED_K1_DEFAULTS:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_PART_EVCOUNT,	process,1,[0],Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_EXIT_PART,	process,1,[0],Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_PERIM_PART,	process,1,[0],Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_TIME_CPW,		process,1,[ 60 ],Request.SYSTEM ));
						
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_BIT_SWITCHES,	process,0,null,Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_AWIRE_TYPE,	process,0,null,Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_PART_PARAMS,	process,1,null,Request.SYSTEM ));
						
						break;
					case NEED_PARTITION_K5A:
						
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_AWIRE_PART_CODE,	process,1,null,Request.SYSTEM ));
						break;
					case ERASE_DISABLED_PARTITION_OF_K5A:
						
						//RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT,	null, 9, [ 0, 0xFFFF ] ,Request.SYSTEM ));
						break;
					case NEED_K5_ADC_TRESH:
						
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_ADC_TRESH,	process,0,null,Request.SYSTEM ));
						
						
						break;
					case NEED_SMS_PARAMS:
						/*addCmd(NAVI.SMS, CMD.VR_SMS_NOTIF);
						addCmd(NAVI.SMS, CMD.VR_SMS_NOTIF_LIST);
						RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_SMS_NOTIF,	process,0,null,Request.SYSTEM ));*/
						
						
						break;
					case NEED_CH_COM_TIME_PARAM_COUNT:
						
						RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_TIME_PARAM_COUNT,	process,0,null,Request.SYSTEM ));
						
						
						break;
					case NEED_KBD:
						
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_KBD_KEY_CNT,	process,0,null,Request.SYSTEM ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_TM_KEY_CNT,	process,0,null,Request.SYSTEM ));
						
						
						break;
					
				}
			} else {
				CLIENT.SYSTEM_LOADED = true;
				launch();
			}
		}
		private function process(p:Package):void
		{
			// break должен стоять, только если команда последняя в списке
			// В случае NEED_SIZE_CMD после первой команды стоит return и только после второй break
			
			var len:int, i:int;
			var params:Array;
			switch( p.cmd )	{
				case CMD.GET_BUF_SIZE:
					switch(p.serverAdr) {
						case SERVER.ADDRESS_TOP:
							SERVER.TOP_BUF_SIZE_SEND =  p.getStructure(1)[1];
							SERVER.TOP_BUF_SIZE_RECEIVE =  p.getStructure(1)[0];							
							break;
						case SERVER.ADDRESS_BOTTOM:
							SERVER.BOTTOM_BUF_SIZE_SEND = p.getStructure(1)[1];
							SERVER.BOTTOM_BUF_SIZE_RECEIVE = p.getStructure(1)[0];
							break;
					}
					dtrace( "SERVER_BUF_SIZE_SEND " + SERVER.BUF_SIZE_SEND ) 
					dtrace( "TOP_BUF_SIZE_SEND " + SERVER.TOP_BUF_SIZE_SEND ) 
					dtrace( "SERVER_BUF_SIZE_RECEIVE " + SERVER.BUF_SIZE_RECEIVE )
					dtrace( "TOP_BUF_SIZE_RECEIVE " + SERVER.TOP_BUF_SIZE_RECEIVE )
					return;
					break;
				case CMD.GET_MAX_IND_CMDS:
					switch(p.serverAdr) {
						case SERVER.ADDRESS_TOP:
							SERVER.TOP_MAX_IND_CMDS = int(p.getStructure(1)) > 0 ? int(p.getStructure(1)) : 0xFF;
							break;
						case SERVER.ADDRESS_BOTTOM:
							SERVER.BOTTOM_MAX_IND_CMDS = int(p.getStructure(1)) > 0 ? int(p.getStructure(1)) : 0xFF;
							break;
					}
					
					dtrace( "SERVER_MAX_IND_CMDS " + SERVER.MAX_IND_CMDS )
					dtrace( "TOP_MAX_IND_CMDS " + SERVER.TOP_MAX_IND_CMDS )
					break;
				case CMD.PARTITION:
					len = p.length;
					PartitionServant.PARTITION = new Object;
					PartitionServant.MAX_PARTITIONS = len;
					var noPartitions:Boolean=true;
					for(i=0; i<len+1; ++i) {
						if ( p.getStructure(i) is Array && p.getStructure(i)[0] != 0 && p.getStructure(i)[0] != undefined ) {
							PartitionServant.PARTITION[i] = {"code":p.getStructure(i)[1], "section":p.getStructure(i)[0] };
							noPartitions = false;
						}
					}
					if ( noPartitions ) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.PARTITION, addPartitionSuccess, 1, [1,0x50,MISC.PARTITION_CREATE_DELAY], Request.SYSTEM ));
						return;	// initMenuSelection запустит дальнейшую обработку команд
					} else
						showPartitions();
					break;
				case CMD.RF_SYSTEM:
					MISC.SYSTEM_INACCESSIBLE = Boolean( p.getStructure()[0] != 1 );
					dtrace( "CLIENT_SYSTEM_INACCESSIBLE " + MISC.SYSTEM_INACCESSIBLE )
					RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM = p.getStructure()[4];
					dtrace( "CLIENT_SYSTEM_PERIOD_OF_TRANSMISSION_ALARM " + RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM )
					break;
				case CMD.VER_INFO1:
					
					SERVER.CONNECTION_TYPE = (p.getStructure()[0] as String).toLowerCase(); 
					break;
				case CMD.SET_ADDR_RS485:
					if (!rs485)
						rs485 = new RS485Operator(load);
					rs485.list = list;
					rs485.process(p);
					return;
				case CMD.VER_INFO:
					
					
					
					var v:VersionVerifier = new VersionVerifier;
					/**
					 *  Заккоменчено тогда когда появилась версия K-16-3G, так как
					 * эта операция применяется только для К-16 и только когда обе платы 
					 * есть, возможно придеться както менять это решение в будущем
					 */
					//v.verify(p.data, SERVER.VER, int(SERVER.BOTTOM_LEVEL), SERVER.BOTTOM_SOFTWARE );
					
					
					v.verify(p.data, DS.K16, int(SERVER.BOTTOM_LEVEL), SERVER.BOTTOM_SOFTWARE );
					
					SERVER.BOTTOM_VERSION_MISMATCH = v.VERSION_MISMATCH;
					SERVER.BOTTOM_APP = ((p.getStructure()[1] as String).split(".") as Array)[1];
					SERVER.BOTTOM_VER_INFO = p.data.slice();
					if(v.VERSION_MISMATCH)
						fDefaultMenu();
					else
						fInitHardware();
					break;
				case CMD.SIM_SLOT_COUNT:
					len = p.getStructure()[0];
					CLIENT.SIM_SLOT_COUNT = len;
					OPERATOR.getSchema( CMD.GPRS_APN_AUTO).StructCount = len;
					if( OPERATOR.getSchema( CMD.GPRS_SIM) )
						OPERATOR.getSchema( CMD.GPRS_SIM).StructCount = len;
					return;
				case CMD.GPRS_APN_COUNT:
					OPERATOR.getSchema( CMD.GPRS_APN_BASE).StructCount = p.getStructure()[0];
					break;
				case CMD.CTRL_COUNT_OUT:
					OPERATOR.getSchema( CMD.CTRL_TYPE_OUT ).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEST_OUT ).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_DOUT_SENSOR).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_INIT_OUT).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_NAME_OUT).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_OUT).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_ST_PART).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_AL_LST_PART).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_AL_PART).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_UNSENT_MESS).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_MANUAL).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_MANUAL_TIME).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_MANUAL_CNT).StructCount = p.getStructure()[0];
					OPERATOR.getSchema( CMD.CTRL_TEMPLATE_FAULT).StructCount = p.getStructure()[0];
					switch(DS.alias) {
						case DS.RDK:
						case DS.RDK_LR:
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_RCTRL).StructCount = p.getStructure()[0];
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_RFSENSALARM).StructCount = p.getStructure()[0];
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_RFSENSSTATE).StructCount = p.getStructure()[0];
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_RF_ALARM_BUTTON).StructCount = p.getStructure()[0];
							break;
						case DS.R10:
						case DS.A_REL:
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_REACT_ST_PART).StructCount = p.getStructure()[0];
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_REACT_ST_ZONE).StructCount = p.getStructure()[0];
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_ALL_FIRE).StructCount = p.getStructure()[0];
							OPERATOR.getSchema( CMD.CTRL_TEMPLATE_REACT_ST_EXT).StructCount = p.getStructure()[0];
							break;
						default:
							break;
					}
					break;
				case CMD.SYS_NOTIF2:
					if (LOC.language != LOC.RU) {
						len = p.length;
						for (var j:int=0; j<len; j++) {
							if( int(p.getParam(1,j+1)) == 1 )
								RequestAssembler.getInstance().fireEvent( new Request(
									p.cmd,null,j+1,[0,p.getParam(2,j+1),p.getParam(3,j+1),p.getParam(4,j+1),p.getParam(5,j+1),p.getParam(6,j+1)]));
						}
					}
					break;
				case CMD.K5_STOP_PANEL:
					break;
				case CMD.CH_COM_TIME_PARAM_COUNT:
					OPERATOR.getSchema( CMD.CH_COM_TIME_PARAM).StructCount = int( p.getParam( 1, 1 ) );
					break;
				case CMD.CTRL_SENSOR_CNT_STRUCT:
					OPERATOR.getSchema( CMD.CTRL_SENSOR_AVAILABLE).StructCount = int(p.getParam(1));
					break;
				case CMD.CTRL_SENSOR_AVAILABLE:
					
					
					var cnt:int = 0;
					for (var k:int=0; k<8; k++) 
					{
						if( UTIL.isBit( k, p.getStructure( 5 )[ 0 ] ))
																cnt++;
					}	
					
					OPERATOR.getSchema( CMD.CTRL_DOUT_SENSOR).StructCount = cnt;
					break;
				case CMD.REBOOT:
					PopUp.getInstance().composeOfflineMessage( PopUp.wrapHeader(loc("sys_attention")), PopUp.wrapMessage("K14_reconnect") );
					SocketProcessor.getInstance().disconnectFinal();
					break;
				case CMD.K9_BIT_SWITCHES:
					
					/*+K9_BIT_SWITCHES включаем сухие контакты
					+K9_AWIRE_TYPE нормальное состоянение шлейфов = разомкнутое
					+K9_PART_PARAMS, +K9_AWIRE_TYPE задержка на вход/выход = 0
					+K9_PART_PARAMS включаем быстроую постановку и 24 часа
					+K5_PART_EVCOUNT количество событий по разделу без ограничений
					+K9_EXIT_PART(3607), +K9_PERIM_PART(3608) кнопка периметр и кнопка выход установить «нет»*/
					
					var bf:int = p.getParamInt(1);
					
					if (!UTIL.isBit(1,bf)) {
						bf = UTIL.changeBit( bf, 1, true );
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_BIT_SWITCHES,	null,1,[bf,p.getParamInt(2)],Request.SYSTEM ));
					}
					break;
				/// читается только приборами К-1
				case CMD.K9_AWIRE_TYPE:
					
					placeDefaultWIRE1M( p );
					
					return;
				case CMD.K9_PART_PARAMS:	
					params = p.getStructure(i+1);
					if (params[4] != 1 || params[6] != 0) {
						params[4] = 1;
						params[6] = 0;
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_PART_PARAMS,	null,1,params,Request.SYSTEM ));
					}
					break;
				case CMD.K5_AWIRE_PART_CODE:	
					if( DS.isfam( DS.K5,  DS.K5, DS.K53G, DS.K5AA, DS.A_BRD  )) excludeUpTo9Part( p );
					break;
				
				
				case CMD.K5_ADC_TRESH:	
					if( DS.isfam( DS.K5,  DS.K5, DS.K53G  )) checkAdcTreshStngs( p );
					break;
				
				
				case CMD.K5_KBD_COUNT:
					OPERATOR.getSchema( CMD.K5_KBD_KEY ).StructCount = OPERATOR.getData( CMD.K5_KBD_KEY_CNT )[ 0 ][ 0 ];
					OPERATOR.getSchema( CMD.K5_TM_KEY ).StructCount = OPERATOR.getData( CMD.K5_TM_KEY_CNT )[ 0 ][ 0 ];
					
					break;
				
				
			}
			load();
		}
		
		
		private function addPartitionSuccess( p:Package ):void
		{
			if ( p.success ) {
				PartitionServant.PARTITION[1] = {"code":0x50, "section":1 }
				RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT, null, 1, [1,PART_FUNCT.TAKEOFFGUARD,MISC.PARTITION_CREATE_DELAY] ));
				showPartitions();
				load();
			}
		}
		
		/** MISC	***************************/
		private function showPartitions():void
		{
			var txt:String = "SERVER_PARTITION:";
			for(var key:String in PartitionServant.PARTITION) {
				txt += "\r    Номер раздела: "+PartitionServant.PARTITION[key]["section"] + ", код: 0x" + int(PartitionServant.PARTITION[key]["code"]).toString(16); 
			}
			dtrace( txt );
		}
		
		/**
		 *  Проверяем, чтобы на модификации K-5A отглушенные шлейфы 
		 * были закреплены за несуществующим разделом
		 */
		private function excludeUpTo9Part( p:Package ):void
		{
			
			var needUpdate:Boolean = false;
			const zerroPart:String = "8";
			var len:int = p.data[ 0 ].length / 2;
			for (var i:int= len /2; i<len; i++) {
				if( p.data[ 0 ][ i ] == zerroPart )continue;
				
				p.data[ 0 ][ i ] = zerroPart;
				needUpdate = true;
				
			}
			
			if( needUpdate )
				RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_AWIRE_PART_CODE, null, 1, p.data[ 0 ] ));
		}
		
		/**
		 *  Проверяем, чтобы на модификации K-5A отглушенные 
		 * шлейфы имели настройки по умолчанию
		 */
		private function checkAdcTreshStngs(p:Package):void
		{
			
			var len:int = p.data.length;
			const defValues:Array = [ 30, 470, 650,806,1009];
			for (var i:int=len / 2; i<len; i++) {
				if( p.data[ i ].every( compare ) ) continue;
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_ADC_TRESH, null, i + 1, defValues ));
			}
			
			
			function compare( element:*, index:int, arr:Array ):Boolean
			{
				return element == defValues[ index ];
			}
			
		}
		
		private function placeDefaultWIRE1M( p:Package ):void
		{
			var params:Array;
			var needRequest:Boolean = false;
			const len:int = p.length + 1;
			for (var i:int = 1; i < len; i++) 
			{
				params = p.getStructure( i );
				if( i != 2 && params[ 0 ] != 0 )
				{
					params[ 0 ] = 0;
					needRequest = true;
				}
				
				if( params[ 3 ] != 0 )
				{
					params[ 3 ] = 0;
					needRequest = true;
				}
				
				if( needRequest ) RequestAssembler.getInstance().fireEvent( new Request( CMD.K9_AWIRE_TYPE,	null,i ,params,Request.SYSTEM ));
				
				needRequest = false;
			}
			
			
			
		}
	}
}
import components.abstract.functions.loc;
import components.abstract.servants.TaskManager;
import components.abstract.sysservants.LoaderServant;
import components.gui.PopUp;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.protocol.statics.CLIENT;
import components.protocol.statics.SERVER;
import components.static.CMD;
import components.static.DS;
import components.static.MISC;

class RS485Operator
{
	public var list:Array;
	
	private var REWRITE:Boolean = false;
	private var load:Function;
	private var rewriteAddrTry:int = 0;	// может быть только 3 попытки перезаписи адреса
	private var maxTrys:int = 4;	// может быть только 3 попытки перезаписи адреса
	
	public function RS485Operator(f:Function)
	{
		load = f;
	}
	public function reset():void
	{
		rewriteAddrTry = 0;
	}
	public function process(p:Package):void
	{	// если подключена только нижняя плата адресация всегда будет 0xff
		if (SERVER.DUAL_DEVICE && p.getStructure()[0] == 0xff ) {
			if (rewriteAddrTry == maxTrys) {
				PopUp.getInstance().construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage(loc("sys_no_comm_with")+ loc(DS.K16 + ".105")) );
				PopUp.getInstance().open();
				return;
			}
			
			if (REWRITE) {
				TaskManager.callLater( getAdr, CLIENT.TIMER_EVENT_SPAM );
				REWRITE = false;
			} else {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.SET_ADDR_RS485, null,1, [1],Request.SYSTEM ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.SET_ADDR_RS485, process, 0, null, Request.SYSTEM ));
				rewriteAddrTry++;
				REWRITE = true;
			}
		} else {
			SERVER.ADDRESS_BOTTOM = SERVER.DUAL_DEVICE == true ? p.getStructure()[0] : 0xff;
			REWRITE = false;
			
			var c:Boolean = MISC.VERSION_MISMATCH;
			
			if (SERVER.DUAL_DEVICE) {
				list.splice(1,0, LoaderServant.NEED_SIZE_CMD_BOTTOM );
				list.splice(1,0, LoaderServant.NEED_VER_INFO_BOTTOM );
				list.splice(1,0, LoaderServant.NEED_APN_INFO );
			}
			
			if (!SERVER.DUAL_DEVICE && DS.app.charAt(0) == "2" ) {
				list.splice(1,0, LoaderServant.NEED_APN_INFO );
			}
			load();
		}
		function getAdr():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.SET_ADDR_RS485, process ));
		}
	}
}