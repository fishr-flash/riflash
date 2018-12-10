package components.abstract
{
	import components.abstract.servants.TaskHelper;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;

	public class SmsServant
	{
		public static var IMEI:String = "";
		
		private static var inst:SmsServant;
		private static const DELAY_CHECK_IMEI:int = 3000;
		public static function getInst():SmsServant
		{
			if (!inst)
				inst = new SmsServant;
			return inst;
		}
		public static var CODE_OBJECT:String = "0050";
		
		public var isCID:Boolean;
		public var isUser:Boolean;
		public var isImeiCID:Boolean;
		
		private var delegate:Function;
		private var notifyData:Array;
		
		
		
		public function load(d:Function):void
		{
			delegate = d;
			
			if (OPERATOR.dataModel.getData(CMD.AUTOTEST_ADD_CYCLE) == null )
				RequestAssembler.getInstance().fireEvent( new Request( CMD.AUTOTEST_ADD_CYCLE, put ));	
			RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_DATE_TIME_NOTIF_K2, put ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_TEXT_K2, put ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.SYS_NOTIF2, put ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.VER_INFO1, put ));
			
		}
		public function checkNotifyData():void
		{
			if (isCID ) {
				if( notifyData[0] != 0 || notifyData[1] != 0 ) {
					notifyData[0] = 0;
					notifyData[1] = 0;
					RequestAssembler.getInstance().fireEvent( new Request( CMD.SYS_NOTIF2, null, 1, notifyData ));
				}
				var a1:Object  = OPERATOR.dataModel.getData(CMD.AUTOTEST_ADD_CYCLE);
				var a2:Object = OPERATOR.dataModel.getData(CMD.AUTOTEST_ADD_CYCLE)[0];
			} else {
				if ( OPERATOR.dataModel.getData(CMD.AUTOTEST_ADD_CYCLE)[0][0] != 0 )
					RequestAssembler.getInstance().fireEvent( new Request( CMD.AUTOTEST_ADD_CYCLE, null, 1, [0] ));
			}
		}
		private function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.SMS_TEXT_K2:
					var arr:Array = p.data;
					isUser = true;
					isImeiCID = true;
					isCID = true;
					var len:int = arr.length;
					for (var i:int=0; i<len; ++i) 
					{
						if( String( arr[ i ] ).indexOf( "{\"imei\": \"" ) == -1  )
						{
							isImeiCID = false;
							break;
							
							
						}
						else if( !testCID( String( arr[ i ] ).slice( 27 ) ) )
						{
							isImeiCID = false;
							break;
						}
							
					}
					
					if( isImeiCID )
					{
						isCID = isUser = false;
						setCode( String( arr[ 0 ] ).slice( 27 ));
						break;
					}
						
					for ( i =0; i<len; ++i) {
						if ( !testCID(arr[i]) ) {
							isCID = false;
							break;
						}
					}
					if (isCID)
						setCode(arr[0]);
					
					isUser = !isImeiCID || !isCID;
					break;
				case CMD.SYS_NOTIF2:
					notifyData = p.getStructure();
					break;
				case CMD.VER_INFO1:
					const imei:String = p.getParam( 4 ).toString() ;
					if( Number( imei ) > 1000 )
					{
						IMEI = "{\"imei\": \"" + imei + "\"}" ;
						
					}
					else
					{
						TaskHelper.access().run( requestImei, DELAY_CHECK_IMEI );
					}
					
					break;
			}
			delegate(p);
		}
		
		private function requestImei():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.VER_INFO1, put ));
		}
		private function setCode(s:String):void
		{
			CODE_OBJECT = s.slice(0,4);
		}
		
		private static function testCID(s:String):Boolean
		{
			var cidPattern:RegExp = /^[B-Fb-f0-9]{15}[A-Fa-f0-9]$/g;
			if( cidPattern.test(s) && s.charAt(15).toUpperCase() == crc(s, true).toUpperCase() )
					return true;
			return false;
		}
		public static function crc(s:String, test:Boolean=false):String
		{
			var cs:int;
			var value:int;
			var len:int = test ? s.length-1: s.length;
			for (var i:int=0; i<len; ++i) {
				value = int("0x"+s.charAt(i));
				cs += value == 0 ? 10 : value;
			}
			var result:int = (Math.ceil(cs/15)*15-cs);
			return result == 0 ? "F" : result.toString(16);
		}
		// вызывается из HistoryLine, для интерпретации CID кода для пользователя
		public static function adaptForHistory(s:String):String
		{
			if( testCID(s) ) {
				var cidnum:String = s.slice( 7,10 ) + "." + s.slice( 6,7 );
				var len:int = ClientArrays.sms_contsctID.length;
				var cidcode:String = s.slice(6,15);
				for (var i:int=0; i<len; ++i) {
					if ( ClientArrays.sms_contsctID[i] == cidcode ) {
						return cidnum + " " + ClientArrays.sms_text[i]
					}
				}
				return cidnum;
			}
			return s;
		}
	}
}