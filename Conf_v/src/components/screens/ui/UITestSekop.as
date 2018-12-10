package components.screens.ui
{
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import spark.primitives.Rect;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class UITestSekop extends UI_BaseComponent
	{
		private const TYPE_PING_VOYAGER:int = 1;
		private const TYPE_PING_SERVER:int = 2;
		private const TYPE_ASK_COORD:int = 3;
		private const TYPE_SEND_TEST:int = 4;
		
		private const ADR_CLIENT:int = 0xFB;
		private const ADR_DEVICE:int = 0xFF;
		private const ADR_SERVICE:int = 0xFE;
		
		private const PACKET_GET_NMEA_RMC:Array = [0x80,0x80,0x80,0x02,0x11,0x00,0xfb,0xff,0x22,0x00,0x01,0xb3,0x05,0x00,0x00,0x26,0xd2];
		private const SEKOP_ROUTE_GPPT:Array = [0x80,0x80,0x80,0x02,0x50,0x00,0xFB,0xFE,0x02,0x00,0x03,0x30,0xF2,0x01,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x6E,0x69,
			0x4A,0x54,0x01,0x00,0xA0,0x3D,0x54,0x45,0x53,0x54,0x00,0xC0,0xEE,0x08,0x18,0xC7,0xE4,0xBF,0xF0,0xBC,0xE4,0xBF,0x01,0x86,0x65,0x4A,0x54,0x56,0x6D,0x4A,0x54,
			0x01,0x01,0x01,0x00,0x00,0x00,0x16,0x00,0x00,0x00,0x6E,0x69,0x4A,0x54,0xD6,0x6A,0x4A,0x54,0x01,0x00,0x00,0x00,0x00,0x17,0xC1];
		private const PING_P2:Array = [0x80,0x80,0x80,0x02,0x11,0x00,0xFB,0xFF,0x03,0x00,0x01,0x12,0x02,0x00,0x00,0x85,0xED];
		private var bPingVoyager:TextButton;
		private var bPingServer:TextButton;
		private var bGetCoord:TextButton;
		private var bSendTest:TextButton;
		private var output:SimpleTextField;
		private var widget:SekopWidget;
		
		private var asked_ping:Boolean;
		
		public function UITestSekop()
		{
			super();
			
			bPingVoyager = add(loc("sekop_ping_voyager"), TYPE_PING_VOYAGER);
		//	bPingServer = add("Послать PING на Сервер", TYPE_PING_SERVER);
			bGetCoord = add(loc("sekop_ask_coord"), TYPE_ASK_COORD);
			bSendTest = add(loc("sekop_send_gpt"), TYPE_SEND_TEST);
			
			output = new SimpleTextField("",700);
			output.setSimpleFormat("left",0,12,false);
			addChild( output );
			output.x = globalX;
			output.y = globalY;
			output.border = true;
			output.height = 400;
			
			widget = new SekopWidget(onResponse);
			
			WidgetMaster.access().registerWidget( CMD.GET_NMEA_RMC, widget );
			WidgetMaster.access().registerWidget( 0, widget );
			
	//		CLIENT.ADDRESS = ADR_CLIENT;
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
		private function add(title:String, num:int):TextButton
		{
			var b:TextButton = new TextButton;
			addChild(b);
			b.setUp( title, onClick, num );
			b.x = globalX;
			b.y = globalY;
			globalY += b.getHeight();
			return b;
		}
		private function onClick(num:int):void
		{
			RequestAssembler.getInstance().clearStackLater();
			switch(num) {
				case TYPE_PING_VOYAGER:
					asked_ping = true;
					write( getCmdName(CMD.PING) + " to adr: "+ ADR_DEVICE );
					SocketProcessor.getInstance().sendGeneratedRequest( buildReuest(PING_P2), onPingResponse );
					//RequestAssembler.getInstance().fireEvent( new Request(CMD.PING, onResponse,0,null,0,0,ADR_DEVICE));
					break;
				case TYPE_PING_SERVER:
					write( getCmdName(CMD.PING) + " to adr: "+ ADR_SERVICE );
					RequestAssembler.getInstance().fireEvent( new Request(CMD.PING, onResponse,0,null,0,0,ADR_SERVICE));
					break;
				case TYPE_ASK_COORD:
					write( getCmdName(CMD.GET_NMEA_RMC) + " to adr: "+ ADR_DEVICE );
					//SocketProcessor.getInstance().sendGeneratedRequest( buildReuest(PACKET_GET_NMEA_RMC), onCoordResponse );
					RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_NMEA_RMC, onResponse));
					break;
				case TYPE_SEND_TEST:
					write( getCmdName(CMD.SEKOP_ROUTE_GPPT) + " to adr: "+ ADR_SERVICE);
					SocketProcessor.getInstance().sendGeneratedRequest( buildReuest(SEKOP_ROUTE_GPPT), null );
					break;
			}
			function buildReuest(a:Array):ByteArray
			{
				var b:ByteArray = new ByteArray;
				var len:int = a.length; 
				for (var i:int=0; i<len; ++i) {
					b.writeByte( a[i] );
				}
				return b;
			}
		}
		private function getCmdName(cmdid:int):String
		{
			return OPERATOR.getSchema( cmdid ).Name;
		}
		private function write(msg:String, fromserver:Boolean=false):void
		{
			if (fromserver)
				output.text += "RESPONSE> "+ msg + "\r";
			else
				output.text = "SEND> "+ msg + "\r";
		}
		private function onResponse(p:Package):void
		{
			var msg:String;
			if (p.success) {
				msg = loc("sekop_response_success");
				if (asked_ping)
					msg = loc("sekop_ping_success");
			} else {
				var len:int;
				msg = OPERATOR.getSchema(p.cmd).Name + "\r";
				for (var str:int=0; str<p.length; str++) {
					len = p.getStructure(str+1).length;
					msg += "\tstructure "+(str+1) + "\r";
					for (var param:int=0; param<len; param++) {
						msg += "\t\tparam "+(param+1) + ": "+p.getStructure(str+1)[param]+"\r";
					}
				}
			
			}
			write(msg, true);
		}
		private function onPingResponse(o:Object=null):void
		{
		}
		private function onCoordResponse(o:Object=null):void
		{
		}
	}
}
import components.interfaces.IWidget;
import components.protocol.Package;
import components.static.CMD;

class SekopWidget implements IWidget
{
	private var fResponse:Function;
	public function SekopWidget(f:Function)
	{
		fResponse = f;
	}
	public function put(p:Package):void
	{
		/*
		switch() {
			case CMD.GET_NMEA_RMC:
				break;
			case CMD.SEKOP_ROUTE_GPPT:
				break;
		}
		*/
		fResponse(p);
	}
}