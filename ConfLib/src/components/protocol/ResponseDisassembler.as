package components.protocol
{
	import components.abstract.servants.WidgetMaster;
	import components.static.MISC;

	public class ResponseDisassembler
	{
		private static var instance:ResponseDisassembler;
		public static function getInst():ResponseDisassembler
		{
			if ( instance == null )	instance = new ResponseDisassembler;
			return instance;
		}
		
		private var protocol:ProtocolBinary2;
		
		public function ResponseDisassembler()
		{
			protocol = new ProtocolBinary2;
		}
		
		public function add(a:Array):void
		{
			var p:Package = protocol.disassemble(a);
			if (p) { // одна из прчин p == null - адрес получателся не 0xFE
				if (MISC.DEBUG_ANSWER_PROTOCOL2 == 1 && p.bin2response)
					SocketProcessor.getInstance().sendGeneratedResponse( protocol.generateAnswer() );
				WidgetMaster.access().process(p);
			}
		}
	}
}