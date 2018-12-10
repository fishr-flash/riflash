package components.protocol
{
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.utils.Base64Encoder;
	import mx.utils.URLUtil;
	
	import components.abstract.functions.dtrace;
	import components.events.GUIEvents;
	import components.static.MISC;
	
	public class ProtocolHttp extends EventDispatcher
	{
		public static const ERROR_SOCKET_KAPUT:int = 405;
		public static const ERROR_NOT_EXIST:int = 404;
		public static const ERROR_TIMEOUT:int = 1001;
		
		public var READY:Boolean=true;
		
		private const SOCKET_TIMEOUT_QUICK:int = 1000;
		private const SOCKET_TIMEOUT_NORMAL:int = 5000;
		
		private var TYPE:int;
		
		private const TYPE_TEXT:int = 0;
		private const TYPE_JPG:int = 1;
		private const TYPE_STREAM:int = 2;
		
		private var socket:Socket;
		private var buffer:ByteArray;
		private var header:ByteArray;
		private var urls:String = "";
		private var user:String = "";
		private var pass:String = "";
		private var start:int = 0;
		private var parseHeaders:Boolean = true;
		private var headers:ArrayCollection = new ArrayCollection();
		private var delegate:Function;
		private var folder:String;
		private var srvHeader:String = "";
		private var timeOut:Timer;
		private var useQuickTimeOut:Boolean;
		
		private var contentLength:int;
		private var FLAG_STREAM:Boolean = false;
		
		private static var params:ProtocolHttpParams;
		
		public function ProtocolHttp(_url:String, _user:String="", _pass:String="", _connection:String="")
		{
			params = new ProtocolHttpParams;
			
			socket = new Socket();
			socket.timeout = 5000;
			socket.addEventListener(Event.CONNECT, onSockConn);
			socket.addEventListener(Event.CLOSE, onSockClose);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSockData);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSError );//function(e:Event):void{});
			
			timeOut = new Timer( SOCKET_TIMEOUT_NORMAL, 1);
			timeOut.addEventListener(TimerEvent.TIMER_COMPLETE, timeOutComplete );
			
			this.urls = _url;
			this.user = _user;
			this.pass = _pass;
		}
		public static function getParams():ProtocolHttpParams
		{
			return params;
		}
		public function connect(_url:String,_delegate:Function, _useQuickTimeout:Boolean):void
		{
			READY = false;
			
			this.delegate = _delegate;
			
			if(!URLUtil.isHttpURL(urls+_url)) {
				sendError("Invalid Url");
				return;
			}
			folder = _url;
			
			var port:uint = URLUtil.getPort(urls);
			if (port == 0)
				port = 80;
			var server:String = URLUtil.getServerName(urls);
			
			try {
				Security.allowDomain(server);
				Security.loadPolicyFile( "http://"+server+":80/crossdomain.xml" );
			} catch (e:IOError) {
				dtrace( "Sandbox: "+ e.errorID + ":" +e.message ); 
			}
			
			socket.connect(server, port);
			
			useQuickTimeOut = _useQuickTimeout;
			FLAG_STREAM = false;
			callTimer();
		}
		public function disconnect():void
		{
			if(socket.connected)
				socket.close();
			start = 0;
			buffer = null;
			header = null;
			contentLength = 0;
			timeOut.stop();
			READY = true;
			this.dispatchEvent( new Event(GUIEvents.EVOKE_READY));
		}
		public function get connected():Boolean
		{
			return socket && socket.connected;
		}
		private function onSockConn(event:Event):void
		{
			dtrace( "Http Socket connected" );
			
			buffer = new ByteArray;
			header = new ByteArray;
			
			var auth:Base64Encoder = new Base64Encoder();
			var request:String = "";
			
			auth.encode(user + ":" + pass);
			
			var liveurl:String = getLiveUrl();
			
			request += "GET /" + liveurl + " HTTP/1.1\r\n"+
				"Host: "+URLUtil.getServerName(urls)+"\r\n";
			if(user.length > 0 && pass.length >= 0)        
				request += "Authorization: Basic " + auth.toString() + "\r\n";
			request += "Cache-Control: no-cache\r\n"
			request += "Connection: "+params.CONNECTION_TYPE+"\r\n\r\n";
			//request += "Connection: Keep-Alive\r\n\r\n";
			parseHeaders = true;
			
			if( MISC.DEBUG_TRACE_HTTP == 1 )
				dtrace( "ProtocolHttp: get: " + liveurl);
			
			socket.writeMultiByte(request, "us-ascii");
			contentLength = 0;
			callTimer();
		}
		private function onSockClose(e:Event):void
		{
			if (buffer.length > 0) {
				buffer.position = 0;
				delegate( buffer );
			} else if (header.length > 0) {
				header.position = 0;
				delegate( header );
			}
			disconnect();
		}
		private function getLiveUrl():String
		{
			var str:String = URLUtil.getServerNameWithPort(urls);
			return urls.substr(urls.indexOf(str) + str.length + 1) + folder;
		}
		private function sendError(msg:String):void
		{
			disconnect(); 
			delegate( assembleError(ERROR_SOCKET_KAPUT) );
			dispatchEvent(new Event( GUIEvents.EVOKE_CONNECTION_ERROR));
			//		if( MISC.DEBUG_TRACE_HTTP == 1 )
			dtrace( "ProtocolHttp: Connect error: " + msg);
			/*		else
			dtrace( "ProtocolHttp: Connect error" );*/
			//Alert.show(msg, "Error");
		}
		private function convert(uint:int):String
		{
			var s:String = uint.toString(16);
			if (s.length>1)
				return s.toUpperCase()+" ";
			return "0"+s.toUpperCase()+" ";
		}
		private function onSockData(event:ProgressEvent):void
		{
			callTimer();
			
			if (contentLength == -1) {
				socket.readBytes(buffer, buffer.length);
				delegate(buffer);
			}
			if (contentLength == 0) {
				
				socket.readBytes(header, header.length);
				header.position = 0;
				var response:String = header.readMultiByte( header.length, "us-ascii") + "\r\n";
				var arr:Array = response.split( "\r\n" );
				
				contentLength = int(readContent(arr, "Content-length: " ));
				srvHeader = parseHeader(readContent( arr, "HTTP/" ));
				if( srvHeader == "404" ) {
					delegate( assembleError(ERROR_NOT_EXIST) );
					timeOut.stop();
					return;
				}
				if( contentLength < 1 )
					return;
				var content:String = readContent( arr, "Content-Type: " ).toLowerCase();
				if (content == "multipart/x-mixed-replace;boundary=mjpegstream") {
					contentLength = -1;
					FLAG_STREAM = true;
					timeOut.stop();
					return;
				}
				
				switch(content) {
					case "text/html":
						TYPE = TYPE_TEXT;
						break;
					case "image/jpeg":
						TYPE = TYPE_JPG;
						break;
					case "multipart/x-mixed-replace;boundary=mjpegstream":
						TYPE = TYPE_STREAM;
						break;
				}
				
				var len:int = header.length;
				for( var k:int=3; k<len; ++k ) {
					if ( header[k-3] == 0xd && header[k-2] == 0xa && header[k-1] == 0xd && header[k] == 0xa )
						break;
				}
				header.position = k+1;
				header.readBytes( buffer );
			} else
				socket.readBytes(buffer, buffer.length);
			
			if ( buffer.length == contentLength || buffer.length == contentLength + 2) {
				timeOut.stop();
				
				buffer.position = 0;
				var response2:String = buffer.readMultiByte( buffer.length, "us-ascii") + "\r\n";
				buffer.position = 0;
				
				if (folder && folder.search( "preview") > -1 )
					trace( "> "+folder );
				
				delegate(buffer);
				// необходимо занулить буферы, чтобы они не были повторно считаны при закрытии сокета
				buffer.length = 0;
				header.length = 0;
			}
		}
		private function parseHeader(s:String):String
		{
			var arr:Array = s.split(" ");
			return arr[1]; 
		}
		private function getContentLength(a:Array, content:String):int
		{
			return 0
		}
		private function readContent(a:Array, content:String):String
		{
			for each(var str:String in a) {
				if(str.toLowerCase().indexOf(content.toLowerCase()) >= 0)
					return str.substr(content.length);
			}
			return "";
		}
		private function onError(e:ErrorEvent):void
		{
			sendError(e.text);
		}
		private function onSError(e:ErrorEvent):void
		{
			sendError("Security-"+e.text);
		}
		
		private function assembleError(e:int):ByteArray
		{
			var b:ByteArray = new ByteArray();
			b.writeByte((e & 0xff00) >> 8 );
			b.writeByte( e & 0x00ff);
			return b;
		}
		private function callTimer():void
		{
			if (!FLAG_STREAM) {
				timeOut.delay = useQuickTimeOut == true ? SOCKET_TIMEOUT_QUICK : SOCKET_TIMEOUT_NORMAL;
				timeOut.reset();
				timeOut.start();
			}
		}
		private function timeOutComplete(ev:TimerEvent):void
		{
			if (params.IGNORE_CONTENTLENGTH) {
				header.position = 0;
				delegate( header );
			} else				
				delegate( assembleError(ERROR_TIMEOUT) );
			disconnect();
		}
		private function print(msg:String):void
		{
			if (MISC.DEBUG_SHOW_HTTPERRORS)
				dtrace( "HTTP: " + msg );
		}
	}
}