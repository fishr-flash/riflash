package components.protocol
{
	public class ProtocolHttpParams
	{
		public static const CONNECTION_CLOSE:String = "close";
		public static const CONNECTION_KEEPALIVE:String = "Keep-Alive";
		
		public var CONNECTION_TYPE:String = CONNECTION_KEEPALIVE;
		public var IGNORE_CONTENTLENGTH:Boolean=false;	// если сервер не сообщил contentLength то после окончания таймаута true вернет накопившиеся байты, false - вернет ошибку
	}
}