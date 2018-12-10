package components.protocol
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.utils.URLUtil;

	public class ProtocolTCP
	{
		private var socket:Socket;
		private var buffer:ByteArray;
		private var delegate:Function;
		private var urls:String = "";
		
		public function ProtocolTCP()
		{
			socket = new Socket();
			socket.timeout = 5000;
			socket.addEventListener(Event.CONNECT, onSockConn);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSockData);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}
		public function connect(_url:String,_delegate:Function, _useQuickTimeout:Boolean):void
		{
			disconnect();
			
		/*	if(!URLUtil.isHttpURL(urls+_url)) {
				sendError("Invalid Url");
				return;
			}*/
			urls = _url;
			this.delegate = _delegate;
			var port:uint = URLUtil.getPort(urls);
			var server:String = getIp(urls);
			
			socket.connect(server, port);       
		}
		private function getIp(url:String):String
		{
			return url.slice(0,url.search(":"));
		}
		public function disconnect():void
		{
			if(socket.connected)
				socket.close();
			buffer = null;
		}
		private function onSockConn(ev:Event):void
		{
			buffer = new ByteArray();
			trace("connected");
		}
		private function onSockData(ev:ProgressEvent):void
		{
			buffer = new ByteArray;
			socket.readBytes(buffer, buffer.length);
			delegate(buffer);
		}
		private function onError(e:ErrorEvent):void
		{
			sendError(e.text);
		}
		private function sendError(msg:String):void
		{
			disconnect(); 
			Alert.show(msg, "Error");
		}
	}
}