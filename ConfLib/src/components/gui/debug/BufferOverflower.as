package components.gui.debug
{
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;

	public class BufferOverflower
	{
		public var result:String="";
		
		public function BufferOverflower(size:int):void
		{
			var cmdint:int = CMD.GPRS_SIM;
			
			var cmd:CommandSchemaModel = OPERATOR.getSchema(cmdint);
			var ssize:int = cmd.GetReadCommandSize(true);
			var r:Request = new Request( cmdint, null, 1, null, Request.NORMAL, Request.PARAM_DONT_CLEAN );
			var total:int = 0;
			
			for (var i:int=14; i<size; i) {
				if ( i + ssize <= size ) {
					RequestAssembler.getInstance().fireEvent( new Request( cmdint, null, 0, null, Request.NORMAL, Request.PARAM_DONT_CLEAN ) );
					i += ssize;
					total++;
				} else
					break;
			}
			result = "запрошено "+total+" команд " +cmd.Name+", ответ занимает "+i +"/"+size+ " байт";
		}
	}
}