package components.protocol
{
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.statics.OPERATOR;
	
	import flash.utils.ByteArray;

	public class ProtocolQueueObject
	{
		private var byteArray:ByteArray;
		private var cloneDetectionCRC:String;
		private var delegate:Function;
		private var command:int;
		private var packetNum:int;
		
		public function ProtocolQueueObject( _ba:ByteArray, _cloneCRC:String, _cmd:int=-1, _delegate:Function=null, _packetNum:int=0 ):void
		{
			byteArray = _ba;
			cloneDetectionCRC = _cloneCRC;
			command = _cmd;
			delegate = _delegate;
			packetNum = _packetNum;
		}
		public function isClone( _crc:String ):Boolean 
		{
			if ( cloneDetectionCRC == _crc ) {
				return true;
			}
			return false;
		}
		public function getByteArray():ByteArray 
		{
			return byteArray;
		}
		public function getSchema():CommandSchemaModel
		{
			return OPERATOR.getSchema( command );
		}
		public function getCallBack():Function
		{
			return delegate;
		}
		public function getPacketNum():int
		{
			return packetNum;
		}
	}
}