package components.protocol
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	
	import components.abstract.functions.dtrace;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;

	public class TunnelOperator extends EventDispatcher
	{
		private static var inst:TunnelOperator;
		public static function access():TunnelOperator
		{
			if(!inst)
				inst = new TunnelOperator;
			return inst;
		}
		/**
		 * 10.78.2.123:22
			login: dev
			password: ochnev12
			
			сам скрипт - /home/dev/lbs/lbs_run.py права на исполнение rwxrwxr-x ( 0775 )
			запускалка для него - /home/dev/lbs/lbs_check.sh
			 * 
			 * 
			 * команды для работы с ssh соединением
			 * 
			 * запускаем KiTTY или PaTTY ( логин/пароль выше )
			 * переходим командой cd, просматриваем каталог dir
			 * выяснить запущен ли скрипт -  pgrep lbs_run в результате должен быть получен номер процесса
			 * остановить  - kill -9 `pgrep lbs_run` или sudo kill -9 `pgrep lbs_run`
			 * запустить - sudo ./lbs_check.sh
			 * задать права для файла - sudo chown +x /home/dev/lbs/lbs_run.py
			 * 
			 * 
		 */
//		private const host:String = "127.0.0.1";
//		private const host:String = "10.0.70.17";
		private const host:String = "188.134.10.212";
		//188.134.10.212:55572
		private const port:int = 55572;
		
		private var queue:Vector.<TunnelRequest>;
		private var socket:Socket;
		private var tr:TunnelRequest;
		
		public function TunnelOperator()
		{
			if (!queue)
				queue = new Vector.<TunnelRequest>;
			
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onChangeOnline );
			
			socket = new Socket;
			socket.addEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(Event.CONNECT, connectHandler);
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		public function online():Boolean
		{
			return socket.connected;
		}
		private function connect():void
		{
			
			try {
				Security.allowDomain("");
				Security.loadPolicyFile( "xmlsocket://"+host+":"+port );
			} catch (e:IOError) {}
			socket.connect( host,port );
		}
		
		private function closeHandler(e:Event):void
		{
			trace("TunnelOperator.closeHandler(e)");
			this.dispatchEvent( new Event( Event.CLOSE ));
		}
		private function connectHandler(e:Event):void
		{
			pushQueue();
		}
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			dtrace( "TunnelOperator.as, ioErrorHandler. " + e.text )
			this.dispatchEvent( new Event( Event.CLOSE ));
		}
		private function securityError(e:SecurityErrorEvent):void
		{
			dtrace( "TunnelOperator.as, securityError. " + e.text )
			this.dispatchEvent( new Event( Event.CLOSE ));
		}
		
		private function socketDataHandler(e:Event):void
		{
	//		trace( "got " + socket.bytesAvailable);
			if (tr) {
				if (tr.binary) {
					if (isNaN(tr.length)) {
						if (socket.bytesAvailable >= 8 ) {
							tr.length = Number(socket.readMultiByte( 8, "win-1251" ));
							if (tr.length == 0)
								tr = null;
						}
					} else {
						socket.readBytes( tr.bytearray, tr.bytearray.length, socket.bytesAvailable );
						if ( tr.bytearray.length == tr.length) {
							if (tr.data)
								tr.callback(tr.bytearray,tr.data);
							else
								tr.callback(tr.bytearray);
							tr = null;
						}
					}
				} else {
					var msg:String = socket.readMultiByte( socket.bytesAvailable, "win-1251" );
					if (tr.data != null)
						tr.callback(msg,tr.data);
					else
						tr.callback(msg);
					tr = null;
				}
			}
			pushQueue();
		}
		
		public function request(request:String, callback:Function, opts:Object=null):void
		{
			
			if (!socket.connected)
				connect();
			// followdata - обьект который сопровождает запрос и прикрепляется к ответу
			// binary - когда требуется принять двоичный файл, первые 8 байт это размер, дальше сама посылка
			queue.push( new TunnelRequest(request,callback,opts));
			pushQueue();
		}
		private function pushQueue():void
		{
			if (queue.length > 0 && !tr && socket.connected) {
				tr = queue.shift();
			//	trace( "to> " +tr.request );
				socket.writeMultiByte(tr.request,"win-1251");
				socket.flush();
			}
		}
		private function onChangeOnline(e:SystemEvents):void
		{
			if (!e.isConneted() && socket.connected)
				socket.close();
		}
	}
}
import flash.utils.ByteArray;

class TunnelRequest
{
	public var request:String;
	public var callback:Function;
	public var data:Object;
	public var binary:Boolean = false;
	public var length:Number = NaN;
	public var bytearray:ByteArray;
	
	public function TunnelRequest(request:String, callback:Function, opts:Object):void
	{
		this.request = request;
		this.callback = callback;
		if (opts) {
			this.data = opts.followdata;
			
			if (opts.binary != null) {
				this.binary = opts.binary;
				if (this.binary)
					bytearray = new ByteArray;
			}
		}
	}
}